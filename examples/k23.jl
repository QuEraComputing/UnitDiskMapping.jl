using UnitDiskMapping, Graphs

k23 = SimpleGraph(Edge.([1=>3, 1=>4, 1=>5, 2=>3, 2=>4, 2=>5]))

# map the graph the a diagonal-coupled unit-disk grid graph.
res = map_graph(k23)
println(res.grid_graph)
# output: a 7 x 11 DUGG
# ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ 
# ● ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ 
# ● ● ● ● ● ● ● ● ● ⋅ ● 
# ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ 

dugg = SimpleGraph(res.grid_graph)

using GenericTensorNetworks

# solve and check the MIS size
source_mis_size = solve(IndependentSet(k23), SizeMax())[]
dugg_mis_size = solve(IndependentSet(dugg), SizeMax())[]
source_mis_size.n == dugg_mis_size.n - res.mis_overhead

# map an MIS for the dugg back
dugg_mis = solve(IndependentSet(dugg), SingleConfigMax())[].c.data
source_mis = map_config_back(res, dugg_mis)
GenericTensorNetworks.is_independent_set(k23, source_mis) && count(isone, source_mis) == source_mis_size.n