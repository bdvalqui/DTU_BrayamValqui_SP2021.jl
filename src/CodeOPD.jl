#Sets
set_generators = 1:2
set_nodes = 1:3
set_demands = 1:2

#Parameters
generators=[100      12;
            80       20]

demands=[100  40;
         50   35]

capacity=1
varcost=2
load_node=1
utility_node=2

network=[ 1  2  100 500;
          1  3  100 500;
          2  3  100 500;
          2  1  100 500;
          3  1  100 500;
          3  2  100 500]

start_node=network[:,1]
end_node=network[:,2]
F_max=network[:,3]
B=network[:,4]

n_node=3
n_link=6

#create a n*m Tuple Array with ‘undefined’ contents
links = Array{Tuple{Int64, Int64},2}(undef, n_link, 1)

for i=1:n_link
  links[i] = (start_node[i], end_node[i])
end

F_max_dict=Dict()
B_dict=Dict()

for i=1:n_link
  F_max_dict[(start_node[i], end_node[i])] = F_max[i]
  B_dict[(start_node[i], end_node[i])] = B[i]
end

MapG=[(1,1), (2,2), (0,0)]
MapD=[(1,2),(2,3),(0,0)]

using JuMP
using Gurobi

m=Model(Gurobi.Optimizer)

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

@constraint(m, constraint5, θ[1] == 0 )

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
println("Comsuption level of demand d:",p_D_value)

Dual_constraint6=zeros(length(set_nodes))

for n in set_nodes
   Dual_constraint6[n]= JuMP.dual(constraint6[n])
end
println("Electricity Price:", Dual_constraint6)

for j in links
println("Power Flow lines $j:", JuMP.value.(f[j]))
end

f_value=zeros(n_link)
global i=1
for j in links
global f_value[i]= JuMP.value.(f[j])
global i=1+i
end
#cd("C:\\Users\\braya\\.julia\\dev\\DTU_BrayamValqui_SP2021\\src")
#include("data.jl")
