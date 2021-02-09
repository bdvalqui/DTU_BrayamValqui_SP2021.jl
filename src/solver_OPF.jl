function solver_OPF(optimizer::Type{<:AbstractOptimizer},resultfile::String="")
#function solver_DeterministicEquivalent(optimizer::Type{<:AbstractOptimizer},resultfile::String="",load_st2::Type{<:AbstractArray{Int64,2}})
#Deterministic Equivalent------------------------------------------------------#
println("Loading inputs...")
#=
(load_st2,Carbprice) = loadinputs("data")

for i in set_scenarios
D[i]=maximum(load_st2[:,i])
end
=#

(syscost_det,p_G_value,p_D_value,Dual_constraint6,f_value)=OPF(optimizer,set_generators,set_nodes,set_demands,generators,demands,capacity,varcost,load_node,utility_node,links,F_max_dict,B_dict,MapG,MapD)

#=
println("")
for j in set_opt
println("x[$j] = ", px_1_det[j])
end
=#

resultfile != "" && open(resultfile, truncate = true) do f

    println(f,"*****************OPF Solution*****************")
    println(f,"")
    println(f,"Objective Function:",syscost_det)
    println(f,"")
    println(f,"Production level of generator g:",p_G_value)
    println(f,"")
    println(f,"Consumption level of demand d:",p_D_value)
    println(f,"")
    println(f,"Electricity Price:",Dual_constraint6)
    println(f,"")
    println(f,"Power Flow:", f_value)
    println(f,"")
    global j=1
    for k in links
    println(f,"Power Flow line $k:", f_value[j])
    global j=j+1
    end
    #=
    println(f,"Second Stage Dispatch Decisions:")
    println(f,p_y_det)
    =#
end
return (syscost_det,p_G_value,p_D_value,Dual_constraint6,f_value)
end
