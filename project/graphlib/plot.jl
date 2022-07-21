using DelimitedFiles
using Plots

sizes = [10,   14,   24,   38,   62,  100,  158,  250,  398,  630, 1000]
mapped_size = readdlm(joinpath(@__DIR__, "data", "Erdos-Renyi-2.dat"))
mapped_size2 = readdlm(joinpath(@__DIR__, "data", "3-Regular-2.dat"))
plt = plot(sizes, sum(mapped_size;dims=2)/size(mapped_size, 2); yscale=:log, xscale=:log, label="Erdos-Renyi")
plot!(plt, sizes, sum(mapped_size2;dims=2)/size(mapped_size2, 2); yscale=:log, xscale=:log, label="3-Regular")