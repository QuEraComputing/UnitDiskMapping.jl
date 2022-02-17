using Graphs, GraphTensorNetworks
using UnitDiskMapping
import GraphTensorNetworks.visualize
g_0 = let
    g = SimpleGraph(6)
    for (i,j) in   [(1,2), (2,3), (1,4), (4,5), (5,6), (2,4), (2,6), (3,5)]
        add_edge!(g, i, j)
    end
    g
end
pos_0 = [(0,0), (1,0), (2,0), (0, -1), (1, -1), (2,-1)]
show_graph(g_0; locs = pos_0)

# unit disk mapping
# UnitDiskMapping.pathwidth(g_0, Branching())  #<- throws error 
w_res = map_graph(Weighted(), g_0, vertex_order=[5, 2, 6, 3, 4, 1]);

mapped_vertex_coordinates = trace_centers(w_res.grid_graph, w_res.mapping_history)

new_locs = coordinates(w_res.grid_graph)
g_m = GraphTensorNetworks.unit_disk_graph(new_locs, 1.5)

show_graph(g_m; locs=new_locs, vertex_colors=[new_locs[i] ∉ mapped_vertex_coordinates ? "white" : "lightblue" for i=1:nv(g_m)])
weight_Δ_0 = [rand() * 0.5 + 0.5 for i = 1:nv(g_0)]
weight_Δ_0 = fill(0.5, )
weight_Δ_0 .= weight_Δ_0 ./ maximum(weight_Δ_0)

weight_Δ_M = ones(nv(g_m))  * 1
for i = 1:nv(g_0)
    weight_Δ_M[findfirst(==(mapped_vertex_coordinates[i]), new_locs)] = weight_Δ_0[w_res.grid_graph.lines[i].vertex]
end 
configs_mapped_0 = solve(IndependentSet(g_0; weights= weight_Δ_0), ConfigsMax())[]
configs_mapped_m = solve(IndependentSet(g_m; weights= weight_Δ_M), ConfigsMax())[]