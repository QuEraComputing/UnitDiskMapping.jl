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
    print(io, "vslot → [$(cl.vstart):$(cl.vstop),$(cl.vslot)], hslot → [$(cl.hslot),$(cl.vslot):$(cl.hstop)]")
end
Base.show(io::IO, ::MIME"text/plain", cl::CopyLine) = Base.show(io, cl)

struct UGrid
    lines::Vector{CopyLine}
    padding::Int
    content::Matrix{Int}
end

export coordinates
Base.:(==)(ug::UGrid, ug2::UGrid) = ug.lines == ug2.lines && ug.content == ug2.content
padding(ug::UGrid) = ug.padding
coordinates(ug::UGrid) = [ci.I for ci in findall(!iszero, ug.content)]

function Graphs.SimpleGraph(ug::UGrid)
    if any(x->abs(x)>1, ug.content)
        error("This mapping is not done yet!")
    end
    return unitdisk_graph(coordinates(ug), 1.6)
end

Base.show(io::IO, ug::UGrid) = print_ugrid(io, ug.content)
function print_ugrid(io::IO, content::AbstractMatrix)
    for i=1:size(content, 1)
        for j=1:size(content, 2)
            showitem(io, content[i,j])
            print(io, " ")
        end
        if i!=size(content, 1)
            println(io)
        end
    end
end
Base.copy(ug::UGrid) = UGrid(ug.lines, ug.padding, copy(ug.content))

function showitem(io, x)
    if x == 1
        print(io, "●")
    elseif x == 0
        print(io, "⋅")
    elseif x == -1
        print(io, "◆")
    elseif x == 2
        print(io, "◉")
    elseif x == -2
        print(io, "○")
    else
        print(io, "?")
    end
end

# TODO:
# 1. check if the resulting graph is a unit-disk
# 2. other simplification rules
const crossing_ruleset = (Cross{false}(),
                    Turn(), WTurn(), Branch(), BranchFix(), TCon(), TrivialTurn(),
                    RotatedGadget(TCon(), 1), ReflectedGadget(Cross{true}(), "y"),
                    ReflectedGadget(TrivialTurn(), "y"), BranchFixB(), EndTurn(),
                    ReflectedGadget(RotatedGadget(TCon(), 1), "y"))
function apply_crossing_gadgets!(ug::UGrid, ruleset=crossing_ruleset)
    tape = Tuple{Pattern,Int,Int}[]
    n = length(ug.lines)
    for j=1:n  # start from 0 because there can be one empty padding column/row.
        for i=1:n
            for pattern in ruleset
                x, y = crossat(ug, i, j) .- cross_location(pattern) .+ (1,1)
                if match(pattern, ug.content, x, y)
                    apply_gadget!(pattern, ug.content, x, y)
                    push!(tape, (pattern, x, y))
                    break
                end
            end
        end
    end
    return ug, tape
end

function apply_simplifier_gadgets!(ug::UGrid; ruleset, nrepeat::Int=10)
    tape = Tuple{Pattern,Int,Int}[]
    for _ in 1:nrepeat, pattern in ruleset
        for j=0:size(ug.content, 2)  # start from 0 because there can be one empty padding column/row.
            for i=0:size(ug.content, 1)
                if match(pattern, ug.content, i, j)
                    apply_gadget!(pattern, ug.content, i, j)
                    push!(tape, (pattern, i, j))
                end
            end
        end
    end
    return ug, tape
end

function unapply_gadgets!(ug::UGrid, tape, configurations)
    for (pattern, i, j) in Base.Iterators.reverse(tape)
        @assert unmatch(pattern, ug.content, i, j)
        for c in configurations
            map_config_back!(pattern, i, j, c)
        end
        unapply_gadget!(pattern, ug.content, i, j)
    end
    cfgs = map(configurations) do c
        map_config_copyback!(ug, c)
    end
    return ug, cfgs
end

# returns a vector of configurations
function _map_config_back(s::Pattern, config)
    d1 = mapped_entry_to_compact(s)
    d2 = source_entry_to_configs(s)
    # get the pin configuration
    bc = mapped_boundary_config(s, config)
    return d2[d1[bc]]
end

function map_config_back!(p::Pattern, i, j, configuration)
    m, n = size(p)
    locs, graph, pins = mapped_graph(p)
    config = [configuration[i+loc[1]-1, j+loc[2]-1] for loc in locs]
    newconfig = rand(_map_config_back(p, config))
    # clear canvas
    for i_=i:i+m-1, j_=j:j+n-1
        safe_set!(configuration,i_,j_, 0)
    end
    locs0, graph0, pins0 = source_graph(p)
    for (k, loc) in enumerate(locs0)
        configuration[i+loc[1]-1,j+loc[2]-1] += newconfig[k]
    end
    return configuration
end

function map_config_copyback!(ug::UGrid, c::AbstractMatrix)
    res = zeros(Int, length(ug.lines))
    for line in ug.lines
        locs = copyline_locations(line; padding=ug.padding)
        count = 0
        for (iloc, loc) in enumerate(locs)
            gi, ci = ug.content[loc...], c[loc...]
            if gi == 2
                if ci == 2
                    count += 1
                elseif ci == 0
                    count += 0
                else    # ci = 1
                    if c[locs[iloc-1]...] == 0 && c[locs[iloc+1]...] == 0
                        count += 1
                    end
                end
            elseif abs(gi) == 1
                count += ci
            else
                error("check your grid at location ($(locs...))!")
            end
        end
        res[line.vertex] = count - (length(locs) ÷ 2)
    end
    return res
