using Test, UnitDiskMapping, Graphs

@testset "GridGraph" begin
    grid = GridGraph((5, 5), [Node(2, 3), Node(2, 4), Node(5, 5)], 1.2)
    g = SimpleGraph(grid)
    @test ne(g) == 1
    @test vertices(grid) == vertices(g)
    @test neighbors(grid, 2) == neighbors(g, 2)

    grid = GridGraph((5, 5), [Node(2, 3), Node(2, 4), Node(5, 5)], 4.0)
    g = SimpleGraph(grid)
    @test ne(g) == 3
    @test vertices(grid) == vertices(g)
    @test neighbors(grid, 2) == neighbors(g, 2)
end