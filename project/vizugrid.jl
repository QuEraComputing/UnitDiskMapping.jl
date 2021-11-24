using UnitDiskMapping, Graphs

g = SimpleGraph(5)
for (i,j) in [(1,2), (2,4), (1,3), (3,4), (4,5), (1,5)]
    add_edge!(g, i, j)
end
ug = embed_graph(g)
join(["$((ci.I[1],ci.I[2]))" for ci in findall(!iszero, ug.content)], ", ")
ug2 = apply_gadgets!(copy(ug))[1]
join(["$((ci.I[1],ci.I[2]))" for ci in findall(!iszero, ug2.content)], ", ")