using UnitDiskMapping, Test, Graphs

@testset "crossing lattice" begin
    d = UnitDiskMapping.crossing_lattice(complete_graph(10), 1:10)
    @test size(d) == (10,10)
    @test d[1,1] == UnitDiskMapping.Block(-1, -1, -1, 1, -1)
    println(d)
end