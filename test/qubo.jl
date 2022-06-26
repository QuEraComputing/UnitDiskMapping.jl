using Test, UnitDiskMapping

@testset "qubo" begin
    n = 6
    H = randn(n) * 0.01
    J = randn(n, n) * 0.01
    qubo = UnitDiskMapping.map_qubo(J, H)
    println(qubo)
    #display(MappingGrid(UnitDiskMapping.CopyLine[], 0, qubo))
end