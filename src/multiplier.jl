const multiplier_locs_and_weights = [
    ((0, -3), 1),   # x0
    ((2, -1), 2),
    ((8, 0), 1),    # x1
    ((1, 1), 3),
    ((3, 1), 3),
    ((0, 2), 1),    # x7
    ((5, 2), 2),
    ((7, 2), 3),
    ((9, 2), 3),
    ((11, 2), 1),   # x2
    ((1, 3), 3),
    ((3, 3), 3),
    ((7, 4), 4),
    ((9, 4), 3),
    ((1, 5), 2),
    ((3, 6), 2),
    ((5, 6), 2),
    ((8, 6), 2),
    ((2, 7), 3),
    ((4, 7), 2),
    ((8, 7), 2),
    ((0, 8), 1),    # x6
    ((11, 8), 1),   # x3
    ((2, 9), 3),
    ((4, 9), 2),
    ((7, 9), 3),
    ((9, 9), 3),
    ((3, 10), 2),
    ((5, 10), 2),
    ((7, 10), 3),
    ((9, 10), 3),
    ((1, 11), 2),
    ((8, 12), 2),
    ((3, 13), 2),
    ((5, 14), 2),
    ((7, 14), 3),
    ((9, 14), 3),
    ((11, 15), 1),  # x4
    ((7, 16), 3),
    ((9, 16), 3),
    ((8, 18), 1),   # x5
]

struct SimpleGridGraph{WT}
    locs::Vector{Tuple{Int,Int}}
    weights::WT
    unit::Float64  # unit distance
end

"""
    multiplier()

Returns the multiplier as a `SimpleGridGraph` instance and a vector of `pins`.
The logic gate constraints on `pins` are

* x1 + x2*x3 + x4 == x5 + 2*x7
* x2 == x6
* x3 == x8
"""
function multiplier()
    locs = map(x->(x[1][1], -x[1][2]), multiplier_locs_and_weights)
    weights = getindex.(multiplier_locs_and_weights, 2)
    pins = [1,3,10,23,38,41,22,6]
    return SimpleGridGraph(locs, weights, 2*sqrt(2)*1.01), pins
end

get_graph(g::SimpleGridGraph) = unit_disk_graph(g.locs, g.unit)