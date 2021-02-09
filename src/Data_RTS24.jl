using CSV
using DataFrames
#include("clustering_ws.jl")
include("Network.jl")

#Number of Iterations Benders
K=1:20
#Sets
#Investemnt Options
set_opt_thermalgenerators = 1:5
set_opt_winds = 1:4
#Existing Units
set_thermalgenerators = 1:10
set_winds = 1:2
set_demands = 1:17
set_nodes = 1:24
set_nodes_ref=1
set_nodes_noref=2:24
#Operating conditions-scenarios-clsuters
set_scenarios= 1:100
#set_scenarios= 1:3
set_times= 1:48

#Penalty
P=10000
V=10000
#Assign the values of demands according to their locations in the network
#3 operating conditions below
#two time zones below#Maybe no key means and just montecarlo simulation? I do need to select, let's say 876 (10%)
max_demand=400
R=0.15
#max_demand=150
#max_wind=10

#Scenarios
a=1/length(set_scenarios)
γ=zeros(length(set_scenarios))
for s in set_scenarios
γ[s]=a
end

network=hcat(From,To,LineCapacity,Susceptance)

start_node=network[:,1]
end_node=network[:,2]
F_max=network[:,3]
B=network[:,4]

n_node=24
n_link=68

links = Array{Tuple{Int64, Int64},2}(undef, n_link, 1)

for i=1:n_link
  links[i] = (start_node[i], end_node[i])
end

set_number_links=1:n_link
number_links=[i for i in set_number_links]

Z=[number_links,links]

links_rev = Array{Tuple{Int64, Int64},2}(undef, n_link, 1)

for i=1:n_link
  links_rev[i] = (end_node[i], start_node[i])
end

F_max_dict=Dict()
B_dict=Dict()

for i=1:n_link
  F_max_dict[(start_node[i], end_node[i])] = F_max[i]
  B_dict[(start_node[i], end_node[i])] = B[i]
end

