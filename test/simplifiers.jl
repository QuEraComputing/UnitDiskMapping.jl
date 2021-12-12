using UnitDiskMapping, Test

@testset "constructor" begin
    p = UnitDiskMapping.DanglingLeg()
    @test size(p) == (4, 3)
    @test UnitDiskMapping.source_locations(p) == UnitDiskMapping.SimpleNode.([(2,2), (3,2), (4,2)])
    @test UnitDiskMapping.mapped_locations(p) == UnitDiskMapping.SimpleNode.([(4,2)])
end