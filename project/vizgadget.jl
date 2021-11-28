using UnitDiskMapping, Graphs

function command_graph(locs, graph, pins, dx, dy, r, name)
    cmd = ""
    for (i,loc) in enumerate(locs)
        if count(==(loc), locs) == 2
            type = 2
        else
            type = 1
        end
        cmd *= command_node(loc[1]+dx, loc[2]+dy, type, i ∈ pins, "$name$i", r) * "\n"
    end
    for e in edges(graph)
        cmd *= command_edge("$name$(e.src)", "$name$(e.dst)") * "\n"
    end
    return cmd
end

function command_node(x, y, type::Int, ispin::Bool, id, r)
    if type == 2
        return "\\node[fill=black,circle,radius=$(r)cm,inner sep=0cm, minimum size=$(r)cm] at ($x, $y) () {};\n\\node[draw=black,fill=none,circle,radius=$(1.5*r)cm,minimum size=$(1.5*r)cm,inner sep=0cm] at ($x, $y) ($id) {};"
    elseif abs(type) == 1
        if ispin
            color = "red"
        else
            color = "black"
        end
        return "\\node[fill=$color,circle,radius=$(r)cm,inner sep=0cm, minimum size=$(r)cm] at ($x, $y) ($id) {};"
    else
        error("")
    end
end

function command_edge(i, j)
    return "\\draw[thick] ($i) -- ($j);"
end

function viz_gadget(p::Pattern)
    locs1, g1, pin1 = source_graph(p)
    locs2, g2, pin2 = mapped_graph(p)
    Gy, Gx = size(p)
    locs1 = map(l->(l[2]-1, Gy-l[1]), locs1)
    locs2 = map(l->(l[2]-1, Gy-l[1]), locs2)
    Wx, Wy = 11, Gy
    xmid, ymid = Wx/2-0.5, Wy/2-0.5
    dx1, dy1 = xmid-Gx, 0
    dx2, dy2 = xmid+1, 0
    source_nodes = command_graph(locs1, g1, pin1, dx1, dy1, 0.3, "s")
    mapped_nodes = command_graph(locs2, g2, pin2, dx2, dy2, 0.3, "d")
    return """
\\documentclass[crop,tikz]{standalone}% 'crop' is the default for v1.0, before it was 'preview'
\\begin{document}
\\begin{tikzpicture}[scale=0.8]
    \\useasboundingbox (-1,-1) rectangle ($Wx,$Wy);
    \\draw[step=1cm,gray,very thin] ($dx1,$(dy1)) grid ($(Gx+dx1-1),$(Gy+dy1-1));
    $source_nodes
    \\draw[step=1cm,gray,very thin] ($dx2,$(dy2)) grid ($(Gx+dx2-1),$(Gy+dy2-1));
    $mapped_nodes
    \\node at ($xmid, $ymid) {\$\\mathbf{\\rightarrow}\$};
\\end{tikzpicture}

\\end{document}
"""
end

function pattern2tikz(folder::String)
    for (p, sub) in UnitDiskMapping.crossing_ruleset
        open(joinpath(folder, sub*"-udg.tex"), "w") do f
            write(f, viz_gadget(p))
        end
    end
end