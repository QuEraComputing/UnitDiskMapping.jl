using Test, UnitDiskMapping, Graphs, GraphTensorNetworks
using GraphTensorNetworks: TropicalF64, content
using Random

@testset "gadgets" begin
    for s in [UnitDiskMapping.crossing_ruleset_weighted...]
        println("Testing gadget:\n$s")
        locs1, g1, pins1 = source_graph(s)
        locs2, g2, pins2 = mapped_graph(s)
        @assert length(locs1) == nv(g1)
        w1 = getfield.(locs1, :weight)
        w2 = getfield.(locs2, :weight)
        gp1 = Independence(g1, openvertices=pins1, weights=w1)
        gp2 = Independence(g2, openvertices=pins2, weights=w2)
        w1[pins1] .-= 1
        w2[pins2] .-= 1
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

@testset "map configurations back" begin
    Random.seed!(2)
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
        mapped_weights = UnitDiskMapping.get_weights(ug3)
        gp = Independence(mgraph; optimizer=GreedyMethod(nrepeat=10),
            simplifier=MergeGreedy(), weights=mapped_weights)
        missize_map = solve(gp, SizeMax())[].n
        missize = solve(Independence(g), CountingMax())[]
        @test mis_overhead0 + mis_overhead1 + mis_overhead2 + missize.n == missize_map

        # trace back configurations
        center_locations = trace_centers(ug3, [tape..., tape2...])
        onelocs = [ci.I for ci in findall(c->c.weight==1, ug3.content)]
        @test sort(onelocs) == sort(center_locations)

        misconfig = solve(gp, SingleConfigMax())[].c.data
        c = zeros(Int, size(ug3.content))
        for (i, loc) in enumerate(findall(!isempty, ug3.content))
            c[loc] = misconfig[i]
        end
        indices = CartesianIndex.(center_locations)
        sc = zeros(Int, nv(g))
        sc[getfield.(ug3.lines, :vertex)] = c[indices]
        @test count(isone, sc) == missize.n
        @test UnitDiskMapping.is_independent_set(g, sc)
    end
end


@testset "interface" begin
    Random.seed!(2)
    g = smallgraph(:petersen)
    res = map_graph(Weighted(), g)

    # checking size
    mgraph = SimpleGraph(res.grid_graph)
    gp = Independence(mgraph; optimizer=TreeSA(ntrials=1, niters=10), simplifier=MergeGreedy(), weights=UnitDiskMapping.get_weights(res.grid_graph))
    missize_map = solve(gp, SizeMax())[].n
    missize = solve(Independence(g), CountingMax())[]
    @test res.mis_overhead + missize.n == missize_map

    # checking mapping back
    misconfigs = solve(gp, ConfigsMax())[].c
    #@test length(misconfigs) == missize.c
    for misconfig in misconfigs.data
        c = zeros(Int, size(res.grid_graph.content))
        for (i, loc) in enumerate(findall(!isempty, res.grid_graph.content))
            c[loc] = misconfig[i]
        end
        original_configs = map_configs_back(res, [c])
        @test count(isone, original_configs[1]) == missize.n
        @test UnitDiskMapping.is_independent_set(g, original_configs[1])
    end
end