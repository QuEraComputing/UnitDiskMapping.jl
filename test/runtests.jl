using UnitDiskMapping
using Test

@testset "utils" begin
    include("utils.jl")
end

@testset "mapping" begin
    include("mapping.jl")
end

@testset "extracting_results" begin
    include("extracting_results.jl")
end

@testset "gadgets" begin
    include("gadgets.jl")
end

@testset "path decomposition" begin
    include("pathdecomposition/pathdecomposition.jl")
end

@testset "simplifiers" begin
    include("simplifiers.jl")
end

@testset "weighted" begin
    include("weighted.jl")
end
