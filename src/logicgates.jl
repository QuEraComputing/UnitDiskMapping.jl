struct Gate{SYM} end
Gate(x::Symbol) = Gate{x}()

autosize(locs) = maximum(first, locs), maximum(last, locs)
function gate_gadget(::Gate{:NOT})
    locs = [(1, 1), (3, 1)]
    weights = fill(1, 2)
    inputs, outputs = [1], [2]
    return GridGraph(autosize(locs), Node.(locs, weights), 2.3), inputs, outputs
end

function gate_gadget(::Gate{:NOR})
    locs = [(2, 1), (1, 3), (2, 5), (4, 2), (4, 4)]
    weights = fill(1, 5)
    inputs, outputs = [1, 3], [2]
    return GridGraph(autosize(locs), Node.(locs, weights), 2.3), inputs, outputs
end

function gate_gadget(::Gate{:OR})
    locs = [(3, 1), (2, 3), (3, 5), (5, 2), (5, 4), (1,3)]
    weights = fill(1, 6)
    weights[2] = 2
    inputs, outputs = [1,3], [6]
    return GridGraph(autosize(locs), Node.(locs, weights), 2.3), inputs, outputs
end

function gate_gadget(::Gate{:NXOR})
    locs = [(2,1), (1,3), (2, 5), (3, 2), (3, 4), (4, 3)]
    weights = [1, 2, 1, 2, 2, 1]
    inputs, outputs = [1,3], [6]
    return GridGraph(autosize(locs), Node.(locs, weights), 2.3), inputs, outputs
end

function gate_gadget(::Gate{:XOR})
    locs = [(2,1), (1,3), (2, 5), (3, 2), (3, 4), (4, 3), (6, 3)]
    weights = [1, 2, 1, 2, 2, 2, 1]
    inputs, outputs = [1,3], [7]
    return GridGraph(autosize(locs), Node.(locs, weights), 2.3), inputs, outputs
end

function gate_gadget(::Gate{:AND})
    u = 1
    locs = [(-3u, 0), (-u, 0), (0, -u), (0, u), (2u, -u), (2u, u)]
    locs = map(loc->loc .+ (2u+1, u+1), locs)
    weights = fill(1, 6)
    weights[2] = 2
    inputs, outputs = [1,6], [3]
    return GridGraph(autosize(locs), Node.(locs, weights), 2.3), inputs, outputs
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

truth_table(solver, gate::Gate) = truth_table(solver, gate_gadget(gate)...)
function truth_table(misenumerator, grid_graph::GridGraph, inputs, outputs)
    g, ws = graph_and_weights(grid_graph)
    res = misenumerator(g, ws)

    # create a k-v pair
    d = Dict{Int,Int}()
    for config in res
        input = sum(i->config[inputs[i]]<<(i-1), 1:length(inputs))
        output = sum(i->config[outputs[i]]<<(i-1), 1:length(outputs))
        if !haskey(d,input)
            d[input] = output
        else
            @assert d[input] == output
        end
    end
    @assert length(d) == 1<<length(inputs)
    return [d[i] for i=0:1<<length(inputs)-1]
end