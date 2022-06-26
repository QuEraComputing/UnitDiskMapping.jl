const SHOW_WEIGHT = Ref(false)
# UnWeighted mode
struct UnWeighted end
# Weighted mode
struct Weighted end
# The static one for unweighted cells
struct ONE end
Base.one(::Type{ONE}) = ONE()
Base.show(io::IO, ::ONE) = print(io, "1")
Base.show(io::IO, ::MIME"text/plain", ::ONE) = print(io, "1")

############################ Cell ############################
# Cell does not have coordinates
abstract type AbstractCell{WT} end
Base.show(io::IO, x::AbstractCell) = print_cell(io, x; show_weight=SHOW_WEIGHT[])
Base.show(io::IO, ::MIME"text/plain", cl::AbstractCell) = Base.show(io, cl)

# SimpleCell
struct SimpleCell{WT} <: AbstractCell{WT}
    occupied::Bool
    weight::WT
    SimpleCell(; occupied=true) = new{ONE}(occupied, ONE())
    SimpleCell(x::Real; occupied=true) = new{typeof(x)}(occupied, x)
    SimpleCell{T}(x::Real; occupied=true) where T = new{T}(occupied, T(x))
end
get_weight(sc::SimpleCell) = sc.weight
Base.empty(::Type{SimpleCell{WT}}) where WT = SimpleCell(one(WT); occupied=false)
Base.isempty(sc::SimpleCell) = !sc.occupied
function print_cell(io::IO, x::AbstractCell; show_weight=false)
    if x.occupied
        print(io, show_weight ? "$(get_weight(x))" : "●")
    else
        print(io, "⋅")
    end
end
WeightedSimpleCell{T<:Real} = SimpleCell{T}
UnWeightedSimpleCell = SimpleCell{ONE}

############################ Node ############################
# The node used in unweighted graph
struct Node{WT}
    loc::Tuple{Int,Int}
    weight::WT
end
Node(x::Real, y::Real) = Node((Int(x), Int(y)), ONE())
Node(x::Real, y::Real, w::Real) = Node((Int(x), Int(y)), w)
Node(xy::Vector{Int}) = Node(xy...)
Node(xy::Tuple{Int,Int}) = Node(xy, ONE())
getxy(p::Node) = p.loc
chxy(n::Node, loc) = Node(loc, n.weight)
Base.iterate(p::Node, i) = Base.iterate(p.loc, i)
Base.iterate(p::Node) = Base.iterate(p.loc)
Base.length(p::Node) = 2
Base.getindex(p::Node, i::Int) = p.loc[i]
offset(p::Node, xy) = chxy(p, getxy(p) .+ xy)
const WeightedNode{T<:Real} = Node{T}
const UnWeightedNode = Node{ONE}

############################ GridGraph ############################
# GridGraph
struct GridGraph{NT<:Node}
    size::Tuple{Int,Int}
    nodes::Vector{NT}
end
Base.show(io::IO, grid::GridGraph) = print_grid(io, grid; show_weight=SHOW_WEIGHT[])
function print_grid(io::IO, grid::GridGraph{Node{WT}}; show_weight=false) where WT
    mat = fill(empty(SimpleCell{WT}), grid.size)
    for node in grid.nodes
        mat[node.loc...] = SimpleCell(node.weight)
    end
    print_grid(io, mat; show_weight)
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
    # generate GridGraph from matrix
    locs = [_to_node(mode, ci.I, mat[ci][2]) for ci in findall(first, mat)]
    return GridGraph(size(mat), locs)
end
_to_node(::UnWeighted, loc::Tuple{Int,Int}, w::Int) = Node(loc)
_to_node(::Weighted, loc::Tuple{Int,Int}, w::Int) = Node(loc, w)

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
function print_grid(io::IO, content::AbstractMatrix; show_weight=false)
    for i=1:size(content, 1)
        for j=1:size(content, 2)
            print_cell(io, content[i,j]; show_weight)
            print(io, " ")
        end
        if i!=size(content, 1)
            println(io)
        end
    end
end