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
Base.:(==)(ug::UGrid, ug2::UGrid) = ug.n == ug2.n && ug.content == ug2.content
padding(ug::UGrid) = ug.padding
coordinates(ug::UGrid) = [ci.I for ci in findall(!iszero, ug.content)]

function plain_ugrid(n::Int; padding=2)
    @assert padding >= 2
    s = 4
    N = (n-1)*s+1+2*padding
    u = zeros(Int, N, N)
    for j=n-1:-1:0
        for i=0:n-1
            # two extra rows
            if 1<=i<=2
                u[i+1, s*j+1+padding] += 1
            end
            # others
            if i<=j
                u[max(2+padding, s*i-s+4+padding):2:s*i+2+padding, s*j+1+padding] .+= 1
                i!=0 && (u[s*i-s+3+padding:2:s*i+padding+1, s*j+1+padding] .+= 1)
            else
                u[s*j+3+padding, max(1+padding, s*i-s+1+padding):s*i+padding] .+= 1
            end
        end
    end
    return UGrid(collect(1:n), padding, u)
end

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
function crossat(ug::UGrid, i, j)
    s = 4
    return (i-1)*s+3+ug.padding, (j-1)*s+1+ug.padding
end
function Graphs.add_edge!(ug::UGrid, i, j)
    I, J = crossat(ug, i, j)
    ug.content[I+1, J] *= -1
    ug.content[I, J-1] *= -1
    return ug
end

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
function apply_gadgets!(ug::UGrid, ruleset=(
                    Cross{false}(), Cross{true}(), TShape{false}(), TShape{true}(),
                    Turn()
                ))
    tape = Tuple{Pattern,Int,Int}[]
    for j=1:size(ug.content, 2)  # start from 0 because there can be one empty padding column/row.
        for i=1:size(ug.content, 1)
            for pattern in ruleset
                if match(pattern, ug.content, i, j)
                    apply_gadget!(pattern, ug.content, i, j)
                    push!(tape, (pattern, i, j))
                    break
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
        map_config_copyback!(ug.n, c, ug.padding)
    end
    return ug, cfgs
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

function map_config_copyback!(n::Int, c::AbstractMatrix, padding::Int)
    store = copy(c)
    s = 4
    res = zeros(Int, n)
    for j=1:n
        for i=1:(n-1)*s + 3
            J = (j-1)*s + 1 + padding
            if i > (j-1)*s+4
                J += i-(j-1)*s-4
                I = (j-1)*s + 3 + padding
                # bits belong to horizontal lines
                if i%s != 0 || (safe_get(c, I, J-1) == 0 && safe_get(c, I, J+1) == 0)
                    if store[I, J] != 0
                        res[j] += 1
                        store[I, J] -= 1
                    end
                end
            else
                I = i-1 + padding
                # bits belong to vertical lines
                if i%s != 0 || (safe_get(c, I-1, J) == 0 && safe_get(c, I+1, J) == 0)
                    if store[I, J] != 0
                        res[j] += 1
                        store[I, J] -= 1
                    end
                end
            end
        end
    end
    return map(res) do x
        if x == 2*(n-1)+1
            false
        elseif x == 2*(n-1) + 2
            true
        else
            error("mapping back fail! got $x (overhead = $((n-1)*2))")
        end
    end
end

export is_independent_set
function is_independent_set(g::SimpleGraph, config)
    for e in edges(g)
        if config[e.src] == config[e.dst] == 1
            return false
        end
    end
    return true
end

function embed_graph(g::SimpleGraph)
    ug = plain_ugrid(nv(g))
    for e in edges(g)
        add_edge!(ug, e.src, e.dst)
    end
    return ug
end


##################### reordered mapping ###################

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
        @show islot
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

function add_copyline!(u::Matrix, tc::CopyLine; padding::Int)
    s = 4
    I = s*(tc.hslot-1)+padding+2
    J = s*(tc.vslot-1)+padding+1
    # grow up
    for i=I+s*(tc.vstart-tc.hslot)+1:I             # even number of nodes up
        u[i, J] += 1
    end
    # grow down
    for i=I:I+s*(tc.vstop-tc.hslot)-1              # even number of nodes down
        if i == I
            u[i+1, J+1] += 1
        else
            u[i, J] += 1
        end
    end
    # grow right
    for j=J+2:J+s*(tc.hstop-tc.vslot)-1            # even number of nodes right
        u[I, j] += 1
    end
    u[I,J+1] += 1                                  # center node
    return u
end

export ugrid
function ugrid(g::SimpleGraph, vertex_order::AbstractVector{Int}; padding=2)
    @assert padding >= 2
    # create an empty canvas
    n = nv(g)
    s = 4
    N = (n-1)*s+1+2*padding
    u = zeros(Int, N, N)

    # add T-copies
    copylines = create_copylines(g, vertex_order)
    #copylines = copylines[1:1]
    for tc in copylines
        #tc = CopyLine(1, 1, 1, 1, nv(g)-8, nv(g))
        @show tc
        add_copyline!(u, tc; padding=padding)
    end
    return UGrid(copylines, padding, u)
end

function crossat2(ug::UGrid, v, w)
    i, j = findfirst(x->x.vertex==v, ug.lines), findfirst(x->x.vertex==w, ug.lines)
    i, j = minmax(i, j)
    hslot = ug.lines[i].hslot
    s = 4
    return (hslot-1)*s+2+ug.padding, (j-1)*s+1+ug.padding
end

export embed_graph2
function embed_graph2(g::SimpleGraph)
    ug = ugrid(g, collect(nv(g):-1:1); padding=2)
    for e in edges(g)
        I, J = crossat2(ug, e.src, e.dst)
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

