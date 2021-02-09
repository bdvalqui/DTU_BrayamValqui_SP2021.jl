#Sets
set_generators = 1:2
set_nodes = 1:3
set_nodes_ref=3
set_nodes_noref=1:2
set_nodes_g= 1:2
set_nodes_d= 2:3
set_demands = 1:2

#Parameters
generators=[100      12;
            80       20]

demands=[100  40;
         50   35]

capacity=1
varcost=2
load_node=1
utility_node=2

network=[ 1  2  100 500;
          1  3   40 500;
          2  3  100 500;
          2  1  100 500;
          3  1  100 500;
          3  2  100 500]

start_node=network[:,1]
end_node=network[:,2]
F_max=network[:,3]
B=network[:,4]

n_node=3
n_link=6

set_links=1:n_link
#create a n*m Tuple Array with ‘undefined’ contents
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

MapG=[(1,1), (2,2), (0,0)]
MapD=[(1,2),(2,3),(0,0)]
