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
* cross_location
* source: (locs, graph, pins/auto)
* mapped: (locs, graph/auto, pins/auto)

### Requires
1. equivalence in MIS-compact tropical tensor (you can check it with tests),
2. the size is <= [-2, 2] x [-2, 2] at the cross (not checked, requires cross offset information),
3. ancillas does not appear at the boundary (not checked),
"""
abstract type CrossPattern <: Pattern end

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
    a = fill(empty(Cell), m, n)
    for (i, j) in locs
        add_cell!(a, i, j)
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

function connect!(m, p::Pattern)
    for (i, j) in connect_locations(p)
        connect_cell!(m, i, j)
    end
    return m
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
    g = simplegraph([(1,2), (2,3), (4,5), (5,6), (1,6)])
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
cross_location(::Cross{true}) = (2,2)
connect_locations(::Cross{true}) = [(2, 1), (3,2)]

# ⋅ ⋅ ● ⋅ ⋅ 
# ● ● ◉ ● ● 
# ⋅ ⋅ ● ⋅ ⋅ 
# ⋅ ⋅ ● ⋅ ⋅ 
function source_graph(::Cross{false})
    locs = [(2,1), (2,2), (2,3), (2,4), (2,5), (1,3), (2,3), (3,3), (4,3)]
    g = simplegraph([(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9)])
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
cross_location(::Cross{false}) = (2,3)

struct Turn <: CrossPattern end
iscon(::Turn) = false
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ● ● 
# ⋅ ⋅ ⋅ ⋅
function source_graph(::Turn)
    locs = [(1,2), (2,2), (3,2), (3,3), (3,4)]
    g = simplegraph([(1,2), (2,3), (3,4), (4,5)])
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
cross_location(::Turn) = (3,2)


export Branch, TrivialTurn, BranchFix, WTurn, TCon, BranchFixB
struct Branch <: CrossPattern end
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ● ● 
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅
function source_graph(::Branch)
    locs = [(1,2), (2,2), (3,2),(3,3),(3,4),(4,3),(4,2),(5,2)]
    g = simplegraph([(1,2), (2,3), (3, 4), (4,5), (4,6), (6,7), (7,8)])
    return locs, g, [1, 5, 8]
end
# ⋅ ● ⋅ ⋅ 
# ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ● 
# ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ⋅
function mapped_graph(::Branch)
    locs = [(1,2), (2,3), (3,2),(3,4),(4,3),(5,2)]
    return locs, unitdisk_graph(locs, 1.5), [1,4,6]
end
Base.size(::Branch) = (5, 4)
cross_location(::Branch) = (3,2)
iscon(::Branch) = false

struct BranchFix <: CrossPattern end
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ● ⋅
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅
function source_graph(::BranchFix)
    locs = [(1,2), (2,2), (2,3),(3,3),(3,2),(4,2)]
    g = simplegraph([(1,2), (2,3), (3,4),(4,5), (5,6)])
    return locs, g, [1, 6]
end
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅
# ⋅ ● ⋅ ⋅ 
function mapped_graph(::BranchFix)
    locs = [(1,2),(2,2),(3,2),(4,2)]
    return locs, unitdisk_graph(locs, 1.5), [1, 4]
end
Base.size(::BranchFix) = (4, 4)
cross_location(::BranchFix) = (2,2)
iscon(::BranchFix) = false

struct WTurn <: CrossPattern end
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ● ● 
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅
function source_graph(::WTurn)
    locs = [(2,3), (2,4), (3,2),(3,3),(4,2)]
    g = simplegraph([(1,2), (1,4), (3,4),(3,5)])
    return locs, g, [2, 5]
end
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ⋅ ● 
# ⋅ ⋅ ● ⋅ 
# ⋅ ● ⋅ ⋅
function mapped_graph(::WTurn)
    locs = [(2,4),(3,3),(4,2)]
    return locs, unitdisk_graph(locs, 1.5), [1, 3]
end
Base.size(::WTurn) = (4, 4)
cross_location(::WTurn) = (2,2)
iscon(::WTurn) = false

struct BranchFixB <: CrossPattern end
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ● ⋅
# ⋅ ● ● ⋅ 
# ⋅ ● ⋅ ⋅
function source_graph(::BranchFixB)
    locs = [(2,3),(3,3),(3,2),(4,2)]
    g = simplegraph([(1,3), (2,3), (2,4)])
    return locs, g, [1, 4]
end
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ⋅ ⋅ ⋅ 
# ⋅ ● ⋅ ⋅
# ⋅ ● ⋅ ⋅ 
function mapped_graph(::BranchFixB)
    locs = [(3,2),(4,2)]
    return locs, unitdisk_graph(locs, 1.5), [1, 2]
end
Base.size(::BranchFixB) = (4, 4)
cross_location(::BranchFixB) = (2,2)
iscon(::BranchFixB) = false


struct TCon <: CrossPattern end
# ⋅ ◆ ⋅ ⋅
# ◆ ● ⋅ ⋅ 
# ⋅ ● ⋅ ⋅
function source_graph(::TCon)
    locs = [(1,2), (2,1), (2,2),(3,2)]
    g = simplegraph([(1,2), (1,3), (3,4)])
    return locs, g, [1,2,4]
end
connect_locations(::TCon) = [(1,2), (2,1)]

# ⋅ ● ⋅ ⋅
# ● ⋅ ● ⋅
# ⋅ ● ⋅ ⋅
function mapped_graph(::TCon)
    locs = [(1,2),(2,1),(2,3),(3,2)]
    return locs, unitdisk_graph(locs, 1.5), [1,2,4]
end
Base.size(::TCon) = (3,4)
cross_location(::TCon) = (2,2)
iscon(::TCon) = true

struct TrivialTurn <: CrossPattern end
# ⋅ ◆
# ◆ ⋅
function source_graph(::TrivialTurn)
    locs = [(1,2), (2,1)]
    g = simplegraph([(1,2)])
    return locs, g, [1,2]
end
# ⋅ ●
# ● ⋅
function mapped_graph(::TrivialTurn)
    locs = [(1,2),(2,1)]
    return locs, unitdisk_graph(locs, 1.5), [1,2]
end
Base.size(::TrivialTurn) = (2,2)
cross_location(::TrivialTurn) = (2,2)
iscon(::TrivialTurn) = true
connect_locations(::TrivialTurn) = [(1,2), (2,1)]

############## Rotation and Flip ###############
export RotatedGadget, ReflectedGadget
struct RotatedGadget{GT} <: Pattern
    gadget::GT
    n::Int
end
function Base.size(r::RotatedGadget)
    m, n = size(r.gadget)
    return r.n%2==0 ? (m, n) : (n, m)
end
struct ReflectedGadget{GT} <: Pattern
    gadget::GT
    mirror::String
end
function Base.size(r::ReflectedGadget)
    m, n = size(r.gadget)
    return r.mirror == "x" || r.mirror == "y" ? (m, n) : (n, m)
end

for T in [:RotatedGadget, :ReflectedGadget]
    @eval function source_graph(r::$T)
        locs, graph, pins = source_graph(r.gadget)
        center = cross_location(r.gadget)
        locs = map(loc->loc .+ _get_offset(r), _apply_transform(r, locs, center))
        return locs, graph, pins
    end
    @eval function mapped_graph(r::$T)
        locs, graph, pins = mapped_graph(r.gadget)
        center = cross_location(r.gadget)
        locs = map(loc->loc .+ _get_offset(r), _apply_transform(r, locs, center))
        return locs, graph, pins
    end
    @eval cross_location(r::$T) = cross_location(r.gadget) .+ _get_offset(r)
    @eval function _get_offset(r::$T)
        m, n = size(r.gadget)
        a, b = _apply_transform(r, [(1,1), (m,n)], cross_location(r.gadget))
        return 1-min(a[1], b[1]), 1-min(a[2], b[2])
    end
    @eval iscon(r::$T) = iscon(r.gadget)
    @eval function connect_locations(r::$T)
        center = cross_location(r.gadget)
        return map(loc->loc .+ _get_offset(r), _apply_transform(r, connect_locations(r.gadget), center))
    end
    @eval vertex_overhead(p::$T) = vertex_overhead(p.gadget)
    @eval function mapped_entry_to_compact(r::$T)
        return mapped_entry_to_compact(r.gadget)
    end
    @eval function source_entry_to_configs(r::$T)
        return source_entry_to_configs(r.gadget)
    end
    @eval mis_overhead(p::$T) = mis_overhead(p.gadget)
end

function _apply_transform(r::RotatedGadget, locs, center)
    return map(locs) do loc
        for _=1:r.n
            loc = rotate90(loc, center)
        end
        loc
    end
end

function _apply_transform(r::ReflectedGadget, locs, center)
    return map(locs) do loc
        if r.mirror == "x"
            reflectx(loc, center)
        elseif r.mirror == "y"
            reflecty(loc, center)
        elseif r.mirror == "diag"
            reflectdiag(loc, center)
        elseif r.mirror == "offdiag"
            reflectoffdiag(loc, center)
        else
            throw(ArgumentError("reflection direction $(r.direction) is not defined!"))
        end
    end
end

export vertex_overhead
function vertex_overhead(p::Pattern)
    nv(mapped_graph(p)[2]) - nv(source_graph(p)[1])
end

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