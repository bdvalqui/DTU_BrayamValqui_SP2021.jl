function OPF_dual(optimizer,set_generators,set_nodes,set_demands,generators,demands,capacity,varcost,load_node,utility_node,links,links_rev,F_max_dict,B_dict,MapG,MapD)

m=Model(optimizer)






@variable(m, μ_G[g in set_generators]>= 0)
@variable(m, μ_D[d in set_demands]>= 0)
@variable(m, η_lower[link in links]>= 0)
@variable(m, η_upper[link in links]>= 0)
@variable(m, λ[set_nodes])
@variable(m, γ)

@objective(m, Min,     sum(μ_D[d]*demands[d,load_node]  for d in set_demands) +
                       sum(μ_G[g]*generators[g,capacity]  for g in set_generators)+
                       sum(F_max_dict[j]*(η_lower[j]+η_upper[j])   for j in links)
                       )


@constraint(m, constraint1[d in set_demands], -demands[d,utility_node]+ μ_D[d]+λ[MapD[d][2]]>= 0)

@constraint(m, constraint2[g in set_generators], generators[g,varcost]+ μ_G[g]-λ[MapG[g][2]]>= 0)

#@constraint(m, constraint3[n in set_nodes_ref],     sum(B_dict[j]*(λ[j[1]]-λ[j[2]]+η_upper[j] -η_lower[j]) for j in links if n == j[1])
#                                                     +γ == 0)

@constraint(m, constraint3[n in set_nodes_ref],     sum(B_dict[j]*(λ[j[1]]-λ[j[2]]+η_upper[j] -η_lower[j]) for j in links if n == j[1])
                                                      +sum(B_dict[j]*(-η_upper[j] +η_lower[j]) for j in links_rev if n == j[2] )+γ == 0)

#@constraint(m, constraint4[n in set_nodes_noref],  sum(B_dict[j]*(λ[j[1]]-λ[j[2]]+η_upper[j] -η_lower[j]) for j in links if n == j[1])
#                                                      == 0)

@constraint(m, constraint4[n in set_nodes_noref],  sum(B_dict[j]*(λ[j[1]]-λ[j[2]]+η_upper[j] -η_lower[j]) for j in links if n == j[1])
                                                      +sum(B_dict[j]*(-η_upper[j] +η_lower[j]) for j in links_rev if n == j[2] )== 0)

@time optimize!(m)

status = termination_status(m)
println("The solution status is: $status")

syscost_det=objective_value(m)

println("System Cost:",syscost_det)

Dual_constraint2=zeros(length(set_generators))

for g in set_generators
   Dual_constraint2[g]= JuMP.dual(constraint2[g])
end
println("Production level of generator g:", Dual_constraint2)

Dual_constraint1=zeros(length(set_demands))

for d in set_demands
   Dual_constraint1[d]= JuMP.dual(constraint1[d])
end
println("Consumption level of demand d: ", Dual_constraint1)


λ_value=zeros(length(set_nodes))
for n in set_nodes
  λ_value[n]=JuMP.value.(λ[n])
end
println("Electricity Price:",λ_value)


#Review this flow lines
#Review all the constraints

f_value=zeros(n_link)
global i=1

for j in links
global jj=j
if set_nodes_ref==jj[1]
global f_value[i]= B_dict[j]*(JuMP.dual(constraint3[j[1]])-JuMP.dual(constraint4[j[2]]))
elseif set_nodes_ref==jj[2]
global f_value[i]= B_dict[j]*(JuMP.dual(constraint4[j[1]])-JuMP.dual(constraint3[j[2]]))
else
global f_value[i]= B_dict[j]*(JuMP.dual(constraint4[j[1]])-JuMP.dual(constraint4[j[2]]))
end
println("Power Flow lines $j:", f_value[i])
global i=1+i
end

return (syscost_det,Dual_constraint2,Dual_constraint1,λ_value,f_value)
end

#cd("C:\\Users\\braya\\.julia\\dev\\DTU_BrayamValqui_SP2021\\src")
#include("Singlefile_OPF_dual.jl")
