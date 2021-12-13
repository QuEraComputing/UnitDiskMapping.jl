using Graphs
# create canvas for graph
# parameters: width, height, margins, node_sizes
# create transparent/blank canvas
# create grid canvas
# initiate a blank canvas
function initiate_empty_canvas(xmin = -1, ymin = -1, xmax=10, ymax=10, scale=1)
    # clear text file
    rm("tikz_graph.tex")

    # create new file
    touch("tikz_graph.tex")

    # open file
    io = open("tikz_graph.tex", "w")

    # preamble
    init_string = """
    \documentclass[crop,tikz]{standalone}
    \usepackage[utf8]{inputenc}

    \begin{document}
    \begin{tikzpicture}[scale= $scale, auto = center ]

    \useasboundingbox ($xmin, $ymin) rectangle ($xmax,$ymax);
    """

    write(io, init_string)
    close(io)
end

# initiate dotted grid
function initiate_dot_grid(xmin = -1, ymin = -1, xmax=10, ymax=10, node_size=2)
    io = open("tikz_graph.tex", "w")

    circle_preamble = """
    \tikzset{circle node/.style = {circle,inner sep=1pt,draw, fill=white}}
    """
    write(circle_preamble, init_string)

    init_grid = """
    \foreach \x in {$xmin,...,$xmax}
    \foreach \y in {$ymin,...,$ymax}
    {
    \fill[fill = lightgray] (\x,\y) circle ($node_size pt);
    }
    """

    write(circle_preamble, init_grid)
    close(io)
end

# close the canvas
function close_canvas()
    io = open("tikz_graph.tex", "w")

    close = """
    \end{tikzpicture}
    \end{document}
    """

    write(circle_preamble, close)
    close(io)
end

function initiate_default_node(node_size=20, node_color="black", opacity=100, text_color="white")
    io = open("tikz_graph.tex", "w")
    node_init = """
    \tikzset{main_node/.style={circle,fill=$node_color !$opacity,draw,minimum size=$node_size pt,inner sep=1pt,
    text=$text_color},
            }
    """
    write(node_init, close)
    close(io)
end

function add_main_node(p::Int, px::Real, py::Real, label::String, node_color="black", node_text="white")
    io = open("tikz_graph.tex", "w")
    add_node_txt = """
    \node[main_node, fill = $node_color, text = $node_text] ($p) at ($px,$py) {$label};
    """
    write(node_init, close)
    close(io)
end

function add_edge(v::Int, w::Int, edge_color = "black", edge_thickness = "thick", bend_type="")
    io = open("tikz_graph.tex", "w")
    add_edge_txt = """
    \draw[draw = $edge_color, $edge_thickness] ($v) to [$bend_type] ($w)
    """
    write(node_init, close)
    close(io)
end


function render_tikz(g::SimpleGraph, locs::AbstractVector, grid_graph=false)
    N = nv(g)

    # find bounds of locs
    min_x = typemax(Float)
    min_y = typemax(Float)
    max_x = 0
    max_y = 0

    n = length(locs)
    for i=1:n
        px, py = locs[i]

        if px > max_x
            max_x = px
        end
        if px < min_x
            min_x = px
        end
        if py > max_y
            max_y = py
        end
        if py < min_y
            min_y = py
        end
    end

    initiate_empty_canvas(xmin=min_x, ymin = min_y, xmax = max_x, ymax = max_y, scale=1)
    if grid_graph == true
        initiate_dot_grid(xmin =min_x, ymin =min_y, xmax=max_x, ymax=max_y, node_size=2)
    end

    initiate_default_node()

    for v in vertices(g)
        add_main_node(v, locs[v][1], locs[v][2], "$v", node_color="black", node_text="white")
    end

    for e in edges(g)
        v1 = src(e)
        v2 = dst(e)
        add_edge(v1, v2, edge_color = "black", edge_thickness = "thick", bend_type="")
    end

    close_canvas()
end
