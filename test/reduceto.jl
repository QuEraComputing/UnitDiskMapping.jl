using Test, UnitDiskMapping, Graphs, GenericTensorNetworks
import ProblemReductions

@testset "reduction graph" begin
    @test ProblemReductions.reduction_graph() isa ProblemReductions.ReductionGraph
end

@testset "rules" begin
    graph = complete_graph(3)  # triangle
    fact = ProblemReductions.Factoring(2, 1, 2)
    is = ProblemReductions.IndependentSet(graph)
    wis = ProblemReductions.IndependentSet(graph, rand(nv(graph)) .* 0.2)
    sg = ProblemReductions.SpinGlass(graph, [0.2, 0.4, -0.6], [0.1, 0.1, 0.1])
    sg2 = ProblemReductions.SpinGlass(graph, [0.1, 0.1, -0.1], [0.1, 0.1, 0.1])
    grid = ProblemReductions.GridGraph(ones(Bool, 2, 2), 1.2)
    sg_square = ProblemReductions.SpinGlass(grid, [0.1, 0.3, -0.1, 0.4], [0.1, 0.1, 0.1, 0.2])
    sg_square2 = ProblemReductions.SpinGlass(grid, [0.1, -0.3, 0.1, 0.4], [0.1, 0.1, 0.1, 0.2])
    for (source, target_type) in [
            sg_square => ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Float64, Vector{Float64}},
            sg_square2 => ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Float64, Vector{Float64}},
            sg => ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Float64, Vector{Float64}},
            sg2 => ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Float64, Vector{Float64}},
            is => ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Int, ProblemReductions.UnitWeight},
            wis => ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Float64, Vector{Float64}},
            fact => ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Int, Vector{Int}},
        ]
        @info "Testing reduction from $(typeof(source)) to $(target_type)"
        # directly solve
        solver = GTNSolver(optimizer=TreeSA(ntrials=1))
        best_source = ProblemReductions.findbest(source, source isa ConstraintSatisfactionProblem ? solver : ProblemReductions.BruteForce())

        # reduce and solve
        result = ProblemReductions.reduceto(target_type, source)
        target = ProblemReductions.target_problem(result)
        @test target isa target_type
        best_target = ProblemReductions.findbest(IndependentSet(SimpleGraph(target.graph), collect(target.weights)), solver)

        # extract the solution
        best_source_extracted_single = unique( ProblemReductions.extract_solution.(Ref(result), best_target) )
        best_source_extracted_multiple = ProblemReductions.extract_multiple_solutions(result, best_target)

        # check if the solutions are the same
        @test best_source_extracted_single ⊆ best_source
        @test Set(best_source_extracted_multiple) == Set(best_source)
    end
end
