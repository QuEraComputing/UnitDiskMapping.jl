struct SimpleCell{RT} <: AbstractCell
    occupied::Bool
    weight::RT
end
function Base.show(io::IO, x::SimpleCell)
    if x.occupied
        print(io, "●")
    else
        print(io, "⋅")
    end
end
Base.show(io::IO, ::MIME"text/plain", cl::SimpleCell) = Base.show(io, cl)
Base.isempty(sc::SimpleCell) = !sc.occupied
Base.zero(::Type{SimpleCell{T}}) where T = SimpleCell(false, zero(T))
SimpleCell(x::Real) = SimpleCell(true, x)
SimpleCell{T}(x::Real) where T = SimpleCell(true, T(x))

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
    res = zeros(T, nrow, ncol)
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
"""
function map_qubo(J::AbstractMatrix{T1}, H::AbstractVector{T2}) where {T1, T2}
    T = promote_type(T1, T2)
    n = length(H)
    @assert size(J) == (n, n) "The size of coupling matrix `J`: $(size(J)) not consistent with size of onsite term `H`: $(size(H))"
    d = crossing_lattice(complete_graph(n), 1:n)
    z = zero(SimpleCell{T})
    e = SimpleCell(one(T))
    res = dragondrop(d) do ci, block
        if block.bottom != -1 && block.left != -1
            # NOTE: right and top can be empty, because we can overshoot the line.
            return [z  z  e  z;
            e  SimpleCell{T}(-J[ci]+H[ci.I[1]]-H[ci.I[2]]+4)  SimpleCell{T}(-J[ci]-H[ci.I[1]]+H[ci.I[2]]+4)  z;
            z  SimpleCell{T}(J[ci]+H[ci.I[1]]+H[ci.I[2]]+4)  SimpleCell{T}(J[ci]-H[ci.I[1]]-H[ci.I[2]]+4)  e;
            z  e  z  z]
        elseif block.top != -1 && block.right != -1
            m = fill(z, 4, 4)
            m[1, 3] = m[3, 4] = e
            return m
        else
            # do nothing
            return fill(z, 4, 4)
        end
    end
    return res[1:end-4, 5:end]
end