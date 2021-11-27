"""
### Provides
1. visualization of mapping
2. the script for generating backward mapping (project/createmap.jl)
3. the script for tikz visualization (project/vizgadget.jl)
"""
abstract type Pattern end
"""
### Properties
* size
* source: (locs, graph, pins/auto)
* mapped: (locs, graph/auto, pins/auto)

### Requires
1. equivalence in MIS-compact tropical tensor (you can check it with tests),
2. the size is <= [-2, 2] x [-2, 2] at the cross (not checked, requires cross offset information),
3. ancillas does not appear at the boundary (not checked),
"""
abstract type CrossPattern <: Pattern end
"""
### Properties
* size
* source: (locs, graph/auto, pins/auto)
* mapped: (locs, graph/auto, pins/auto)

### Requires
1. equivalence in MIS-compact tropical tensor (you can check it with tests),
2. ancillas does not appear at the boundary (not checked),
"""
abstract type SimplifyPattern <: Pattern end

export source_matrix, mapped_matrix
function source_matrix(p::Pattern)
    m, n = size(p)
    locs, _, _ = source_graph(p)
    a = locs2matrix(m, n, locs)
    iscon(p) && connect!(a, p)
    return a
end

function mapped_matrix(p::Pattern)
    m, n = size(p)
    locs, _, _ = mapped_graph(p)
    locs2matrix(m, n, locs)
end

function locs2matrix(m, n, locs::AbstractVector{Tuple{Int,Int}})
    a = zeros(Int, m, n)
    for (i, j) in locs
        a[i, j] += 1
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

Base.show(io::IO, ::MIME"text/plain", p::Pattern) = Base.show(io, p)
function Base.show(io::IO, p::Pattern)
    print_ugrid(io, source_matrix(p))
    println(io)
    println(io, " "^(size(p)[2]-1) * "↓")
    print_ugrid(io, mapped_matrix(p))
end

function apply_gadget!(p::Pattern, matrix, i, j)
    a = mapped_matrix(p)
    m, n = size(a)
    for ci in CartesianIndices((m, n))
        safe_set!(matrix, i+ci.I[1]-1, j+ci.I[2]-1, a[ci])  # e.g. the Truncated gadget requires safe set
    end
    return matrix
end

function unapply_gadget!(p, matrix, i, j)
    a = source_matrix(p)
    m, n = size(a)
    for ci in CartesianIndices((m, n))
        safe_set!(matrix, i+ci.I[1]-1, j+ci.I[2]-1, a[ci])  # e.g. the Truncated gadget requires safe set
    end
    return matrix
end

struct Cross{CON} <: CrossPattern end
iscon(::Cross{CON}) where {CON} = CON
# ⋅ ● ⋅ 
# ◆ ◉ ● 
# ⋅ ◆ ⋅ 
function source_graph(::Cross{true})
    locs = [(2,1), (2,2), (2,3), (1,2), (2,2), (3,2)]
    g = SimpleGraph(6)
    for (i,j) in [(1,2), (2,3), (4,5), (5,6), (1,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,4,6,3]
end

# ⋅ ● ⋅ 
# ● ● ● 
# ⋅ ● ⋅ 
function mapped_graph(::Cross{true})
    locs = [(2,1), (2,2), (2,3), (1,2), (3,2)]
    locs, unitdisk_graph(locs, 1.5), [1,4,5,3]
end
Base.size(::Cross{true}) = (3, 3)
function connect!(m, ::Cross{true})
    m[2,1] *= -1
    m[3,2] *= -1
    return m
end

# ⋅ ⋅ ● ⋅ ⋅ 
# ● ● ◉ ● ● 
# ⋅ ⋅ ● ⋅ ⋅ 
# ⋅ ⋅ ● ⋅ ⋅ 
function source_graph(::Cross{false})
    g = SimpleGraph(9)
    locs = [(2,1), (2,2), (2,3), (2,4), (2,5), (1,3), (2,3), (3,3), (4,3)]
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,6,9,5]
end

