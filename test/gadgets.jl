using UnitDiskMapping, Test
using GraphTensorNetworks
using GraphTensorNetworks: content
using Graphs

@testset "gadgets" begin
    function is_diff_by_const(t1::AbstractArray{T}, t2::AbstractArray{T}) where T
        x = NaN
        for (a, b) in zip(t1, t2)
            if isinf(a) && isinf(b)
                continue
            end
            if isinf(a) || isinf(b)
                return false, 0
            end
            if isnan(x)
                x = (a - b)
            elseif x != a - b
                return false, 0
            end
        end
        return true, x
    end
    for s in (Cross{false}(), Cross{true}(), TShape{:V, true}(), TShape{:V,false}(),
            TShape{:H,true}(), TShape{:H, false}(), Turn(), Corner{true}(), Corner{false}())
        @show s
        locs1, g1, pins1 = source_graph(s)
        locs2, g2, pins2 = mapped_graph(s)
        @assert length(locs1) == nv(g)
        m1 = mis_compactify!(solve(Independence(g1, openvertices=pins1), "size max"))
        m2 = mis_compactify!(solve(Independence(g2, openvertices=pins2), "size max"))
        @test nv(g1) == length(locs1) && nv(g2) == length(locs2)
        sig, diff = is_diff_by_const(content.(m1), content.(m2))
        @test diff == -mis_overhead(s)
        @test sig
    end
end