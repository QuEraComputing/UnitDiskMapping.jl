function simplegraph(edgelist::AbstractVector{Tuple{Int,Int}})
    nv = maximum(x->max(x...), edgelist)
    g = SimpleGraph(nv)
    for (i,j) in edgelist
        add_edge!(g, i, j)
    end
    return g
end

for OP in [:rotate90, :reflectx, :reflecty, :reflectdiag, :reflectoffdiag]
    @eval function $OP(loc, center)
        dx, dy = $OP(loc .- center)
        return (center[1]+dx, center[2]+dy)
    end
end

function rotate90(loc)
    return -loc[2], loc[1]
end
function reflectx(loc)
    loc[1], -loc[2]
end
function reflecty(loc)
    -loc[1], loc[2]
end
function reflectdiag(loc)
    -loc[2], -loc[1]
end
function reflectoffdiag(loc)
    loc[2], loc[1]
end