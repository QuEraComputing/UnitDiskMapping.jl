using Random, Test, UnitDiskMapping
using UnitDiskMapping.PathDecomposition: branch_and_bound, vsep, Layout, addremove_format
using Graphs

@testset "B & B" begin
    Random.seed!(2)
    g = smallgraph(:petersen)
    adjm = adjacency_matrix(g)
    for i=1:10
        pm = randperm(nv(g))
        gi = SimpleGraph(adjm[pm, pm])
        L = branch_and_bound(gi)
        @test vsep(L) == 5
        @test vsep(Layout(gi, L.vertices)) == 5
        arem = addremove_format(L, g)
        @test sum(x->length(x[2]), arem) == nv(g)
    end
    g = smallgraph(:tutte)
    res = pathwidth(g, Branching())
    @test vsep(res) == 6
    g = smallgraph(:tutte)
    res = pathwidth(g, Greedy(nrepeat=50))
    @test vsep(res) == 6
end