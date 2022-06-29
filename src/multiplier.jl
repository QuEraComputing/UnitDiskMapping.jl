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

"""
    multiplier()

Returns the multiplier as a `SimpleGridGraph` instance and a vector of `pins`.
The logic gate constraints on `pins` are

* x1 + x2*x3 + x4 == x5 + 2*x7
* x2 == x6
* x3 == x8
"""
function multiplier()
    xmin = minimum(x->x[1][1], multiplier_locs_and_weights)
    xmax = maximum(x->x[1][1], multiplier_locs_and_weights)
    ymin = minimum(x->x[1][2], multiplier_locs_and_weights)
    ymax = maximum(x->x[1][2], multiplier_locs_and_weights)

    nodes = [Node(loc[2]-ymin+1, loc[1]-xmin+1, w) for (loc, w) in multiplier_locs_and_weights]
    pins = [1,3,10,23,38,41,22,6]
    return GridGraph((ymax-ymin+1, xmax-xmin+1), nodes, 2*sqrt(2)*1.01), pins
end

"""
    map_factoring(M::Int, N::Int)

Setup a factoring circuit with M-bit `q` register (second input) and N-bit `p` register (first input).
The `m` register size is (M+N-1), which stores the output.
Call [`solve_factoring`](@ref) to solve a factoring problem with the mapping result.
"""
function map_factoring(M::Int, N::Int)
    block, pin = multiplier()
    m, n = size(block) .- (4, 1)
    G = glue(fill(cell_matrix(block), (M,N)), 4, 1)
    WIDTH = 3
    leftside = zeros(eltype(G), size(G,1), WIDTH)
    for i=1:M-1
        for (a, b) in [(12, WIDTH), (14,1), (16,1), (18, 2), (14,1), (16,1), (18, 2), (19,WIDTH)]
            leftside[(i-1)*m+a, b] += SimpleCell(1)
        end
    end
    G = glue(reshape([leftside, G], 1, 2), 0, 1)
    gg = GridGraph(G, block.radius)
    locs = getfield.(gg.nodes, :loc)
    coo(i, j) = ((i-1)*m, (j-1)*n+WIDTH-1)
    pinloc(i, j, index) = findfirst(==(block.nodes[pin[index]].loc .+ coo(i, j)), locs)
    pp = [pinloc(1, j, 2) for j=N:-1:1]
    pq = [pinloc(i, N, 3) for i=1:M]
    pm = [
        [pinloc(i, N, 5) for i=1:M]...,
        [pinloc(M, j, 5) for j=N-1:-1:1]...,
    ]
    p0 = [
        [pinloc(1, j, 1) for j=1:N]...,
        [pinloc(i, N, 4) for i=1:M]...,
    ]
    return FactoringResult(gg, pp, pq, pm, p0)
end

struct FactoringResult{NT}
    grid_graph::GridGraph{NT}
    pins_input1::Vector{Int}
    pins_input2::Vector{Int}
    pins_output::Vector{Int}
    pins_zeros::Vector{Int}
end

function map_config_back(res::FactoringResult, cfg)
    return asint(cfg[res.pins_input1]), asint(cfg[res.pins_input2])
end

# convert vector to integer
asint(v::AbstractVector) = sum(i->v[i]<<(i-1), 1:length(v))

"""
    solve_factoring(missolver, mres::FactoringResult, x::Int) -> (Int, Int)

Solve a factoring problem by solving the mapped weighted MIS problem on a unit disk grid graph.
It returns (a, b) such that ``a  b = x`` holds.
`missolver(graph, weights)` should return a vector of integers as the solution.
"""
function solve_factoring(missolver, mres::FactoringResult, target::Int)
    g, ws = graph_and_weights(mres.grid_graph)
    mg, vmap = set_target(g, [mres.pins_zeros..., mres.pins_output...], target << length(mres.pins_zeros))
    res = missolver(mg, ws[vmap])
    cfg = zeros(Int, nv(g))
    cfg[vmap] .= res
    return map_config_back(mres, cfg)
end

function set_target(g::SimpleGraph, pins::AbstractVector, target::Int)
    vs = collect(vertices(g))
    for (i, p) in enumerate(pins)
        bitval = (target >> (i-1)) & 1
        if bitval == 1
            # remove pin and its neighbor
            vs = setdiff(vs, neighbors(g, p) ∪ [p])
        else
            # remove pin
            vs = setdiff(vs, [p])
        end
    end
    return induced_subgraph(g, vs)
end