# ⋅ ⋅ ● ⋅ ⋅ 
# ● ● ● ● ● 
# ⋅ ● ● ● ⋅ 
# ⋅ ⋅ ● ⋅ ⋅ 
function mapped_graph(::Cross{false})
    locs = [(2,1), (2,2), (2,3), (2,4), (2,5), (1,3), (3,3), (4,3), (3, 2), (3,4)]
    locs, unitdisk_graph(locs, 1.5), [1,6,8,5]
end
Base.size(::Cross{false}) = (4, 5)

struct TShape{CON} <: CrossPattern end
iscon(::TShape{CON}) where {CON} = CON
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ● ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅
function source_graph(::TShape{false})
    locs = [(3, 1), (1,2), (2,2), (3,2), (4,2), (5,2)]
    g = SimpleGraph(6)
    for (i,j) in [(2,3), (3,4), (4,5), (5,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,2,6]
end

# ⋅ ● ⋅ ⋅ 
# ⋅ ⋅ ● ⋅ 
# ● ⋅ ● ⋅ 
# ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ⋅
function mapped_graph(::TShape{false})
    locs = [(3, 1), (1,2), (2,3), (3,3), (4,3), (5,2)]
    locs, unitdisk_graph(locs, 1.5), [1, 2, 6]
end
Base.size(::TShape{false}) = (5, 4)

#   ●
#   ●
# ◆ ● 
#   ◆
function source_graph(::TShape{true})
    locs = [(3, 1), (1,2), (2,2), (3,2), (4,2)]
    g = SimpleGraph(5)
    for (i,j) in [(1,5), (2,3), (3,4), (4,5)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,2,5]
end
#   ●
#     ●
# ●   ● 
#   ●
function mapped_graph(::TShape{true})
    locs = [(3, 1), (1,2), (2,3), (3,3), (4,2)]
    locs, unitdisk_graph(locs, 1.5), [1, 2, 5]
end
function connect!(m, ::TShape{true})
    m[3,1] *= -1
    m[4,2] *= -1
    return m
end
Base.size(::TShape{true}) = (4, 4)

struct Turn <: CrossPattern end
iscon(::Turn) = false
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ● ● 
# ⋅ ⋅ ⋅ ⋅
function source_graph(::Turn)
    locs = [(1,2), (2,2), (3,2), (3,3), (3,4)]
    g = SimpleGraph(5)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,5]
end

# ⋅ ● ⋅ ⋅ 
# ⋅ ⋅ ● ⋅ 
# ⋅ ⋅ ⋅ ● 
# ⋅ ⋅ ⋅ ⋅
function mapped_graph(::Turn)
    locs = [(1,2), (2,3), (3,4)]
    locs, unitdisk_graph(locs, 1.5), [1,3]
end
Base.size(::Turn) = (4, 4)


struct Branch end
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ● ● 
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅
function source_graph(::Branch)
end
# ⋅ ● ⋅ ⋅ 
# ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ● 
# ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ⋅
function mapped_graph(::Branch)
end

struct BigTurn end
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ● ● 
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅
function source_graph(::BigTurn)
end
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ⋅ ● 
# ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ⋅
function mapped_graph(::BigTurn)
end

struct SmallTurn end
# ⋅ ⋅ ⋅
# ⋅ ● ⋅
# ⋅ ● ●
# ⋅ ⋅ ⋅
function source_graph(::SmallTurn)
end
# ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅
# ⋅ ⋅ ●
# ⋅ ⋅ ⋅
function mapped_graph(::SmallTurn)
end

############## Rotation and Flip ###############
#   ◆
# ◆ ● 
#   ●
#   ●

# ⋅ ◆ ⋅ ⋅
# ◆ ● ● ●

# ⋅ ◆ ⋅ 
# ◆ ◉ ● 
# ⋅ ● ⋅ 

struct TrivialTurn end
# ⋅ ◆
# ◆ ⋅
function source_graph(::TrivialTurn)
end
# ⋅ ●
# ● ⋅
function mapped_graph(::TrivialTurn)
end

export vertex_overhead, mis_overhead
function vertex_overhead(p::Pattern)
    nv(mapped_graph(p)[2]) - nv(source_graph(p)[1])
end

for T in [:Cross, :Turn]
    @eval mis_overhead(p::$T) = -1
end
@eval mis_overhead(p::TShape) = 0

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