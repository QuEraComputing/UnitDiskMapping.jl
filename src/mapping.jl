export UnWeighted, Weighted
struct UnWeighted end
struct Weighted end

export Cell, AbstractCell
abstract type AbstractCell end
struct Cell <: AbstractCell
    occupied::Bool
    doubled::Bool
    connected::Bool
end
Base.isempty(cell::Cell) = !cell.occupied
Base.empty(::Type{Cell}) = Cell(false, false, false)
function Base.show(io::IO, x::Cell)
    if x.occupied
        if x.doubled
            print(io, "◉")
        elseif x.connected
            print(io, "◆")
        else
            print(io, "●")
        end
    else
        print(io, "⋅")
    end
end
Base.show(io::IO, ::MIME"text/plain", cl::Cell) = Base.show(io, cl)

struct UGrid{CT<:AbstractCell}
    lines::Vector{CopyLine}
    padding::Int
    content::Matrix{CT}
end

export coordinates
Base.:(==)(ug::UGrid{CT}, ug2::UGrid{CT}) where CT = ug.lines == ug2.lines && ug.content == ug2.content
padding(ug::UGrid) = ug.padding
coordinates(ug::UGrid) = [ci.I for ci in findall(!isempty, ug.content)]
function add_cell!(m::AbstractMatrix{<:Cell}, node::SimpleNode)
    i, j = node
    if isempty(m[i,j])
        m[i, j] = Cell(true, false, false)
    else
        @assert !(m[i, j].doubled) && !(m[i, j].connected)
        m[i, j] = Cell(true, true, false)
    end
end
function connect_cell!(m::AbstractMatrix{<:Cell}, i::Int, j::Int)
    if m[i, j] !== Cell(true, false, false)
        error("can not connect at [$i,$j] of type $(m[i,j])")
    end
    m[i, j] = Cell(true, false, true)
end

function Graphs.SimpleGraph(ug::UGrid)
    if any(x->x.doubled, ug.content)
        error("This mapping is not done yet!")
    end
    return unitdisk_graph(coordinates(ug), 1.6)
end

Base.show(io::IO, ug::UGrid) = print_ugrid(io, ug.content)
function print_ugrid(io::IO, content::AbstractMatrix)
    for i=1:size(content, 1)
        for j=1:size(content, 2)
            print(io, content[i,j])
            print(io, " ")
        end
        if i!=size(content, 1)
            println(io)
        end
    end
end
Base.copy(ug::UGrid) = UGrid(ug.lines, ug.padding, copy(ug.content))

# TODO:
# 1. check if the resulting graph is a unit-disk
# 2. other simplification rules
const crossing_ruleset = (Cross{false}(),
                    Turn(), WTurn(), Branch(), BranchFix(), TCon(), TrivialTurn(),
                    RotatedGadget(TCon(), 1), ReflectedGadget(Cross{true}(), "y"),
                    ReflectedGadget(TrivialTurn(), "y"), BranchFixB(), EndTurn(),
                    ReflectedGadget(RotatedGadget(TCon(), 1), "y"))
get_ruleset(::UnWeighted) = crossing_ruleset
function apply_crossing_gadgets!(mode, ug::UGrid)
    ruleset = get_ruleset(mode)
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
        locs = copyline_locations(nodetype(ug), line; padding=ug.padding)
        count = 0
        for (iloc, loc) in enumerate(locs)
            gi, ci = ug.content[loc...], c[loc...]
            if gi.doubled
                if ci == 2
                    count += 1
                elseif ci == 0
                    count += 0
                else    # ci = 1
                    if c[locs[iloc-1]...] == 0 && c[locs[iloc+1]...] == 0
                        count += 1
                    end
                end
            elseif !isempty(gi)
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

