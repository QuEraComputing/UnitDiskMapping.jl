using UnitDiskMapping, Test, Graphs

@testset "constructor" begin
    p = UnitDiskMapping.DanglingLeg()
    @test size(p) == (4, 3)
    @test UnitDiskMapping.source_locations(p) == UnitDiskMapping.SimpleNode.([(2,2), (3,2), (4,2)])
    @test UnitDiskMapping.mapped_locations(p) == UnitDiskMapping.SimpleNode.([(4,2)])
end

@testset "macros" begin
    @gg Test1 = """
    . . . .
    . . @ .
    . @ . .
    . @ . .
    """ => """
    . . . .
    . . . .
    . . . .
    . @ . .
    """
    sl, sg, sp = source_graph(Test1())
    ml, mg, mp = mapped_graph(Test1())
    @show sg, collect(edges(sg))
    @test sl == UnitDiskMapping.SimpleNode.([(3, 2), (4,2), (2, 3)])
    @test sg == UnitDiskMapping.simplegraph([(1,2), (1,3)])
    @test sp == [2]
    @test ml == [UnitDiskMapping.SimpleNode(4,2)]
    @test mg == UnitDiskMapping.SimpleGraph(1)
    @test mp == [1]
end