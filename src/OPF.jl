function OPF(optimizer,set_generators,set_nodes,set_demands,generators,demands,capacity,varcost,load_node,utility_node,links,F_max_dict,B_dict,MapG,MapD)

m=Model(optimizer)

@variable(m, f[link in links] )
@variable(m, θ[set_nodes])
@variable(m, p_G[g in set_generators]>= 0)
@variable(m, p_D[d in set_demands]>= 0)
#@variable(m, f[link in links] <= F_max_dict[link])

@objective(m, Max, sum(sum(demands[d,utility_node]*p_D[d]  for d in set_demands) -
                       sum(generators[g,varcost]*p_G[g]  for g in set_generators)))

@constraint(m, constraint1[g in set_generators], p_G[g] <= generators[g,capacity])

@constraint(m, constraint2[d in set_demands],  p_D[d] <= demands[d,load_node])

@constraint(m, constraint3[j in links], f[j] == B_dict[j]*(θ[j[1]]-θ[j[2]]))

@constraint(m, constraint4[j in links], f[j] <= F_max_dict[j])

@constraint(m, constraint5, θ[3] == 0 )

#Analyze shadow prices in Jump/ it is different if supply is on the right hand-side
@constraint(m, constraint6[n in set_nodes], +sum(p_G[g] for g in set_generators if n == MapG[g][2])
                                          -sum(p_D[d] for d in set_demands if n == MapD[d][2])
                                          -sum(f[j] for j in links if n == j[:][1])== 0)

@time optimize!(m)

status = termination_status(m)
println("The solution status is: $status")

syscost_det=objective_value(m)

println("System Cost:",syscost_det)

p_G_value=zeros(length(set_generators))
for g in set_generators
  p_G_value[g]=JuMP.value.(p_G[g])
end
println("Production level of generator g:",p_G_value)

p_D_value=zeros(length(set_demands))
for d in set_demands
  p_D_value[d]=JuMP.value.(p_D[d])
end
println("Consumption level of demand d:",p_D_value)

Dual_constraint6=zeros(length(set_nodes))

for n in set_nodes
   Dual_constraint6[n]= JuMP.dual(constraint6[n])
end
println("Electricity Price:", Dual_constraint6)

for j in links
println("Power Flow line $j:", JuMP.value.(f[j]))
end

f_value=zeros(n_link)
global i=1
for j in links
global f_value[i]= JuMP.value.(f[j])
global i=1+i
end

return (syscost_det,p_G_value,p_D_value,Dual_constraint6,f_value)
end

#cd("C:\\Users\\braya\\.julia\\dev\\DTU_BrayamValqui_SP2021\\src")
#include("OPF.jl")
