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
        m1 = mis_compactify!(solve(Independence(g1, openvertices=pins1), "size max"))
        m2 = mis_compactify!(solve(Independence(g2, openvertices=pins2), "size max"))
        @test nv(g1) == length(locs1) && nv(g2) == length(locs2)
        @show m1, m2
        sig, diff = is_diff_by_const(content.(m1), content.(m2))
        @test diff == -mis_overhead(s)
        @test sig
    end
end

s = Cross{false}()
locs1, g1, pins1 = source_graph(s)
locs2, g2, pins2 = mapped_graph(s)
solve(Independence(g1, openvertices=pins1), "configs max")
solve(Independence(g2, openvertices=pins1), "configs max")

function compact_map(a::AbstractArray{T}) where T
    b = mis_compactify!(copy(a))
    n = length(a)
    d = Dict{Int,Int}()  # the mapping from bad to good
    for i=1:n
        val_a = a[i]
        if iszero(b[i]) && !iszero(val_a)
            bs_a = i-1
            for j=1:n # search for the entry b[j] compactify a[i]
                bs_b = j-1
                if b[j] == val_a && (bs_b & bs_a) == bs_b  # find you!
                    d[bs_a] = bs_b
                    break
                end
            end
        else
            d[i-1] = i-1
        end
    end
    return d
end
