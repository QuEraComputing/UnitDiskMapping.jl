function dragondrop(f, d::CrossingLattice)
    grid = map(zip(CartesianIndices(d), d)) do (ci, block)
        #println(block)
        f(ci, block)
    end
    return glue(grid)
end

function glue2(grid::AbstractMatrix{<:AbstractMatrix{T}}) where T
    @assert size(grid, 1) > 0 && size(grid, 2) > 0
    nrow = sum(x->size(x, 1)-1, grid) + 1
    ncol = sum(x->size(x, 2)-1, grid) + 1
    res = zeros(T, nrow, ncol)
    ioffset = 0
    for i=1:size(grid, 1)
        joffset = 0
        for j=1:size(grid, 2)
            chunk = grid[i, j]
            res[ioffset+1:ioffset+size(chunk, 1), joffset+1:joffset+size(chunk, 2)] .+= chunk
            joffset += size(chunk, 2) - 1
            j == size(grid, 2) && (ioffset += size(chunk, 1)-1)
        end
    end
    return res
end

function glue(grid::AbstractMatrix{<:AbstractMatrix{T}}) where T
    #display(grid)
    @assert size(grid, 1) > 0 && size(grid, 2) > 0
    nrow = sum(x->size(x, 1), grid[:,1])
    ncol = sum(x->size(x, 2), grid[1,:])
    res = fill(empty(T), nrow, ncol)
    ioffset = 0
    for i=1:size(grid, 1)
        joffset = 0
        for j=1:size(grid, 2)
            chunk = grid[i, j]
            res[ioffset+1:ioffset+size(chunk, 1), joffset+1:joffset+size(chunk, 2)] .= chunk
            joffset += size(chunk, 2)
            j == size(grid, 2) && (ioffset += size(chunk, 1))
        end
    end
    return res
end

"""
QUBO problem that defined by the following Hamiltonian.

```math
E(z) = -\\sum_{i<j} J_{ij} z_i z_j + \\sum_i h_i z_i
```

A QUBO gadget is

```
⋅ ⋅ ● ⋅
● A B ⋅
⋅ C D ●
⋅ ● ⋅ ⋅
```

where `A`, `B`, `C` and `D` are weights of nodes that defined as

```math
\\begin{align}
A = -J_{ij} + 4\\\\
B = J_{ij} + 4\\\\
C = J_{ij} + 4\\\\
D = -J_{ij} + 4
\\end{align}
```

The rest nodes: `●` have weights 2 (boundary nodes have weights ``1 - h_i``).
"""
function map_qubo(J::AbstractMatrix{T1}, h::AbstractVector{T2}) where {T1, T2}
    T = promote_type(T1, T2)
    n = length(h)
    @assert size(J) == (n, n) "The size of coupling matrix `J`: $(size(J)) not consistent with size of onsite term `h`: $(size(h))"
    d = crossing_lattice(complete_graph(n), 1:n)
    chunks = render_grid(T, d)
    # add coupling
    for i=1:n-1
        for j=i+1:n
            a = J[i,j]
            chunks[i, j][2:3, 2:3] .+= SimpleCell.([-a a; a -a])
        end
    end
    grid = glue(chunks)
    # add one extra row
    # make the grid larger by one unit
    gg, pins = post_process_grid(grid, h, -h)
    mis_overhead = (n - 1) * n * 4 + 2n - 4
    return QUBOResult(gg, pins, mis_overhead)
end

function render_grid(::Type{T}, cl::CrossingLattice) where T
    adjm = adjacency_matrix(cl.graph)
    n = nv(cl.graph)
    z = empty(SimpleCell{T})
    one = SimpleCell(T(1))
    two = SimpleCell(T(2))
    four = SimpleCell(T(4))

    # replace chunks
    # for pure crossing, they are 
    #      ●
    #  ● ● ●
    #    ● ● ●
    #    ●

    # for crossing with edge, they are 
    #    ●
    #  ● ● ●
    #    ●
    return map(zip(CartesianIndices(cl), cl)) do (ci, block)
        if block.bottom != -1 && block.left != -1
            # NOTE: for border vertices, we set them to weight 1.
            [z  z  (block.top == -1 ? one : two)  z;
            (block.left == -1 ? one : two)  four   four  z;
            z    four   four  (block.right == -1 ? one : two);
            z  (ci.I[1] == n-1 ? one : two)  z  z]
        elseif block.top != -1 && block.right != -1 # the L turn
            m = fill(z, 4, 4)
            m[1, 3] = m[2, 4] = two
            m
        elseif block.right != -1 # the left most site
            m = fill(z, 4, 4)
            m[3, 4] = one
            m
        else
            # do nothing
            fill(z, 4, 4)
        end
    end
end

# h0 and h1 are offset of energy for 0 state and 1 state.
function post_process_grid(grid::Matrix{SimpleCell{T}}, h0, h1) where T
    n = length(h0)
    # the first vertex
    grid[3, 4] += SimpleCell{T}(h1[1])
    grid[2, 5] += SimpleCell{T}(h0[1])
    # 2-
    topbar = zeros(SimpleCell{T}, 1, 4*n-3)
    topbar[1, 3:4:end] .+= SimpleCell{T}.(1 .+ h1[2:end])
    grid[1, 7:4:end] .+= SimpleCell{T}.(1 .+ h0[2:end])

    mat = vcat(topbar, grid[1:end-4, 4:end])

    # generate GridGraph from matrix
    locs = [Node(ci.I, mat[ci].weight) for ci in findall(x->x.occupied, mat)]
    gg = GridGraph(size(mat), locs, 1.5)

    # find pins
    pins = [findfirst(x->x.loc == (4, 1), locs)]
    for i=1:n-1
        push!(pins, findfirst(x->x.loc == (1, i*4-1), locs))
    end
    return gg, pins
end

struct QUBOResult{NT}
    grid_graph::GridGraph{NT}
    pins::Vector{Int}
    mis_overhead::Int
end

function map_configs_back(res::QUBOResult, configs::AbstractVector)
    return map_qubo_config_back.(Ref(res), configs)
end
function map_qubo_config_back(res::QUBOResult, cfg)
    return cfg[res.pins]
end