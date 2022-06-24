# Cell does not have coordinates
abstract type AbstractCell end

# UnWeighted mode
struct UnWeighted end
# Weighted mode
struct Weighted end

# SimpleNode and WeightedNode (elements in a grid graph)
abstract type AbstractNode end

# The node used in unweighted graph
struct SimpleNode{T} <: AbstractNode
    x::T
    y::T
end
SimpleNode(xy::Tuple{Int,Int}) = SimpleNode(xy...)
SimpleNode(xy::Vector{Int}) = SimpleNode(xy...)
getxy(p::SimpleNode) = (p.x, p.y)
chxy(::SimpleNode, loc) = SimpleNode(loc...)
Base.iterate(p::AbstractNode, i) = Base.iterate((p.x, p.y), i)
Base.iterate(p::AbstractNode) = Base.iterate((p.x, p.y))
Base.length(p::AbstractNode) = 2
Base.getindex(p::AbstractNode, i::Int) = i==1 ? p.x : (@assert i==2; p.y)
offset(p::AbstractNode, xy) = chxy(p, getxy(p) .+ xy)

# The node used in weighted graph
struct WeightedNode{T,WT} <: AbstractNode
    x::T
    y::T
    weight::WT
end
getxy(wn::WeightedNode) = (wn.x, wn.y)
chxy(wn::WeightedNode, xy) = WeightedNode(xy..., wn.weight)

# GridGraph
struct GridGraph{NT<:AbstractNode}
    size::Tuple{Int,Int}
    nodes::Vector{NT}
end

function gridgraphfromstring(mode::Union{Weighted, UnWeighted}, str::String)
    item_array = Vector{Tuple{Bool,Int}}[]
    for line in split(str, "\n")
        items = [item for item in split(line, " ") if !isempty(item)]
        list = if mode isa Weighted   # TODO: the weighted version need to be tested! Consider removing it!
            @assert all(item->item ∈ (".", "⋅", "@", "●", "o", "◯") || (length(item)==1 && isdigit(item[1])), items)
            map(items) do item
                if item ∈ ("@", "●")
                    true, 2
                elseif item ∈ ("o", "◯")
                    true, 1
                elseif item ∈ (".", "⋅")
                    false, 0
                else
                    true, parse(Int, item)
                end
            end
        else
            @assert all(item->item ∈ (".", "⋅", "@", "●"), items)
            map(items) do item
                item ∈ ("@", "●") ? (true, 1) : (false, 0)
            end
        end
        if !isempty(list)
            push!(item_array, list)
        end
    end
    @assert all(==(length(item_array[1])), length.(item_array))
    mat = permutedims(hcat(item_array...), (2,1))
    locs = [_to_node(mode, ci.I, mat[ci][2]) for ci in findall(first, mat)]
    return GridGraph(size(mat), locs)
end
_to_node(::UnWeighted, loc::Tuple{Int,Int}, w::Int) = SimpleNode(loc...)
_to_node(::Weighted, loc::Tuple{Int,Int}, w::Int) = WeightedNode(loc..., w)

function gg_func(mode, expr)
    @assert expr.head == :(=)
    name = expr.args[1]
    pair = expr.args[2]
    @assert pair.head == :(call) && pair.args[1] == :(=>)
    g1 = gridgraphfromstring(mode, pair.args[2])
    g2 = gridgraphfromstring(mode, pair.args[3])
    @assert g1.size == g2.size
    @assert g1.nodes[vertices_on_boundary(g1)] == g2.nodes[vertices_on_boundary(g2)]
    return quote
        struct $(esc(name)) <: SimplifyPattern end
        Base.size(::$(esc(name))) = $(g1.size)
        $UnitDiskMapping.source_locations(::$(esc(name))) = $(g1.nodes)
        $UnitDiskMapping.mapped_locations(::$(esc(name))) = $(g2.nodes)
        $(esc(name))
    end
end

macro gg(expr)
    gg_func(UnWeighted(), expr)
end

# printing function for Grid graphs
function print_grid(io::IO, content::AbstractMatrix)
    for i=1:size(content, 1)
        for j=1:size(content, 2)
            print(io, content[i,j])
            print(io, " ")
        end
        if i!=size(content, 1)
            println(io)
        end
    end
end