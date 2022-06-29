using UnitDiskMapping, Test
using GenericTensorNetworks

@testset "map results back" begin
    for s in [UnitDiskMapping.crossing_ruleset..., UnitDiskMapping.simplifier_ruleset...]
        _, g0, pins0 = source_graph(s)
        locs, g, pins = mapped_graph(s)
        d1 = UnitDiskMapping.mapped_entry_to_compact(s)
        d2 = UnitDiskMapping.source_entry_to_configs(s)
        m = solve(IndependentSet(g, openvertices=pins), ConfigsMax())
        t = solve(IndependentSet(g0, openvertices=pins0), SizeMax())
        for i=1:length(m)
            for v in m[i].c.data
                bc = UnitDiskMapping.mapped_boundary_config(s, v)
                compact_bc = d1[bc]
                sc = d2[compact_bc]
                for sbc in sc
                    ss = UnitDiskMapping.source_boundary_config(s, sbc)
                    @test ss == compact_bc
                    @test count(isone, sbc) == Int(t[compact_bc+1].n)
                end
            end
        end
    end
end