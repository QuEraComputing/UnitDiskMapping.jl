using UnitDiskMapping
using Test

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