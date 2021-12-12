using Test, UnitDiskMapping, Graphs, GraphTensorNetworks
using GraphTensorNetworks: TropicalF64, content

@testset "gadgets" begin
    function missize(gp, weights)
        contractf(x->TropicalF64(weights[x[1]]), gp)
    end

    for s in [UnitDiskMapping.crossing_ruleset_weighted...]
        println("Testing gadget:\n$s")
        locs1, g1, pins1 = source_graph(s)
        locs2, g2, pins2 = mapped_graph(s)
        @assert length(locs1) == nv(g1)
        gp1 = Independence(g1, openvertices=pins1)
        gp2 = Independence(g2, openvertices=pins2)
        m1 = mis_compactify!(missize(gp1, getfield.(locs1, :weight)))
        m2 = mis_compactify!(missize(gp2, getfield.(locs2, :weight)))
        @test nv(g1) == length(locs1) && nv(g2) == length(locs2)
        sig, diff = UnitDiskMapping.is_diff_by_const(content.(m1), content.(m2))
        @test sig
        @test diff == -mis_overhead(s)
    end
end

@testset "map configurations back" begin
    function wmissize(gp, weights)
        contractf(x->TropicalF64(weights[x[1]]), gp)
    end
    for graphname in [:petersen, :bull, :cubical, :house, :diamond, :tutte]
        @show graphname
        g = smallgraph(graphname)
        ug = embed_graph(Weighted(), g)
        mis_overhead0 = mis_overhead_copylines(ug)
        ug2, tape = apply_crossing_gadgets!(copy(ug), UnitDiskMapping.crossing_ruleset_weighted)
        ug3, tape2 = apply_simplifier_gadgets!(copy(ug2); ruleset=[RotatedGadget(UnitDiskMapping.DanglingLeg(), n) for n=0:3])
        mis_overhead1 = sum(x->mis_overhead(x[1]), tape)
        mis_overhead2 = isempty(tape2) ? 0 : sum(x->mis_overhead(x[1]), tape2)
        mapped_graph = SimpleGraph(ug3)
        mapped_weights = get_weights(ug3)
        gp = Independence(mapped_graph; optimizer=GreedyMethod(nrepeat=10), simplifier=MergeGreedy())
        missize_map = wmissize(gp, mapped_weights)[].n
        missize = solve(Independence(g), "size max")[].n
        @test mis_overhead0 + mis_overhead1 + mis_overhead2 + missize == missize_map
        #T = GraphTensorNetworks.sampler_type(nv(g), 2)
        #misconfig = contractf(x->CountingTropical(weights[x[1]], onehotv(T, x[1], 1)), gp, "config max")[].c
        #c = zeros(Int, size(ug3.content))
        #for (i, loc) in enumerate(findall(!isempty, ug3.content))
        #    c[loc] = misconfig.data[i]
        #end
        #res, cs = unapply_gadgets!(copy(ug3), [tape..., tape2...], [copy(c)])
        #@test count(isone, cs[1]) == missize
        #@test is_independent_set(g, cs[1])
    end
end

