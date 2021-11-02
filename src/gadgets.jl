abstract type Pattern end
struct TShape{VH,CON} <: Pattern end
struct Corner{CON} <: Pattern end
struct Turn <: Pattern end
struct Cross{CON} <: Pattern end
iscon(::TShape{VH,CON}) where {VH, CON} = CON
iscon(::Corner{CON}) where {CON} = CON
iscon(::Cross{CON}) where {CON} = CON

function Base.match(::Cross{false}, matrix, i, j)  # needs additional check to detect environment
    matrix[i, j] == 2 || return false
    if j<3 || j>size(matrix, 2)-2 || i<2 || i > size(matrix, 1)-2
        return false
    end
    @inbounds for j_=j-2:j+2
        for i_=i-1:i+2
            if i_ == i
                if j_ != j
                    matrix[i_, j_] == 2*iseven(j-j_)-1 || return false
                end
            elseif j==j_
                matrix[i_, j_] == 2*iseven(i-i_)-1 || return false
            else
                matrix[i_, j_] == 0 || return false
            end
        end
    end
    return true
end

function Base.match(::Cross{true}, matrix, i, j)  # needs additional check to detect environment
    matrix[i, j] == -2 || return false
    if j<4 || j>size(matrix, 2)-1 || i<4 || i > size(matrix, 1)-2
        return false
    end
    for j_=j-3:j+1
        for i_=i-3:i+2
            if i_ == i
                if j_ != j
                    abs(matrix[i_, j_]) == 1 || return false
                end
            elseif j==j_
                abs(matrix[i_, j_]) == 1 || return false
            else
                matrix[i_, j_] == 0 || return false
            end
        end
    end
    return true
end

function Base.match(s::TShape{:H}, matrix, i, j)
    matrix[i, j] == (iscon(s) ? -2 : 2) || return false
    i==1 && j!=1 && j!=size(matrix, 2) || return false
    return abs(matrix[1,j-1]) == abs(matrix[1,j+1]) == abs(matrix[2,j]) == 1 && matrix[2,j+1] == matrix[2,j-1] == 0
end

function Base.match(s::TShape{:V}, matrix, i, j)
    matrix[i, j] == (iscon(s) ? -2 : 2) || return false
    j==size(matrix, 2) && i!=1 && i!=size(matrix, 1) || return false
    return abs(matrix[i-1,end]) == abs(matrix[i+1,end]) == abs(matrix[i,end-1]) == 1 && matrix[i+1,end-1] == matrix[i-1,end-1] == 0
end

function Base.match(::Turn, matrix, i, j)
    i >= 3 && j<=size(matrix, 2)-2 || return false
    for i_=i-2:i
        for j_=j:j+2
            if i_ == i || j_ == j
                abs(matrix[i_,j_]) == 1 || return false
            else
                matrix[i_,j_] == 0 || return false
            end
        end
    end
    return true
end

function Base.match(s::Corner, matrix, i, j)
    j == size(matrix, 2) && i==1 || return false
    for j_=j-2:j
        for i_=i:i+2
            if i_ == i && j_ == j
                matrix[i_, j_] == (iscon(s) ? -2 : 2) || return false
            elseif i_ == i || j_ == j
                abs(matrix[i_,j_]) == 1 || return false
            else
                matrix[i_,j_] == 0 || return false
            end
        end
    end
    return true
end

#   1
# 2-o-2
#   2
function apply_gadget!(::Cross{false}, matrix, i, j)
    matrix[i, j] = -1
    matrix[i-1, j] = -1
    matrix[i+1, j-1] = -1
    matrix[i+1, j+1] = -1
    return matrix
end

#   3
# 3-o-1
#   2
function apply_gadget!(::Cross{true}, matrix, i, j)
    matrix[i, j-2] = 0
    matrix[i, j] = 0
    matrix[i-2, j] = 0
    matrix[i+1, j] = 0
    matrix[i-1,j-2] = -1
    matrix[i-2,j-1] = -1
    matrix[i-1,j-1] = -1
    matrix[i+1,j-1] = -1
    return matrix
end

# 1-o-1
#   1
function apply_gadget!(::TShape{:H, false}, matrix, i, j)
    matrix[i, j] = -1
    matrix[i+1, j] = 0
    return matrix
end
function apply_gadget!(::TShape{:H, true}, matrix, i, j)
    matrix[i, j] = 0
    return matrix
end

#   1
# 1-o
#   1
function apply_gadget!(::TShape{:V, false}, matrix, i, j)
    matrix[i, j] = -1
    matrix[i, j-1] = 0
    return matrix
end
function apply_gadget!(::TShape{:V, true}, matrix, i, j)
    matrix[i, j] = 0
    return matrix
end

#  2
#  o2
function apply_gadget!(::Turn, matrix, i, j)
    matrix[i, j] = 0
    matrix[i-1, j] = 0
    matrix[i, j+1] = 0
    matrix[i-1, j+1] = -1
    return matrix
end

#  2
#  o2
function apply_gadget!(::Corner{false}, matrix, i, j)
    matrix[i, j] = 0
    matrix[i+1, j] = 0
    matrix[i, j-1] = 0
    return matrix
end

function apply_gadget!(::Corner{true}, matrix, i, j)
    matrix[i, j] = 0
    return matrix
end

using Graphs

function embed_graph(g::SimpleGraph, zoom_level::Int)
    ug = UGrid(nv(g), zoom_level)
    for e in edges(g)
        add_edge!(ug, e.src, e.dst)
    end
    return ug
end

function source_graph(::Cross{false})
    locs = [(0,1), (1,1), (1,2), (1,3), (1,4), (0,2), (1,2), (2,2), (3,2)]
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

function source_graph(::TShape{:H,true})
    locs = [(2,0), (2,1), (2,2), (2,3), (2,4), (0,2), (1,2), (2,2)]
    g = SimpleGraph(8)
    for (i,j) in [(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (3,6)]
        add_edge!(g, i, j)
    end
    return locs, g, [1,5,8]
end
function mapped_graph(::TShape{:H,true})
    locs = [(2, 0), (2,1), (2,3), (2,4), (1,2), (0,2)]
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
    map(x->(x[2], x[1]), locs), graph, pins
end

function mapped_graph(::TShape{:V,C}) where C
    locs, graph, pins = mapped_graph(TShape{:H,C}())
    map(x->(x[2], x[1]), locs), graph, pins
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