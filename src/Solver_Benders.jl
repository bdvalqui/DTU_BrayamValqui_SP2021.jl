#Test
function Solver_Benders(optimizer::Type{<:AbstractOptimizer},resultfile::String="")
#function solver_DeterministicEquivalent(optimizer::Type{<:AbstractOptimizer},resultfile::String="",load_st2::Type{<:AbstractArray{Int64,2}})
#Deterministic Equivalent------------------------------------------------------#
println("Loading inputs...")

(p_D,D,Τ,wind,wind_opt,Ns_H) = loadinputs("data")

for i in K
set_K=1:i

(syscost_det_stage1,x_w_value,x_e_value,investment_cost_value)=Investment_OPF_stage1(optimizer,set_opt_thermalgenerators,set_opt_winds,set_thermalgenerators,set_winds,set_demands,set_nodes,set_nodes_ref,set_nodes_noref,set_scenarios,set_times,P,V,max_demand,R,p_D,D,γ,Τ,wind,wind_opt,Ns_H,links,F_max_dict,B_dict,MapG,MapG_opt,MapD,MapW,MapW_opt,tech_thermal,tech_thermal_opt,tech_wind,tech_wind_opt,capacity_per_unit,varcost,invcost,maxBuilds,ownership,capacity_existingunits,fixedcost,EmissionsRate,HeatRate,fuelprice,life,CRF_thermal_opt,CRF_wind_opt,set_K,Set_Dual_constraint3_st2,Set_Dual_constraint4_st2,Set_Dual_constraint5_st2,Set_Dual_constraint6_st2,Set_Dual_constraint8_st2,Set_Dual_constraint10_st2)

#global Set_α[i]=pα
global Set_investment_cost[i]=investment_cost_value
global Set_lowerbound[i]=syscost_det_stage1
global Set_invements_thermal[:,i]=x_e_value
global Set_invements_wind[:,i]=x_w_value

global Τ_det=0

Threads.@threads for s in set_scenarios
#for s in set_scenarios
println("iter $s ran $(Threads.threadid())")
global Τ_det=Τ[s]

(subproblem_obj,Dual_constraint3_st2,Dual_constraint4_st2,Dual_constraint5_st2,Dual_constraint6_st2,Dual_constraint8_st2,Dual_constraint10_st2)=Investment_OPF_stage2(optimizer,x_w_value,x_e_value,set_opt_thermalgenerators,set_opt_winds,set_thermalgenerators,set_winds,set_demands,set_nodes,set_nodes_ref,set_nodes_noref,set_scenarios,set_times,P,V,max_demand,R,p_D,D,γ,Τ_det,wind,wind_opt,Ns_H,links,F_max_dict,B_dict,MapG,MapG_opt,MapD,MapW,MapW_opt,tech_thermal,tech_thermal_opt,tech_wind,tech_wind_opt,capacity_per_unit,varcost,invcost,maxBuilds,ownership,capacity_existingunits,fixedcost,EmissionsRate,HeatRate,fuelprice,life,CRF_thermal_opt,CRF_wind_opt)


global subproblem_obj_sce[s,i]=subproblem_obj

global Set_Dual_constraint3_st2[:,:,s,i]=Dual_constraint3_st2
global Set_Dual_constraint4_st2[:,:,s,i]=Dual_constraint4_st2
global Set_Dual_constraint5_st2[:,:,s,i]=Dual_constraint5_st2
global Set_Dual_constraint6_st2[:,:,s,i]=Dual_constraint6_st2
global Set_Dual_constraint8_st2[:,:,s,i]=Dual_constraint8_st2
global Set_Dual_constraint10_st2[:,:,s,i]=Dual_constraint10_st2

end

global Set_stage2_cost[i]=sum(subproblem_obj_sce[s,i]*γ[s] for s in set_scenarios)
global Set_upperbound[i]= Set_investment_cost[i]+Set_stage2_cost[i]

end
resultfile != "" && open(resultfile, truncate = true) do f

    println(f,"*****************OPF Solution*****************")
    println(f,"")
    println(f,"Objective Function-Stage 1:",Set_lowerbound)
    println(f,"")
    println(f,"Objective Function-Stage 2:",Set_upperbound)
    println(f,"")
    println(f,"Wind Investments: ",Set_invements_wind)
    println(f,"")
    println(f,"Thermal Investments: ",Set_invements_thermal)
    end

return (Set_lowerbound,Set_invements_wind,Set_invements_thermal,Set_upperbound,Τ)
end
