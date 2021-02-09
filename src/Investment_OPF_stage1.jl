function Investment_OPF_stage1(optimizer,set_opt_thermalgenerators,set_opt_winds,set_thermalgenerators,set_winds,set_demands,set_nodes,set_nodes_ref,set_nodes_noref,set_scenarios,set_times,P,V,max_demand,R,p_D,D,γ,Τ,wind,wind_opt,Ns_H,links,F_max_dict,B_dict,MapG,MapG_opt,MapD,MapW,MapW_opt,tech_thermal,tech_thermal_opt,tech_wind,tech_wind_opt,capacity_per_unit,varcost,invcost,maxBuilds,ownership,capacity_existingunits,fixedcost,EmissionsRate,HeatRate,fuelprice,life,CRF_thermal_opt,CRF_wind_opt,set_K,Set_Dual_constraint3_st2,Set_Dual_constraint4_st2,Set_Dual_constraint5_st2,Set_Dual_constraint6_st2,Set_Dual_constraint8_st2,Set_Dual_constraint10_st2)

m=Model(optimizer)

#=
@variable(m, f[link in links,t in set_times,s in set_scenarios] )
@variable(m, θ[n in set_nodes,t in set_times,s in set_scenarios])
@variable(m, p_G_e[e in set_thermalgenerators,t in set_times,s in set_scenarios]>= 0)
@variable(m, p_G_e_opt[e in set_opt_thermalgenerators,t in set_times,s in set_scenarios]>= 0)
@variable(m, p_G_w[w in set_winds,t in set_times,s in set_scenarios]>= 0)
@variable(m, p_G_w_opt[w in set_opt_winds,t in set_times,s in set_scenarios]>= 0)
@variable(m, r_d[d in set_demands,t in set_times,s in set_scenarios]>= 0)
@variable(m, r_w[w in set_winds,t in set_times,s in set_scenarios]>= 0)
@variable(m, r_w_opt[w in set_opt_winds,t in set_times,s in set_scenarios]>= 0)
=#

@variable(m, x_e[e in set_opt_thermalgenerators]>= 0)
@variable(m, x_w[w in set_opt_winds]>= 0)
#Auxiliary variable Benders
@variable(m, α >= 0)
#Auxiliary variable to determine the cost per scenario
#@variable(m, problem1_cost_scenario[s in set_scenarios])
@variable(m, investment_cost)

@objective(m, Min, sum(tech_thermal_opt[e,invcost]*CRF_thermal_opt[e]*x_e[e]  for e in set_opt_thermalgenerators)
                  +sum(tech_wind_opt[w,invcost]*CRF_wind_opt[w]*x_w[w]  for w in set_opt_winds)
                  +sum(tech_thermal[e,fixedcost]*(tech_thermal[e,capacity_existingunits])  for e in set_thermalgenerators)
                  +sum(tech_wind[w,fixedcost]*(tech_wind[w,capacity_existingunits])  for w in set_winds)
                  +sum(tech_thermal_opt[e,fixedcost]*(x_e[e])  for e in set_opt_thermalgenerators)
                  +sum(tech_wind_opt[w,fixedcost]*(x_w[w])  for w in set_opt_winds)
                  +α)


@constraint(m, constraint1,  sum(tech_thermal[e,capacity_existingunits] for e in set_thermalgenerators)
                            +sum(tech_wind[w,capacity_existingunits] for w in set_winds)
                            +sum(x_w[w] for w in set_opt_winds)
                            +sum(x_e[e] for e in set_opt_thermalgenerators) >= D*(1+R))

@constraint(m, constraint2[w in set_opt_winds], x_w[w] <= tech_wind_opt[w,maxBuilds])

@constraint(m, constraint3,  α>=α_down)


@constraint(m, constraint4[K in set_K],
                      α>=sum( (sum(sum(tech_thermal[e,capacity_existingunits]*Set_Dual_constraint3_st2[e,t,s,K] for e in set_thermalgenerators) for t in set_times)
                             +sum(sum(x_e[e]*Set_Dual_constraint4_st2[e,t,s,K] for e in set_opt_thermalgenerators) for t in set_times)
                             +sum(sum(tech_wind[w,capacity_existingunits]*wind[w,t]*Set_Dual_constraint5_st2[w,t,s,K] for w in set_winds) for t in set_times)
                             +sum(sum(x_w[w]*wind_opt[w,t]*Set_Dual_constraint6_st2[w,t,s,K] for w in set_opt_winds) for t in set_times)
                             +sum(sum(F_max_dict[Z[2][j]]*Set_Dual_constraint8_st2[Z[1][j],t,s,K] for j in set_number_links) for t in set_times)
                             +sum(sum(sum(p_D[d,t]*max_demand for d in set_demands if n == MapD[d][2])*Set_Dual_constraint10_st2[n,t,s,K] for n in set_nodes) for t in set_times)
                                 )*γ[s] for s in set_scenarios  )  )


