using Test, UnitDiskMapping, Graphs, GraphTensorNetworks
using GraphTensorNetworks: TropicalF64, content
using Random

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
        w1 = getfield.(locs1, :weight)
        w2 = getfield.(locs2, :weight)
        w1[pins1] .-= 1
        w2[pins2] .-= 1
        m1 = missize(gp1, w1)
        m2 = missize(gp2, w2)
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

@testset "map configurations back" begin
    Random.seed!(2)
    function wmissize(gp, weights)
        contractf(x->TropicalF64(weights[x[1]]), gp)
    end
    for graphname in [:petersen, :bull, :cubical, :house, :diamond, :tutte]
        @show graphname
        g = smallgraph(graphname)
        ug = embed_graph(Weighted(), g)
        mis_overhead0 = mis_overhead_copylines(ug)
        ug2, tape = apply_crossing_gadgets!(Weighted(), copy(ug))
        ug3, tape2 = apply_simplifier_gadgets!(copy(ug2); ruleset=[RotatedGadget(UnitDiskMapping.DanglingLeg(), n) for n=0:3])
        mis_overhead1 = sum(x->mis_overhead(x[1]), tape)
        mis_overhead2 = isempty(tape2) ? 0 : sum(x->mis_overhead(x[1]), tape2)
        mgraph = SimpleGraph(ug3)
        mapped_weights = get_weights(ug3)
        gp = Independence(mgraph; optimizer=GreedyMethod(nrepeat=10), simplifier=MergeGreedy())
        missize_map = wmissize(gp, mapped_weights)[].n
        missize = solve(Independence(g), "size max")[].n
        @test mis_overhead0 + mis_overhead1 + mis_overhead2 + missize == missize_map

        # trace back configurations
        center_locations = trace_centers(ug3, [tape..., tape2...])
        onelocs = [ci.I for ci in findall(c->c.weight==1, ug3.content)]
        @test sort(onelocs) == sort(center_locations)

        T = GraphTensorNetworks.sampler_type(nv(mgraph), 2)
        misconfig = contractf(x->CountingTropical(mapped_weights[x[1]], onehotv(T, x[1], 1)), gp)[].c
        c = zeros(Int, size(ug3.content))
        for (i, loc) in enumerate(findall(!isempty, ug3.content))
            c[loc] = misconfig.data[i]
        end
        indices = CartesianIndex.(center_locations)
        sc = zeros(Int, nv(g))
        sc[getfield.(ug3.lines, :vertex)] = c[indices]
        @test count(isone, sc) == missize
        @test is_independent_set(g, sc)
    end
end


@testset "interface" begin
    Random.seed!(2)
    function wmissize(gp, weights)
        contractf(x->TropicalF64(weights[x[1]]), gp)
    end
    g = smallgraph(:petersen)
    res = map_graph(Weighted(), g)

    # checking size
    mgraph = SimpleGraph(res.grid_graph)
    gp = Independence(mgraph; optimizer=TreeSA(ntrials=1, niters=10), simplifier=MergeGreedy())
    missize_map = wmissize(gp, get_weights(res.grid_graph))[].n
    missize = solve(Independence(g), "size max")[].n
    @test res.mis_overhead + missize == missize_map

    # checking mapping back
    T = GraphTensorNetworks.sampler_type(nv(mgraph), 2)
    misconfig = contractf(x->CountingTropical(get_weights(res.grid_graph)[x[1]], onehotv(T, x[1], 1)), gp)[].c
    c = zeros(Int, size(res.grid_graph.content))
    for (i, loc) in enumerate(findall(!isempty, res.grid_graph.content))
        c[loc] = misconfig.data[i]
    end
    original_configs = map_configs_back(res, [c])
    @test count(isone, original_configs[1]) == missize
    @test is_independent_set(g, original_configs[1])
end
