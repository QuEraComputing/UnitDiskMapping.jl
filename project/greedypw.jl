using Graphs

struct Layout{T}
    vertices::Vector{T}
end
vsep(G, layout::Layout) = isempty(layout.vertices) ? 0 : maximum(i->vsep(G, layout, i), 1:length(layout.vertices))
vsep(G, layout::Layout, i::Int) = length(sneighbors(G, layout.vertices[1:i]))
sneighbors(G, S) = [v for v in setdiff(vertices(G), S) if any(s->has_edge(G, v, s), S)]
⊙(layout::Layout{T}, v::T) where T = Layout([layout.vertices..., v])
Graphs.vertices(layout::Layout) = layout.vertices

# determine the pathwidth of a given graph 
# output ordering and bins 
function greedy(G::AbstractGraph, P)
    S = vertices(P)
    V = collect(vertices(G))
    P2 = P
    keepgoing = true
    while keepgoing
        keepgoing = false
        neighbors_S = sneighbors(G, S)
        for v in setdiff(V,S)
            if neighbors(G, v) ⊆ (S ∪ neighbors_S)
                P2 = P ⊙ v
                S = S ∪ [v]
                keepgoing = true
            end
        end
        for v in neighbors_S
            if length(setdiff(neighbors(G, v), (S ∪ neighbors_S))) == 1
                P2 = P ⊙ v
                S = S ∪ [v]
                keepgoing = true
            end
        end
    end
    return P2
end

function update_prefix_table!(G, vP, P, current, vs)
    if vs < current && vsep(G, P) == vs
        b = 0
    else
        b = 1
    end
    old = (vertices(P), vsep(G, P), 0)
    new = (vertices(P), vsep(G, P), b)
    if old ∈ vP
        replace!(vP, old=>new)
    else
        push!(vP, new)
    end
end

function branch_and_bound(G::AbstractGraph)
    L = Layout(collect(vertices(G)))
    branch_and_bound!(G, Layout(Int[]), vsep(G, L), L, Tuple{Vector{Int}, Int,Int}[])
end

# P is the prefix
# vs is its vertex seperation of L
function branch_and_bound!(G::AbstractGraph, P::Layout, vs, L::Layout, vP)
    V = collect(vertices(G))
    if (vsep(G, P) < vs) && (vertices(P), vsep(G, P), 1) ∉ vP
        P2 = greedy(G, P)
        vsep_P2 = vsep(G, P2)
        if sort(vertices(P2)) == V && vsep_P2 < vs
            return (vsep_P2, P2)
        else
            current = vs
            remaining = setdiff(V, vertices(P2))
            vsep_order = argsort([vsep(G, P2 ⊙ x) for x in remaining])
            for v in remaining[vsep_order]  # by increasing values of vsep(P2 ⊙ v)
                if vsep(G, P2 ⊙ v) < vs
                    (vs3, L3) = branch_and_bound!(G, P2 ⊙ v, vs, L, vP)
                    if vs3 < vs
                        (vs, L) = (vs3, L3)
                    end
                end
            end
            update_prefix_table!(G, vP, P, current, vs)
        end
    end
    return (vs, L)
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
        vs, L = branch_and_bound(gi)
        @test vs == 5
        @test vsep(gi, L) == 5
    end
end