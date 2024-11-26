struct IndependentSetKSGResult{NT, VT} <: ProblemReductions.AbstractReductionResult
    mapres::MappingResult{NT}
    weights::VT
end

# unweighted reduction
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph, Int, ProblemReductions.UnitWeight}}, problem::ProblemReductions.IndependentSet{GT, Int, ProblemReductions.UnitWeight} where GT<:SimpleGraph)
    return IndependentSetKSGResult(map_graph(UnWeighted(), problem.graph), problem.weights)
end

function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph, T, Vector{T}}} where T, problem::ProblemReductions.IndependentSet{GT} where GT<:SimpleGraph)
    return IndependentSetKSGResult(map_graph(Weighted(), problem.graph), problem.weights)
end

function ProblemReductions.target_problem(res::IndependentSetKSGResult{<:UnWeightedNode})
    return ProblemReductions.IndependentSet(SimpleGraph(res.mapres.grid_graph))
end
function ProblemReductions.target_problem(res::IndependentSetKSGResult{<:WeightedNode})
    graph, _ = graph_and_weights(res.mapres.grid_graph)
    weights = UnitDiskMapping.map_weights(res.mapres, res.weights)
    return ProblemReductions.IndependentSet(graph, weights)
end

function ProblemReductions.extract_solution(res::IndependentSetKSGResult, sol)
    return map_config_back(res.mapres, sol)
end