using Test, UnitDiskMapping, Graphs, GenericTensorNetworks
import ProblemReductions

@testset "rules" begin
    graph = complete_graph(3)  # triangle
    fact = ProblemReductions.Factoring(2, 1, 2)
    is = ProblemReductions.IndependentSet(graph)
    wis = ProblemReductions.IndependentSet(graph, rand(nv(graph)) .* 0.2)
    for (source, target_type) in [
            # please add more tests here
            is => ProblemReductions.IndependentSet{ProblemReductions.GridGraph, Int, ProblemReductions.UnitWeight},
            wis => ProblemReductions.IndependentSet{ProblemReductions.GridGraph, Float64, Vector{Float64}},
            fact => ProblemReductions.IndependentSet{ProblemReductions.GridGraph, Int, Vector{Int}},
        ]
        @info "Testing reduction from $(typeof(source)) to $(target_type)"
        # directly solve
        best_source = ProblemReductions.findbest(source, ProblemReductions.BruteForce())

        # reduce and solve
        result = ProblemReductions.reduceto(target_type, source)
        target = ProblemReductions.target_problem(result)
        @test target isa target_type
        #best_target = findbest(target, BruteForce())
        best_target = GenericTensorNetworks.solve(GenericTensorNetwork(GenericTensorNetworks.IndependentSet(SimpleGraph(target.graph), collect(target.weights))), ConfigsMax())[].c.data

        # extract the solution
        best_source_extracted_single = unique( ProblemReductions.extract_solution.(Ref(result), best_target) )
        best_source_extracted_multiple = ProblemReductions.extract_multiple_solutions(result, best_target)

        # check if the solutions are the same
        @test best_source_extracted_single ⊆ best_source
        @test Set(best_source_extracted_multiple) == Set(best_source)
    end
end
