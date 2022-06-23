using Test, UnitDiskMapping, Graphs, GenericTensorNetworks
using GenericTensorNetworks: TropicalF64, content
using Random
using UnitDiskMapping: is_independent_set

@testset "gadgets" begin
    for s in [UnitDiskMapping.crossing_ruleset_weighted..., UnitDiskMapping.default_simplifier_ruleset(Weighted())...]
        println("Testing gadget:\n$s")
        locs1, g1, pins1 = source_graph(s)
        locs2, g2, pins2 = mapped_graph(s)
        @assert length(locs1) == nv(g1)
        w1 = getfield.(locs1, :weight)
        w2 = getfield.(locs2, :weight)
        w1[pins1] .-= 1
        w2[pins2] .-= 1
        gp1 = IndependentSet(g1, openvertices=pins1, weights=w1)
        gp2 = IndependentSet(g2, openvertices=pins2, weights=w2)
        m1 = solve(gp1, SizeMax())
        m2 = solve(gp2, SizeMax())
        mm1 = maximum(m1)
        mm2 = maximum(m2)
        @test nv(g1) == length(locs1) && nv(g2) == length(locs2)
        if !(all((mm1 .== m1) .== (mm2 .== m2)))
            @show m1
            @show m2
        end
        @test all((mm1 .== m1) .== (mm2 .== m2))
        @test content(mm1 / mm2) == -mis_overhead(s)
    end
end

@testset "copy lines" begin
    for (vstart, vstop, hstop) in [
            (3, 7, 8), (3, 5, 8), (5, 9, 8), (5, 5, 8),
            (1, 7, 5), (5, 8, 5),  (1, 5, 5), (5, 5, 5)]
        tc = UnitDiskMapping.CopyLine(1, 5, 5, vstart, vstop, hstop)
        locs = UnitDiskMapping.copyline_locations(UnitDiskMapping.WeightedNode, tc; padding=2)
        g = SimpleGraph(length(locs))
        weights = getfield.(locs, :weight)
        for i=1:length(locs)-1
            if i==1 || locs[i-1].weight == 1  # starting point
                add_edge!(g, length(locs), i)
            else
                add_edge!(g, i, i-1)
            end
        end
        gp = IndependentSet(g; weights=weights)
        @test solve(gp, SizeMax())[].n == UnitDiskMapping.mis_overhead_copyline(Weighted(), tc)
    end
end

@testset "map configurations back" begin
    Random.seed!(2)
    for graphname in [:petersen, :bull, :cubical, :house, :diamond, :tutte]
        @show graphname
        g = smallgraph(graphname)
        ug = embed_graph(Weighted(), g)
        mis_overhead0 = mis_overhead_copylines(ug)
        ug2, tape = apply_crossing_gadgets!(Weighted(), copy(ug))
        ug3, tape2 = apply_simplifier_gadgets!(copy(ug2); ruleset=[UnitDiskMapping.weighted(RotatedGadget(UnitDiskMapping.DanglingLeg(), n)) for n=0:3])
        mis_overhead1 = sum(x->mis_overhead(x[1]), tape)
        mis_overhead2 = isempty(tape2) ? 0 : sum(x->mis_overhead(x[1]), tape2)

        # trace back configurations
        mgraph = SimpleGraph(ug3)
        weights = fill(0.5, nv(g))
        mapped_weights = UnitDiskMapping.map_weights(UnitDiskMapping.MappingResult(ug3, [tape..., tape2...], mis_overhead0+mis_overhead1+mis_overhead2), weights)
        gp = IndependentSet(mgraph; optimizer=GreedyMethod(nrepeat=10), simplifier=MergeGreedy(), weights=mapped_weights)
        missize_map = solve(gp, CountingMax())[]
        missize = solve(IndependentSet(g; weights=weights), CountingMax())[]
        @test mis_overhead0 + mis_overhead1 + mis_overhead2 + missize.n == missize_map.n
        @test missize.c == missize_map.c

        T = GenericTensorNetworks.sampler_type(nv(mgraph), 2)
        misconfig = solve(gp, SingleConfigMax())[].c
        c = zeros(Int, size(ug3.content))
        for (i, loc) in enumerate(findall(!isempty, ug3.content))
            c[loc] = misconfig.data[i]
        end

        center_locations = trace_centers(ug3, [tape..., tape2...])
        indices = CartesianIndex.(center_locations)
        sc = c[indices]
        @test count(isone, sc) == missize.n * 2
        @test is_independent_set(g, sc)
    end
end


@testset "interface" begin
    Random.seed!(2)
    g = smallgraph(:petersen)
    res = map_graph(Weighted(), g)

    # checking size
    mgraph = SimpleGraph(res.grid_graph)
    ws = rand(nv(g))
    weights = UnitDiskMapping.map_weights(res, ws)

    gp = IndependentSet(mgraph; optimizer=TreeSA(ntrials=1, niters=10), simplifier=MergeGreedy(), weights=weights)
    missize_map = solve(gp, SizeMax())[].n
    missize = solve(IndependentSet(g; weights=ws), SizeMax())[].n
    @test res.mis_overhead + missize == missize_map

    # checking mapping back
    T = GenericTensorNetworks.sampler_type(nv(mgraph), 2)
    misconfig = solve(gp, SingleConfigMax())[].c
    original_configs = map_configs_back(res, [collect(misconfig.data)])
    @test count(isone, original_configs[1]) == solve(IndependentSet(g), SizeMax())[].n
    @test is_independent_set(g, original_configs[1])
end
