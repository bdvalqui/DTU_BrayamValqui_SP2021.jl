function solver_OPF_dual(optimizer::Type{<:AbstractOptimizer},resultfile::String="")
#function solver_DeterministicEquivalent(optimizer::Type{<:AbstractOptimizer},resultfile::String="",load_st2::Type{<:AbstractArray{Int64,2}})
#Deterministic Equivalent------------------------------------------------------#
println("Loading inputs...")

(syscost_det,Dual_constraint2,Dual_constraint1,λ_value,f_value)=OPF_dual(optimizer,set_generators,set_nodes,set_demands,generators,demands,capacity,varcost,load_node,utility_node,links,links_rev,F_max_dict,B_dict,MapG,MapD)

resultfile != "" && open(resultfile, truncate = true) do f

    println(f,"*****************OPF Solution (Dual Problem)*****************")
    println(f,"")
    println(f,"Objective Function:",syscost_det)
    println(f,"")
    println(f,"Production level of generator g:",Dual_constraint2)
    println(f,"")
    println(f,"Consumption level of demand d:",Dual_constraint1)
    println(f,"")
    println(f,"Electricity Price:",λ_value)
    println(f,"")
    println(f,"Power Flow:", f_value)
    println(f,"")
    global j=1
    for k in links
    println(f,"Power Flow line $k:", f_value[j])
    global j=j+1
    end
end

return (syscost_det,Dual_constraint2,Dual_constraint1,λ_value,f_value)
end
