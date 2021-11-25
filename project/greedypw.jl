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
    neighbors_S = sneighbors(G, S)
    while any(v->neighbors(G, v) ⊆ (S ∪ neighbors_S), setdiff(V,S)) ||
        any(v->length(setdiff(neighbors(G, v), (S ∪ neighbors_S))) == 1, neighbors_S)
        P2 = P ⊙ v
        S = S ∪ [v]
    end
    return P2
end

function update_prefix_table!(G, vP, P, current, vs)
    if vs < current && vsetp(G, P) == vs
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
            return (vset_P2, P2)
        else
            current = vs
            remaining = sort(setdiff(V, vertices(P2)), by=x->vsep(G, P2 ⊙ x))
            for v in remaining  # by increasing values of vsetp(P2 ⊙ v)
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