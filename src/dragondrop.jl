# Glue multiple blocks into a whole
# `DI` and `DJ` are the overlap in row and columns between two adjacent blocks.
function glue(grid::AbstractMatrix{<:AbstractMatrix{SimpleCell{T}}}, DI::Int, DJ::Int) where T
    @assert size(grid, 1) > 0 && size(grid, 2) > 0
    nrow = sum(x->size(x, 1)-DI, grid[:,1]) + DI
    ncol = sum(x->size(x, 2)-DJ, grid[1,:]) + DJ
    res = zeros(SimpleCell{T}, nrow, ncol)
    ioffset = 0
    for i=1:size(grid, 1)
        joffset = 0
        for j=1:size(grid, 2)
            chunk = grid[i, j]
            res[ioffset+1:ioffset+size(chunk, 1), joffset+1:joffset+size(chunk, 2)] .+= chunk
            joffset += size(chunk, 2) - DJ
            j == size(grid, 2) && (ioffset += size(chunk, 1)-DI)
        end
    end
    return res
end

"""
    map_qubo(J::AbstractMatrix, h::AbstractVector) -> QUBOResult

Map a QUBO problem to a weighted MIS problem on a defected King's graph, where a QUBO problem is defined by the following Hamiltonian

```math
E(z) = -\\sum_{i<j} J_{ij} z_i z_j + \\sum_i h_i z_i
```

!!! note

    The input coupling strength and onsite energies must be << 1.

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
    d = CrossingLattice(d.width, d.height, d.lines, SimpleGraph(n))
    chunks = render_grid(T, d)
    # add coupling
    for i=1:n-1
        for j=i+1:n
            a = J[i,j]
            chunks[i, j][2:3, 2:3] .+= SimpleCell.([-a a; a -a])
        end
    end
    grid = glue(chunks, 0, 0)
    # add one extra row
    # make the grid larger by one unit
    gg, pins = post_process_grid(grid, h, -h)
    mis_overhead = (n - 1) * n * 4 + 2n - 4
    return QUBOResult(gg, pins, mis_overhead)
end

"""
    map_simple_wmis(graph::SimpleGraph, weights::AbstractVector) -> WMISResult

Map a weighted MIS problem to a weighted MIS problem on a defected King's graph.

!!! note

    The input coupling strength and onsite energies must be << 1.
    This method does not provide path decomposition based optimization, check [`map_graph`](@ref) for the path decomposition optimized version.
"""
function map_simple_wmis(graph::SimpleGraph, weights::AbstractVector{T}) where {T}
    n = length(weights)
    @assert nv(graph) == n
    d = crossing_lattice(complete_graph(n), 1:n)
    d = CrossingLattice(d.width, d.height, d.lines, graph)
    chunks = render_grid(T, d)
    grid = glue(chunks, 0, 0)
    # add one extra row
    # make the grid larger by one unit
    gg, pins = post_process_grid(grid, weights, zeros(T, length(weights)))
    mis_overhead = (n - 1) * n * 4 + 2n - 4 - 2*ne(graph)
    return WMISResult(gg, pins, mis_overhead)
end

function render_grid(::Type{T}, cl::CrossingLattice) where T
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
    #    ●   ●
    #    ●
    return map(zip(CartesianIndices(cl), cl)) do (ci, block)
        if block.bottom != -1 && block.left != -1
            # NOTE: for border vertices, we set them to weight 1.
            if has_edge(cl.graph, ci.I...)
                [z  (block.top == -1 ? one : two)  z  z;
                (block.left == -1 ? one : two)  two   two  z;
                z    two   z  (block.right == -1 ? one : two);
                z  (ci.I[1] == n-1 ? one : two)  z  z]
            else
                [z  z  (block.top == -1 ? one : two)  z;
                (block.left == -1 ? one : two)  four   four  z;
                z    four   four  (block.right == -1 ? one : two);
                z  (ci.I[1] == n-1 ? one : two)  z  z]
            end
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
    for j=1:length(h0)-1
        if grid[1, 3+j*4].occupied
            grid[1, 3+j*4] += SimpleCell{T}(1 + h0[1+j])
        else
            @assert grid[1, 2+j*4].occupied
            grid[1, 2+j*4] += SimpleCell{T}(1 + h0[1+j])
        end
    end

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
function map_config_back(res::QUBOResult, cfg)
    return cfg[res.pins]
end

struct WMISResult{NT}
    grid_graph::GridGraph{NT}
    pins::Vector{Int}
    mis_overhead::Int
end
function map_config_back(res::WMISResult, cfg)
    return 1 .- cfg[res.pins]
end