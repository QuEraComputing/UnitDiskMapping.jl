# normalized to minimum weight and maximum weight
function LuxorGraphPlot.show_graph(gg::GridGraph;
        format = :svg,
        filename = nothing,
        padding_left = 10,
        padding_right = 10,
        padding_top = 10,
        padding_bottom = 10,
        show_number = false,
        config = GraphDisplayConfig(),
        texts = nothing,
        vertex_colors=nothing,
    )
    texts !== nothing && show_number && @warn "not showing number due to the manually specified node texts."
    # plot!
    unit = 33.0
    coos = coordinates(gg)
    xmin, xmax = extrema(first.(coos))
    ymin, ymax = extrema(last.(coos))
    nodestore() do ns
        filledlocs = map(coo->circle!((unit * (coo[2] - 1), -unit * (coo[1] - 1)), config.vertex_size), coos)
        emptylocs, edges = [], []
        for i=xmin:xmax, j=ymin:ymax
            (i, j) ∉ coos && push!(emptylocs, circle!(((j-1) * unit, -(i-1) * unit), config.vertex_size/10))
        end
        for e in Graphs.edges(graph_and_weights(gg)[1])
            i, j = e.src, e.dst
            push!(edges, Connection(filledlocs[i], filledlocs[j]))
        end
        with_nodes(ns; format, filename, padding_bottom, padding_left, padding_right, padding_top, background=config.background) do
            config2 = copy(config)
            config2 = GraphDisplayConfig(; vertex_color="#333333", vertex_stroke_color="transparent")
            texts = texts===nothing && show_number ? string.(1:length(filledlocs)) : texts
            LuxorGraphPlot.render_nodes(filledlocs, config; texts, vertex_colors)
            LuxorGraphPlot.render_edges(edges, config)
            LuxorGraphPlot.render_nodes(emptylocs, config2; texts=nothing)
        end
    end
end

function show_grayscale(gg::GridGraph; wmax=nothing, kwargs...)
    _, ws0 = graph_and_weights(gg)
    ws = tame_weights.(ws0)
    if wmax === nothing
        wmax = maximum(abs, ws)
    end
    cmap = Colors.colormap("RdBu", 200)
    # 0 -> 100
    # wmax -> 200
    # wmin -> 1
    vertex_colors= [cmap[max(1, round(Int, 100+w/wmax*100))] for w in ws]
    show_graph(gg; vertex_colors, kwargs...)
end
tame_weights(w::ONE) = 1.0
tame_weights(w::Real) = w

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
        color_pins[pin] = ("green", "p$('₀'+i)")
    end
    for (i, pin) in enumerate(mres.pins_input2)
        color_pins[pin] = ("blue", "q$('₀'+i)")
    end
    for (i, pin) in enumerate(mres.pins_output)
        color_pins[pin] = ("red", "m$('₀'+i)")
    end
    for (i, pin) in enumerate(mres.pins_zeros)
        color_pins[pin] = ("gray", "0")
    end
    show_pins(mres.grid_graph, color_pins; kwargs...)
end

for TP in [:QUBOResult, :WMISResult, :SquareQUBOResult]
    @eval function show_pins(mres::$TP; kwargs...)
        color_pins = Dict{Int,Tuple{String,String}}()
        for (i, pin) in enumerate(mres.pins)
            color_pins[pin] = ("red", "v$('₀'+i)")
        end
        show_pins(mres.grid_graph, color_pins; kwargs...)
    end
end

function show_config(gg::GridGraph, config; kwargs...)
    vertex_colors=[iszero(c) ? "white" : "red" for c in config]
    show_graph(gg; vertex_colors, kwargs...)
end

function show_pins(mres::MappingResult{<:WeightedNode}; kwargs...)
    locs = getfield.(mres.grid_graph.nodes, :loc)
    center_indices = map(loc->findfirst(==(loc), locs), trace_centers(mres))
    color_pins = Dict{Int,Tuple{String,String}}()
    for (i, pin) in enumerate(center_indices)
        color_pins[pin] = ("red", "v$('₀'+i)")
    end
    show_pins(mres.grid_graph, color_pins; kwargs...)
end

function show_pins(gate::Gate; kwargs...)
    grid_graph, inputs, outputs = gate_gadget(gate)
    color_pins = Dict{Int,Tuple{String,String}}()
    for (i, pin) in enumerate(inputs)
        color_pins[pin] = ("red", "x$('₀'+i)")
    end
    for (i, pin) in enumerate(outputs)
        color_pins[pin] = ("blue", "y$('₀'+i)")
    end
    show_pins(grid_graph, color_pins; kwargs...)
end
