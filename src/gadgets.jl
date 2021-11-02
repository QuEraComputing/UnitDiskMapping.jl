abstract type Pattern end
struct TShape{VH,CON} <: Pattern end
struct Corner{CON} <: Pattern end
struct Turn <: Pattern end
struct Cross{CON} <: Pattern end
iscon(::TShape{VH,CON}) where {VH, CON} = CON
iscon(::Corner{CON}) where {CON} = CON
iscon(::Cross{CON}) where {CON} = CON
iscon(::Turn) = false

export source_matrix, mapped_matrix
function source_matrix(p::Pattern)
    locs, graph, openvertices = source_graph(p)
    return locs2matrix(locs, openvertices, iscon(p))
end

function mapped_matrix(p::Pattern)
    locs, graph, openvertices = mapped_graph(p)
    return locs2matrix(locs, openvertices, iscon(p))
end

function locs2matrix(locs::AbstractVector{Tuple{Int,Int}}, openvertices, iscon)
    m, n, dx, dy = _size_shift(locs, openvertices)
    a = zeros(Int, m, n)
    for (i, j) in locs
        a[i+dx, j+dy] += 1
        if a[i+dx, j+dy] == 2 && iscon
            a[i+dx, j+dy] = -2
        end
    end
    return a
end

function Base.match(p::Pattern, matrix, i, j)
    a = source_matrix(p)
    m, n = size(a)
    all(ci->safe_get(matrix, i+ci.I[1]-1, j+ci.I[2]-1) == a[ci], CartesianIndices((m, n)))
end

function safe_get(matrix, i, j)
    m, n = size(matrix)
    (i<1 || i>m || j<1 || j>n) && return 0
    return @inbounds matrix[i, j]
end

function safe_set!(matrix, i, j, val)
    m, n = size(matrix)
    if i<1 || i>m || j<1 || j>n
        @assert val == 0
    else
        @inbounds matrix[i, j] = val
    end
    return val
end


function apply_gadgets!(p, matrix, i, j)
    a = mapped_matrix(p)
    m, n = size(a)
    for ci in CartesianIndices((m, n))
        safe_set!(matrix, i+ci.I[1]-1, i+ci.I[2]-1, a[ci])  # e.g. the Corner gadget requires safe set
    end
    return matrix
end

function Base.size(p::Pattern)
    locs, graph, openvertices = source_graph(p)
    xmax, ymax, xoffset, yoffset = _size_shift(locs, openvertices)
    return xmax+xoffset, ymax+yoffset
end

function _size_shift(locs, openvertices)
    xmin = ymin = 100
    xmax = ymax = 0
    for (i,(x, y)) in enumerate(locs)
        if i ∈ openvertices
            xmax = max(x, xmax)
            ymax = max(y, ymax)
            xmin = min(x, xmin)
            ymin = min(y, ymin)
        else
            xmax = max(x+1, xmax)
            ymax = max(y+1, ymax)
            xmin = min(x-1, xmin)
            ymin = min(y-1, ymin)
        end
    end
    @show xmax, xmin
    return @show xmax-xmin+1, ymax-xmin+1, -xmin+1, -ymin+1
end

function embed_graph(g::SimpleGraph, zoom_level::Int)
    ug = UGrid(nv(g), zoom_level)
    for e in edges(g)
        add_edge!(ug, e.src, e.dst)
    end
    return ug
end

function source_graph(::Cross{false})
    locs = [(1,0), (1,1), (1,2), (1,3), (1,4), (0,2), (1,2), (2,2), (3,2)]
    g = SimpleGraph(9)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6,9,5]
end
function mapped_graph(::Cross{false})
    locs = [(1,0), (1,1), (1,2), (1,3), (1,4), (2,1), (2,2), (2,3), (3,2), (0,2)]
    locs, unitdisk_graph(locs, 1.5), [1,9,10,5]
end
function source_graph(::Cross{true})
    g = SimpleGraph(11)
    locs = [(3,0), (3,1), (3,2), (3,3), (3,4), (0,3), (1,3), (2,3), (3,3), (4,3), (5,3)]
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9), (9,10), (10, 11), (4,9)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6,11,5]
end
function mapped_graph(::Cross{true})
    locs = [(3,0), (2,1), (2,2), (2,3), (3,4), (0,3), (1,2), (3,2), (4,2), (5, 3)]
    locs, unitdisk_graph(locs, 1.5), [1,6,10,5]
end

# ● ◆ ● 
#   ●
function source_graph(::TShape{:H,true})
    locs = [(0,0), (0,1), (0,2), (0,3), (0,4), (2,2), (1,2), (0,2)]
    g = SimpleGraph(8)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (3,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,5,6]
end
# ● ◉ ● 
#   ●
function mapped_graph(::TShape{:H,true})
    locs = [(0, 0), (0,1), (0,3), (0,4), (1,2), (2,2)]
    locs, unitdisk_graph(locs, 1.5), [1, 4, 6]
end

function source_graph(::TShape{:H,false}) where VH
    locs = [(2,0), (2,1), (2,2), (2,3), (2,4), (0,2), (1,2), (2,2)]
    g = SimpleGraph(8)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,5,8]
end
function mapped_graph(::TShape{:H,false})
    locs = [(2, 0), (2,1), (2,3), (2,4), (2,2), (0,2)]
    locs, unitdisk_graph(locs, 1.5), [1, 4, 6]
end

function source_graph(::TShape{:V,C}) where C
    locs, graph, pins = source_graph(TShape{:H,C}())
    map(x->(x[2], 2-x[1]), locs), graph, pins
end

function mapped_graph(::TShape{:V,C}) where C
    locs, graph, pins = mapped_graph(TShape{:H,C}())
    map(x->(x[2], 2-x[1]), locs), graph, pins
end

function source_graph(::Turn)
    locs = [(0,0), (1,0), (2,0), (2,1), (2,2)]
    g = SimpleGraph(5)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,5]
end
function mapped_graph(::Turn)
    locs = [(0,0), (1,1), (2,2)]
    locs, unitdisk_graph(locs, 1.5), [1,3]
end

function source_graph(::Corner{true})
    locs = [(0,0), (0,1), (0,2), (0,2), (1,2), (2,2)]
    g = SimpleGraph(6)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (5,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6]
end
function mapped_graph(::Corner{true})
    locs = [(0,0), (0,1), (1,2), (2,2)]
    locs, unitdisk_graph(locs, 1.5), [1,4]
end
function source_graph(::Corner{false})
    locs = [(0,0), (0,1), (0,2), (0,2), (1,2), (2,2)]
    g = SimpleGraph(6)
    for (i,j) in [(1,2), (2,3), (4,5), (5,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6]
end
function mapped_graph(::Corner{false})
    locs = [(0,0), (2,2)]
    locs, unitdisk_graph(locs, 1.5), [1,2]
end

export vertex_overhead, mis_overhead
function vertex_overhead(p::Pattern)
    nv(mapped_graph(p)[2]) - nv(source_graph(p)[1])
end

for T in [:TShape, :Cross, :Turn, :(Corner{true})]
    @eval mis_overhead(p::$T) = -1
end
@eval mis_overhead(p::Corner{false}) = -2