# NT is node type
function copyline_locations(::Type{NT}, tc::CopyLine; padding::Int) where NT
    s = 4
    nline = 0
    I, J = center_location(tc; padding=padding)
    locations = NT[]
    # grow up
    start = I+s*(tc.vstart-tc.hslot)+1
    if tc.vstart < tc.hslot
        nline += 1
    end
    for i=I:-1:start             # even number of nodes up
        push!(locations, node(NT, i, J, 1+(i!=start)))   # half weight on last node
    end
    # grow down
    stop = I+s*(tc.vstop-tc.hslot)-1
    if tc.vstop > tc.hslot
        nline += 1
    end
    for i=I:stop              # even number of nodes down
        if i == I
            push!(locations, node(NT, i+1, J+1, 2))
        else
            push!(locations, node(NT, i, J, 1+(i!=stop)))
        end
    end
    # grow right
    stop = J+s*(tc.hstop-tc.vslot)-1
    if tc.hstop > tc.vslot
        nline += 1
    end
    for j=J+2:stop            # even number of nodes right
        push!(locations, node(NT, I, j, 1 + (j!=stop)))   # half weight on last node
    end
    push!(locations, node(NT, I, J+1, nline))                     # center node
    return locations
end
nodetype(::UGrid{Cell}) = SimpleNode{Int}
nodetype(::UnWeighted) = SimpleNode{Int}
node(::Type{<:SimpleNode}, i, j, w) = SimpleNode(i, j)

export ugrid
function ugrid(mode, g::SimpleGraph, vertex_order::AbstractVector{Int}; padding=2, nrow=nv(g))
    @assert padding >= 2
    # create an empty canvas
    n = nv(g)
    s = 4
    N = (n-1)*s+1+2*padding
    M = nrow*s+1+2*padding
    u = fill(empty(mode isa Weighted ? WeightedCell{Int} : Cell), M, N)

    # add T-copies
    copylines = create_copylines(g, vertex_order)
    for tc in copylines
        for loc in copyline_locations(nodetype(mode), tc; padding=padding)
            add_cell!(u, loc)
        end
    end
    ug = UGrid(copylines, padding, u)
    for e in edges(g)
        I, J = crossat(ug, e.src, e.dst)
        connect_cell!(ug.content, I, J-1)
        if !isempty(ug.content[I-1, J])
            connect_cell!(ug.content, I-1, J)
        else
            connect_cell!(ug.content, I+1, J)
        end
    end
    return ug
end

function crossat(ug::UGrid, v, w)
    i, j = findfirst(x->x.vertex==v, ug.lines), findfirst(x->x.vertex==w, ug.lines)
    i, j = minmax(i, j)
    hslot = ug.lines[i].hslot
    s = 4
    return (hslot-1)*s+2+ug.padding, (j-1)*s+1+ug.padding
end

"""
    embed_graph([mode,] g::SimpleGraph; vertex_order=Branching())

Embed graph `g` into a unit disk grid, where the optional argument `mode` can be `Weighted()` or `UnWeighted`.
The `vertex_order` can be a vector or one of the following inputs

    * `Greedy()` fast but non-optimal.
    * `Branching()` slow but optimal.
"""
embed_graph(g::SimpleGraph; vertex_order=Branching()) = embed_graph(UnWeighted(), g; vertex_order)
function embed_graph(mode, g::SimpleGraph; vertex_order=Branching())
    if vertex_order isa AbstractVector
        L = PathDecomposition.Layout(g, collect(vertex_order[end:-1:1]))
    else
        L = pathwidth(g, vertex_order)
    end
    # we reverse the vertex order of the pathwidth result,
    # because this order corresponds to the vertex-seperation.
    ug = ugrid(mode, g, L.vertices[end:-1:1]; padding=2, nrow=L.vsep+1)
    return ug
end

export mis_overhead_copylines
function mis_overhead_copylines(ug::UGrid{WC}) where {WC}
    sum(ug.lines) do line
        mis_overhead_copyline(WC <: WeightedCell ? Weighted() : UnWeighted(), line)
    end
end

function mis_overhead_copyline(w::W, line::CopyLine) where W
    if W === Weighted
        s = 4
        return (line.hslot - line.vstart) * s +
            (line.vstop - line.hslot) * s +
            max((line.hstop - line.vslot) * s - 2, 0)
    else
        locs = copyline_locations(nodetype(w), line; padding=2)
        @assert length(locs) % 2 == 1
        return length(locs) ÷ 2
    end
