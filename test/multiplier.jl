using GenericTensorNetworks
using Test, UnitDiskMapping, Graphs
#using LuxorGraphPlot

@testset "multiplier" begin
    m, pins = UnitDiskMapping.multiplier()
    g = UnitDiskMapping.get_graph(m)
    #colormap = ["#FFFFFF", "#AAAAAA", "#444444", "#000000"]
    #LuxorGraphPlot.show_graph(g; locs=m.locs, vertex_colors=getindex.(Ref(colormap), m.weights)) |> display
    configs = solve(IndependentSet(g; m.weights), ConfigsMax())[].c

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