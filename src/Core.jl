const SHOW_WEIGHT = Ref(false)
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
    SimpleCell(x::Union{Real,ONE}; occupied=true) = new{typeof(x)}(occupied, x)
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
Base.:+(a::SimpleCell{T}, b::SimpleCell{T}) where T<:Real = a.occupied ? (b.occupied ? SimpleCell(a.weight + b.weight) : a) : b
Base.zero(::Type{SimpleCell{T}}) where T = SimpleCell(one(T); occupied=false)
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
    radius::Float64
end
function Base.show(io::IO, grid::GridGraph)
    println(io, "$(typeof(grid)) (radius = $(grid.radius))")
    print_grid(io, grid; show_weight=SHOW_WEIGHT[])
end
Base.size(gg::GridGraph) = gg.size
Base.size(gg::GridGraph, i::Int) = gg.size[i]
function graph_and_weights(grid::GridGraph)
    return unit_disk_graph(getfield.(grid.nodes, :loc), grid.radius), getfield.(grid.nodes, :weight)
end
function Graphs.SimpleGraph(grid::GridGraph{Node{ONE}})
    return unit_disk_graph(getfield.(grid.nodes, :loc), grid.radius)
end
coordinates(grid::GridGraph) = getfield.(grid.nodes, :loc)

# printing function for Grid graphs
function print_grid(io::IO, grid::GridGraph{Node{WT}}; show_weight=false) where WT
    print_grid(io, cell_matrix(grid); show_weight)
end
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
function cell_matrix(gg::GridGraph{Node{WT}}) where WT
    mat = fill(empty(SimpleCell{WT}), gg.size)
    for node in gg.nodes
        mat[node.loc...] = SimpleCell(node.weight)
    end
    return mat
end

function GridGraph(m::AbstractMatrix{SimpleCell{WT}}, radius::Real) where WT
    nodes = Node{WT}[]
    for j=1:size(m, 2)
        for i=1:size(m, 1)
            if !isempty(m[i, j])
                push!(nodes, Node((i,j), m[i,j].weight))
            end
        end
    end
    return GridGraph(size(m), nodes, radius)
end