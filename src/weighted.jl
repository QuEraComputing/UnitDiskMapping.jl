struct WeightedCell{RT}
    occupied::Bool
    doubled::Bool
    connected::Bool
    weight::RT
end

abstract type WeightedCrossPattern end
abstract type WeightedSimplifyPattern end
const WeightedPattern = Union{WeightedCrossPattern, WeightedSimplifyPattern}

export source_matrix, mapped_matrix
function source_matrix(p::WeightedPattern)
    m, n = size(p)
    locs, _, _, weight = source_graph(p)
    a = locs2matrix(m, n, locs, weight)
    iscon(p) && connect!(a, p)
    return a
end

function mapped_matrix(p::Pattern)
    m, n = size(p)
    locs, _, _, weight = mapped_graph(p)
    locs2matrix(m, n, locs, weight)
end

function locs2matrix(m, n, locs::AbstractVector{Tuple{Int,Int}}, weight)
    a = fill(empty(Cell), m, n)
    for (i, j) in locs
        add_cell!(a, i, j, weight)
    end
    return a
end