end

##### Interfaces ######
export MappingResult, map_graph, map_configs_back

struct MappingResult{CT}
    grid_graph::UGrid{CT}
    mapping_history::Vector{Tuple{Pattern,Int,Int}}
    mis_overhead::Int
end

"""
    map_graph([mode=Weighted(),] g::SimpleGraph; vertex_order=Branching(), ruleset=[...])

Map a graph to a unit disk grid graph that being "equivalent" to the original graph, and return a `MappingResult` instance.
Here "equivalent" means a maximum independent set in the grid graph can be mapped back to
a maximum independent set of the original graph in polynomial time.

Positional Arguments
-------------------------------------
* `mode` is optional, it can be `Weighted()` (default) or `UnWeighted()`.
* `g` is a graph instance, check the documentation of [`Graphs`](https://juliagraphs.org/Graphs.jl/dev/) for details.

Keyword Arguments
-------------------------------------
* `vertex_order` specifies the order finding algorithm for vertices.
Different vertex orders have different path width, i.e. different depth of mapped grid graph.
It can be a vector or one of the following inputs
    * `Greedy()` fast but not optimal.
    * `Branching()` slow but optimal.
* `ruleset` specifies and extra set of optimization patterns (not the crossing patterns).
"""
function map_graph(g::SimpleGraph; vertex_order=Branching(), ruleset=default_simplifier_ruleset(UnWeighted()))
    map_graph(UnWeighted(), g; ruleset=ruleset, vertex_order=vertex_order)
end
function map_graph(mode, g::SimpleGraph; vertex_order=Branching(), ruleset=default_simplifier_ruleset(mode))
    ug = embed_graph(mode, g; vertex_order=vertex_order)
    mis_overhead0 = mis_overhead_copylines(ug)
    ug, tape = apply_crossing_gadgets!(mode, ug)
    ug, tape2 = apply_simplifier_gadgets!(ug; ruleset=ruleset)
    mis_overhead1 = isempty(tape) ? 0 : sum(x->mis_overhead(x[1]), tape)
    mis_overhead2 = isempty(tape2) ? 0 : sum(x->mis_overhead(x[1]), tape2)
    return MappingResult(ug, vcat(tape, tape2) , mis_overhead0 + mis_overhead1 + mis_overhead2)
end

"""
    map_configs_back(res::MappingResult, configs::AbstractVector)

Map MIS solutions for the mapped graph to a solution for the source graph.
"""
function map_configs_back(res::MappingResult, configs::AbstractVector)
    cs = map(configs) do cfg
        c = zeros(Int, size(res.grid_graph.content))
        for (i, loc) in enumerate(findall(!isempty, res.grid_graph.content))
            c[loc] = cfg[i]
        end
        c
    end
    return _map_configs_back(res, cs)
end
_map_configs_back(r::MappingResult{<:Cell}, configs::AbstractVector{<:AbstractMatrix}) = unapply_gadgets!(copy(r.grid_graph), r.mapping_history, copy.(configs))[2]

default_simplifier_ruleset(::UnWeighted) = vcat([rotated_and_reflected(rule) for rule in simplifier_ruleset]...)
default_simplifier_ruleset(::Weighted) = weighted.(default_simplifier_ruleset(UnWeighted()))

export print_config
print_config(mr::MappingResult, config::AbstractMatrix) = print_config(stdout, mr, config)
function print_config(io::IO, mr::MappingResult, config::AbstractMatrix)
    content = mr.grid_graph.content
    @assert size(content) == size(config)
    for i=1:size(content, 1)
        for j=1:size(content, 2)
            cell = content[i, j]
            @assert !(cell.connected || cell.doubled)
            if !isempty(cell)
                if !iszero(config[i,j])
                    print(io, "●")
                else
                    print(io, "○")
                end
            else
                if !iszero(config[i,j])
                    error("configuration not valid, there is not vertex at location $((i,j)).")
                end
                print(io, "⋅")
            end
            print(io, " ")
        end
        if i!=size(content, 1)
            println(io)
        end
    end
end

