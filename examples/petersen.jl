using UnitDiskMapping, Graphs

function petersen_graph()
    graph = SimpleGraph(10)
    for (i, j) in [(1,2), (1,4), (1,9), (2,3), (2, 7), (3,5), (3, 10), (4, 5), (4,6), (5, 8), (6, 7), (6,10), (7,8),(8,9),(9,10)]
        add_edge!(graph, i, j)
    end
    @assert all(==(3), degree.(Ref(graph), 1:10))
    return graph
end

g = petersen_graph()
res = map_graph(g)
G = SimpleGraph(res.grid_graph)

using GenericTensorNetworks
s1 = solve(IndependentSet(g), SizeMax())
s2 = solve(IndependentSet(SimpleGraph(G)), SizeMax())
s1[].n == s2[].n - res.mis_overhead