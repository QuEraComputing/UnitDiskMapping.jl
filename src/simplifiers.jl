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
vertices_on_boundary(gg::GridGraph) = vertices_on_boundary(gg.nodes, gg.size...)

#################### Macros ###############################3
function gridgraphfromstring(mode::Union{Weighted, UnWeighted}, str::String; radius)
    item_array = Vector{Tuple{Bool,Int}}[]
    for line in split(str, "\n")
        items = [item for item in split(line, " ") if !isempty(item)]
        list = if mode isa Weighted   # TODO: the weighted version need to be tested! Consider removing it!
            @assert all(item->item ∈ (".", "⋅", "@", "●", "o", "◯") || (length(item)==1 && isdigit(item[1])), items)
            map(items) do item
                if item ∈ ("@", "●")
                    true, 2
                elseif item ∈ ("o", "◯")
                    true, 1
                elseif item ∈ (".", "⋅")
                    false, 0
                else
                    true, parse(Int, item)
                end
            end
        else
            @assert all(item->item ∈ (".", "⋅", "@", "●"), items)
            map(items) do item
                item ∈ ("@", "●") ? (true, 1) : (false, 0)
            end
        end
        if !isempty(list)
            push!(item_array, list)
        end
    end
    @assert all(==(length(item_array[1])), length.(item_array))
    mat = permutedims(hcat(item_array...), (2,1))
    # generate GridGraph from matrix
    locs = [_to_node(mode, ci.I, mat[ci][2]) for ci in findall(first, mat)]
    return GridGraph(size(mat), locs, radius)
end
_to_node(::UnWeighted, loc::Tuple{Int,Int}, w::Int) = Node(loc)
_to_node(::Weighted, loc::Tuple{Int,Int}, w::Int) = Node(loc, w)

function gg_func(mode, expr)
    @assert expr.head == :(=)
    name = expr.args[1]
    pair = expr.args[2]
    @assert pair.head == :(call) && pair.args[1] == :(=>)
    g1 = gridgraphfromstring(mode, pair.args[2]; radius=1.5)
    g2 = gridgraphfromstring(mode, pair.args[3]; radius=1.5)
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

# simple rules for crossing gadgets
for (GT, s1, m1, s3, m3) in [
            (:(DanglingLeg), [1], [1], [], []),
        ]
    @eval function weighted(g::$GT)
        slocs, sg, spins = source_graph(g)
        mlocs, mg, mpins = mapped_graph(g)
        sw, mw = fill(2, length(slocs)), fill(2, length(mlocs))
        sw[$(s1)] .= 1
        sw[$(s3)] .= 3
        mw[$(m1)] .= 1
        mw[$(m3)] .= 3
        return weighted(g, sw, mw)
    end
end
