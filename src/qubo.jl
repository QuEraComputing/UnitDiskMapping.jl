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
E(z) = \\sum_{i<j} J_{ij} z_i z_j + \\sum_i H_i z_i
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
A = -J_{ij} + H_i - H_j + 4\\\\
B = -J_{ij} - H_i + H_j + 4\\\\
C = J_{ij} + H_i + H_j + 4\\\\
D = J_{ij} - H_i - H_j + 4
\\end{align}
```

The rest nodes: `●` have weights 2 (boundary nodes have weights 1).
"""
function map_qubo(J::AbstractMatrix{T1}, H::AbstractVector{T2}) where {T1, T2}
    T = promote_type(T1, T2)
    n = length(H)
    @assert size(J) == (n, n) "The size of coupling matrix `J`: $(size(J)) not consistent with size of onsite term `H`: $(size(H))"
    d = crossing_lattice(complete_graph(n), 1:n)
    z = empty(SimpleCell{T})
    one = SimpleCell(T(1))
    two = SimpleCell(T(2))
    res = dragondrop(d) do ci, block
        if block.bottom != -1 && block.left != -1
            # NOTE: for border vertices, we set them to weight 1.
            return [z  z  two  z;
            two  SimpleCell{T}(J[ci]+4)    SimpleCell{T}(-J[ci]+4)  z;
            z    SimpleCell{T}(-J[ci]+4)   SimpleCell{T}(J[ci]+4)  (block.right == -1 ? one : two);
            z  (ci.I[1] == n-1 ? one : two)  z  z]
        elseif block.top != -1 && block.right != -1
            m = fill(z, 4, 4)
            m[1, 3] = m[2, 4] = two
            return m
        else
            # do nothing
            return fill(z, 4, 4)
        end
    end

    # the first vertex
    res[2, 4] = SimpleCell{T}(1 + H[1])
    res[2, 5] = SimpleCell{T}(2 - H[1])
    # 2-
    topbar = fill(z, 1, 4*n-3)
    topbar[1, 3:4:end] .= SimpleCell{T}.(1 .+ H[2:end])
    res[1, 7:4:end] .= SimpleCell{T}.(2 .- H[2:end])

    mat = vcat(topbar, res[1:end-4, 4:end])
    # generate GridGraph from matrix
    locs = [Node(ci.I, mat[ci].weight) for ci in findall(x->x.occupied, mat)]
    return GridGraph(size(mat), locs, 1.5)
end