using Test, UnitDiskMapping
using GenericTensorNetworks, Graphs
using LinearAlgebra: triu

@testset "qubo" begin
    n = 5
    H = randn(n) * 0.001
    J = triu(randn(n, n) * 0.001, 1); J += J'
    qubo = UnitDiskMapping.map_qubo(J, H)
    println(qubo)
    graph, weights = UnitDiskMapping.graph_and_weights(qubo)
    r1 = solve(IndependentSet(graph; weights), SingleConfigMax())[]
    # 4J_{ij} n_i n_j - 2J_{ij}n_i - 2J_{ij}n_j + J_{ij}
    # 2H_i n_i - H_i
    J2 = vcat([[-2*J[i,j] for j=i+1:n] for i=1:n]...)
    H2 = 2 .* H
    r2 = solve(SpinGlass(complete_graph(n); edge_weights=J2, vertex_weights=H2), SingleConfigMax())[]
    r3 = r2.n + sum(J) * 0.5 - sum(H)
    @test r1.n % 1 ≈ r3 % 1
    #@show r2
    #@show r1.n, r3, sum(abs.(H)), sum(abs.(J))/2
    #display(MappingGrid(UnitDiskMapping.CopyLine[], 0, qubo))
end