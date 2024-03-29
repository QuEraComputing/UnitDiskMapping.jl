# Do not modify this file, because it is automatically generated by `project/createmap.jl`

function mapped_entry_to_compact(::Cross{false})
    return Dict([5 => 4, 12 => 4, 8 => 0, 1 => 0, 0 => 0, 6 => 0, 11 => 11, 9 => 9, 14 => 2, 3 => 2, 7 => 2, 4 => 4, 13 => 13, 15 => 11, 2 => 2, 10 => 2])
end

function source_entry_to_configs(::Cross{false})
    return Dict(Pair{Int64, Vector{BitVector}}[5 => [[1, 0, 1, 0, 0, 0, 1, 0, 1], [1, 0, 0, 1, 0, 0, 1, 0, 1]], 12 => [[0, 0, 1, 0, 1, 0, 1, 0, 1], [0, 1, 0, 0, 1, 0, 1, 0, 1]], 8 => [[0, 0, 1, 0, 1, 0, 0, 1, 0], [0, 1, 0, 0, 1, 0, 0, 1, 0], [0, 0, 1, 0, 1, 0, 1, 0, 0], [0, 1, 0, 0, 1, 0, 1, 0, 0]], 1 => [[1, 0, 1, 0, 0, 0, 0, 1, 0], [1, 0, 0, 1, 0, 0, 0, 1, 0], [1, 0, 1, 0, 0, 0, 1, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0]], 0 => [[0, 1, 0, 1, 0, 0, 0, 1, 0], [0, 1, 0, 1, 0, 0, 1, 0, 0]], 6 => [[0, 1, 0, 1, 0, 1, 0, 0, 1]], 11 => [[1, 0, 1, 0, 1, 1, 0, 1, 0]], 9 => [[1, 0, 1, 0, 1, 0, 0, 1, 0], [1, 0, 1, 0, 1, 0, 1, 0, 0]], 14 => [[0, 0, 1, 0, 1, 1, 0, 0, 1], [0, 1, 0, 0, 1, 1, 0, 0, 1]], 3 => [[1, 0, 1, 0, 0, 1, 0, 1, 0], [1, 0, 0, 1, 0, 1, 0, 1, 0]], 7 => [[1, 0, 1, 0, 0, 1, 0, 0, 1], [1, 0, 0, 1, 0, 1, 0, 0, 1]], 4 => [[0, 1, 0, 1, 0, 0, 1, 0, 1]], 13 => [[1, 0, 1, 0, 1, 0, 1, 0, 1]], 15 => [[1, 0, 1, 0, 1, 1, 0, 0, 1]], 2 => [[0, 1, 0, 1, 0, 1, 0, 1, 0]], 10 => [[0, 0, 1, 0, 1, 1, 0, 1, 0], [0, 1, 0, 0, 1, 1, 0, 1, 0]]])
end

mis_overhead(::Cross{false}) = -1


function mapped_entry_to_compact(::Cross{true})
    return Dict([5 => 5, 12 => 12, 8 => 0, 1 => 0, 0 => 0, 6 => 6, 11 => 11, 9 => 9, 14 => 14, 3 => 3, 7 => 7, 4 => 0, 13 => 13, 15 => 15, 2 => 0, 10 => 10])
end

function source_entry_to_configs(::Cross{true})
    return Dict(Pair{Int64, Vector{BitVector}}[5 => [], 12 => [[0, 0, 1, 0, 0, 1]], 8 => [[0, 0, 1, 0, 1, 0]], 1 => [[1, 0, 0, 0, 1, 0]], 0 => [[0, 1, 0, 0, 1, 0]], 6 => [[0, 1, 0, 1, 0, 1]], 11 => [[1, 0, 1, 1, 0, 0]], 9 => [[1, 0, 1, 0, 1, 0]], 14 => [[0, 0, 1, 1, 0, 1]], 3 => [[1, 0, 0, 1, 0, 0]], 7 => [], 4 => [[0, 1, 0, 0, 0, 1]], 13 => [], 15 => [], 2 => [[0, 1, 0, 1, 0, 0]], 10 => [[0, 0, 1, 1, 0, 0]]])
end

mis_overhead(::Cross{true}) = -1


function mapped_entry_to_compact(::Turn)
    return Dict([0 => 0, 2 => 0, 3 => 3, 1 => 0])
end

function source_entry_to_configs(::Turn)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[0, 1, 0, 1, 0]], 2 => [[0, 1, 0, 0, 1], [0, 0, 1, 0, 1]], 3 => [[1, 0, 1, 0, 1]], 1 => [[1, 0, 1, 0, 0], [1, 0, 0, 1, 0]]])
end

