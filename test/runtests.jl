using UnitDiskMapping
using Test

@testset "utils" begin
    include("utils.jl")
end

@testset "copyline" begin
    include("copyline.jl")
end

@testset "multiplier" begin
    include("multiplier.jl")
end

@testset "logic gates" begin
    include("logicgates.jl")
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

@testset "drag and drop" begin
    include("dragondrop.jl")
end

@testset "visualize" begin
    include("visualize.jl")
end
