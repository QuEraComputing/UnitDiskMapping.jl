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
    mis_overhead = (n - 1) * n * 4 + n - 4
    return QUBOResult(gg, pins, mis_overhead)
end

"""
    map_qubo_restricted(coupling::AbstractVector) -> RestrictedQUBOResult

Map a nearest-neighbor restricted QUBO problem to a weighted MIS problem on a grid graph,
where the QUBO problem can be specified by a vector of `(i, j, i', j', J)`.

```math
E(z) = -\\sum_{(i,j)\\in E} J_{ij} z_i z_j
```

A FM gadget is

```
- ⋅ + ⋅ ⋅ ⋅ + ⋅ -
⋅ ⋅ ⋅ ⋅ 4 ⋅ ⋅ ⋅ ⋅ 
+ ⋅ - ⋅ ⋅ ⋅ - ⋅ +
```

where `+`, `-` and `4` are weights of nodes `+J`, `-J` and `4J`.

```
- ⋅ + ⋅ ⋅ ⋅ + ⋅ -
⋅ ⋅ ⋅ 4 ⋅ 4 ⋅ ⋅ ⋅ 
+ ⋅ - ⋅ ⋅ ⋅ - ⋅ +
```
"""
function map_qubo_restricted(coupling::AbstractVector{Tuple{Int,Int,Int,Int,T}}) where {T}
    m, n = max(maximum(x->x[1], coupling), maximum(x->x[3], coupling)), max(maximum(x->x[2], coupling), maximum(x->x[4], coupling))
    hchunks = [zeros(SimpleCell{T}, 3, 9) for i=1:m, j=1:n-1]
    vchunks = [zeros(SimpleCell{T}, 9, 3) for i=1:m-1, j=1:n]
    # add coupling
    for (i, j, i2, j2, J) in coupling
        @assert (i2, j2) == (i, j+1) || (i2, j2) == (i+1, j)
        if (i2, j2) == (i, j+1)
            hchunks[i, j] .+= cell_matrix(gadget_qubo_restricted(J))
        else
            vchunks[i, j] .+= rotr90(cell_matrix(gadget_qubo_restricted(J)))
        end
    end
    grid = glue(hchunks, -3, 3) .+ glue(vchunks, 3, -3)
    return RestrictedQUBOResult(GridGraph(grid, 2.01*sqrt(2)))
end

function gadget_qubo_restricted(J::T) where T
    a = abs(J)
    return GridGraph((3, 9),
        [
            Node((1,1), -a),
            Node((3,1), -a),
            Node((1,9), -a),
            Node((3,9), -a),
            Node((1,3), a),
            Node((3,3), a),
            Node((1,7), a),
            Node((3,7), a),
            (J > 0 ? [Node((2,5), 4a)] : [Node((2,4), 4a), Node((2,6), 4a)])...
        ], 2.01*sqrt(2))
end

"""
    map_qubo_square(coupling::AbstractVector, onsite::AbstractVector) -> SquareQUBOResult

Map a QUBO problem on square lattice to a weighted MIS problem on a grid graph,
where the QUBO problem can be specified by
* a vector coupling of `(i, j, i', j', J)`, s.t. (i', j') == (i, j+1) or (i', j') = (i+1, j).
* a vector of onsite term `(i, j, h)`.

```math
E(z) = -\\sum_{(i,j)\\in E} J_{ij} z_i z_j + h_i z_i
```

The gadget for suqare lattice QUBO problem is as follows
```
⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ 
○ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ○ 
⋅ ⋅ ⋅ ● ⋅ ● ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ 
```
where white circles have weight 1 and black circles have weight 2. The unit distance is `2.3`.
"""
function map_qubo_square(coupling::AbstractVector{Tuple{Int,Int,Int,Int,T1}}, onsite::AbstractVector{Tuple{Int,Int,T2}}) where {T1,T2}
    T = promote_type(T1, T2)
    m, n = max(maximum(x->x[1], coupling), maximum(x->x[3], coupling)), max(maximum(x->x[2], coupling), maximum(x->x[4], coupling))
    hchunks = [zeros(SimpleCell{T}, 4, 9) for i=1:m, j=1:n-1]
    vchunks = [zeros(SimpleCell{T}, 9, 4) for i=1:m-1, j=1:n]
    # add coupling
    sumJ = zero(T)
    for (i, j, i2, j2, J) in coupling
        @assert (i2, j2) == (i, j+1) || (i2, j2) == (i+1, j)
        if (i2, j2) == (i, j+1)
            hchunks[i, j] .+= cell_matrix(gadget_qubo_square(T))
            hchunks[i, j][4, 5] -= SimpleCell(T(2J))
        else
            vchunks[i, j] .+= rotr90(cell_matrix(gadget_qubo_square(T)))
            vchunks[i, j][5, 1] -= SimpleCell(T(2J))
        end
        sumJ += J
    end
    # right shift by 2
    grid = glue(hchunks, -4, 1)
    grid = pad(grid; left=2, right=1)
    # down shift by 1
    grid2 = glue(vchunks, 1, -4)
    grid2 = pad(grid2; top=1, bottom=2)
    grid .+= grid2
    
    # add onsite terms
    sumh = zero(T)
    for (i, j, h) in onsite
        grid[(i-1)*8+2, (j-1)*8+3] -= SimpleCell(T(2h))
        sumh += h
    end

    overhead = 5 * length(coupling) - sumJ - sumh
    gg = GridGraph(grid, 2.3)
    pins = Int[]
    for (i, j, h) in onsite
        push!(pins, findfirst(n->n.loc == ((i-1)*8+2, (j-1)*8+3), gg.nodes))
    end
    return SquareQUBOResult(gg, pins, overhead)
