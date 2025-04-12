module ProblemReductionsExt

using UnitDiskMapping, UnitDiskMapping.Graphs
import ProblemReductions: reduceto, target_problem, extract_multiple_solutions
import ProblemReductions

function _to_gridgraph(g::UnitDiskMapping.GridGraph)
    return ProblemReductions.GridGraph(getfield.(g.nodes, :loc), g.radius)
end
function _extract_weights(g::UnitDiskMapping.GridGraph{<:WeightedNode})
    getfield.(g.nodes, :weight)
end

###### unweighted reduction
struct IndependentSetToKSG{NT, VT} <: ProblemReductions.AbstractReductionResult
    mapres::MappingResult{NT}
    weights::VT
end
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Int, ProblemReductions.UnitWeight}}, problem::ProblemReductions.IndependentSet{GT, Int, ProblemReductions.UnitWeight} where GT<:SimpleGraph)
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
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Float64, Vector{Float64}}}, problem::ProblemReductions.IndependentSet{GT} where GT<:SimpleGraph)
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
    raw_graph::ProblemReductions.GridGraph{2}
    raw_weight::Vector{Int}
    vmap::Vector{Int}
    problem::ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Int, Vector{Int}}
end
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Int, Vector{Int}}}, problem::ProblemReductions.Factoring)
    mres = map_factoring(problem.m, problem.n)
    g = _to_gridgraph(mres.grid_graph)
    ws = getfield.(mres.grid_graph.nodes, :weight)
    mg, vmap = UnitDiskMapping.set_target(g, [mres.pins_zeros..., mres.pins_output...], problem.input << length(mres.pins_zeros))
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

###### Spinglass problem to MIS on KSG ######
# NOTE: I am not sure about the correctness of this reduction. If you encounter a bug, please question this function!
struct SpinGlassToIndependentSet{NT} <: ProblemReductions.AbstractReductionResult
    mapres::QUBOResult{NT}
end
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Float64, Vector{Float64}}}, problem::ProblemReductions.SpinGlass{<:SimpleGraph})
    n = length(problem.h)
    M = similar(problem.h, n, n)
    for (e, j) in zip(edges(problem.graph), problem.J)
        M[e.src, e.dst] = M[e.dst, e.src] = j
    end
    return SpinGlassToIndependentSet(map_qubo(M, -problem.h))
end

function ProblemReductions.target_problem(res::SpinGlassToIndependentSet)
    grid = _to_gridgraph(res.mapres.grid_graph)
    ws = getfield.(res.mapres.grid_graph.nodes, :weight)
    return ProblemReductions.IndependentSet(grid, ws)
end

function ProblemReductions.extract_solution(res::SpinGlassToIndependentSet, sol)
    res = map_config_back(res.mapres, sol)
    return Int.(res)
end
 
###### Spinglass problem on grid to MIS on KSG ######
# NOTE: the restricted layout is not implemented, since it is not often used
struct SquareSpinGlassToIndependentSet{NT} <: ProblemReductions.AbstractReductionResult
    mapres::SquareQUBOResult{NT}
end
function ProblemReductions.reduceto(::Type{ProblemReductions.IndependentSet{ProblemReductions.GridGraph{2}, Float64, Vector{Float64}}}, problem::ProblemReductions.SpinGlass{ProblemReductions.GridGraph{2}})
    g = problem.graph
    @assert 1 <= g.radius < sqrt(2) "Only support nearest neighbor interaction"
    coupling = [(g.locations[e.src]..., g.locations[e.dst]..., J) for (e, J) in zip(edges(g), problem.J)]
    onsite = [(i, j, -h) for ((i, j), h) in zip(g.locations, problem.h)]
    # a vector coupling of `(i, j, i', j', J)`, s.t. (i', j') == (i, j+1) or (i', j') = (i+1, j).
    # a vector of onsite term `(i, j, h)`.
    return SquareSpinGlassToIndependentSet(map_qubo_square(coupling, onsite))
end

function ProblemReductions.target_problem(res::SquareSpinGlassToIndependentSet)
    grid = _to_gridgraph(res.mapres.grid_graph)
    ws = getfield.(res.mapres.grid_graph.nodes, :weight)
    return ProblemReductions.IndependentSet(grid, ws)
end

function ProblemReductions.extract_solution(res::SquareSpinGlassToIndependentSet, sol)
    res = map_config_back(res.mapres, sol)
    return Int.(res)
end
end 
