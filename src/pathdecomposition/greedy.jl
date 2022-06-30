function greedy_exact(G::AbstractGraph, P)
    keepgoing = true
    while keepgoing
        keepgoing = false
        for list in (P.disconnected, P.neighbors)
            for v in list
                if all(nb->nb ∈ P.vertices || nb ∈ P.neighbors, neighbors(G, v))
                    P = ⊙(G, P, v)
                    keepgoing = true
                end
            end
        end
        for v in P.neighbors
            if count(nb -> nb ∉ P.vertices && nb ∉ P.neighbors, neighbors(G, v)) == 1
                P = ⊙(G, P, v)
                keepgoing = true
            end
        end
    end
    return P
end

function greedy_decompose(G::AbstractGraph)
    P = Layout(G, Int[])
    while true
        P = greedy_exact(G, P)
        if !isempty(P.neighbors)
            P = greedy_step(G, P, P.neighbors)
        elseif !isempty(P.disconnected)
            P = greedy_step(G, P, P.disconnected)
        else
            break
        end
    end
    return P
end

function greedy_step(G, P, list)
    layouts = [⊙(G, P, v) for v in list]
    costs = vsep.(layouts)
    best_cost = minimum(costs)
    return layouts[rand(findall(==(best_cost), costs))]
end