#@constraint(m, constraint3[e in set_thermalgenerators,t in set_times,s in set_scenarios], p_G_e[e,t,s] <= tech_thermal[e,capacity_existingunits])

#@constraint(m, constraint4[e in set_opt_thermalgenerators,t in set_times,s in set_scenarios], p_G_e_opt[e,t,s] <= x_e[e])

#@constraint(m, constraint5[w in set_winds,t in set_times,s in set_scenarios], p_G_w[w,t,s] +r_w[w,t,s] == tech_wind[w,capacity_existingunits]*wind[w,t])

#@constraint(m, constraint6[w in set_opt_winds,t in set_times,s in set_scenarios], p_G_w_opt[w,t,s] +r_w_opt[w,t,s] == x_w[w]*wind_opt[w,t])

#@constraint(m, constraint7[j in links,t in set_times,s in set_scenarios], f[j,t,s] == B_dict[j]*(θ[j[1],t,s]-θ[j[2],t,s]))

#@constraint(m, constraint8[j in links,t in set_times,s in set_scenarios], f[j,t,s] <= F_max_dict[j])

#@constraint(m, constraint9[t in set_times,s in set_scenarios], θ[set_nodes_ref,t,s] == 0 )

#=
@constraint(m, constraint10[n in set_nodes, t in set_times,s in set_scenarios],
              +sum(p_G_e[e,t,s] for e in set_thermalgenerators if n == MapG[e][2])
              +sum(p_G_e_opt[e,t,s] for e in set_opt_thermalgenerators if n == MapG_opt[e][2])
              +sum(p_G_w[w,t,s] for w in set_winds if n == MapW[w][2])
              +sum(p_G_w_opt[w,t,s] for w in set_opt_winds if n == MapW_opt[w][2])
              +sum(r_d[d,t,s] for d in set_demands if n == MapD[d][2])
              -sum(p_D[d,t]*max_demand for d in set_demands if n == MapD[d][2])
              -sum(f[j,t,s] for j in links if n == j[1])== 0)
=#

#Auxiliary Constraints= Cost per scenario
#=
@constraint(m, constraint11[s in set_scenarios], problem1_cost_scenario[s] == sum((
                  +sum(tech_thermal[e,varcost]*p_G_e[e,t,s] for e in set_thermalgenerators)
                  +sum(tech_thermal_opt[e,varcost]*p_G_e_opt[e,t,s]  for e in set_opt_thermalgenerators)
                  +sum(tech_wind[w,varcost]*p_G_w[w,t,s]  for w in set_winds)
                  +sum(tech_wind_opt[w,varcost]*p_G_w_opt[w,t,s]  for w in set_opt_winds)
                  +sum(V*r_d[d,t,s]  for d in set_demands)
                  +sum(P*r_w[w,t,s]  for w in set_winds)
                  +sum(P*r_w_opt[w,t,s]  for w in set_opt_winds)
                  +sum(Τ[s]*tech_thermal[e,EmissionsRate]*tech_thermal[e,HeatRate]*p_G_e[e,t,s] for e in set_thermalgenerators)
                  +sum(Τ[s]*tech_thermal_opt[e,EmissionsRate]*tech_thermal_opt[e,HeatRate]*p_G_e_opt[e,t,s] for e in set_opt_thermalgenerators))*Ns_H[t]  for t in set_times)
                  +sum(tech_thermal_opt[e,invcost]*CRF_thermal_opt[e]*x_e[e]  for e in set_opt_thermalgenerators)
                  +sum(tech_wind_opt[w,invcost]*CRF_wind_opt[w]*x_w[w]  for w in set_opt_winds)
                  +sum(tech_thermal[e,fixedcost]*(tech_thermal[e,capacity_existingunits])  for e in set_thermalgenerators)
                  +sum(tech_wind[w,fixedcost]*(tech_wind[w,capacity_existingunits])  for w in set_winds)
                  +sum(tech_thermal_opt[e,fixedcost]*(x_e[e])  for e in set_opt_thermalgenerators)
                  +sum(tech_wind_opt[w,fixedcost]*(x_w[w])  for w in set_opt_winds))
=#
#Auxiliary Constraints= Investment Cost

@constraint(m, constraint12, investment_cost == sum(tech_thermal_opt[e,invcost]*CRF_thermal_opt[e]*x_e[e]  for e in set_opt_thermalgenerators)
+sum(tech_wind_opt[w,invcost]*CRF_wind_opt[w]*x_w[w]  for w in set_opt_winds)
+sum(tech_thermal[e,fixedcost]*(tech_thermal[e,capacity_existingunits])  for e in set_thermalgenerators)
+sum(tech_wind[w,fixedcost]*(tech_wind[w,capacity_existingunits])  for w in set_winds)
+sum(tech_thermal_opt[e,fixedcost]*(x_e[e])  for e in set_opt_thermalgenerators)
+sum(tech_wind_opt[w,fixedcost]*(x_w[w])  for w in set_opt_winds))