mis_overhead(::Turn) = -1


function mapped_entry_to_compact(::WTurn)
    return Dict([0 => 0, 2 => 0, 3 => 3, 1 => 0])
end

function source_entry_to_configs(::WTurn)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[1, 0, 1, 0, 0]], 2 => [[0, 0, 0, 1, 1], [1, 0, 0, 0, 1]], 3 => [[0, 1, 0, 1, 1]], 1 => [[0, 1, 0, 1, 0], [0, 1, 1, 0, 0]]])
end

mis_overhead(::WTurn) = -1


function mapped_entry_to_compact(::Branch)
    return Dict([0 => 0, 4 => 0, 5 => 5, 6 => 6, 2 => 0, 7 => 7, 3 => 3, 1 => 0])
end

function source_entry_to_configs(::Branch)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[0, 1, 0, 1, 0, 0, 1, 0]], 4 => [[0, 0, 1, 0, 0, 1, 0, 1], [0, 1, 0, 0, 0, 1, 0, 1], [0, 1, 0, 1, 0, 0, 0, 1]], 5 => [[1, 0, 1, 0, 0, 1, 0, 1]], 6 => [[0, 0, 1, 0, 1, 1, 0, 1], [0, 1, 0, 0, 1, 1, 0, 1]], 2 => [[0, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 0, 1, 0, 1, 0], [0, 0, 1, 0, 1, 1, 0, 0], [0, 1, 0, 0, 1, 1, 0, 0]], 7 => [[1, 0, 1, 0, 1, 1, 0, 1]], 3 => [[1, 0, 1, 0, 1, 0, 1, 0], [1, 0, 1, 0, 1, 1, 0, 0]], 1 => [[1, 0, 1, 0, 0, 0, 1, 0], [1, 0, 1, 0, 0, 1, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0]]])
end

mis_overhead(::Branch) = -1


function mapped_entry_to_compact(::BranchFix)
    return Dict([0 => 0, 2 => 2, 3 => 1, 1 => 1])
end

function source_entry_to_configs(::BranchFix)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[0, 1, 0, 1, 0, 0], [0, 1, 0, 0, 1, 0], [0, 0, 1, 0, 1, 0]], 2 => [[0, 1, 0, 1, 0, 1]], 3 => [[1, 0, 0, 1, 0, 1], [1, 0, 1, 0, 0, 1]], 1 => [[1, 0, 1, 0, 1, 0]]])
end

mis_overhead(::BranchFix) = -1


function mapped_entry_to_compact(::TrivialTurn)
    return Dict([0 => 0, 2 => 2, 3 => 3, 1 => 1])
end

function source_entry_to_configs(::TrivialTurn)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[0, 0]], 2 => [[0, 1]], 3 => [], 1 => [[1, 0]]])
end

mis_overhead(::TrivialTurn) = 0


function mapped_entry_to_compact(::TCon)
    return Dict([0 => 0, 4 => 0, 5 => 5, 6 => 6, 2 => 2, 7 => 7, 3 => 3, 1 => 0])
end

function source_entry_to_configs(::TCon)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[0, 0, 1, 0]], 4 => [[0, 0, 0, 1]], 5 => [[1, 0, 0, 1]], 6 => [[0, 1, 0, 1]], 2 => [[0, 1, 1, 0]], 7 => [], 3 => [], 1 => [[1, 0, 0, 0]]])
end

mis_overhead(::TCon) = 0


function mapped_entry_to_compact(::BranchFixB)
    return Dict([0 => 0, 2 => 2, 3 => 3, 1 => 1])
end

function source_entry_to_configs(::BranchFixB)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[0, 0, 1, 0], [0, 1, 0, 0]], 2 => [[0, 0, 1, 1]], 3 => [[1, 0, 0, 1]], 1 => [[1, 1, 0, 0]]])
end

mis_overhead(::BranchFixB) = -1


function mapped_entry_to_compact(::EndTurn)
    return Dict([0 => 0, 1 => 1])
end

function source_entry_to_configs(::EndTurn)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[0, 0, 1], [0, 1, 0]], 1 => [[1, 0, 1]]])
end

mis_overhead(::EndTurn) = -1


function mapped_entry_to_compact(::UnitDiskMapping.DanglingLeg)
    return Dict([0 => 0, 1 => 1])
end

function source_entry_to_configs(::UnitDiskMapping.DanglingLeg)
    return Dict(Pair{Int64, Vector{BitVector}}[0 => [[1, 0, 0], [0, 1, 0]], 1 => [[1, 0, 1]]])
end

mis_overhead(::UnitDiskMapping.DanglingLeg) = -1
