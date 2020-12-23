using DTU_BrayamValqui_SP2021
using Test
using Gurobi

println("*****************OPF Solution*****************")
#OPF------------------------------------------------------#
@time (syscost_det,p_G_value,p_D_value,Dual_constraint6,f_value)=solver_OPF(Gurobi.Optimizer,"results/OPF_Solution.txt")

#cd("C:\\Users\\braya\\.julia\\dev\\DTU_BrayamValqui_SP2021\\test")
