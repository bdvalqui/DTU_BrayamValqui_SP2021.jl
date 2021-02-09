#Test
function Solver_CentralPlanner(optimizer::Type{<:AbstractOptimizer},resultfile::String="")
#function solver_DeterministicEquivalent(optimizer::Type{<:AbstractOptimizer},resultfile::String="",load_st2::Type{<:AbstractArray{Int64,2}})
#Deterministic Equivalent------------------------------------------------------#
println("Loading inputs...")

(p_D,D,Τ,wind,wind_opt,Ns_H) = loadinputs("data")

(syscost_det,x_w_value,x_e_value)=Investment_OPF_original(optimizer,set_opt_thermalgenerators,set_opt_winds,set_thermalgenerators,set_winds,set_demands,set_nodes,set_nodes_ref,set_nodes_noref,set_scenarios,set_times,P,V,max_demand,R,p_D,D,γ,Τ,wind,wind_opt,Ns_H,links,F_max_dict,B_dict,MapG,MapG_opt,MapD,MapW,MapW_opt,tech_thermal,tech_thermal_opt,tech_wind,tech_wind_opt,capacity_per_unit,varcost,invcost,maxBuilds,ownership,capacity_existingunits,fixedcost,EmissionsRate,HeatRate,fuelprice,life,CRF_thermal_opt,CRF_wind_opt)

resultfile != "" && open(resultfile, truncate = true) do f

    println(f,"*****************OPF Solution*****************")
    println(f,"")
    println(f,"Objective System Cost: ",syscost_det)
    println(f,"")
    println(f,"Wind Investments: ",x_w_value)
    println(f,"")
    println(f,"Thermal Investments: ",x_e_value)
    end

return (syscost_det,x_w_value,x_e_value)
end
