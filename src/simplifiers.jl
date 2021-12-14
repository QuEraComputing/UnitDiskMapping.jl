export @gg
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
iscon(s::SimplifyPattern) = false
cross_location(s::SimplifyPattern) = size(s) .÷ 2
function source_locations end
function mapped_locations end
function mapped_graph(p::SimplifyPattern)
    locs = mapped_locations(p)
    return locs, unitdisk_graph(locs, 1.5), vertices_on_boundary(locs, size(p)...)
end
function source_graph(p::SimplifyPattern)
    locs = source_locations(p)
    return locs, unitdisk_graph(locs, 1.5), vertices_on_boundary(locs, size(p)...)
end
function vertices_on_boundary(locs, m, n)
    findall(loc->loc[1]==1 || loc[1]==m || loc[2]==1 || loc[2]==n, locs)
end

struct GridGraph{NT<:AbstractNode}
    size::Tuple{Int,Int}
    nodes::Vector{NT}
end
vertices_on_boundary(gg::GridGraph) = vertices_on_boundary(gg.nodes, gg.size...)

function gridgraphfromstring(mode::Union{Weighted, UnWeighted}, str::String)
    item_array = Vector{Int}[]
    for line in split(str, "\n")
        items = [item for item in split(line, " ") if !isempty(item)]
        list = if mode isa Weighted   # TODO: the weighted version need to be tested! Consider removing it!
            @assert all(item->item ∈ (".", "⋅", "@", "●", "o", "◯"), items)
            [item ∈ ("@", "●") ? 2 : (item ∈ ("o", "◯") ? 1 : 0) for item in items]
        else
            @assert all(item->item ∈ (".", "⋅", "@", "●"), items)
            [item ∈ ("@", "●") ? 1 : 0 for item in items]
        end
        if !isempty(list)
            push!(item_array, list)
        end
    end
    @assert all(==(length(item_array[1])), length.(item_array))
    mat = hcat(item_array...)'
    locs = [_to_node(mode, ci.I, mat[ci]) for ci in findall(!iszero, mat)]
    return GridGraph(size(mat), locs)
end
_to_node(::UnWeighted, loc::Tuple{Int,Int}, w::Int) = SimpleNode(loc...)
_to_node(::Weighted, loc::Tuple{Int,Int}, w::Int) = WeightedNode(loc..., w)

function gg_func(mode, expr)
    @assert expr.head == :(=)
    name = expr.args[1]
    pair = expr.args[2]
    @assert pair.head == :(call) && pair.args[1] == :(=>)
    g1 = gridgraphfromstring(mode, pair.args[2])
    g2 = gridgraphfromstring(mode, pair.args[3])
    @assert g1.size == g2.size
    @assert g1.nodes[vertices_on_boundary(g1)] == g2.nodes[vertices_on_boundary(g2)]
    return quote
        struct $(esc(name)) <: SimplifyPattern end
        Base.size(::$(esc(name))) = $(g1.size)
        $UnitDiskMapping.source_locations(::$(esc(name))) = $(g1.nodes)
        $UnitDiskMapping.mapped_locations(::$(esc(name))) = $(g2.nodes)
        $(esc(name))
    end
end

macro gg(expr)
    gg_func(UnWeighted(), expr)
end

# # How to add a new simplification rule
# 1. specify a gadget like the following. Use either `o` and `●` to specify a vertex,
# either `.` or `⋅` to specify a placeholder.
@gg DanglingLeg =
    """ 
    ⋅ ⋅ ⋅ 
    ⋅ ● ⋅ 
    ⋅ ● ⋅ 
    ⋅ ● ⋅ 
    """=>"""
    ⋅ ⋅ ⋅ 
    ⋅ ⋅ ⋅ 
    ⋅ ⋅ ⋅ 
    ⋅ ● ⋅
    """

# 2. add your gadget to simplifier ruleset.
const simplifier_ruleset = SimplifyPattern[DanglingLeg()]
# set centers (vertices with weight 1) for the weighted version
source_centers(::WeightedGadget{DanglingLeg}) = [(2,2)]
mapped_centers(::WeightedGadget{DanglingLeg}) = [(4,2)]

# 3. run the script `project/createmap` to generate `mis_overhead` and other informations required
# for mapping back. (Note: will overwrite the source file `src/extracting_results.jl`)