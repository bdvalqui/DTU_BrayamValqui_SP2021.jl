using DTU_BrayamValqui_SP2021
using Test
using Gurobi
using GLPK
using CPLEX


println("*****************OPF Solution*****************")
#OPF------------------------------------------------------#
@time (syscost_det,p_G_value,p_D_value,Dual_constraint6,f_value)=solver_OPF(Gurobi.Optimizer,"results/OPF_Solution.txt")

@time (syscost_det,Dual_constraint2,Dual_constraint1,λ_value,f_value)=solver_OPF_dual(Gurobi.Optimizer,"results/OPF_Dual_Solution.txt")

#cd("C:\\Users\\braya\\.julia\\dev\\DTU_BrayamValqui_SP2021\\test")
