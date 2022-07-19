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

@cast function sample(graphname::String; seed::Int=2)
    folder=joinpath(@__DIR__, "data")
    if !isdir(folder)
        mkpath(folder)
    end
    sizes = 10:10:100
    Random.seed!(seed)
    res_sizes = Int[]
    for n in sizes
        g = if graphname == "Erdos-Renyi"
            erdos_renyi(n, 0.3)
        elseif graphname == "3-Regular"
            random_regular_graph(n, 3)
        else
            error("graph name $graphname not defined!")
        end
        res = map_graph(g; vertex_order=Greedy())
        m = length(res.grid_graph.nodes)
        @info "size $n, mapped graph size $m."
        push!(res_sizes, m)
    end
    filename = "$graphname-$seed.dat"
    writedlm(joinpath(folder, filename), res_sizes)
end

@main