end

function remove_order(g::AbstractGraph, vertex_order::AbstractVector{Int})
    addremove = [Int[] for _=1:nv(g)]
    adjm = adjacency_matrix(g)
    counts = zeros(Int, nv(g))
    totalcounts = sum(adjm; dims=1)
    for (i, v) in enumerate(vertex_order)
        counts .+= adjm[:,v]
        for j=1:nv(g)
            if !iszero(adjm[j,v]) && counts[j] == totalcounts[j]
                # ensure remove after add!
                push!(addremove[max(i, findfirst(==(j), vertex_order))], j)
            end
        end
    end
    return addremove
end

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

function copyline_locations(tc::CopyLine; padding::Int)
    s = 4
    I = s*(tc.hslot-1)+padding+2
    J = s*(tc.vslot-1)+padding+1
    locations = Tuple{Int,Int}[]
    # grow up
    for i=I+s*(tc.vstart-tc.hslot)+1:I             # even number of nodes up
        push!(locations, (i, J))
    end
    # grow down
    for i=I:I+s*(tc.vstop-tc.hslot)-1              # even number of nodes down
        if i == I
            push!(locations, (i+1, J+1))
        else
            push!(locations, (i, J))
        end
    end
    # grow right
    for j=J+2:J+s*(tc.hstop-tc.vslot)-1            # even number of nodes right
        push!(locations, (I, j))
    end
    push!(locations, (I, J+1))                     # center node
    return locations
end

export ugrid
function ugrid(g::SimpleGraph, vertex_order::AbstractVector{Int}; padding=2, nrow=nv(g))
    @assert padding >= 2
    # create an empty canvas
    n = nv(g)
    s = 4
    N = (n-1)*s+1+2*padding
    M = nrow*s+1+2*padding
    u = zeros(Int, M, N)

    # add T-copies
    copylines = create_copylines(g, vertex_order)
    for tc in copylines
        for loc in copyline_locations(tc; padding=padding)
            u[loc...] += 1
        end
    end
    return UGrid(copylines, padding, u)
end

function crossat(ug::UGrid, v, w)
    i, j = findfirst(x->x.vertex==v, ug.lines), findfirst(x->x.vertex==w, ug.lines)
    i, j = minmax(i, j)
    hslot = ug.lines[i].hslot
    s = 4
    return (hslot-1)*s+2+ug.padding, (j-1)*s+1+ug.padding
end

"""
    embed_graph(g::SimpleGraph; vertex_order=Greedy())

Embed graph `g` into a unit disk grid. The `vertex_order` can be a vector or one of the following inputs

    * `Greedy()` fast but non-optimal.
    * `Branching()` slow but optimal.
"""
function embed_graph(g::SimpleGraph; vertex_order=Greedy())
    if vertex_order isa AbstractVector
        L = PathDecomposition.Layout(g, collect(vertex_order))
    else
        L = pathwidth(g, vertex_order)
    end
    ug = ugrid(g, L.vertices; padding=2, nrow=L.vsep+1)
    for e in edges(g)
        I, J = crossat(ug, e.src, e.dst)
        @assert ug.content[I, J-1] == 1
        ug.content[I, J-1] *= -1
        if ug.content[I-1, J] == 1
            ug.content[I-1, J] *= -1
        else
            @assert ug.content[I+1, J] == 1
            ug.content[I+1, J] *= -1
        end
    end
    return ug
end

export mis_overhead_copylines
function mis_overhead_copylines(ug::UGrid)
    sum(ug.lines) do line
        locs = copyline_locations(line; padding=ug.padding)
        @assert length(locs) % 2 == 1
        length(locs) ÷ 2
    end
end

##### Interfaces ######
export MappingResult, map_graph, map_configs_back

struct MappingResult
    grid_graph::UGrid
    mapping_history::Vector{Tuple{Pattern,Int,Int}}
    mis_overhead::Int
end

"""
    map_graph(g::SimpleGraph; ruleset=[...])

Map a graph to a unit disk grid graph that being "equivalent" to the original graph.
Here "equivalent" means a maximum independent set in the grid graph can be mapped back to
a maximum independent set of the original graph in polynomial time.

Returns a `MappingResult` instance.
"""
function map_graph(g::SimpleGraph; ruleset=[RotatedGadget(DanglingLeg(), n) for n=0:3])
    ug = embed_graph(g)
    mis_overhead0 = mis_overhead_copylines(ug)
    ug, tape = apply_crossing_gadgets!(ug)
    ug, tape2 = apply_simplifier_gadgets!(ug; ruleset=ruleset)
    mis_overhead1 = sum(x->mis_overhead(x[1]), tape)
    mis_overhead2 = sum(x->mis_overhead(x[1]), tape2)
    return MappingResult(ug, vcat(tape, tape2) , mis_overhead0 + mis_overhead1 + mis_overhead2)
end

map_configs_back(r::MappingResult, configs::AbstractVector) = unapply_gadgets!(copy(r.grid_graph), r.mapping_history, copy.(configs))[2]
