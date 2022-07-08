using UnitDiskMapping, Test

@testset "gates" begin
    for gate in [:NOT, :XOR, :AND, :OR, :NOR, :NXOR]
        g, inputs, outputs = gate_gadget(Gate(gate))
        truth_table()
    end
end