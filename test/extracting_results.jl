using UnitDiskMapping, Test
using GraphTensorNetworks

@testset "map results back" begin
    for s in (Cross{false}(), Cross{true}(), Turn(), TCon(), 
                    WTurn(), Branch(), BranchFix(), TrivialTurn(),
                    RotatedGadget(TCon(), 1), ReflectedGadget(Cross{true}(), "y"),
                    ReflectedGadget(TrivialTurn(), "y"), BranchFixB(),
                    ReflectedGadget(RotatedGadget(TCon(), 1), "y"),)
        _, g0, pins0 = source_graph(s)
        locs, g, pins = mapped_graph(s)
        d1 = mapped_entry_to_compact(s)
        d2 = source_entry_to_configs(s)
        m = solve(Independence(g, openvertices=pins), "configs max")
        t = solve(Independence(g0, openvertices=pins0), "size max")
        for i=1:length(m)
            for v in m[i].c.data
                bc = mapped_boundary_config(s, v)
                compact_bc = d1[bc]
                sc = d2[compact_bc]
                for sbc in sc
                    ss = source_boundary_config(s, sbc)
                    @test ss == compact_bc
                    @test count(isone, sbc) == Int(t[compact_bc+1].n)
                end
            end
        end
    end
end