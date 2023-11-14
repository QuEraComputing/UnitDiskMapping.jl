# for mapping to a grid graph
using UnitDiskMapping, Graphs
# for solving the MIS
using GenericTensorNetworks

########## The 5-vertex graph ##########
# the five vertex demo graph in the paper: "COMPUTER-ASSISTED GADGET DESIGN AND PROBLEM REDUCTION OF UNWEIGHTED MAXIMUM INDEPENDENT SET"
function demograph()
    g = SimpleGraph(5)
    for (i, j) in [(1, 2), (2, 4), (3, 4), (1, 3), (4, 5), (1, 5)]
        add_edge!(g, i, j)
    end
    return g
end

# create the source graph
g = demograph()

# map it to a grid graph (unweighted)
# the vertex order is optimized with the Branching path decomposition algorithm
mapres = UnitDiskMapping.map_graph(g; vertex_order=Branching())

# visualize the mapped graph in terminal or in a plotting plane
print(mapres.grid_graph)
show_graph(mapres.grid_graph)

# solve the MIS size of the source graph
s1 = solve(IndependentSet(g), SizeMax())[]
# solve the MIS size of the mapped graph
s2 = solve(IndependentSet(SimpleGraph(mapres.grid_graph)), SizeMax())[]
# show that the overhead is correct
s1.n == s2.n - mapres.mis_overhead

# the solution of the mapped graph
mapped_mis = solve(IndependentSet(SimpleGraph(mapres.grid_graph)), SingleConfigMax())[].c.data
# plot the solution
show_config(mapres.grid_graph, mapped_mis)
# map the solution back
original_mis = UnitDiskMapping.map_config_back(mapres, collect(mapped_mis))
# show that it is an MIS
UnitDiskMapping.is_independent_set(g, original_mis)

########## The Petersen graph ##########
# create the source graph as a petersen graph
g = smallgraph(:petersen)

# map it to a grid graph (unweighted)
mapres = UnitDiskMapping.map_graph(g)

# solve the MIS size of the source graph
s1 = solve(IndependentSet(g), SizeMax())[]
# solve the MIS size of the mapped graph
s2 = solve(IndependentSet(SimpleGraph(mapres.grid_graph)), SizeMax())[]
# show that the overhead is correct
s1.n == s2.n - mapres.mis_overhead

# get an MIS
mapped_mis = solve(IndependentSet(SimpleGraph(mapres.grid_graph)), SingleConfigMax())[].c
# map it back
original_mis = UnitDiskMapping.map_config_back(mapres, collect(mapped_mis.data))
# show that it is an MIS
UnitDiskMapping.is_independent_set(g, original_mis)