MapG=[(1,2),(2,7),(3,13),(4,15),(5,15),(6,16),(7,21),(8,22),(9,23),(10,23)]
MapG_opt=[(1,16),(2,17),(3,19),(4,21),(5,22)]
MapD=[(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(11,13),(12,14),(13,15),(14,16),(15,18),(16,19),(17,20)]

MapW=[(1,1),(2,18)]
MapW_opt=[(1,19),(2,21),(3,23),(4,8)]


#Main difference with GAMS is that I calculate the variable cost beforehand
#NREL 2020 Data

#Nuclear and Coal in this case
tech_thermal=[        1500      9.20       7185655         10000            1              400              118988       0                 10.461        0.66        60
                      1500      9.20       7185655         10000            1              400              118988       0                 10.461        0.66        60
                      1500      9.20       7185655         10000            1              400              118988       0                 10.461        0.66        60
                      1000      21.76      4149988         10000            1              300              39695        0.0955             8.638        2.01        75
                      1000      21.76      4149988         10000            1              300              39695        0.0955             8.638        2.01        75
                      500       31.24      982962          10000            1              250              11395        0.0531            9.5145        2.81        55
                      500       31.24      982962          10000            1              250              11395        0.0531            9.5145        2.81        55
                      500       20.19      1088328         10000            1              250              12863        0.0531            6.4005        2.81        55
                      500       20.19      1088328         10000            1              250              12863        0.0531            6.4005        2.81        55
                      500       20.19      1088328         10000            1              250              12863        0.0531            6.4005        2.81        55]

tech_thermal_opt=[   1000      26.50        5299096        10000            1              0               53114        0.0096            9.751         2.01        75
                     1000      35.84        6830748        10000            1              0               58242        0.0096            12.507        2.01        75
                     500       31.24        982962         10000            1              0               11395        0.0531            9.5145        2.81        55
                     500       20.19        1088328        10000            1              0               12863        0.0531            6.4005        2.81        55
                     500       26.85        2778138        10000            1              0               26994        0.0053             7.525        2.81        55]

tech_wind=[   300         0.0               1604886        10000            1             200              43205        0                    0          0.00        30
              300         0.0               1604886        10000            1             200              43205        0                    0          0.00        30]

tech_wind_opt=[300         0.0              1604886        300               1             0               43205        0                    0          0.00        30
               300         0.0              1604886        300               1             0               43205        0                    0          0.00        30
               300         0.0              1604886        300               1             0               43205        0                    0          0.00        30
               300         0.0              1604886        300               1             0               43205        0                    0          0.00        30]

 #Indices for set_tech
capacity_per_unit=1
varcost=2
invcost=3
maxBuilds=4
ownership=5
capacity_existingunits=6
fixedcost=7
EmissionsRate=8
HeatRate=9
fuelprice=10
life=11

WACC=0.08

CRF_thermal_opt=zeros(5)

for i in 1:5
CRF_thermal_opt[i]=WACC/(1 - (1 / ( (1 + WACC)^tech_thermal_opt[i,life])))
end

CRF_wind_opt=zeros(4)

for i in 1:4
CRF_wind_opt[i]=WACC/(1 - (1 / ( (1 + WACC)^tech_wind_opt[i,life])))
end


α_down=-10000

Set_α=zeros(length(K))
Set_master_obj=zeros(length(K))
#Set_stage1_cost=zeros(length(K))
Set_invements_thermal=SharedArray(zeros(length(set_opt_thermalgenerators),length(K)))
Set_invements_wind=SharedArray(zeros(length(set_opt_winds),length(K)))

Set_investment_cost=zeros(length(K))
Set_lowerbound=zeros(length(K))


subproblem_obj_sce=SharedArray(zeros(length(set_scenarios),length(K)))
Set_stage2_cost=zeros(length(K))
Set_upperbound=zeros(length(K))
Set_Dual_constraint3_st2=SharedArray(zeros(length(set_thermalgenerators),length(set_times),length(set_scenarios),length(K)))
Set_Dual_constraint4_st2=SharedArray(zeros(length(set_opt_thermalgenerators),length(set_times),length(set_scenarios),length(K)))
Set_Dual_constraint5_st2=SharedArray(zeros(length(set_winds),length(set_times),length(set_scenarios),length(K)))
Set_Dual_constraint6_st2=SharedArray(zeros(length(set_opt_winds),length(set_times),length(set_scenarios),length(K)))
Set_Dual_constraint8_st2=SharedArray(zeros(n_link,length(set_times),length(set_scenarios),length(K)))
Set_Dual_constraint10_st2=SharedArray(zeros(length(set_nodes),length(set_times),length(set_scenarios),length(K)))

#Compute Var Cost
#2020 Data

#=


tech=[1000      26.50        5299096        10000            1              0               53114        0.0096            9.751         2.01        75
      1000      35.84        6830748        10000            1              0               58242        0.0096            12.507        2.01        75
      500       31.24        982962         10000            1              0               11395        0.0531            9.5145        2.81        55
      500       20.19        1088328        10000            1              0               12863        0.0531            6.4005        2.81        55
      500       26.85        2778138        10000            1              0               26994        0.0053             7.525        2.81        55
      300       0.0          1604886        10000            1              0               43205        0                    0          0.00        30
      300       0.0          1599902        10000            1              0               18760        0                    0          0.00        30
      1500      9.20         7185655        10000            1             10               118988       0                 10.461        0.66        60
      1000      21.76        4149988        10000            1              8               39695        0.0955             8.638        2.01        75]


TABLE Tech(q,GEN_PARAMS)
                    capacity   var_cost      invcost       maxBuilds      ownership   existingunits        fixedcost    EmissionsRate     HeatRate      FPPRICE     LIFE
*                    [MW]      [$/MWh]       [$/MW]   [Number of Units]                                   [$/MW-yr]    [ton/MMBTU]        [MMBTU/MWh] [$/MMBTU]   [years]
Coal_CCS_30_1        1000      26.50        5299096        10000            1              0               53114        0.0096            9.751         2.01        75
Coal_CCS_90_1        1000      35.84        6830748       10000            1              0               58242        0.0096            12.507        2.01        75
Gas_CT_1             500       31.24        982962         10000            1              0               11395        0.0531            9.5145        2.81        55
Gas_CC_1             500       20.19        1088328        10000            1              0               12863        0.0531            6.4005        2.81        55
Gas_CC_CCS_1         500       26.85       2778138        10000            1              0               26994        0.0053             7.525        2.81        55
Wind_onshore_1       300         0.0        1604886        10000            1              0               43205        0                    0          0.00        30
Solar_Utility_PV_1   300         0.0        1599902        10000            1              0               18760        0                    0          0.00        30
Nuclear_1            1500      9.20       7185655        10000            1             10               118988       0                 10.461        0.66        60
Coal_new_1           1000      21.76       4149988        10000            1              8                39695       0.0955             8.638        2.01        75
;

=#
