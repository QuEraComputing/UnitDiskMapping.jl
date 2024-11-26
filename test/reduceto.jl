using Test, UnitDiskMapping, ProblemReductions, Graphs

@testset "rules" begin
    graph = complete_graph(3)  # triangle
    is = IndependentSet(graph)
    wis = IndependentSet(graph, rand(nv(graph)) .* 0.2)
    for (source, target_type) in [
            # please add more tests here
            is => IndependentSet{ProblemReductions.GridGraph, Int, UnitWeight},
            wis => IndependentSet{ProblemReductions.GridGraph, Int, Vector{Int}},
        ]
        @info "Testing reduction from $(typeof(source)) to $(target_type)"
        # directly solve
        best_source = findbest(source, BruteForce())

        # reduce and solve
        result = reduceto(target_type, source)
        target = target_problem(result)
        best_target = findbest(target, BruteForce())

        # extract the solution
        best_source_extracted_single = unique( extract_solution.(Ref(result), best_target) )
        best_source_extracted_multiple = extract_multiple_solutions(result, best_target)

        # check if the solutions are the same
        @test best_source_extracted_single ⊆ best_source
        @test Set(best_source_extracted_multiple) == Set(best_source)
    end
end
