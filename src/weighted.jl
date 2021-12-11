# TODO:
# * add path decomposition
struct WeightedCell{RT} <: AbstractCell
    occupied::Bool
    doubled::Bool
    connected::Bool
    weight::RT
end

abstract type WeightedCrossPattern <: Pattern end
abstract type WeightedSimplifyPattern <:Pattern end
struct WeightedGadget{GT} <: Pattern
    gadget::GT
    factor::Int
end
const WeightedPattern = Union{WeightedCrossPattern, WeightedSimplifyPattern, WeightedGadget}

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

struct WeightedNode{T,WT} <: Node
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

function source_graph(r::WeightedGadget)
    locs, g, pins = source_graph(r.gadget)
    _mul_weight.(locs, r.factor), g, pins
end
function mapped_graph(r::WeightedGadget)
    locs, g, pins = mapped_graph(r.gadget)
    _mul_weight.(locs, r.factor), g, pins
end
_mul_weight(node::SimpleNode, factor) = WeightedNode(node..., factor)
mis_overhead(p::WeightedGadget) = 2*mis_overhead(p.gadget)

# new gadgets
struct WeightedWTurn <: WeightedCrossPattern end
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ◯ ● 
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅

# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ⋅ ● 
# ⋅ ⋅ ◯ ⋅ 
# ⋅ ● ⋅ ⋅

struct WeightedBranchFix <: WeightedCrossPattern end
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ◯ ⋅
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅

# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅
# ⋅ ◯ ⋅ ⋅ 
# ⋅ ● ⋅ ⋅

struct WeightedTurn <: WeightedCrossPattern end
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ◯ ● 
# ⋅ ⋅ ⋅ ⋅

# ⋅ ● ⋅ ⋅ 
# ⋅ ⋅ ◯ ⋅ 
# ⋅ ⋅ ⋅ ● 
# ⋅ ⋅ ⋅ ⋅

struct WeightedBranch <: WeightedCrossPattern end
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ◯ ● 
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅


# ⋅ ● ⋅ ⋅   ?
# ⋅ ⋅ ◯ ⋅ 
# ⋅ ● ⋅ ● 
# ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ⋅

struct WeightedBranchFixB <: WeightedCrossPattern end
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ◯ ⋅
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅

# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ⋅ ⋅
# ⋅ ◯ ⋅ ⋅ 
# ⋅ ● ⋅ ⋅

for T in [:Cross, :TrivialTurn, :TCon]
    @eval weighted(c::$T) = WeightedGadget(c, 2)
end
unweighted(w::WeightedGadget) = w.gadget
weighted(r::RotatedGadget) = RotatedGadget(weighted(r.gadget), r.n)
weighted(r::ReflectedGadget) = ReflectedGadget(weighted(r.gadget), r.mirror)
unweighted(r::RotatedGadget) = RotatedGadget(unweighted(r.gadget), r.n)
unweighted(r::ReflectedGadget) = ReflectedGadget(unweighted(r.gadget), r.mirror)

for T in [:Turn, :Branch, :BranchFix, :BranchFixB, :WTurn]
    WT = Symbol(:Weighted, T)
    @eval weighted(::$T) = $WT()
    @eval unweighted(::$WT) = $T()
end

for (T, centerloc) in [(:Turn, (2, 3)), (:Branch, (2, 3)), (:BranchFix, (3, 2)), (:BranchFixB, (3, 2)), (:WTurn, (3, 3))]
    WT = Symbol(:Weighted, T)
    @eval function source_graph(r::$WT)
        raw = unweighted(r)
        locs, g, pins = source_graph(raw)
        return map(loc->_mul_weight(loc, loc == SimpleNode(cross_location(raw) .+ (0, 1)) ? 1 : 2), locs), g, pins
    end
    @eval function mapped_graph(r::$WT)
        raw = unweighted(r)
        locs, g, pins = mapped_graph(raw)
        return map(loc->_mul_weight(loc, loc == SimpleNode($centerloc) ? 1 : 2), locs), g, pins
    end
end

for T in [:WeightedCrossPattern, :WeightedGadget]
    @eval Base.size(r::$T) = size(unweighted(r))
    @eval cross_location(r::$T) = cross_location(unweighted(r))
    @eval iscon(r::$T) = iscon(unweighted(r))
    @eval connected_nodes(r::$T) = connected_nodes(unweighted(r))
    @eval vertex_overhead(r::$T) = vertex_overhead(unweighted(r))
end

const crossing_ruleset_weighted3 = weighted.(crossing_ruleset)