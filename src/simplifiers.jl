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
vertices_on_boundary(gg::GridGraph) = vertices_on_boundary(gg.nodes, gg.size...)

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
