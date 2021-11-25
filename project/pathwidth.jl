using Graphs

# determine the pathwidth of a given graph 
# output ordering and bins 
function pathwidth(G::SimpleGraph)
    bags = Vector{Int}[]
    ordering = Int[]
    
    B1 = Int[]
    
    list_vertices = collect(vertices(G))
    list_edges = [(e.src, e.dst) for e in edges(G)]
    
    v = list_vertices[1]
    push!(B1, v)
    push!(bags, B1)
    push!(ordering, v)
    
    pathwidth = 0
    
    while length(list_edges) > 0
        add_v = nothing
        remove_edge = nothing
        
        B2 = Int[]
        
        # find vertices that no longer have edges 
        for v in B1
            push!(B2, v)
            for w in neighbors(G, v)
                if add_v === nothing
                    e1 = (v, w)
                    e2 = (w, v)
                    if e1 in list_edges
                        add_v = w 
                        remove_edge = e1
                    elseif e2 in list_edges
                        add_v = w
                        remove_edge = e2
                    end
                end
            end
            # no more edges in edge list for v 
            if add_v === nothing
                deleteat!(B2, findall(==(v), B2))
            end
            println("B1: ", B1)
        end
            

        if add_v !== nothing
            if !(add_v in B1)
                # add add_v to B2 
                push!(B2,add_v)
                push!(ordering, add_v)
            end
            deleteat!(list_edges, findfirst(==(remove_edge), list_edges))
        end

        B1 = B2 
        push!(bags,B1)
        if length(B1) > pathwidth
            pathwidth = length(B1)
        end
        print(bags)
    end
    
    return ordering, bags, pathwidth
end

pathwidth(smallgraph(:petersen))