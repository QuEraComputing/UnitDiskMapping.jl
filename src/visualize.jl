# normalized to minimum weight and maximum weight
function LuxorGraphPlot.show_graph(gg::GridGraph;
        vertex_colors=nothing,
        vertex_sizes=nothing,
        vertex_shapes=nothing,
        vertex_stroke_colors=nothing,
        vertex_text_colors=nothing,
        edge_colors=nothing,
        texts = nothing,
        format=:png, filename=nothing,
        vertex_size=0.35,
        fontsize=24,
        kwargs...)
    # transpose (i, j) to make them consistent with terminal output
	locs = [(j,i) for (i,j) in coordinates(gg)]
    length(locs) == 0 && return _draw(()->nothing, 100, 100; format, filename)
    edges = [(e.src, e.dst) for e in Graphs.edges(graph_and_weights(gg)[1])]

    # configure canvas and plot
    xmin, ymin, xmax, ymax = LuxorGraphPlot.get_bounding_box(locs)
    config = LuxorGraphPlot.GraphDisplayConfig(; vertex_size, fontsize, kwargs...)
    Dx, Dy = ((xmax-xmin)+2*config.xpad)*config.unit, ((ymax-ymin)+2*config.ypad)*config.unit
    transform(loc) = loc[1]-xmin+config.xpad, loc[2]-ymin+config.ypad

    # compute empty locations
    empty_locations = Tuple{Int,Int}[]
    for i=xmin:xmax, j=ymin:ymax
        (i, j) ∉ locs && push!(empty_locations, (i, j))
    end

    # plot!
    LuxorGraphPlot._draw(Dx, Dy; format, filename) do
        LuxorGraphPlot._show_graph(transform.(locs), edges,
        vertex_colors, vertex_stroke_colors, vertex_text_colors, vertex_sizes, vertex_shapes, edge_colors, texts, config)

        config2 = LuxorGraphPlot.GraphDisplayConfig(; vertex_size=config.vertex_size/10,
                                     vertex_fill_color="#333333",
                                     vertex_stroke_color="transparent",
                                     kwargs...,
                                     )
        LuxorGraphPlot._show_graph(transform.(empty_locations), Tuple{Int,Int}[],
                nothing, nothing, nothing, nothing, nothing, nothing, fill("", length(empty_locations)), config2)
    end
end

function show_grayscale(gg::GridGraph; kwargs...)
	locs = [(j,i) for (i,j) in coordinates(gg)]
    g, ws = graph_and_weights(gg)
    wmax = maximum(abs, ws)
    cmap = Colors.colormap("RdBu", 200)
    # 0 -> 100
    # wmax -> 200
    # wmin -> 1
    vertex_colors= [cmap[max(1, round(Int, 100+w/wmax*100))] for w in ws]
    show_graph(gg; vertex_colors, kwargs...)
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

function show_pins(mres::MappingResult; kwargs...)
    locs = getfield.(mres.grid_graph.nodes, :loc)
    center_indices = map(loc->findfirst(==(loc), locs), trace_centers(mres))
    color_pins = Dict{Int,Tuple{String,String}}()
    for (i, pin) in enumerate(center_indices)
        color_pins[pin] = ("red", "v$i")
    end
    show_pins(mres.grid_graph, color_pins; kwargs...)
end
