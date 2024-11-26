struct IndependentSetToKSG{NT, VT} <: ProblemReductions.AbstractReductionResult
    mapres::MappingResult{NT}
    weights::VT
end
function _to_gridgraph(g::UnitDiskMapping.GridGraph)
    return ProblemReductions.GridGraph(g.size, getfield.(g.nodes, :loc), g.radius)
end
function _extract_weights(g::UnitDiskMapping.GridGraph{<:WeightedNode})
    getfield.(g.nodes, :weight)
end

###### unweighted reduction
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph, Int, ProblemReductions.UnitWeight}}, problem::ProblemReductions.IndependentSet{GT, Int, ProblemReductions.UnitWeight} where GT<:SimpleGraph)
    return IndependentSetToKSG(map_graph(UnWeighted(), problem.graph), problem.weights)
end

function ProblemReductions.target_problem(res::IndependentSetToKSG{<:UnWeightedNode})
    return ProblemReductions.IndependentSet(_to_gridgraph(res.mapres.grid_graph))
end
function ProblemReductions.extract_solution(res::IndependentSetToKSG, sol)
    return map_config_back(res.mapres, sol)
end

###### Weighted reduction
# TODO: rescale the weights to avoid errors
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph, T, Vector{T}}} where T, problem::ProblemReductions.IndependentSet{GT} where GT<:SimpleGraph)
    return IndependentSetToKSG(map_graph(Weighted(), problem.graph), problem.weights)
end
function ProblemReductions.target_problem(res::IndependentSetToKSG{<:WeightedNode})
    graph = _to_gridgraph(res.mapres.grid_graph)
    weights = UnitDiskMapping.map_weights(res.mapres, res.weights)
    return ProblemReductions.IndependentSet(graph, weights)
end

###### Factoring ######
struct FactoringToIndependentSet{NT} <: ProblemReductions.AbstractReductionResult
    mapres::FactoringResult{NT}
    raw_graph::ProblemReductions.GridGraph
    raw_weight::Vector{Int}
    vmap::Vector{Int}
    problem::ProblemReductions.IndependentSet{ProblemReductions.GridGraph, Int, Vector{Int}}
end
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph, T, Vector{T}}} where T, problem::ProblemReductions.Factoring)
    mres = map_factoring(problem.m, problem.n)
    g = _to_gridgraph(mres.grid_graph)
    ws = getfield.(mres.grid_graph.nodes, :weight)
    mg, vmap = set_target(g, [mres.pins_zeros..., mres.pins_output...], problem.input << length(mres.pins_zeros))
    return FactoringToIndependentSet(mres, g, ws, vmap, ProblemReductions.IndependentSet(mg, ws[vmap]))
end

function ProblemReductions.target_problem(res::FactoringToIndependentSet)
    return res.problem
end

function ProblemReductions.extract_solution(res::FactoringToIndependentSet, sol)
    cfg = zeros(Int, nv(res.raw_graph))
    cfg[res.vmap] .= sol
    i1, i2 = map_config_back(res.mapres, cfg)
    return vcat([i1>>(k-1) & 1 for k=1:length(res.mapres.pins_input1)], [i2>>(k-1) & 1 for k=1:length(res.mapres.pins_input2)])
end