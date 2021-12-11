# TODO:
# * add path decomposition
struct WeightedCell{RT} <: AbstractCell
    occupied::Bool
    doubled::Bool
    connected::Bool
    weight::RT
end

abstract type WeightedCrossPattern end
abstract type WeightedSimplifyPattern end
const WeightedPattern = Union{WeightedCrossPattern, WeightedSimplifyPattern}

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

struct WeightedCross{CON} <: WeightedCrossPattern end

function source_graph(::WeightedCross)
    locs = [WeightedNode(x, y, 2) for (x, y) in [(3,1), (3,2), (3,3), (3,4), (3,5), (1,3), (2,3), (3,3), (4,3), (5,3)]]
    graph = simplegraph([(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9), (9,10)])
    return locs, graph, [1,5,6,10]
end

function mapped_graph(::WeightedCross{true})
    locs = [WeightedNode(x, y, 2) for (x, y) in [(3,1), (3,2), (3,3), (3,4), (3,5), (1,3), (2,3), (3,3), (4,3), (5,3)]]
    return locs, graph, [1,5,6,10]
end

function copyline_locations(tc::CopyLine{Weighted}; padding::Int)
    s = 4
    I = s*(tc.hslot-1)+padding+2
    J = s*(tc.vslot-1)+padding+1
    locations = WeightedNode{Int}[]
    # grow up
    for i=I+s*(tc.vstart-tc.hslot)+1:I             # even number of nodes up
        push!(locations, WeightedNode(i, J, 2))
    end
    # grow down
    for i=I:I+s*(tc.vstop-tc.hslot)-1              # even number of nodes down
        if i == I
            push!(locations, WeightedNode(i+1, J+1, 2))
        else
            push!(locations, WeightedNode(i, J, 2))
        end
    end
    # grow right
    for j=J+2:J+s*(tc.hstop-tc.vslot)-1            # even number of nodes right
        push!(locations, WeightedNode(I, j, 2))
    end
    push!(locations, WeightedNode(I, J+1, 1))                     # center node
    return locations
end

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