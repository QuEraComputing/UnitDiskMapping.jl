using Test, UnitDiskMapping
using GenericTensorNetworks, Graphs
using GenericTensorNetworks.OMEinsum.LinearAlgebra: triu

@testset "qubo" begin
    n = 7
    H = randn(n) * 0.001
    J = triu(randn(n, n) * 0.001, 1); J += J'
    qubo = UnitDiskMapping.map_qubo(J, H)
    @test show_pins(qubo) !== nothing
    println(qubo)
    graph, weights = UnitDiskMapping.graph_and_weights(qubo.grid_graph)
    r1 = solve(IndependentSet(graph; weights), SingleConfigMax())[]
    J2 = vcat([Float64[J[i,j] for j=i+1:n] for i=1:n]...)
    r2 = solve(SpinGlass(complete_graph(n); J=J2, h=H), SingleConfigMax())[]
    @test r1.n - qubo.mis_overhead ≈ r2.n
    @test r1.n % 1 ≈ r2.n % 1
    c1 = map_configs_back(qubo, [r1.c.data])
    @test spinglass_energy(complete_graph(n), c1[]; J=J2, h=H) ≈ spinglass_energy(complete_graph(n), r2.c.data; J=J2, h=H)
    #display(MappingGrid(UnitDiskMapping.CopyLine[], 0, qubo))
end

@testset "simple wmis" begin
    for graphname in [:petersen, :bull, :cubical, :house, :diamond]
        @show graphname
        g0 = smallgraph(graphname)
        n = nv(g0)
        w0 = ones(n) * 0.01
        wmis = UnitDiskMapping.map_simple_wmis(g0, w0)
        @test show_pins(wmis) !== nothing
        graph, weights = UnitDiskMapping.graph_and_weights(wmis.grid_graph)
        r1 = solve(IndependentSet(graph; weights), SingleConfigMax())[]
        r2 = solve(IndependentSet(g0; weights=w0), SingleConfigMax())[]
        @test r1.n - wmis.mis_overhead ≈ r2.n
        @test r1.n % 1 ≈ r2.n % 1
        c1 = map_configs_back(wmis, [r1.c.data])
        @test sum(c1[] .* w0) == r2.n
    end
end