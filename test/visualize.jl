using UnitDiskMapping, Graphs, LuxorGraphPlot, LuxorGraphPlot.Luxor, LinearAlgebra
using Test

@testset "show_graph" begin
    g = smallgraph(:petersen)
    res = map_graph(g)
    @test show_graph(res.grid_graph) isa Luxor.Drawing
    @test show_grayscale(res.grid_graph) isa Luxor.Drawing
    @test show_pins(res.grid_graph, Dict("red"=>[1,2,4])) isa Luxor.Drawing
    config = rand(0:1, length(coordinates(res.grid_graph)))
    @test show_config(res.grid_graph, config; show_number=true) isa Drawing
end

@testset "show_graph - weighted" begin
    g = smallgraph(:petersen)
    res = map_graph(Weighted(), g)
    @test show_grayscale(res.grid_graph) isa Luxor.Drawing
    @test show_pins(res) isa Luxor.Drawing
end

@testset "show_pins, logic" begin
    mres = UnitDiskMapping.map_factoring(2, 2)
    @test show_pins(mres) isa Luxor.Drawing
    gd = UnitDiskMapping.Gate(:AND)
    @test show_pins(gd) isa Luxor.Drawing
end
 
@testset "show_pins, qubo" begin
    n = 7
    H = -randn(n) * 0.05
    J = triu(randn(n, n) * 0.001, 1); J += J'
    qubo = UnitDiskMapping.map_qubo(J, H)
    @test show_pins(qubo) isa Luxor.Drawing
 
    m, n = 6, 6
    coupling = [
        [(i,j,i,j+1,0.01*randn()) for i=1:m, j=1:n-1]...,
        [(i,j,i+1,j,0.01*randn()) for i=1:m-1, j=1:n]...
    ]
    onsite = vec([(i, j, 0.01*randn()) for i=1:m, j=1:n])
    qubo = UnitDiskMapping.map_qubo_square(coupling, onsite)
    @test show_pins(qubo) isa Luxor.Drawing
end