using UnitDiskMapping, Test
using GenericTensorNetworks
using GenericTensorNetworks: content
using Graphs

@testset "gadgets" begin
    for s in [UnitDiskMapping.crossing_ruleset..., UnitDiskMapping.simplifier_ruleset...]
        println("Testing gadget:\n$s")
        locs1, g1, pins1 = source_graph(s)
        locs2, g2, pins2 = mapped_graph(s)
        @assert length(locs1) == nv(g1)
        m1 = mis_compactify!(solve(IndependentSet(g1, openvertices=pins1), SizeMax()))
        m2 = mis_compactify!(solve(IndependentSet(g2, openvertices=pins2), SizeMax()))
        @test nv(g1) == length(locs1) && nv(g2) == length(locs2)
        sig, diff = UnitDiskMapping.is_diff_by_const(content.(m1), content.(m2))
        @test diff == -mis_overhead(s)
        @test sig
    end
end

@testset "rotated_and_reflected" begin
    @test length(rotated_and_reflected(UnitDiskMapping.DanglingLeg())) == 4
    @test length(rotated_and_reflected(Cross{false}())) == 4
    @test length(rotated_and_reflected(Cross{true}())) == 4
    @test length(rotated_and_reflected(BranchFixB())) == 8
end