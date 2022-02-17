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
ug = embed_graph(g)
G, tape = apply_gadgets!(copy(ug))
locs = coordinates(G)

using GraphTensorNetworks
s1 = solve(Independence(g), SizeMax())
s2 = solve(Independence(SimpleGraph(G)), SizeMax())
mis_overhead0 = 2 * nv(g) * (nv(g)-1) + nv(g)
mis_overhead1 = sum(x->mis_overhead(x[1]), tape)
s1[].n == s2[].n - mis_overhead0 - mis_overhead1