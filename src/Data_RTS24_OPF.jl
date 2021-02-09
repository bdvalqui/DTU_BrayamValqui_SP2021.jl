include("Network.jl")
#Sets
set_generators = 1:12
set_nodes = 1:24
set_nodes_ref=1
set_nodes_noref=2:24
set_nodes_g= [1,2,7,13,15,15,16,18,21,22,23,23]
set_nodes_d= [1,2,3,4,5,6,7,8,9,10,13,14,15,16,18,19,20]
set_demands = 1:17

#Parameters
generators=[152	  13.32
            152	  13.32
            350 	20.7
            591	  20.93
            60	  26.11
            155	  10.52
            155	  10.52
            400	  6.02
            400  	5.47
            300  	0
            310	  10.52
            350	  10.89]

demands=[67.48	   32
         60.38	   35
         111.88	   40
         46.17	   33
         44.40	   32
         85.24	   30
         78.14	   34
         106.55	   29
         108.33	   30
         120.76	   34
         165.15	   31
         120.76	   35
         197.12	   37
         62.15	   32
         207.77	   35
         113.65	   32
         79.91	  37]

capacity=1
varcost=2
load_node=1
utility_node=2

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

MapG=[(1,1),(2,2),(3,7),(4,13),(5,15),(6,15),(7,16),(8,18),(9,21),(10,22),(11,23),(12,23)]
MapD=[(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(11,13),(12,14),(13,15),(14,16),(15,18),(16,19),(17,20)]
