using Test, UnitDiskMapping
using GenericTensorNetworks, Graphs
using GenericTensorNetworks.OMEinsum.LinearAlgebra: triu
using Random

@testset "qubo" begin
    n = 7
    H = -randn(n) * 0.05
    J = triu(randn(n, n) * 0.001, 1); J += J'
    qubo = UnitDiskMapping.map_qubo(J, H)
    @test show_pins(qubo) !== nothing
    println(qubo)
    graph, weights = UnitDiskMapping.graph_and_weights(qubo.grid_graph)
    r1 = solve(GenericTensorNetwork(IndependentSet(graph, weights)), SingleConfigMax())[]
    J2 = vcat([Float64[J[i,j] for j=i+1:n] for i=1:n]...)
    r2 = solve(SpinGlass(complete_graph(n); J=J2, h=H), SingleConfigMax())[]
    @test r1.n - qubo.mis_overhead ≈ r2.n
    @test r1.n % 1 ≈ r2.n % 1
    c1 = map_config_back(qubo, r1.c.data)
    @test spinglass_energy(complete_graph(n), c1; J=J2, h=H) ≈ spinglass_energy(complete_graph(n), r2.c.data; J=J2, h=H)
    #display(MappingGrid(UnitDiskMapping.CopyLine[], 0, qubo))
end

@testset "simple wmis" begin
    for graphname in [:petersen, :bull, :cubical, :house, :diamond]
        @show graphname
        g0 = smallgraph(graphname)
        n = nv(g0)
        w0 = ones(n) * 0.01
        wmis = UnitDiskMapping.map_simple_wmis(g0, w0)
        graph, weights = UnitDiskMapping.graph_and_weights(wmis.grid_graph)
        r1 = solve(GenericTensorNetwork(IndependentSet(graph, weights)), SingleConfigMax())[]
        r2 = solve(GenericTensorNetwork(IndependentSet(g0, w0)), SingleConfigMax())[]
        @test r1.n - wmis.mis_overhead ≈ r2.n
        @test r1.n % 1 ≈ r2.n % 1
        c1 = map_config_back(wmis, r1.c.data)
        @test sum(c1 .* w0) == r2.n
    end
end

@testset "restricted qubo" begin
    n = 5
    coupling = [
        [(i,j,i,j+1,rand([-1,1])) for i=1:n, j=1:n-1]...,
        [(i,j,i+1,j,rand([-1,1])) for i=1:n-1, j=1:n]...
    ]
    qubo = UnitDiskMapping.map_qubo_restricted(coupling)
    graph, weights = UnitDiskMapping.graph_and_weights(qubo.grid_graph)
    r1 = solve(GenericTensorNetwork(IndependentSet(graph, weights)), SingleConfigMax())[]


    weights = Int[]
    g2 = SimpleGraph(n*n)
    for (i,j,i2,j2,J) in coupling
        add_edge!(g2, (i-1)*n+j, (i2-1)*n+j2)
        push!(weights, J)
    end
    r2 = solve(SpinGlass(g2; J=weights), SingleConfigMax())[]
    @show r1, r2
end

@testset "square qubo" begin
    Random.seed!(4)
    m, n = 6, 6
    coupling = [
        [(i,j,i,j+1,0.01*randn()) for i=1:m, j=1:n-1]...,
        [(i,j,i+1,j,0.01*randn()) for i=1:m-1, j=1:n]...
    ]
    onsite = vec([(i, j, 0.01*randn()) for i=1:m, j=1:n])
    qubo = UnitDiskMapping.map_qubo_square(coupling, onsite)
    graph, weights = UnitDiskMapping.graph_and_weights(qubo.grid_graph)
    r1 = solve(GenericTensorNetwork(IndependentSet(graph, weights)), SingleConfigMax())[]

    # solve spin glass directly
    g2 = SimpleGraph(m*n)
    Jd = Dict{Tuple{Int,Int}, Float64}()
    for (i,j,i2,j2,J) in coupling
        edg = (i+(j-1)*m, i2+(j2-1)*m)
        Jd[edg] = J
        add_edge!(g2, edg...)
    end

    Js, hs = Float64[], zeros(Float64, nv(g2))
    for e in edges(g2)
        push!(Js, Jd[(e.src, e.dst)])
    end
    for (i,j,h) in onsite
        hs[i+(j-1)*m] = h
    end
    r2 = solve(SpinGlass(g2; J=Js, h=hs), SingleConfigMax())[]
    @test r1.n - qubo.mis_overhead ≈ r2.n
    c1 = map_config_back(qubo, collect(Int,r1.c.data))
    c2 = collect(r2.c.data)
    @test spinglass_energy(g2, c1; J=Js, h=hs) ≈ spinglass_energy(g2, c2; J=Js, h=hs)
end