@time optimize!(m)

#cd("C:\\Users\\braya\\Desktop\\Doctorado\\Doctorado EEUU\\Semesters\\Spring Semester 2021\\DTU Course\\Project\\Step 4\\Julia")
#Print output
println("Number of variables and Constraints:")
display(m)

status = termination_status(m)
println("The solution status is: $status")

syscost_det=objective_value(m)

println("Total Cost:",syscost_det)

investment_cost_value=JuMP.value.(investment_cost)

x_w_value=zeros(length(set_opt_winds))
for w in set_opt_winds
println("Investment decision for candidate wind unit $w: ",JuMP.value.(x_w[w]))
x_w_value[w]=JuMP.value.(x_w[w])
end

x_e_value=zeros(length(set_opt_thermalgenerators))
for e in set_opt_thermalgenerators
println("Investment decision for candidate thermal unit $e: ",JuMP.value.(x_e[e]))
x_e_value[e]=JuMP.value.(x_e[e])
end

return (syscost_det,x_w_value,x_e_value,investment_cost_value)
end

#=
p_G_e_value=zeros(length(set_thermalgenerators),length(set_times),length(set_scenarios))
for t in set_times, s in set_scenarios, e in set_thermalgenerators
#println("Production level of existing thermal generator $e in time $t under scenario $s:",JuMP.value.(p_G_e[e,t,s]))
  p_G_e_value[e,t,s]=JuMP.value.(p_G_e[e,t,s])
end

p_G_e_opt_value=zeros(length(set_opt_thermalgenerators),length(set_times),length(set_scenarios))
for t in set_times, s in set_scenarios, e in set_opt_thermalgenerators
#println("Production level of candidate thermal generator $e in time $t under scenario $s:",JuMP.value.(p_G_e_opt[e,t,s]))
  p_G_e_opt_value[e,t,s]=JuMP.value.(p_G_e_opt[e,t,s])
end

p_G_w_value=zeros(length(set_winds),length(set_times),length(set_scenarios))
for t in set_times, s in set_scenarios, w in set_winds
#println("Production level of wind unit $w in time $t under scenario $s:",JuMP.value.(p_G_w[w,t,s]))
  p_G_w_value[w,t,s]=JuMP.value.(p_G_w[w,t,s])
end

p_G_w_opt_value=zeros(length(set_opt_winds),length(set_times),length(set_scenarios))
for t in set_times, s in set_scenarios, w in set_opt_winds
#println("Production level of candidare wind unit $w in time $t under scenario $s: ",JuMP.value.(p_G_w_opt[w,t,s]))
  p_G_w_opt_value[w,t,s]=JuMP.value.(p_G_w_opt[w,t,s])
end

p_D_value=zeros(length(set_demands),length(set_scenarios))
for d in set_demands, s in set_scenarios
  p_D_value[d,s]=p_D[d,s]*max_demand
end
#println("Comsuption level of demand d: ",p_D_value)

r_d_value=zeros(length(set_demands),length(set_times),length(set_scenarios))
for t in set_times, s in set_scenarios, d in set_demands
#println("Unserved energy of demand $d in time $t under scenario $s:",JuMP.value.(r_d[d,t,s]))
  r_d_value[d,t,s]=JuMP.value.(r_d[d,t,s])
end

r_w_value=zeros(length(set_winds),length(set_times),length(set_scenarios))

for t in set_times, s in set_scenarios, w in set_winds
#println("Curtailment of wind unit $w in time $t under scenario $s: ",JuMP.value.(r_w[w,t,s]))
  r_w_value[w,t,s]=JuMP.value.(r_w[w,t,s])
end

Dual_constraint10=zeros(length(set_nodes),length(set_times),length(set_scenarios))

for   t in set_times, s in set_scenarios,n in set_nodes
   Dual_constraint10[n,t,s]= JuMP.dual(constraint10[n,t,s])/(Ns_H[t]*γ[s])
#println("Electricity Price in node $n in time $t under scenario $s: ", Dual_constraint10[n,t,s])
end

df1 = DataFrame( Dual_constraint10)
#CSV.write("Electrity_Price.csv", df1)

#for s in set_scenarios, t in set_times, j in links
#println("Power Flow lines $j in time $t under scenario $s: ", JuMP.value.(f[j,t,s]))
#end

f_value=zeros(n_link,length(set_times),length(set_scenarios))
global i=1
for j in links
  for t in set_times
  for s in set_scenarios
global f_value[i,t,s]= JuMP.value.(f[j,t,s])
  end
end
global i=i+1
end

=#

#=
print("")

for n in set_nodes, s in set_scenarios, t in set_times
   println("Electricity Price in node $n in time $t under scenario $s: ", JuMP.dual(constraint10[n,t,s]))
end
=#
