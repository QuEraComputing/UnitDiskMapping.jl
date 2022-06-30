
function g_not()
    u = sqrt(0.5)
    locs = [(-u, 0.0), (u, 0.0)]
    weights = fill(1, 2)
    inputs, outputs = [1], [2]
    edges = [(1,2)]
    return locs, edges, weights, inputs, outputs
end

function g_nor(; rot=3)
    locs = [rot15(0.0, 1.0, i) for i=rot:rot+4]
    weights = fill(1, 5)
    inputs, outputs = [1,3], [2]
    edges = [(1,2), (2,3), (3,4), (4,5), (5,1)]
    return locs, edges, weights, inputs, outputs
end

function g_or(; rot=3)
    locs = [rot15(0.0, 1.0, i) .+ (0.3, 0.0) for i=rot:rot+4]
    weights = fill(1, 6)
    weights[2] = 2
    inputs, outputs = [1,3], [6]
    edges = [(1,2), (2,3), (3,4), (4,5), (5,1), (2,6)]
    push!(locs, rot15(0.0, 1.0, rot+1) .* 1.75)
    return locs, edges, weights, inputs, outputs
end

function g_nxor()
    locs = [rot16(0.0, 1.0, i) for i=3:8]
    weights = [1, 2, 1, 2, 1, 2]
    inputs, outputs = [1,3], [5]
    edges = [(1,2), (2,3), (3,4), (4,5), (5,6), (1,6), (2,4), (4,6), (2,6)]
    return locs, edges, weights, inputs, outputs
end

function g_xor()
    locs = [rot16(0.0, 1.0, i) for i=3:8]
    push!(locs, locs[5] .* 1.75)
    weights = [1, 2, 1, 2, 2, 2, 1]
    inputs, outputs = [1,3], [7]
    edges = [(1,2), (2,3), (3,4), (4,5), (5,6), (1,6), (2,4), (4,6), (2,6), (5,7)]
    return locs, edges, weights, inputs, outputs
end

# inputs are mutually disconnected
# full adder
struct VertexScheduler
    count::Base.RefValue{Int}
    circuit::Vector{Pair{Symbol,Vector{Int}}}
    edges::Vector{Tuple{Int,Int}}
    weights::Vector{Int}
end
VertexScheduler() = VertexScheduler(Ref(0), Pair{Symbol,Vector{Int}}[], Tuple{Int,Int}[], Int[])
function newvertices!(vs::VertexScheduler, k::Int=1)
    vs.count[] += k
    append!(vs.weights, zeros(Int,k))
    return vs.count[]-k+1:vs.count[]
end

for (SYM, F) in [
        (:XOR, :g_xor),
        (:OR, :g_or),
        (:AND, :g_and),
    ]
@eval function apply!(::Val{$(QuoteNode(SYM))}, vs::VertexScheduler, a::Int, b::Int)
    locs, edges, weights, inputs, outputs = $F()
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
    push!(vs.circuit, $(QuoteNode(SYM)) => [inputs..., outputs...])

    return out
end
end

function multiplier()
    c = VertexScheduler()
    x0, x1, x2, x3 = newvertices!(c, 4)
    x12 = apply!(Val(:AND), c, x1, x2)
    x4 = apply!(Val(:XOR), c, x0, x12)
    x5 = apply!(Val(:XOR), c, x3, x4)  # 5 is sum
    x6 = apply!(Val(:AND), c, x3, x4)
    x7 = apply!(Val(:AND), c, x0, x12)
    x8 = apply!(Val(:OR), c, x6, x7)
    return c, [x0, x1, x2, x3], [x8, x5]
end

# function and!(c, dx, dy)
#     locs = [rot16(0.0, 1.0, i) .+ (dx, dy) for i=3:8]
#     c1 = rgbcolor!(c, 191, 191, 191)
#     c2 = rgbcolor!(c, 127, 127, 127)
#     colors = [c1, c2, c1, c2, c1, c2]
#     texts = ["\$a\$", "", "\$b\$", "", "\$c\$", ""]
#     edges = [(1,2), (2,3), (3,4), (4,5), (5,6), (1,6), (2,4), (4,6), (2,6)]
#     vg!(c, locs, edges; colors, texts)
#     text!(c, dx, dy-1.5, raw"$c = a \veebar b$")
# end

function g_and()
    u = sqrt(0.5)
    locs = [(-2u, 0.0), (-u, 0.0), (0.0, -u), (0.0, u), (2u, -u), (2u, u)]
    weights = fill(1, 6)
    weights[2] = 2
    inputs, outputs = [1,6], [3]
    edges = [(1,2), (2,3), (3,4), (2,4), (3,5), (4,6), (5,6)]
    return locs, edges, weights, inputs, outputs
end

