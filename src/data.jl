#Sets
set_tech = 1:6
set_opt = 1:4
set_exist = 5:6
#set_periods = 1:24
set_periods = 1:672
#set_scenarios = 1:20
set_scenarios = 1:200

#Progressive Hedging Parameter
γ=100

tech=[300       2       1200         1               1             0             0          0.0531      9.87;
      300       3       800          1               1             0             0          0.0531      9.00;
      300       2       1000        1              2            0              0            0.0531      9.87;
      300       3        900         1              2            0              0            0.0531      9.00;
       0        0         0           0               1             0             0          0.0531      9.87;
       0        0         0           0               2             0             0          0.0531      9.87]

       #=
 load_st2=[300        300;
           379        379;
           420        420;
          200        250;
           470        425;
          470        425;
          220        280;
           330        340;
          330        340;
          200        250;
          470        425;
           330        340;
               200        250;
               470        425;
                379        379;
               220        280;
               330        340;
               470        425;
               330        340;
               200        250;
               470        425;
               470        425;
               379        379;
               450        300]
=#
#Carbprice=[20;135]


               #Indices for set_tech
               capacity=1
               varcost=2
               invcost=3
               maxBuilds=4
               ownership=5
               existingunits=6
               fixedcost=7
               EmissionsRate=8
               HeatRate=9

               prob=zeros(length(set_scenarios))
               for s in set_scenarios
               prob[s]=1/length(set_scenarios)
               end

               #Parameters
               voll=100000
               Rm=0.1

α_down=-10000

#D=[470;425]
#=
D=zeros(length(set_scenarios))
for i in set_scenarios
D[i]=maximum(load_st2[:,i])
end
=#

#Define number of iterations
K=1:4
iteration_ben=0
#These variables are determined in the ierations, so can not be in data.jl
#SetDual_constraint1_st2=zeros(length(set_opt),length(set_periods),length(set_scenarios),length(K))
#SetDual_constraint2_st2=zeros(length(set_tech),length(set_periods),length(set_scenarios),length(K))
#SetDual_constraint3_st2=zeros(length(set_periods),length(set_scenarios),length(K))
Set_α=zeros(length(K))
Set_master_obj=zeros(length(K))
Set_stage1_cost=zeros(length(K))
#subproblem_obj_sce=zeros(length(set_scenarios),length(K))
Set_stage2_cost=zeros(length(K))
Set_upperbound=zeros(length(K))
Set_invements=zeros(length(set_opt),length(K))
D=zeros(length(set_scenarios))


SetDual_constraint1_st2=SharedArray(zeros(length(set_opt),length(set_periods),length(set_scenarios),length(K)))
SetDual_constraint2_st2=SharedArray(zeros(length(set_tech),length(set_periods),length(set_scenarios),length(K)))
SetDual_constraint3_st2=SharedArray(zeros(length(set_periods),length(set_scenarios),length(K)))
subproblem_obj_sce=SharedArray(zeros(length(set_scenarios),length(K)))
invesments_sce=SharedArray(zeros(length(set_opt),length(set_scenarios),length(K)))
average_invesments=SharedArray(ones(length(set_opt),length(K)))
x_bar=SharedArray(ones(length(set_opt)))
λ_iter=SharedArray(ones(length(set_opt),length(set_scenarios),length(K)+1))
λ=SharedArray(ones(length(set_opt)))
#λ_iter_bar=SharedArray(ones(length(set_opt),length(K)))
obj_sce=SharedArray(zeros(length(K)))
#obj_sce=1
prob_scenario=0
