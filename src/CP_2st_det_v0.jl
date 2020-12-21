function det_2st(optimizer,tech,load_st2,D,Carbprice,prob,voll,Rm,set_tech,set_opt,set_exist,set_periods,set_scenarios,capacity,varcost,invcost,maxBuilds,ownership,existingunits,fixedcost,EmissionsRate,HeatRate)

  m=Model(optimizer)

  @variable(m, x[set_opt] >= 0)
  @variable(m, y[set_tech,set_periods,set_scenarios] >= 0)
  @variable(m, r[set_periods,set_scenarios] >= 0)

   @objective(m, Min,sum( ((sum(sum(tech[q,varcost]*y[q,t,s] for q in set_tech) for t in set_periods))
                        +sum(voll*r[t,s] for t in set_periods)
                        +sum(sum(tech[g,fixedcost]*tech[g,existingunits]*tech[g,capacity] for g in set_exist) for t in set_periods)
                        +sum(sum((tech[j,invcost]+tech[j,fixedcost])*x[j]*tech[j,capacity] for j in set_opt) for t in set_periods)
                        +sum(sum(Carbprice[s]*tech[q,EmissionsRate]*tech[q,HeatRate]*y[q,t,s] for q in set_tech) for t in set_periods)
                        )*prob[s] for s in set_scenarios))

  @constraint(m, constraint1[j in set_opt],
                            x[j] <= tech[j,maxBuilds])

  @constraint(m, constraint2[j in set_opt, t in set_periods,s in set_scenarios],
              y[j,t,s] <= x[j]*tech[j,capacity]+tech[j,existingunits]*tech[j,capacity])

  @constraint(m, constraint3[g in set_exist, t in set_periods,s in set_scenarios],
             y[g,t,s] <= tech[g,existingunits]*tech[g,capacity])

  @constraint(m, constraint4[t in set_periods,s in set_scenarios],
    r[t,s] +sum(y[q,t,s] for q in set_tech)==load_st2[t,s])

  @constraint(m, constraint5[s in set_scenarios],
            sum(x[j]*tech[j,capacity] for j in set_opt)+sum(tech[g,existingunits]*tech[g,capacity] for g in set_exist)>=D[s]*(1+Rm))

  @time optimize!(m)

  px_1_det=zeros(length(set_opt))
  for j in set_opt
    px_1_det[j]=JuMP.value.(x[j])
  end

  p_y_det=zeros(length(set_tech),length(set_periods),length(set_scenarios))
  for s in set_scenarios,t in set_periods, q in set_tech
    p_y_det[q,t,s]= JuMP.value.(y[q,t,s])
  end
  syscost_det=objective_value(m)
return (px_1_det,p_y_det,syscost_det)
end
