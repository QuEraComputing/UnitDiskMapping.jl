using UnitDiskMapping, Graphs, Random
using Comonicon
using DelimitedFiles

include("readgraphs.jl")

# map all connected non-isomorphic graphs
@cast function mapall(n::Int)
    graphs = load_g6(joinpath(dirname(@__DIR__), "data", "graph$n.g6"))
    for g in graphs
        if is_connected(g)
            result = map_graph(g)
        end
    end
end

@cast function sample(graphname::String; seed::Int=2, nrepeat=100)
    folder=joinpath(@__DIR__, "data")
    if !isdir(folder)
        mkpath(folder)
    end
    #sizes = 10:10:100
    sizes = [10, 14, 24, 38, 62, 100, 158, 250, 398, 630, 1000]
    Random.seed!(seed)
    res_sizes = zeros(Int, length(sizes), nrepeat)
    for (j, n) in enumerate(sizes)
        for i=1:nrepeat
            g = if graphname == "Erdos-Renyi"
                erdos_renyi(n, 0.3)
            elseif graphname == "3-Regular"
                random_regular_graph(n, 3)
            else
                error("graph name $graphname not defined!")
            end
            res = map_graph(g; vertex_order=Greedy(), ruleset=[])
            m = length(res.grid_graph.nodes)
            @info "size $n, i = $i, mapped graph size $m."
            res_sizes[j,i] = m
        end
    end
    filename = "$graphname-$seed.dat"
    writedlm(joinpath(folder, filename), res_sizes)
end

@main
