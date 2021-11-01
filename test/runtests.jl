using UnitDiskMapping
using Test

@testset "mapping" begin
    include("mapping.jl")
end

@testset "gadgets" begin
    include("gadgets.jl")
end