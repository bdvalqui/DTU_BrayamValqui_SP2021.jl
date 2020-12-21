function solver_DeterministicEquivalent(optimizer::Type{<:AbstractOptimizer},resultfile::String="")
#function solver_DeterministicEquivalent(optimizer::Type{<:AbstractOptimizer},resultfile::String="",load_st2::Type{<:AbstractArray{Int64,2}})
#Deterministic Equivalent------------------------------------------------------#
println("Loading inputs...")
(load_st2,Carbprice) = loadinputs("data")

for i in set_scenarios
D[i]=maximum(load_st2[:,i])
end

(px_1_det,p_y_det,syscost_det) = det_2st(optimizer,tech,load_st2,D,Carbprice,prob,voll,Rm,set_tech,set_opt,set_exist,set_periods,set_scenarios,capacity,varcost,invcost,maxBuilds,ownership,existingunits,fixedcost,EmissionsRate,HeatRate)

#=
println("")
for j in set_opt
println("x[$j] = ", px_1_det[j])
end
=#

resultfile != "" && open(resultfile, truncate = true) do f

    println(f,"*****************Deterministic Equivalent Solution*****************")
    println(f,"")
    println(f,"Objective Function:",syscost_det)
    println(f,"")
    println(f,"First Stage Investments:", px_1_det)
    println(f,"")
    #=
    println(f,"Second Stage Dispatch Decisions:")
    println(f,p_y_det)
    =#
end
return (px_1_det,p_y_det,syscost_det)
end
