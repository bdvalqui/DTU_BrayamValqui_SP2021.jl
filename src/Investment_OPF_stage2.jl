function Investment_OPF_stage2(optimizer,x_w_value,x_e_value,set_opt_thermalgenerators,set_opt_winds,set_thermalgenerators,set_winds,set_demands,set_nodes,set_nodes_ref,set_nodes_noref,set_scenarios,set_times,P,V,max_demand,R,p_D,D,γ,Τ_det,wind,wind_opt,Ns_H,links,F_max_dict,B_dict,MapG,MapG_opt,MapD,MapW,MapW_opt,tech_thermal,tech_thermal_opt,tech_wind,tech_wind_opt,capacity_per_unit,varcost,invcost,maxBuilds,ownership,capacity_existingunits,fixedcost,EmissionsRate,HeatRate,fuelprice,life,CRF_thermal_opt,CRF_wind_opt)

m=Model(optimizer)

@variable(m, f[link in links,t in set_times] )
@variable(m, θ[n in set_nodes,t in set_times])
@variable(m, p_G_e[e in set_thermalgenerators,t in set_times]>= 0)
@variable(m, p_G_e_opt[e in set_opt_thermalgenerators,t in set_times]>= 0)
@variable(m, p_G_w[w in set_winds,t in set_times]>= 0)
@variable(m, p_G_w_opt[w in set_opt_winds,t in set_times]>= 0)
@variable(m, r_d[d in set_demands,t in set_times]>= 0)
@variable(m, r_w[w in set_winds,t in set_times]>= 0)
@variable(m, r_w_opt[w in set_opt_winds,t in set_times]>= 0)


@objective(m, Min,sum((
                  +sum(tech_thermal[e,varcost]*p_G_e[e,t] for e in set_thermalgenerators)
                  +sum(tech_thermal_opt[e,varcost]*p_G_e_opt[e,t]  for e in set_opt_thermalgenerators)
                  +sum(tech_wind[w,varcost]*p_G_w[w,t]  for w in set_winds)
                  +sum(tech_wind_opt[w,varcost]*p_G_w_opt[w,t]  for w in set_opt_winds)
                  +sum(V*r_d[d,t]  for d in set_demands)
                  +sum(P*r_w[w,t]  for w in set_winds)
                  +sum(P*r_w_opt[w,t]  for w in set_opt_winds)
                  +sum(Τ_det*tech_thermal[e,EmissionsRate]*tech_thermal[e,HeatRate]*p_G_e[e,t] for e in set_thermalgenerators)
                  +sum(Τ_det*tech_thermal_opt[e,EmissionsRate]*tech_thermal_opt[e,HeatRate]*p_G_e_opt[e,t] for e in set_opt_thermalgenerators))*Ns_H[t] for t in set_times))

#=
@constraint(m, constraint1,  sum(tech_thermal[e,capacity_existingunits] for e in set_thermalgenerators)
                            +sum(tech_wind[w,capacity_existingunits] for w in set_winds)
                            +sum(x_w[w] for w in set_opt_winds)
                            +sum(x_e[e] for e in set_opt_thermalgenerators) >= D*(1+R))


@constraint(m, constraint2[w in set_opt_winds], x_w[w] <= tech_wind_opt[w,maxBuilds])
=#

@constraint(m, constraint3[e in set_thermalgenerators,t in set_times], p_G_e[e,t] <= tech_thermal[e,capacity_existingunits])

@constraint(m, constraint4[e in set_opt_thermalgenerators,t in set_times], p_G_e_opt[e,t] <= x_e_value[e])

@constraint(m, constraint5[w in set_winds,t in set_times], p_G_w[w,t] +r_w[w,t] == tech_wind[w,capacity_existingunits]*wind[w,t])

@constraint(m, constraint6[w in set_opt_winds,t in set_times], p_G_w_opt[w,t] +r_w_opt[w,t] == x_w_value[w]*wind_opt[w,t])

@constraint(m, constraint7[j in links,t in set_times], f[j,t] == B_dict[j]*(θ[j[1],t]-θ[j[2],t]))

@constraint(m, constraint8[j in links,t in set_times], f[j,t] <= F_max_dict[j])

@constraint(m, constraint9[t in set_times], θ[set_nodes_ref,t] == 0 )

@constraint(m, constraint10[n in set_nodes, t in set_times],
              +sum(p_G_e[e,t] for e in set_thermalgenerators if n == MapG[e][2])
              +sum(p_G_e_opt[e,t] for e in set_opt_thermalgenerators if n == MapG_opt[e][2])
              +sum(p_G_w[w,t] for w in set_winds if n == MapW[w][2])
              +sum(p_G_w_opt[w,t] for w in set_opt_winds if n == MapW_opt[w][2])
              +sum(r_d[d,t,] for d in set_demands if n == MapD[d][2])
              -sum(p_D[d,t]*max_demand for d in set_demands if n == MapD[d][2])
              -sum(f[j,t] for j in links if n == j[1])== 0)

@time optimize!(m)

#cd("C:\\Users\\braya\\Desktop\\Doctorado\\Doctorado EEUU\\Semesters\\Spring Semester 2021\\DTU Course\\Project\\Step 4\\Julia")
#Print output
status = termination_status(m)
println("The solution status is: $status")

syscost_det=objective_value(m)

Dual_constraint3_st2=zeros(length(set_thermalgenerators),length(set_times))
for e in set_thermalgenerators,t in set_times
   Dual_constraint3_st2[e,t]= JuMP.dual(constraint3[e,t])
end

Dual_constraint4_st2=zeros(length(set_opt_thermalgenerators),length(set_times))
for e in set_opt_thermalgenerators,t in set_times
   Dual_constraint4_st2[e,t]= JuMP.dual(constraint4[e,t])
end

Dual_constraint5_st2=zeros(length(set_winds),length(set_times))
for w in set_winds,t in set_times
   Dual_constraint5_st2[w,t]= JuMP.dual(constraint5[w,t])
end

Dual_constraint6_st2=zeros(length(set_opt_winds),length(set_times))
for w in set_opt_winds,t in set_times
   Dual_constraint6_st2[w,t]= JuMP.dual(constraint6[w,t])
end

Dual_constraint8_st2=zeros(n_link,length(set_times))


for j in number_links, t in set_times
Dual_constraint8_st2[Z[1][j],t]= JuMP.dual(constraint8[Z[2][j],t])
end

#=
global l=1
for j in links
for t in set_times
Dual_constraint8_st2[l,t]= JuMP.dual(constraint8[j,t])
end
global l=l+1
end
global l=1
=#

Dual_constraint10_st2=zeros(length(set_nodes),length(set_times))
for n in set_nodes,t in set_times
   Dual_constraint10_st2[n,t]= JuMP.dual(constraint10[n,t])
end

return (syscost_det,Dual_constraint3_st2,Dual_constraint4_st2,Dual_constraint5_st2,Dual_constraint6_st2,Dual_constraint8_st2,Dual_constraint10_st2)
end