end

function pad(m::AbstractMatrix{T}; top::Int=0, bottom::Int=0, left::Int=0, right::Int=0) where T
    if top != 0
        padt = zeros(T, 0, size(m, 2))
        m = vglue([padt, m], -top)
    end
    if bottom != 0
        padb = zeros(T, 0, size(m, 2))
        m = vglue([m, padb], -bottom)
    end
    if left != 0
        padl = zeros(T, size(m, 1), 0)
        m = hglue([padl, m], -left)
    end
    if right != 0
        padr = zeros(T, size(m, 1), 0)
        m = hglue([m, padr], -right)
    end
    return m
end
vglue(mats, i::Int) = glue(reshape(mats, :, 1), i, 0)
hglue(mats, j::Int) = glue(reshape(mats, 1, :), 0, j)

function gadget_qubo_square(::Type{T}) where T
    DI = 1
    DJ = 2
    one = T(1)
    two = T(2)
    return GridGraph((4, 9),
        [
            Node((1+DI,1), one),
            Node((1+DI,1+DJ), two),
            Node((DI,3+DJ), two),
            Node((1+DI,5+DJ), two),
            Node((1+DI,5+2DJ), one),
            Node((2+DI,2+DJ), two),
            Node((2+DI,4+DJ), two),
            Node((3+DI,3+DJ), one),
        ], 2.3)
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
    mis_overhead = (n - 1) * n * 4 + n - 4 - 2*ne(graph)
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
                (ci.I[2]==2 ? one : two)  two   two  z;
                z    two   z  (block.right == -1 ? one : two);
                z  (ci.I[1] == n-1 ? one : two)  z  z]
            else
                [z  z  (block.top == -1 ? one : two)  z;
                (ci.I[2]==2 ? one : two)  four   four  z;
                z    four   four  (block.right == -1 ? one : two);
                z  (ci.I[1] == n-1 ? one : two)  z  z]
            end
        elseif block.top != -1 && block.right != -1 # the L turn
            m = fill(z, 4, 4)
            m[1, 3] = m[2, 4] = two
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
    mat = grid[1:end-4, 5:end]
    mat[2, 1] += SimpleCell{T}(h0[1])   # top left
    mat[size(mat, 1),size(mat, 2)-2] += SimpleCell{T}(h1[end])  # bottom right
    for j=1:length(h0)-1
        # top side
        offset = mat[1, j*4-1].occupied ? 1 : 2
        @assert mat[1, j*4-offset].occupied
        mat[1, j*4-offset] += SimpleCell{T}(h0[1+j])
        # right side
        offset = mat[j*4-1,size(mat,2)].occupied ? 1 : 2
        @assert mat[j*4-offset,size(mat,2)].occupied
        mat[j*4-offset,size(mat, 2)] += SimpleCell{T}(h1[j])
    end

    # generate GridGraph from matrix
    locs = [Node(ci.I, mat[ci].weight) for ci in findall(x->x.occupied, mat)]
    gg = GridGraph(size(mat), locs, 1.5)

    # find pins
    pins = [findfirst(x->x.loc == (2, 1), locs)]
    for i=1:n-1
        push!(pins, findfirst(x->x.loc == (1, i*4-1) || x.loc == (1,i*4-2), locs))
    end
    return gg, pins
end

struct QUBOResult{NT}
    grid_graph::GridGraph{NT}
    pins::Vector{Int}
    mis_overhead::Int
end
function map_config_back(res::QUBOResult, cfg)
    return 1 .- cfg[res.pins]
end

struct WMISResult{NT}
    grid_graph::GridGraph{NT}
    pins::Vector{Int}
    mis_overhead::Int
end
function map_config_back(res::WMISResult, cfg)
    return cfg[res.pins]
end

struct RestrictedQUBOResult{NT}
    grid_graph::GridGraph{NT}
end
function map_config_back(res::RestrictedQUBOResult, cfg)
end

struct SquareQUBOResult{NT}
    grid_graph::GridGraph{NT}
    pins::Vector{Int}
    mis_overhead::Float64
end
function map_config_back(res::SquareQUBOResult, cfg)
    return cfg[res.pins]
end
