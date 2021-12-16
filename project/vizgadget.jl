using UnitDiskMapping.TikzGraph, Graphs
using UnitDiskMapping: crossing_ruleset, Pattern, source_graph, mapped_graph

function command_graph!(canvas, locs, graph, pins, dx, dy, r, name)
    for (i,loc) in enumerate(locs)
        if count(==(loc), locs) == 2
            Node(loc[1]+dx, loc[2]+dy, fill="none", id="ext-$name$i", minimum_size="$(1.5*r)cm") >> canvas
        end
        Node(loc[1]+dx, loc[2]+dy, fill=i∈pins ? "red" : "black", draw="none", id="$name$i", minimum_size="$(r)cm") >> canvas
    end
    for e in edges(graph)
        Line("$name$(e.src)", "$name$(e.dst)"; line_width=1.0) >> canvas
    end
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
    return canvas(; props=Dict("scale"=>"0.8")) do c
        BoundingBox(-1,Wx-1,-1,Wy-1) >> c
        Mesh(dx1, Gx+dx1-1, dy1, Gy+dy1-1; step="1cm", draw=rgbcolor!(c, 200,200,200), line_width=0.5) >> c
        command_graph!(c, locs1, g1, pin1, dx1, dy1, 0.3, "s")
        Mesh(dx2, Gx+dx2-1, dy2, Gy+dy2-1; step="1cm", draw=rgbcolor!(c, 200,200,200), line_width=0.03) >> c
        command_graph!(c, locs2, g2, pin2, dx2, dy2, 0.3, "d")
        PlainText(xmid, ymid, "\$\\mathbf{\\rightarrow}\$") >> c
    end
end

function pattern2tikz(folder::String)
    for p in crossing_ruleset
        open(joinpath(folder, string(typeof(p).name.name)*"-udg.tex"), "w") do f
            write(f, viz_gadget(p))
        end
    end
end

pattern2tikz(joinpath("_local"))