using UnitDiskMapping, Test
using GenericTensorNetworks

@testset "gates" begin
    for (f, gate) in [(!, :NOT), (⊻, :XOR), ((a, b)->a && b, :AND),
        ((a, b)->a || b, :OR), ((a, b)->!(a || b), :NOR), ((a, b)->!(a ⊻ b), :NXOR)]
        @info gate
        g, inputs, outputs = gate_gadget(Gate(gate))
        @test UnitDiskMapping.truth_table(Gate(gate)) do graph, weights
            collect.(Int, solve(IndependentSet(graph; weights), ConfigsMax())[].c.data)
        end == [f([x>>(i-1) & 1 == 1 for i=1:length(inputs)]...) for x in 0:1<<length(inputs)-1]
    end
end