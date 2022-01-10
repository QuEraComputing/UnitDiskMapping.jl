using UnitDiskMapping.TikzGraph

function routine(centerx, centery, width, height, text; kwargs...)
    Node(centerx, centery, shape="rectangle", rounded_corners = "0.5ex", minimum_width="$(width)cm", minimum_height="$(height)cm", line_width="1pt", minimum_size="", text=text, kwargs...)
end

# aspect = width/height
function decision(centerx, centery, width, height, text; kwargs...)
    Node(centerx, centery, shape="diamond", minimum_size="$(height)cm", aspect=width/height, text=text, line_width="1pt", kwargs...)
end

function arrow(nodes...; kwargs...)
    Line(nodes...; arrow="->", line_width="1pt", kwargs...)
end

function draw_flowchart()
    canvas(libs=["shapes"]) do c
        n1 = routine(0.0, 0.0, 3, 1, "input graph") >> c
        n2 = decision(0.0, -3, 3, 1, "satisfies the crossing criteria") >> c
        n3 = decision(0.0, -6, 3, 1, "has a same tropical tensor") >> c
        arrow(n1, n2) >> c
        arrow(n2, n3; annotate="T") >> c
        arrow(n2, (3.0, -3.0), (3.0, 0.0), n1; annotate="F") >> c
    end
end

writepdf("_local/flowchart.tex", draw_flowchart())