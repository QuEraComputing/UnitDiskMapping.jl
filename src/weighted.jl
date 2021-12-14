export WeightedCell, WeightedGadget, WeightedNode
# TODO:
# * add path decomposition
struct WeightedCell{RT} <: AbstractCell
    occupied::Bool
    doubled::Bool
    connected::Bool
    weight::RT
end

struct WeightedGadget{GT} <: Pattern
    gadget::GT
end
const WeightedGadgetTypes = Union{WeightedGadget, RotatedGadget{<:WeightedGadget}, ReflectedGadget{<:WeightedGadget}}

Base.isempty(cell::WeightedCell) = !cell.occupied
Base.empty(::Type{WeightedCell{RT}}) where RT = WeightedCell(false, false, false,0)
function Base.show(io::IO, x::WeightedCell)
    if x.occupied
        if x.doubled
            print(io, "◉")
        elseif x.connected
            print(io, "◆")
        elseif x.weight == 2
            print(io, "●")
        else
            print(io, "◯")
        end
    else
        print(io, "⋅")
    end
end
Base.show(io::IO, ::MIME"text/plain", cl::WeightedCell) = Base.show(io, cl)

struct WeightedNode{T,WT} <: AbstractNode
    x::T
    y::T
    weight::WT
end
getxy(wn::WeightedNode) = (wn.x, wn.y)
chxy(wn::WeightedNode, xy) = WeightedNode(xy..., wn.weight)

function add_cell!(m::AbstractMatrix{<:WeightedCell}, node::WeightedNode)
    i, j = node
    if isempty(m[i,j])
        m[i, j] = WeightedCell(true, false, false, node.weight)
    else
        @assert !(m[i, j].doubled) && !(m[i, j].connected) && m[i,j].weight == node.weight
        m[i, j] = WeightedCell(true, true, false, node.weight)
    end
end
function connect_cell!(m::AbstractMatrix{<:WeightedCell}, i::Int, j::Int)
    if !m[i, j].occupied || m[i,j].doubled || m[i,j].connected
        error("can not connect at [$i,$j] of type $(m[i,j])")
    end
    m[i, j] = WeightedCell(true, false, true, m[i,j].weight)
end
_weight_type(::CopyLine{Weighted}) = WeightedNode{Int,Int}
_weight2(::CopyLine{Weighted}, i, j) = WeightedNode(i, j, 2)
_weight1(::CopyLine{Weighted}, i, j) = WeightedNode(i, j, 1)
_cell_type(::Type{<:WeightedNode}) = WeightedCell{Int}

weighted(c::Pattern) = WeightedGadget(c)
unweighted(w::WeightedGadget) = w.gadget
weighted(r::RotatedGadget) = RotatedGadget(weighted(r.gadget), r.n)
weighted(r::ReflectedGadget) = ReflectedGadget(weighted(r.gadget), r.mirror)
unweighted(r::RotatedGadget) = RotatedGadget(unweighted(r.gadget), r.n)
unweighted(r::ReflectedGadget) = ReflectedGadget(unweighted(r.gadget), r.mirror)
mis_overhead(w::WeightedGadget) = mis_overhead(w.gadget) * 2

function source_graph(r::WeightedGadget)
    raw = unweighted(r)
    locs, g, pins = source_graph(raw)
    return map(loc->_mul_weight(loc, getxy(loc) ∈ source_centers(r) ? 1 : 2), locs), g, pins
end
function mapped_graph(r::WeightedGadget)
    raw = unweighted(r)
    locs, g, pins = mapped_graph(raw)
    return map(loc->_mul_weight(loc, getxy(loc) ∈ mapped_centers(r) ? 1 : 2), locs), g, pins
end
_mul_weight(node::SimpleNode, factor) = WeightedNode(node..., factor)

for (T, centerloc) in [(:Turn, (2, 3)), (:Branch, (2, 3)), (:BranchFix, (3, 2)), (:BranchFixB, (3, 2)), (:WTurn, (3, 3)), (:EndTurn, (1, 2))]
    @eval source_centers(::WeightedGadget{<:$T}) = [cross_location($T()) .+ (0, 1)]
    @eval mapped_centers(::WeightedGadget{<:$T}) = [$centerloc]
end
# default to having no source center!
source_centers(::WeightedGadget) = Tuple{Int,Int}[]
mapped_centers(::WeightedGadget) = Tuple{Int,Int}[]
for T in [:(RotatedGadget{<:WeightedGadget}), :(ReflectedGadget{<:WeightedGadget})]
    @eval function source_centers(r::$T)
        cross = cross_location(r.gadget)
        return map(loc->loc .+ _get_offset(r), _apply_transform.(Ref(r), source_centers(r.gadget), Ref(cross)))
    end
    @eval function mapped_centers(r::$T)
        cross = cross_location(r.gadget)
        return map(loc->loc .+ _get_offset(r), _apply_transform.(Ref(r), mapped_centers(r.gadget), Ref(cross)))
    end
end

Base.size(r::WeightedGadget) = size(unweighted(r))
cross_location(r::WeightedGadget) = cross_location(unweighted(r))
iscon(r::WeightedGadget) = iscon(unweighted(r))
connected_nodes(r::WeightedGadget) = connected_nodes(unweighted(r))
vertex_overhead(r::WeightedGadget) = vertex_overhead(unweighted(r))

const crossing_ruleset_weighted = weighted.(crossing_ruleset)
get_ruleset(::Weighted) = crossing_ruleset_weighted

export get_weights
get_weights(ug::UGrid) = [ug.content[ci...].weight for ci in coordinates(ug)]

# mapping configurations back
export trace_centers
function move_center(w::WeightedGadgetTypes, nodexy, offset)
    for (sc, mc) in zip(source_centers(w), mapped_centers(w))
        if offset == sc
            return nodexy .+ mc .- sc  # found
        end
    end
    error("center not found, source center = $(source_centers(w)), while offset = $(offset)")
end

trace_centers(r::MappingResult) = trace_centers(r.grid_graph, r.mapping_history)
function trace_centers(ug::UGrid, tape)
    center_locations = map(x->center_location(x; padding=ug.padding) .+ (0, 1), ug.lines)
    for (gadget, i, j) in tape
        m, n = size(gadget)
        for (k, centerloc) in enumerate(center_locations)
            offset = centerloc .- (i-1,j-1)
            if 1<=offset[1] <= m && 1<=offset[2] <= n
                center_locations[k] = move_center(gadget, centerloc, offset)
            end
        end
    end
    return center_locations
end

function map_configs_back(r::MappingResult{<:WeightedCell}, configs::AbstractVector)
    center_locations = trace_centers(r)
    res = [zeros(Int, length(r.grid_graph.lines)) for i=1:length(configs)]
    for (ri, c) in zip(res, configs)
        for (line, loc) in zip(r.grid_graph.lines, center_locations)
            ri[line.vertex] = c[loc...]
        end
    end
    return res
end