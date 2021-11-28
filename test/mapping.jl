using UnitDiskMapping, Test
using Graphs, GraphTensorNetworks

@testset "crossing connect count" begin
    g = smallgraph(:bull)
    ug = embed_graph(g; vertex_order=collect(nv(g):-1:1))
    gadgets = [
                    Cross{false}(), Cross{true}(),
                    Turn(), WTurn(), Branch(), BranchFix(), TCon(), TrivialTurn(),
                    RotatedGadget(TCon(), 1), ReflectedGadget(Cross{true}(), "y"),
                    ReflectedGadget(TrivialTurn(), "y"), BranchFixB(),
                    ReflectedGadget(RotatedGadget(TCon(), 1), "y"),]
    for (s, c) in zip(gadgets,
                    [1,0,
                    1,1,0,1,1,1,
                    0, 0,
                    2, 0,
                    1,
                    ])
        @show s
        @test sum(match.(Ref(s), Ref(ug.content), (0:size(ug.content, 1))', 0:size(ug.content,2))) == c
    end
    mug, tape = apply_crossing_gadgets!(copy(ug))
    for s in gadgets
        @test sum(match.(Ref(s), Ref(mug.content), (0:size(mug.content, 1))', 0:size(mug.content,2))) == 0
    end
    ug2 = unapply_gadgets!(copy(mug), tape, [])[1]
    @test UnitDiskMapping.padding(ug2) == 2
    @test ug == ug2
end

@testset "map configurations back" begin
    for graphname in [:petersen, :bull, :cubical, :house, :diamond, :tutte]
        @show graphname
        g = smallgraph(graphname)
        ug = embed_graph(g)
        mis_overhead0 = mis_overhead_copylines(ug)
        ug2, tape = apply_crossing_gadgets!(copy(ug))
        mis_overhead1 = sum(x->mis_overhead(x[1]), tape)
        missize_map = solve(Independence(SimpleGraph(ug2)), "size max"; optimizer=TreeSA(ntrials=1, niters=10), simplifier=MergeGreedy())[].n
        missize = solve(Independence(g), "size max")[].n
        @test mis_overhead0 + mis_overhead1 + missize == missize_map
        misconfig = solve(Independence(SimpleGraph(ug2)), "config max"; optimizer=TreeSA(ntrials=1, niters=10), simplifier=MergeGreedy())[].c
        c = zeros(Int, size(ug2.content))
        for (i, loc) in enumerate(findall(!iszero, ug2.content))
            c[loc] = misconfig.data[i]
        end
        @test all(ci->UnitDiskMapping.safe_get(c, ci.I...)==0 || (UnitDiskMapping.safe_get(c, ci.I[1], ci.I[2]+1) == 0 && UnitDiskMapping.safe_get(c, ci.I[1]+1, ci.I[2]) == 0 &&
            UnitDiskMapping.safe_get(c, ci.I[1]-1, ci.I[2]) == 0 && UnitDiskMapping.safe_get(c, ci.I[1], ci.I[2]-1) == 0 &&
            UnitDiskMapping.safe_get(c, ci.I[1]-1, ci.I[2]-1) == 0 && UnitDiskMapping.safe_get(c, ci.I[1]-1, ci.I[2]+1) == 0 &&
            UnitDiskMapping.safe_get(c, ci.I[1]+1, ci.I[2]-1) == 0 && UnitDiskMapping.safe_get(c, ci.I[1]+1, ci.I[2]+1) == 0
        ), CartesianIndices((55, 55)))
        res, cs = unapply_gadgets!(copy(ug2), tape, [copy(c)])
        @test count(isone, cs[1]) == missize
        @test is_independent_set(g, cs[1])
    end
end