using UnitDiskMapping: rotate90, reflectx, reflecty, reflectdiag, reflectoffdiag
using Test

@testset "symmetry operations" begin
    center = (2,2)
    loc = (4,3)
    @test rotate90(loc, center) == (1,4)
    @test reflectx(loc, center) == (4,1)
    @test reflecty(loc, center) == (0,3)
    @test reflectdiag(loc, center) == (1,0)
    @test reflectoffdiag(loc, center) == (3,4)
end