# create canvas for graph 
# parameters: width, height, margins, node_sizes 
# create transparent/blank canvas 
# create grid canvas 

# initiate a blank canvas 
function initiate_empty_canvas(Wx=10, Wy=10, scale=1)
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

    \useasboundingbox (-1,-1) rectangle ($Wx,$Wy);
    """
    
    write(io, init_string)
    close(io)
end

# initiate dotted grid
function initiate_dot_grid(Wx=10, Wy=10, node_size=2)
    io = open("tikz_graph.tex", "w")
    
    circle_preamble = """
    \tikzset{circle node/.style = {circle,inner sep=1pt,draw, fill=white}}
    """
    write(circle_preamble, init_string)

    init_grid = """
    \foreach \x in {0,...,$Wx}
    \foreach \y in {0,...,$Wy}
    {
    \fill[fill = gray] (\x,\y) circle ($node_size pt);
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








