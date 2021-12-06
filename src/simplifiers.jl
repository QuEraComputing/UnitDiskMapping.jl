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

struct GridGraph
    size::Tuple{Int,Int}
    locations::Vector{Tuple{Int,Int}}
end
vertices_on_boundary(gg::GridGraph) = vertices_on_boundary(gg.locations, gg.size...)

function gridgraphfromstring(str::String)
    item_array = Vector{Bool}[]
    for line in split(str, "\n")
        list = [item ∈ ("o", "●") ? true : (@assert item ∈ (".", "⋅"); false) for item in split(line, " ") if !isempty(item)]
        if !isempty(list)
            push!(item_array, list)
        end
    end
    @assert all(==(length(item_array[1])), length.(item_array))
    mat = hcat(item_array...)'
    locs = findall(mat)
    return GridGraph(size(mat), locs)
end

const simplifier_ruleset = SimplifyPattern[]

macro gg(expr)
    @assert expr.head == :(=)
    name = expr.args[1]
    pair = expr.args[2]
    @assert pair.head == :(call) && pair.args[1] == :(=>)
    g1 = gridgraphfromstring(pair.args[2])
    g2 = gridgraphfromstring(pair.args[3])
    @assert g1.size == g2.size
    @assert g1.locations[vertices_on_boundary(g1)] == g2.locations[vertices_on_boundary(g2)]
    return quote
        struct $(esc(name)) <: SimplifyPattern end
        Base.size(::$(esc(name))) = $(g1.size)
        $UnitDiskMapping.source_locations(::$(esc(name))) = $(g1.locations)
        $UnitDiskMapping.mapped_locations(::$(esc(name))) = $(g2.locations)
        push!($(simplifier_ruleset), $(esc(name))())
        $(esc(name))
    end
end

# # How to add a new simplification rule
# 1. specify a gadget like the following. Use either `o` and `●` to specify a vertex,
# either `.` or `⋅` to specify a placeholder.
# ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅
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

@gg Square =
    """
    ⋅ ● ⋅ ⋅
    ● ⋅ ● ⋅
    ⋅ ● ⋅ ⋅
    ⋅ ⋅ ⋅ ⋅
    """=>"""
    ⋅ ● ⋅ ⋅
    ● ⋅ ⋅ ⋅
    ⋅ ⋅ ⋅ ⋅
    ⋅ ⋅ ⋅ ⋅
    """

@gg Cane =
    """
    ⋅ ⋅ ⋅ ⋅
    ⋅ ● ⋅ ⋅
    ● ⋅ ● ⋅
    ⋅ ⋅ ● ⋅
    ⋅ ⋅ ● ⋅
    """=>"""
    ⋅ ⋅ ⋅ ⋅
    ⋅ ⋅ ⋅ ⋅
    ● ⋅ ⋅ ⋅
    ⋅ ● ⋅ ⋅
    ⋅ ⋅ ● ⋅
    """

@gg CLoop = 
"""
⋅ ⋅ ⋅ ⋅
⋅ ⋅ ● ⋅
⋅ ● ⋅ ●
⋅ ● ⋅ ⋅
⋅ ⋅ ● ⋅
"""=>"""
⋅ ⋅ ⋅ ⋅
⋅ ⋅ ⋅ ⋅
⋅ ⋅ ⋅ ●
⋅ ⋅ ● ⋅
⋅ ⋅ ● ⋅
"""


# 2. run the script `project/createmap` to generate `mis_overhead` and other informations required
# for mapping back. (Note: will overwrite the source file `src/extracting_results.jl`)
