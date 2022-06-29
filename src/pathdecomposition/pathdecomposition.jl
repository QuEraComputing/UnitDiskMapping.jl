module PathDecomposition
using Graphs

export pathwidth, PathDecompositionMethod, Branching, Greedy

struct Layout{T}
    vertices::Vector{T}
    vsep::Int
    neighbors::Vector{T}
    disconnected::Vector{T}
end
Base.hash(layout::Layout) = hash(layout.vertices)
function Base.:(==)(l::Layout, m::Layout)
    l.vsep == m.vsep && l.vertices == m.vertices
end
function Layout(g::SimpleGraph, vertices)
    vs, nbs = vsep_and_neighbors(g, vertices)
    Layout(vertices, vs, nbs, setdiff(1:nv(g), nbs ∪ vertices))
end
function vsep_and_neighbors(G::SimpleGraph, vertices::AbstractVector{T}) where T
    vs, nbs = 0, T[]
    for i=1:length(vertices)
        S = vertices[1:i]
        nbs = [v for v in setdiff(Graphs.vertices(G), S) if any(s->has_edge(G, v, s), S)]
        vsi = length(nbs)
        if vsi > vs
            vs = vsi
        end
    end
    return vs, nbs
end
vsep(layout::Layout) = layout.vsep
vsep_last(layout::Layout) = length(layout.neighbors)

function vsep_updated(G::SimpleGraph, layout::Layout{T}, v::T) where T
    vs = vsep_last(layout)
    if v ∈ layout.neighbors
        vs -= 1
    end
    for w in neighbors(G, v)
        if w ∉ layout.vertices && w ∉ layout.neighbors
            vs += 1
        end
    end
    vs = max(vs, layout.vsep)
    return vs
end
function vsep_updated_neighbors(G::SimpleGraph, layout::Layout{T}, v::T) where T
    vs = vsep_last(layout)
    nbs = copy(layout.neighbors)
    disc = copy(layout.disconnected)
    if v ∈ nbs
        deleteat!(nbs, findfirst(==(v), nbs))
        vs -= 1
    else
        deleteat!(disc, findfirst(==(v), disc))
    end
    for w in neighbors(G, v)
        if w ∉ layout.vertices && w ∉ nbs
            vs += 1
            push!(nbs, w)
            deleteat!(disc, findfirst(==(w), disc))
        end
    end
    vs = max(vs, layout.vsep)
    return vs, nbs, disc
end
# update the Layout by a single vertex
function ⊙(G::SimpleGraph, layout::Layout{T}, v::T) where T
    vertices = [layout.vertices..., v]
    vs_new, neighbors_new, disconnected = vsep_updated_neighbors(G, layout, v)
    vs_new = max(layout.vsep, vs_new)
    return Layout(vertices, vs_new, neighbors_new, disconnected)
end
Graphs.vertices(layout::Layout) = layout.vertices


##### Interfaces #####
abstract type PathDecompositionMethod end

struct Branching <: PathDecompositionMethod end
Base.@kwdef struct Greedy <: PathDecompositionMethod
    nrepeat::Int = 10
end

"""
    pathwidth(g::AbstractGraph, method)

Compute the optimal path decomposition of graph `g`, returns a `Layout` instance.
`method` can be

    * Greedy(; nrepeat=10)
    * Branching
"""
function pathwidth(g::AbstractGraph, ::Branching)
    return branch_and_bound(g)
end

function pathwidth(g::AbstractGraph, method::Greedy)
    res = Layout{Int}[]
    for _ = 1:method.nrepeat
        push!(res, greedy_decompose(g))
    end
    return res[argmin(vsep.(res))]
end

include("greedy.jl")
include("branching.jl")

end

using .PathDecomposition