using Graphs
using IterTools: chain

struct Layout{T}
    vertices::Vector{T}
    vsep::Int
    neighbors::Vector{T}
    disconnected::Vector{T}
end
function Layout(g::SimpleGraph, vertices)
    vs, nbs = vsep_and_neighbors(g, vertices)
    Layout(vertices, vs, nbs, setdiff(1:nv(g), nbs ∪ vertices))
end
function vsep_and_neighbors(G::SimpleGraph, vertices::AbstractVector{T}) where T
    vs, nbs = 0, T[]
    for i=1:length(vertices)
        nbs = sneighbors(G, vertices[1:i])
        vsi = length(nbs)
        if vsi > vs
            vs = vsi
        end
    end
    return vs, nbs
end
vsep(layout::Layout) = layout.vsep
vsep_last(layout::Layout) = length(layout.neighbors)
sneighbors(G, S) = [v for v in setdiff(vertices(G), S) if any(s->has_edge(G, v, s), S)]

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
function ⊙(G::SimpleGraph, layout::Layout{T}, v::T) where T
    vertices = [layout.vertices..., v]
    vs_new, neighbors_new, disconnected = vsep_updated_neighbors(G, layout, v)
    vs_new = max(layout.vsep, vs_new)
    return Layout(vertices, vs_new, neighbors_new, disconnected)
end
Graphs.vertices(layout::Layout) = layout.vertices

# determine the pathwidth of a given graph 
# output ordering and bins 
function greedy(G::AbstractGraph, P)
    V = collect(vertices(G))
    keepgoing = true
    vertice_and_neighbors = vcat(P.vertices, P.neighbors)
    while keepgoing
        keepgoing = false
        for v in chain(P.disconnected, P.neighbors)
            if neighbors(G, v) ⊆ vertice_and_neighbors
                P = ⊙(G, P, v)
                push!(vertice_and_neighbors, v)
                keepgoing = true
            end
        end
        for v in P.neighbors
            if count(∉(vertice_and_neighbors), neighbors(G, v)) == 1
                P = ⊙(G, P, v)
                push!(vertice_and_neighbors, v)
                keepgoing = true
            end
        end
    end
    return P
end

function update_prefix_table!(G, vP, P, current, vs)
    if vs < current && vsep(P) == vs
        b = 0
    else
        b = 1
    end
    old = (vertices(P), vsep(P), 0)
    new = (vertices(P), vsep(P), b)
    if old ∈ vP
        replace!(vP, old=>new)
    else
        push!(vP, new)
    end
end

function branch_and_bound(G::AbstractGraph)
    branch_and_bound!(G, Layout(G, Int[]), Layout(G, collect(vertices(G))), Tuple{Vector{Int}, Int,Int}[])
end

# P is the prefix
# vs is its vertex seperation of L
function branch_and_bound!(G::AbstractGraph, P::Layout, L::Layout, vP)
    V = collect(vertices(G))
    if (vsep(P) < vsep(L)) && (vertices(P), vsep(P), 1) ∉ vP
        P2 = greedy(G, P)
        vsep_P2 = vsep(P2)
        if sort(vertices(P2)) == V && vsep_P2 < vsep(L)
            return P2
        else
            current = vsep(L)
            remaining = vcat(P2.neighbors, P2.disconnected)
            vsep_order = sortperm([vsep_updated(G, P2, x) for x in remaining])
            for v in remaining[vsep_order]  # by increasing values of vsep(P2 ⊙ v)
                if vsep_updated(G, P2, v) < vsep(L)
                    L3 = branch_and_bound!(G, ⊙(G, P2, v), L, vP)
                    if vsep(L3) < vsep(L)
                        L = L3
                    end
                end
            end
            update_prefix_table!(G, vP, P, current, vsep(L))
        end
    end
    return L
end

branch_and_bound(smallgraph(:petersen))

using Random, Test
@testset "B & B" begin
    Random.seed!(2)
    g = smallgraph(:petersen)
    adjm = adjacency_matrix(g)
    for i=1:10
        pm = randperm(nv(g))
        gi = SimpleGraph(adjm[pm, pm])
        L = branch_and_bound(gi)
        @test vsep(L) == 5
        @test vsep(Layout(gi, L.vertices)) == 5
    end
end