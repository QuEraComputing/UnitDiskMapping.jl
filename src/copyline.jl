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
    print(io, "$(typeof(cl)): vslot → [$(cl.vstart):$(cl.vstop),$(cl.vslot)], hslot → [$(cl.hslot),$(cl.vslot):$(cl.hstop)]")
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

function center_location(tc::CopyLine; padding::Int) where NT
    s = 4
    I = s*(tc.hslot-1)+padding+2
    J = s*(tc.vslot-1)+padding+1
    return I, J
end

