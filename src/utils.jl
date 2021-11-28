export is_independent_set, unitdisk_graph

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

function unitdisk_graph(locs::AbstractVector, unit::Real)
    n = length(locs)
    g = SimpleGraph(n)
    for i=1:n, j=i+1:n
        if sum(abs2, locs[i] .- locs[j]) < unit ^ 2
            add_edge!(g, i, j)
        end
    end
    return g
end

function is_independent_set(g::SimpleGraph, config)
    for e in edges(g)
        if config[e.src] == config[e.dst] == 1
            return false
        end
    end
    return true
end

function is_diff_by_const(t1::AbstractArray{T}, t2::AbstractArray{T}) where T <: Real
    x = NaN
    for (a, b) in zip(t1, t2)
        if isinf(a) && isinf(b)
            continue
        end
        if isinf(a) || isinf(b)
            return false, 0
        end
        if isnan(x)
            x = (a - b)
        elseif x != a - b
            return false, 0
        end
    end
    return true, x
end
