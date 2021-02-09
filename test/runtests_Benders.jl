using DTU_BrayamValqui_SP2021
using Test
using Gurobi
using GLPK
using CPLEX


println("*****************Benders Solution*****************")
#OPF------------------------------------------------------#
#@time (syscost_det,p_G_value,p_D_value,Dual_constraint6,f_value)=solver_OPF(Gurobi.Optimizer,"results/OPF_Solution.txt")

@time (Set_stage1_cost,Set_invements_wind,Set_invements_thermal,Set_upperbound,Τ)=Solver_Benders(Gurobi.Optimizer,"results/Benders_Solution.txt")
#cd("C:\\Users\\braya\\.julia\\dev\\DTU_BrayamValqui_SP2021\\test")
