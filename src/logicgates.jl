struct Gate{SYM} end
Gate(x::Symbol) = Gate{x}()

function gate_gadget(::Gate{:NOT})
    locs = [(1, 1), (3, 1)]
    weights = fill(1, 2)
    inputs, outputs = [1], [2]
    return GridGraph((1, 3), Node.(locs, weights), 2.3), inputs, outputs
end

function gate_gadget(::Gate{:NOR}; rot=3)
    locs = [rot15(0.0, 1.0, i) for i=rot:rot+4]
    weights = fill(1, 5)
    inputs, outputs = [1,3], [2]
    edges = [(1,2), (2,3), (3,4), (4,5), (5,1)]
    return locs, edges, weights, inputs, outputs
end

function gate_gadget(::Gate{:OR}; rot=3)
    locs = [rot15(0.0, 1.0, i) .+ (0.3, 0.0) for i=rot:rot+4]
    weights = fill(1, 6)
    weights[2] = 2
    inputs, outputs = [1,3], [6]
    edges = [(1,2), (2,3), (3,4), (4,5), (5,1), (2,6)]
    push!(locs, rot15(0.0, 1.0, rot+1) .* 1.75)
    return locs, edges, weights, inputs, outputs
end

function gate_gadget(::Gate{:NXOR})
    locs = [rot16(0.0, 1.0, i) for i=3:8]
    weights = [1, 2, 1, 2, 1, 2]
    inputs, outputs = [1,3], [5]
    edges = [(1,2), (2,3), (3,4), (4,5), (5,6), (1,6), (2,4), (4,6), (2,6)]
    return locs, edges, weights, inputs, outputs
end

function gate_gadget(::Gate{:XOR})
    locs = [rot16(0.0, 1.0, i) for i=3:8]
    push!(locs, locs[5] .* 1.75)
    weights = [1, 2, 1, 2, 2, 2, 1]
    inputs, outputs = [1,3], [7]
    edges = [(1,2), (2,3), (3,4), (4,5), (5,6), (1,6), (2,4), (4,6), (2,6), (5,7)]
    return locs, edges, weights, inputs, outputs
end

function gate_gadget(::Gate{:AND})
    u = sqrt(0.5)
    locs = [(-2u, 0.0), (-u, 0.0), (0.0, -u), (0.0, u), (2u, -u), (2u, u)]
    weights = fill(1, 6)
    weights[2] = 2
    inputs, outputs = [1,6], [3]
    edges = [(1,2), (2,3), (3,4), (2,4), (3,5), (4,6), (5,6)]
    return locs, edges, weights, inputs, outputs
end

# inputs are mutually disconnected
# full adder
struct VertexScheduler
    count::Base.RefValue{Int}
    circuit::Vector{Pair{Gate,Vector{Int}}}
    edges::Vector{Tuple{Int,Int}}
    weights::Vector{Int}
end
VertexScheduler() = VertexScheduler(Ref(0), Pair{Gate,Vector{Int}}[], Tuple{Int,Int}[], Int[])
function newvertices!(vs::VertexScheduler, k::Int=1)
    vs.count[] += k
    append!(vs.weights, zeros(Int,k))
    return vs.count[]-k+1:vs.count[]
end

function apply!(g::Gate{SYM}, vs::VertexScheduler, a::Int, b::Int) where SYM
    locs, edges, weights, inputs, outputs = gadget(g)
    vertices = newvertices!(vs, length(locs)-2)
    out = vertices[end]

    # map locations
    mapped_locs = zeros(Int, length(locs))
    mapped_locs[inputs] .= [a, b]
    mapped_locs[outputs] .= [out]
    mapped_locs[setdiff(1:length(locs), inputs ∪ outputs)] .= vertices[1:end-1]

    # map edges
    for (i, j) in edges
        push!(vs.edges, (mapped_locs[i], mapped_locs[j]))
    end

    # add weights
    vs.weights[mapped_locs] .+= weights

    # update circuit
    push!(vs.circuit, g => [inputs..., outputs...])

    return out
end

function logicgate_multiplier()
    c = VertexScheduler()
    x0, x1, x2, x3 = newvertices!(c, 4)
    x12 = apply!(Gate(:AND), c, x1, x2)
    x4 = apply!(Gate(:XOR), c, x0, x12)
    x5 = apply!(Gate(:XOR), c, x3, x4)  # 5 is sum
    x6 = apply!(Gate(:AND), c, x3, x4)
    x7 = apply!(Gate(:AND), c, x0, x12)
    x8 = apply!(Gate(:OR), c, x6, x7)
    return c, [x0, x1, x2, x3], [x8, x5]
end

truth_table(solver, gate::Gate) = truth_table(solver, gate_gadget(gate))
function truth_table(missolver, grid_graph::GridGraph, inputs, outputs)
    g, ws = graph_and_weights(grid_graph)
    openvertices = [inputs..., outputs...]
    res = missolver(g, ws, openvertices)
    table = zeros(Int, 2^length(inputs))
    table[i]
end
function solve_factoring(missolver, mres::FactoringResult, target::Int)
    g, ws = graph_and_weights(mres.grid_graph)
    mg, vmap = set_target(g, [mres.pins_zeros..., mres.pins_output...], target << length(mres.pins_zeros))
    res = missolver(mg, ws[vmap])
    cfg = zeros(Int, nv(g))
    cfg[vmap] .= res
    return map_config_back(mres, cfg)
end