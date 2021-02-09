#Sets
#Investemnt Options
set_opt_thermalgenerators = 1:5
set_opt_winds = 1:2
#Existing Units
set_thermalgenerators = 1:2
set_winds = 1:3
set_demands = 1:2
set_nodes = 1:3
set_nodes_ref=1
set_nodes_noref=2:3
#Operating conditions-scenarios-clsuters
set_scenarios= 1:3
set_times= 1:3
#Penalty
P=10000
V=10000
#Assign the values of demands according to their locations in the network
#3 operating conditions below
#two time zones below#Maybe no key means and just montecarlo simulation? I do need to select, let's say 876 (10%)
max_demand=150
R=0.15
#max_demand=150
#max_wind=10
p_D_rowdata=[   0.701	    0.7194
                0.3358	  0.3367
                0.6465	  0.6496]
p_D=p_D_rowdata'

p_D_MW=p_D*max_demand
D= maximum(sum(p_D_MW, dims=1))

#Scenarios
a=1/length(set_scenarios)
γ=zeros(length(set_scenarios))
for s in set_scenarios
γ[s]=a
end

Τ=[100
   100
   100]

#2 wind zones
wind_max=10
wind_rowdata= [0.2027	   0.2027	    0.1803
               0.1429	   0.1429	    0.1803
               0.5865	   0.5865	    0.1803]
wind=wind_rowdata'

wind_opt_rowdata= [0.2027	   0.1803
                  0.1429	   0.1803
                  0.5865	   0.1803]
wind_opt=wind_opt_rowdata'

#ϑ
#Change to the weights from k-means

Ns_H=[5000
      3000
      760]

network=[ 1  2  100  500;
          1  3  100  500;
          2  3  100  500;
          2  1  100  500;
          3  1  100  500;
          3  2  100  500]

start_node=network[:,1]
end_node=network[:,2]
F_max=network[:,3]
B=network[:,4]

n_node=3
n_link=6

links = Array{Tuple{Int64, Int64},2}(undef, n_link, 1)

for i=1:n_link
  links[i] = (start_node[i], end_node[i])
end

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

MapG=[(1,1), (2,2)]
MapG_opt=[(1,2),(2,3),(3,1),(4,2),(5,3)]
#Define this according to zones
MapD=[(1,2),(2,3)]
MapW=[(1,1),(2,2),(3,3)]
MapW_opt=[(1,1),(2,3)]

#Main difference with GAMS is that I calculate the variable cost beforehand
#NREL 2020 Data

#Nuclear and Coal in this case
tech_thermal=[        1500      9.20       7185655         10000            1              80               118988       0                 10.461        0.66        60
                      1000      21.76      4149988         10000            1              100              39695        0.0955             8.638        2.01        75]

tech_thermal_opt=[   1000      26.50        5299096        10000            1              0               53114        0.0096            9.751         2.01        75
                     1000      35.84        6830748        10000            1              0               58242        0.0096            12.507        2.01        75
                     500       31.24        982962         10000            1              0               11395        0.0531            9.5145        2.81        55
                     500       20.19        1088328        10000            1              0               12863        0.0531            6.4005        2.81        55
                     500       26.85        2778138        10000            1              0               26994        0.0053             7.525        2.81        55]

tech_wind=[   300         0.0               1604886        10000            1             10                43205        0                    0          0.00        30
              300         0.0               1604886        10000            1             10                43205        0                    0          0.00        30
              300         0.0               1604886        10000            1             10                43205        0                    0          0.00        30]

tech_wind_opt=[300         0.0              1604886        10000             1             0                43205        0                    0          0.00        30
               300         0.0              1604886        10000             1             0                43205        0                    0          0.00        30]

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

CRF_wind_opt=zeros(2)

for i in 1:2
CRF_wind_opt[i]=WACC/(1 - (1 / ( (1 + WACC)^tech_wind_opt[i,life])))
end

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
