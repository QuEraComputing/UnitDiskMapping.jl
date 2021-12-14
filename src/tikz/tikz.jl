module TikzGraph
export rgbcolor!, Node, Line, BoundingBox, Mesh, Canvas, >>, command, canvas, generate_standalone, StringElement, PlainText

const instance_counter = Ref(0)
abstract type AbstractTikzElement end

struct Canvas
    header::String
    colors::Dict{String, Tuple{Int,Int,Int}}
    contents::Vector{AbstractTikzElement}
    props::Dict{String,String}
end

function canvas(f; header="", colors=Dict{String,Tuple{Int,Int,Int}}(), props=Dict{String,String}())
    canvas = Canvas(header, colors, AbstractTikzElement[], props)
    f(canvas)
    return canvas
end

Base.:(>>)(element::AbstractTikzElement, canvas::Canvas) = push!(canvas.contents, element)
Base.:(>>)(element::String, canvas::Canvas) = push!(canvas.contents, StringElement(element))

function rgbcolor!(canvas::Canvas, red::Int, green::Int, blue::Int)
    instance_counter[] += 1
    colorname = "color$(instance_counter[])"
    canvas.colors[colorname] = (red,green,blue)
    return colorname
end
function generate_rgbcolor(name, red, green, blue)
    return "\\definecolor{$name}{RGB}{$red,$green,$blue}"
end

struct StringElement <: AbstractTikzElement
    str::String
end
command(s::StringElement) = s.str

struct BoundingBox <: AbstractTikzElement
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
end
function command(box::BoundingBox)
    return "\\useasboundingbox ($(box.xmin),$(box.ymin)) rectangle ($(box.xmax),$(box.ymax));"
end

struct Node <: AbstractTikzElement
    x::Float64
    y::Float64
    shape::String
    id::String
    text::String
    props::Dict{String,String}
end

function Node(x, y;
        shape::String = "circle",
        id = string((instance_counter[] += 1; instance_counter[])), 
        text::String = "",
        fill = "none",
        draw = "black",
        inner_sep = "0cm",
        minimum_size = "0.2cm",
        line_width = 0.03,
        kwargs...)
    props = build_props(;
        fill = fill,
        draw = draw,
        inner_sep = inner_sep,
        minimum_size = minimum_size,
        line_width = line_width,
        kwargs...)
    return Node(x, y, shape, id, text, props)
end
function build_props(; kwargs...)
    Dict([replace(string(k), "_"=>" ")=>string(v) for (k,v) in kwargs])
end

function command(node::Node)
    return "\\node[$(node.shape), $(command(node.props))] at ($(node.x), $(node.y)) ($(node.id)) {$(node.text)};"
end

struct Mesh <: AbstractTikzElement
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    props::Dict{String,String}
end

function Mesh(xmin, xmax, ymin, ymax; step="1.0cm", draw="gray", line_width=0.03, kwargs...)
    Mesh(xmin, xmax, ymin, ymax, build_props(; step=step, draw=draw, line_width=line_width, kwargs...))
end
function command(grid::Mesh)
    return "\\draw[$(command(grid.props))] ($(grid.xmin),$(grid.ymin)) grid ($(grid.xmax),$(grid.ymax));"
end

struct Line <: AbstractTikzElement
    src::String
    dst::String
    controls::Vector{Int}
    props::Dict{String,String}
end

function Line(src, dst; controls=Int[], line_width = "0.03", kwargs...)
    Line(string(src), string(dst), controls, build_props(; line_width=line_width, kwargs...))
end
Line(src::Node, dst::Node; kwargs...) = Line(src.id, dst.id)

function command(edge::Line)
    head = "\\draw[$(command(edge.props))]"
    if isempty(edge.controls)
        return "$head ($(edge.src)) -- ($(edge.dst));"
    else
        return "$head ($(edge.src)) .. controls $(join(["($c)" for c in edge.controls], " and ")) .. ($(edge.dst));"
    end
end

struct PlainText <: AbstractTikzElement
    x::Float64
    y::Float64
    text::String
    props::Dict{String,String}
end
function PlainText(x, y, text; kwargs...)
    PlainText(x, y, text, build_props(; kwargs...))
end
function command(text::PlainText)
    "\\node[$(command(text.props))] at ($(text.x), $(text.y)) {$(text.text)};"
end

function command(node::Dict)  # properties
    return join(["$k=$v" for (k,v) in node], ", ")
end

function generate_standalone(header::String, props::Dict, content::String)
    return """
\\documentclass[crop,tikz]{standalone}
$(header)
\\begin{document}
\\begin{tikzpicture}[$(command(props))]
$content
\\end{tikzpicture}
\\end{document}
"""
end
generate_standalone(canvas::Canvas) = generate_standalone(canvas.header, canvas.props, join([[generate_rgbcolor(k,v...) for (k,v) in canvas.colors]..., command.(canvas.contents)...], "\n"))

function Base.write(io::IO, canvas::Canvas)
    write(io, generate_standalone(canvas))
end

end