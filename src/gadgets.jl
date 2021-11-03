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
    m, n = size(p)
    locs, _, _, _ = source_graph(p)
    return locs2matrix(m, n, locs, iscon(p))
end

function mapped_matrix(p::Pattern)
    m, n = size(p)
    locs, _, _ = mapped_graph(p)
    return locs2matrix(m, n, locs, iscon(p))
end

function locs2matrix(m, n, locs::AbstractVector{Tuple{Int,Int}}, iscon)
    a = zeros(Int, m, n)
    for (i, j) in locs
        a[i, j] += 1
        if a[i, j] == 2 && iscon
            a[i, j] = -2
        end
    end
    return a
end

function Base.match(p::Pattern, matrix, i, j)
    a = source_matrix(p)
    m, n = size(a)
    all(ci->safe_get(matrix, i+ci.I[1]-1, j+ci.I[2]-1) == a[ci], CartesianIndices((m, n)))
end

function unmatch(p::Pattern, matrix, i, j)
    a = mapped_matrix(p)
    m, n = size(a)
    all(ci->safe_get(matrix, i+ci.I[1]-1, j+ci.I[2]-1) == a[ci], CartesianIndices((m, n)))
end

function safe_get(matrix, i, j)
    m, n = size(matrix)
    (i<1 || i>m || j<1 || j>n) && return 0
    return matrix[i, j]
end

function safe_set!(matrix, i, j, val)
    m, n = size(matrix)
    if i<1 || i>m || j<1 || j>n
        @assert val == 0
    else
        matrix[i, j] = val
    end
    return val
end


function apply_gadget!(p::Pattern, matrix, i, j)
    a = mapped_matrix(p)
    m, n = size(a)
    for ci in CartesianIndices((m, n))
        safe_set!(matrix, i+ci.I[1]-1, j+ci.I[2]-1, a[ci])  # e.g. the Corner gadget requires safe set
    end
    return matrix
end

function unapply_gadget!(p, matrix, i, j)
    a = source_matrix(p)
    m, n = size(a)
    for ci in CartesianIndices((m, n))
        safe_set!(matrix, i+ci.I[1]-1, j+ci.I[2]-1, a[ci])  # e.g. the Corner gadget requires safe set
    end
    return matrix
end

function embed_graph(g::SimpleGraph, zoom_level::Int)
    ug = UGrid(nv(g), zoom_level)
    for e in edges(g)
        add_edge!(ug, e.src, e.dst)
    end
    return ug
end

function source_graph(::Cross{false})
    locs = [(2,1), (2,2), (2,3), (2,4), (2,5), (1,3), (2,3), (3,3), (4,3)]
    g = SimpleGraph(9)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6,9,5], [2,2,2,2,2,1,1,1,1]
end
function mapped_graph(::Cross{false})
    locs = [(2,1), (2,2), (2,3), (2,4), (2,5), (3,2), (3,3), (3,4), (4,3), (1,3)]
    locs, unitdisk_graph(locs, 1.5), [1,9,10,5]
end
Base.size(::Cross{false}) = (4, 5)
function source_graph(::Cross{true})
    g = SimpleGraph(11)
    locs = [(4,1), (4,2), (4,3), (4,4), (4,5), (1,4), (2,4), (3,4), (4,4), (5,4), (6,4)]
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9), (9,10), (10, 11), (4,9)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6,11,5], [2,2,2,2,2,1,1,1,1,1,1]
end
function mapped_graph(::Cross{true})
    locs = [(4,1), (3,2), (3,3), (3,4), (4,5), (1,4), (2,3), (4,3), (5,3), (6, 4)]
    locs, unitdisk_graph(locs, 1.5), [1,6,10,5]
end
Base.size(::Cross{true}) = (6, 5)

# ● ◆ ● 
#   ●
function source_graph(::TShape{:H,true})
    locs = [(2,1), (2,2), (2,3), (2,4), (2,5), (4,3), (3,3), (2,3)]
    g = SimpleGraph(8)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (3,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,5,6], [2,2,2,2,2,1,1,1]
end
# ● ◉ ● 
#   ●
function mapped_graph(::TShape{:H,true})
    locs = [(2, 1), (2,2), (2,4), (2,5), (3,3), (4,3)]
    locs, unitdisk_graph(locs, 1.5), [1, 4, 6]
end
Base.size(::TShape{:V}) = (5, 4)

function source_graph(::TShape{:H,false}) where VH
    locs = [(2,1), (2,2), (2,3), (2,4), (2,5), (4,3), (3,3), (2,3)]
    g = SimpleGraph(8)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,5,6], [2,2,2,2,2,1,1,1]
end
function mapped_graph(::TShape{:H,false})
    locs = [(2, 1), (2,2), (2,4), (2,5), (2,3), (4,3)]
    locs, unitdisk_graph(locs, 1.5), [1, 4, 6]
end
Base.size(::TShape{:H}) = (4, 5)

function source_graph(::TShape{:V,C}) where C
    locs, graph, pins, belongs = source_graph(TShape{:H,C}())
    map(x->(x[2], 5-x[1]), locs), graph, pins, belongs
end

function mapped_graph(::TShape{:V,C}) where C
    locs, graph, pins = mapped_graph(TShape{:H,C}())
    map(x->(x[2], 5-x[1]), locs), graph, pins
end

function source_graph(::Turn)
    locs = [(1,2), (2,2), (3,2), (3,3), (3,4)]
    g = SimpleGraph(5)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,5], [1,1,1,2,2]
end
function mapped_graph(::Turn)
    locs = [(1,2), (2,3), (3,4)]
    locs, unitdisk_graph(locs, 1.5), [1,3]
end
Base.size(::Turn) = (4, 4)

function source_graph(::Corner{true})
    locs = [(2,1), (2,2), (2,3), (2,3), (3,3), (4,3)]
    g = SimpleGraph(6)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (5,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6], [2,2,2,1,1,1]
end
function mapped_graph(::Corner{true})
    locs = [(2,1), (2,2), (3,3), (4,3)]
    locs, unitdisk_graph(locs, 1.5), [1,4]
end
function source_graph(::Corner{false})
    locs = [(2,1), (2,2), (2,3), (2,3), (3,3), (4,3)]
    g = SimpleGraph(6)
    for (i,j) in [(1,2), (2,3), (4,5), (5,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6], [2,2,2,1,1,1]
end
function mapped_graph(::Corner{false})
    locs = [(2,1), (4,3)]
    locs, unitdisk_graph(locs, 1.5), [1,2]
end
Base.size(::Corner) = (4, 4)

export vertex_overhead, mis_overhead
function vertex_overhead(p::Pattern)
    nv(mapped_graph(p)[2]) - nv(source_graph(p)[1])
end

for T in [:TShape, :Cross, :Turn, :(Corner{true})]
    @eval mis_overhead(p::$T) = -1
end
@eval mis_overhead(p::Corner{false}) = -2

export mapped_boundary_config, source_boundary_config
function mapped_boundary_config(p::Pattern, config)
    _boundary_config(mapped_graph(p)[3], config)
end
function source_boundary_config(p::Pattern, config)
    _boundary_config(source_graph(p)[3], config)
end
function _boundary_config(pins, config)
    res = 0
    for (i,p) in enumerate(pins)
        res += Int(config[p]) << (i-1)
    end
    return res
end