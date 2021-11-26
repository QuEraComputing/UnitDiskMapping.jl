# Reference
# ----------------------------
# Coudert, D., Mazauric, D., & Nisse, N. (2014).
# Experimental evaluation of a branch and bound algorithm for computing pathwidth.
# https://doi.org/10.1007/978-3-319-07959-2_5

function branch_and_bound(G::AbstractGraph)
    branch_and_bound!(G, Layout(G, Int[]), Layout(G, collect(vertices(G))), Dict{Layout{Int},Bool}())
end

# P is the prefix
# vs is its vertex seperation of L
function branch_and_bound!(G::AbstractGraph, P::Layout, L::Layout, vP::Dict)
    V = collect(vertices(G))
    if (vsep(P) < vsep(L)) && !haskey(vP, P)
        P2 = greedy_exact(G, P)
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
            # update Layout table
            vP[P] = !(vsep(L) < current && vsep(P) == vsep(L))
        end
    end
    return L
end