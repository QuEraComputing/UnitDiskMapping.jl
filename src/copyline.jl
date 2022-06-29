#    vslot
#      ↓
#      |          ← vstart
#      |
#      |-------   ← hslot
#      |      ↑   ← vstop
#            hstop
struct CopyLine
    vertex::Int
    vslot::Int
    hslot::Int
    vstart::Int
    vstop::Int
    hstop::Int  # there is no hstart
end
function Base.show(io::IO, cl::CopyLine)
    print(io, "$(typeof(cl)) $(cl.vertex): vslot → [$(cl.vstart):$(cl.vstop),$(cl.vslot)], hslot → [$(cl.hslot),$(cl.vslot):$(cl.hstop)]")
end
Base.show(io::IO, ::MIME"text/plain", cl::CopyLine) = Base.show(io, cl)

# create copy lines using path decomposition
# `g` is the graph,
# `ordered_vertices` is a vector of vertices.
function create_copylines(g::SimpleGraph, ordered_vertices::AbstractVector{Int})
    slots = zeros(Int, nv(g))
    hslots = zeros(Int, nv(g))
    rmorder = remove_order(g, ordered_vertices)
    # assign hslots
    for (i, (v, rs)) in enumerate(zip(ordered_vertices, rmorder))
        # update slots
        islot = findfirst(iszero, slots)
        slots[islot] = v
        hslots[i] = islot
        for r in rs
            slots[findfirst(==(r), slots)] = 0
        end
    end
    vstarts = zeros(Int, nv(g))
    vstops = zeros(Int, nv(g))
    hstops = zeros(Int, nv(g))
    for (i, v)  in enumerate(ordered_vertices)
        relevant_hslots = [hslots[j] for j=1:i if has_edge(g, ordered_vertices[j], v) || v == ordered_vertices[j]]
        relevant_vslots = [i for i=1:nv(g) if has_edge(g, ordered_vertices[i], v) || v == ordered_vertices[i]]
        vstarts[i] = minimum(relevant_hslots)
        vstops[i] = maximum(relevant_hslots)
        hstops[i] = maximum(relevant_vslots)
    end
    return [CopyLine(ordered_vertices[i], i, hslots[i], vstarts[i], vstops[i], hstops[i]) for i=1:nv(g)]
end

# -1 means no line
struct Block
    top::Int
    bottom::Int
    left::Int
    right::Int
    connected::Int # -1 for not exist, 0 for not, 1 for yes.
end

Base.show(io::IO, ::MIME"text/plain", block::Block) = Base.show(io, block)
function Base.show(io::IO, block::Block)
    print(io, "$(get_row_string(block, 1))\n$(get_row_string(block, 2))\n$(get_row_string(block, 3))")
end
function get_row_string(block::Block, i)
    _s(x::Int) = x == -1 ? '⋅' : (x < 10 ? '0'+x : 'a'+(x-10))
    if i == 1
        return " ⋅ $(_s(block.top)) ⋅"
    elseif i==2
        return " $(_s(block.left)) $(block.connected == -1 ? '⋅' : (block.connected == 1 ? '●' : '○')) $(_s(block.right))"
    elseif i==3
        return " ⋅ $(_s(block.bottom)) ⋅"
    end
end

function crossing_lattice(g, ordered_vertices)
    lines = create_copylines(g, ordered_vertices)
    ymin = minimum(l->l.vstart, lines)
    ymax = maximum(l->l.vstop, lines)
    xmin = minimum(l->l.vslot, lines)
    xmax = maximum(l->l.hstop, lines)
    return CrossingLattice(xmax-xmin+1, ymax-ymin+1, lines, g)
end

struct CrossingLattice <: AbstractArray{Block, 2}
    width::Int
    height::Int
    lines::Vector{CopyLine}
    graph::SimpleGraph{Int}
end
Base.size(lattice::CrossingLattice) = (lattice.height, lattice.width)


function Base.getindex(d::CrossingLattice, i::Int, j::Int)
    if !(1<=i<=d.width || 1<=j<=d.height)
        throw(BoundsError(d, (i, j)))
    end
    left = right = top = bottom = -1
    for line in d.lines
        # vertical slot
        if line.vslot == j
            if line.vstart == line.vstop == i   # a row
            elseif line.vstart == i   # starting
                @assert bottom == -1
                bottom = line.vertex
            elseif line.vstop == i   # stopping
                @assert top == -1
                top = line.vertex
            elseif line.vstart < i < line.vstop   # middle
                @assert top == -1
                @assert bottom == -1
                top = bottom = line.vertex
            end
        end
        # horizontal slot
        if line.hslot == i
            if line.vslot == line.hstop == j  # a col
            elseif line.vslot == j
                @assert right == -1
                right = line.vertex
            elseif line.hstop == j
                @assert left == -1
                left = line.vertex
            elseif line.vslot < j < line.hstop
                @assert left == -1
                @assert right == -1
                left = right = line.vertex
            end
        end
    end
    h = left == -1 ? right : left
    v = top == -1 ? bottom : top
    return Block(top, bottom, left, right, (v == -1 || h == -1) ? -1 : has_edge(d.graph, h, v))
end

Base.show(io::IO, ::MIME"text/plain", d::CrossingLattice) = Base.show(io, d)
function Base.show(io::IO, d::CrossingLattice)
    for i=1:d.height
        for k=1:3
            for j=1:d.width
                print(io, get_row_string(d[i,j], k), " ")
            end
            i == d.height && k==3 || println()
        end
        i == d.height || println()
    end
end
