using UnitDiskMapping
using UnitDiskMapping.TikzGraph

function print_mapback(folder::String)
    for (p, sub) in ((Cross{true}(), "crosscon"), (Cross{false}(), "cross"),
        (Branch(), "branch"), (TCon(), "tcon"))
        println()
        println(typeof(p))
        for (bc, bcs) in allbcs(p)
            println(bcs)
            for config in map_config_back(p, bc)
                println(latex_config(p, config))
            end
        end
    end
end

function map_config_back(s::Pattern, cbc)
    d2 = source_entry_to_configs(s)
    # get the pin configuration
    return d2[cbc]
end

function allbcs(s::Pattern)
    d1 = mapped_entry_to_compact(s)
    ks = unique(values(d1))
    d2 = Dict([k=>Int[] for k in ks])
    for (k, v) in d1
        push!(d2[v], k)
    end
    return d2
end

function latex_config(p::Pattern, config)
    (m, n) = size(p)
    locs, = source_graph(p)
    a = zeros(Int, m, n)
    for ((i, j), c) in zip(locs, config)
        if c
            if a[i,j] == 0
                a[i,j] = 1
            elseif a[i,j] == -1
                a[i,j] = 1
            elseif a[i,j] == 1
                a[i,j] = 2
            end
        else
            if a[i,j] == 0
                a[i,j] = -1
            elseif a[i,j] == -1
                a[i,j] = -1
            elseif a[i,j] == 1
                a[i,j] = 1
            end
        end
    end
    s = raw"\begin{equation*}\begin{matrix}"
    for i=1:m
        for j=1:n
            if j!=1
                s *= raw"&"
            end
            if a[i,j] == 2
                s *= raw"\doubleblackcircle"
            elseif a[i,j] == 1
                s *= raw"\blackcircle"
            elseif a[i,j] == -1
                s *= raw"\whitecircle"
            else
                s *= raw"\makebox[1em]{$\cdot$}"
            end
        end
        if i!=m
            s *= raw"\\\\"
        end
    end
    s *= raw"\end{matrix}\end{equation*}"
    return s
end