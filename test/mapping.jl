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
        ug3, tape2 = apply_simplifier_gadgets!(copy(ug2); ruleset=[RotatedGadget(UnitDiskMapping.DanglingLeg(), n) for n=0:3])
        mis_overhead1 = sum(x->mis_overhead(x[1]), tape)
        mis_overhead2 = sum(x->mis_overhead(x[1]), tape2)
        @show mis_overhead2
        gp = Independence(SimpleGraph(ug3); optimizer=GreedyMethod(nrepeat=10), simplifier=MergeGreedy())
        missize_map = solve(gp, "size max")[].n
        missize = solve(Independence(g), "size max")[].n
        @test mis_overhead0 + mis_overhead1 + mis_overhead2 + missize == missize_map
        misconfig = solve(gp, "config max")[].c
        c = zeros(Int, size(ug3.content))
        for (i, loc) in enumerate(findall(!iszero, ug3.content))
            c[loc] = misconfig.data[i]
        end
        @test all(ci->UnitDiskMapping.safe_get(c, ci.I...)==0 || (UnitDiskMapping.safe_get(c, ci.I[1], ci.I[2]+1) == 0 && UnitDiskMapping.safe_get(c, ci.I[1]+1, ci.I[2]) == 0 &&
            UnitDiskMapping.safe_get(c, ci.I[1]-1, ci.I[2]) == 0 && UnitDiskMapping.safe_get(c, ci.I[1], ci.I[2]-1) == 0 &&
            UnitDiskMapping.safe_get(c, ci.I[1]-1, ci.I[2]-1) == 0 && UnitDiskMapping.safe_get(c, ci.I[1]-1, ci.I[2]+1) == 0 &&
            UnitDiskMapping.safe_get(c, ci.I[1]+1, ci.I[2]-1) == 0 && UnitDiskMapping.safe_get(c, ci.I[1]+1, ci.I[2]+1) == 0
        ), CartesianIndices((55, 55)))
        res, cs = unapply_gadgets!(copy(ug3), [tape..., tape2...], [copy(c)])
        @test count(isone, cs[1]) == missize
        @test is_independent_set(g, cs[1])
    end
end

@testset "interface" begin
    g = smallgraph(:petersen)
    res = map_graph(g)

    # checking size
    gp = Independence(SimpleGraph(res.grid_graph); optimizer=TreeSA(ntrials=1, niters=10), simplifier=MergeGreedy())
    missize_map = solve(gp, "size max")[].n
    missize = solve(Independence(g), "size max")[].n
    @test res.mis_overhead + missize == missize_map

    # checking mapping back
    misconfig = solve(gp, "config max")[].c
    c = zeros(Int, size(res.grid_graph.content))
    for (i, loc) in enumerate(findall(!iszero, res.grid_graph.content))
        c[loc] = misconfig.data[i]
    end
    original_configs = map_configs_back(res, [c])
    @test count(isone, original_configs[1]) == missize
    @test is_independent_set(g, original_configs[1])
end