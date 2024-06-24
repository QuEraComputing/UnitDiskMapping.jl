using GenericTensorNetworks
using Test, UnitDiskMapping, Graphs
#using LuxorGraphPlot

@testset "multiplier" begin
    m, pins = UnitDiskMapping.multiplier()
    g, ws = UnitDiskMapping.graph_and_weights(m)
    configs = solve(GenericTensorNetwork(IndependentSet(g, ws)), ConfigsMax())[].c

    # completeness
    inputs = Int[]
    for config in configs
        ci = config[pins[1:4]]
        push!(inputs, ci[1]+ci[2]<<1+ci[3]<<2+ci[4]<<3)
    end
    @test length(unique(inputs)) == 16

    # soundness
    for config in configs
        ci = Int.(config[pins])
        println(ci[1:4], " " ,ci[5])
        @test ci[2] == ci[6]
        @test ci[3] == ci[8]
        @test ci[1] + ci[2]*ci[3] + ci[4] == ci[5] + 2 * ci[7]
    end
end

@testset "factoring" begin
    mres = UnitDiskMapping.map_factoring(2, 2)
    res = UnitDiskMapping.solve_factoring(mres, 6) do g, ws
        collect(Int, solve(GenericTensorNetwork(IndependentSet(g, ws)), SingleConfigMax())[].c.data)
    end
    @test res == (2, 3) || res == (3, 2)

    res = UnitDiskMapping.solve_factoring(mres, 9) do g, ws
        collect(Int, solve(GenericTensorNetwork(IndependentSet(g, ws)), SingleConfigMax())[].c.data)
    end
    @test res == (3, 3)

    mres = UnitDiskMapping.map_factoring(2, 3)
    res = UnitDiskMapping.solve_factoring(mres, 15) do g, ws
        collect(Int, solve(GenericTensorNetwork(IndependentSet(g, ws)), SingleConfigMax())[].c.data)
    end
    @test res == (5, 3) || res == (3, 5)
end