module TikzGraph
export rgbcolor!, Node, Line, BoundingBox, Mesh, Canvas, >>, command, canvas, generate_standalone, StringElement, PlainText, uselib!
export Cycle, Controls, annotate, Annotate, autoid!, vizgraph!

const instance_counter = Ref(0)
abstract type AbstractTikzElement end

struct Canvas
    header::String
    libs::Vector{String}
    colors::Dict{String, Tuple{Int,Int,Int}}
    contents::Vector{AbstractTikzElement}
    props::Dict{String,String}
end

function canvas(f; header="", libs=String[], colors=Dict{String,Tuple{Int,Int,Int}}(), props=Dict{String,String}())
    canvas = Canvas(header, libs, colors, AbstractTikzElement[], props)
    f(canvas)
    return canvas
end

Base.:(>>)(element::AbstractTikzElement, canvas::Canvas) = (push!(canvas.contents, element); element)
Base.:(>>)(element::String, canvas::Canvas) = (push!(canvas.contents, StringElement(element)); element)

function uselib!(canvas::Canvas, lib::String)
    push!(canvas.libs, lib)
    return lib
end
function rgbcolor!(canvas::Canvas, red::Int, green::Int, blue::Int)
    colorname = "color$(autoid!())"
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
    return "\\useasboundingbox ($(box.xmin),$(box.ymin)) rectangle ($(box.xmax-box.xmin),$(box.ymax-box.ymin));"
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
        id = autoid!(),
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
autoid!() = string((instance_counter[] += 1; instance_counter[]))
function build_props(; kwargs...)
    Dict([replace(string(k), "_"=>" ")=>string(v) for (k,v) in kwargs])
end

function command(node::Node)
    return "\\node[$(parse_args([string(node.shape)], node.props))] at ($(node.x), $(node.y)) ($(node.id)) {$(node.text)};"
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
    return "\\draw[$(parse_args(String[], grid.props))] ($(grid.xmin),$(grid.ymin)) grid ($(grid.xmax),$(grid.ymax));"
end

struct Cycle end
struct Controls
    start::String
    controls::Vector{String}
    stop::String
    Controls(start, c1, stop) = new(parse_path(start), [parse_path(c1)], parse_path(stop))
    Controls(start, c1, c2, stop) = new(parse_path(start), [parse_path(c1), parse_path(c2)], parse_path(stop))
end

struct Annotate
    args::Vector{String}   # e.g. "[midway, above]"
    id::String
    text::String
end
Base.isempty(ann::Annotate) = isempty(ann.text)

struct Line <: AbstractTikzElement
    path::Vector{String}
    arrow::String
    annotate::Annotate
    props::Dict{String,String}
end
function Line(path...; annotate::Union{String,Annotate}="", arrow::String="", line_width = "0.03", kwargs...)
    ann = annotate isa String ? Annotate(["midway", "above", "sloped"], "", annotate) : annotate
    Line(collect(parse_path.(path)), arrow, ann, build_props(; line_width=line_width, kwargs...))
end
parse_path(t::Tuple) = "$(t)"
parse_path(n::Node) = "($(n.id))"
parse_path(s::String) = "($s)"
parse_path(s::Cycle) = "cycle"
function parse_path(c::Controls)
    "$(c.start) .. controls $(join(["$c" for c in c.controls], " and ")) .. $(c.stop)"
end
function command(edge::Line)
    head = "\\draw[$(parse_args([edge.arrow], edge.props))]"
    path = join(edge.path, " -- ")
    ann = edge.annotate
    isempty(ann) && return "$head $path;"
    annotate = "node [$(parse_args(ann.args, Dict{String,String}()))] ($(ann.id)) {$(ann.text)}"
    return "$head $path $annotate;"
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
    "\\node[$(parse_args(String[], text.props))] at ($(text.x), $(text.y)) {$(text.text)};"
end

annotate(node::Node, text; offsetx=0, offsety=0, kwargs...) = PlainText(node.x+offsetx, node.y+offsety, text; kwargs...)

function parse_args(args::Vector, kwargs::Dict)  # properties
    return join(filter(!isempty, [args..., ["$k=$v" for (k,v) in kwargs if !isempty(v)]...]), ", ")
end

function generate_standalone(libs::Vector, header::String, props::Dict, content::String)
    return """
\\documentclass[crop,tikz]{standalone}
$(join(["\\usepgflibrary{$lib}" for lib in libs], "\n"))
$(header)
\\begin{document}
\\begin{tikzpicture}[$(parse_args(String[], props))]
$content
\\end{tikzpicture}
\\end{document}
"""
end
generate_standalone(canvas::Canvas) = generate_standalone(canvas.libs, canvas.header, canvas.props, join([[generate_rgbcolor(k,v...) for (k,v) in canvas.colors]..., command.(canvas.contents)...], "\n"))

function Base.write(io::IO, canvas::Canvas)
    write(io, generate_standalone(canvas))
end

function vizgraph!(c::Canvas, locations::AbstractVector, edges; fills=fill("black", length(locations)),
        texts=fill("", length(locations)), ids=[autoid!() for i=1:length(locations)], minimum_size="0.4cm", draw="", line_width="1pt")
    nodes = Node[]
    lines = Line[]
    for i=1:length(locations)
        n = Node(locations[i]...; fill=fills[i], minimum_size=minimum_size, draw=draw, id=ids[i], text=texts[i]) >> c
        push!(nodes, n)
    end
    for (i, j) in edges
        l = Line(nodes[i], nodes[j], line_width=line_width) >> c
        push!(lines, l)
    end
    return nodes, lines
end

end
