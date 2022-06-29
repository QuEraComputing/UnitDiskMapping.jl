# normalized to minimum weight and maximum weight
function LuxorGraphPlot.show_graph(gg::GridGraph; vertex_size=0.35, fontsize=24, kwargs...)
	locs = [(j,i) for (i,j) in coordinates(gg)]
    g, ws = graph_and_weights(gg)
    show_graph(g; locs, vertex_size, fontsize, kwargs...)
end

function show_grayscale(gg::GridGraph; vertex_size=0.35, fontsize=24, kwargs...)
	locs = [(j,i) for (i,j) in coordinates(gg)]
    g, ws = graph_and_weights(gg)
    wmax = maximum(abs, ws)
    cmap = Colors.colormap("RdBu", 200)
    # 0 -> 100
    # wmax -> 200
    # wmin -> 1
    vertex_colors= [cmap[max(1, round(Int, 100+w/wmax*100))] for w in ws]
    show_graph(g; locs, vertex_size, fontsize, vertex_colors, kwargs...)
end

function show_pins(gg::GridGraph, color_pins::AbstractDict; kwargs...)
    vertex_colors=String[]
    texts=String[]
    for i=1:length(gg.nodes)
        c, t = haskey(color_pins, i) ? color_pins[i] : ("white", "")
        push!(vertex_colors, c)
        push!(texts, t)
    end
    show_graph(gg; vertex_colors, texts, kwargs...)
end

function show_pins(mres::FactoringResult; kwargs...)
    color_pins = Dict{Int,Tuple{String,String}}()
    for (i, pin) in enumerate(mres.pins_input1)
        color_pins[pin] = ("green", "p$i")
    end
    for (i, pin) in enumerate(mres.pins_input2)
        color_pins[pin] = ("blue", "p$i")
    end
    for (i, pin) in enumerate(mres.pins_output)
        color_pins[pin] = ("red", "m$i")
    end
    for (i, pin) in enumerate(mres.pins_zeros)
        color_pins[pin] = ("gray", "0")
    end
    show_pins(mres.grid_graph, color_pins; kwargs...)
end

function show_pins(mres::QUBOResult; kwargs...)
    color_pins = Dict{Int,Tuple{String,String}}()
    for (i, pin) in enumerate(mres.pins)
        color_pins[pin] = ("red", "v$i")
    end
    show_pins(mres.grid_graph, color_pins; kwargs...)
end

function show_pins(mres::WMISResult; kwargs...)
    color_pins = Dict{Int,Tuple{String,String}}()
    for (i, pin) in enumerate(mres.pins)
        color_pins[pin] = ("red", "v$i")
    end
    show_pins(mres.grid_graph, color_pins; kwargs...)
end

function show_config(gg::GridGraph, config; kwargs...)
    vertex_colors=[iszero(c) ? "white" : "red" for c in config]
    show_graph(gg; vertex_colors, kwargs...)
end