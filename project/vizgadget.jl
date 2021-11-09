using UnitDiskMapping, Graphs

function command_node(type::Int, ispin::Bool)
    if type == 2
        "\\node[fill=yellow,circle,radius=\\r] at ($x+\\dx, $y+\\dy) ($id) {};"
    elseif abs(type) == 1
        if ispin
            "\\node[fill=red,circle,radius=\\r] at ($x+\\dx, $y+\\dy) ($id) {};"
        else
            "\\node[fill,circle,radius=\\r] at ($x+\\dx, $y+\\dy) ($id) {};"
        end
    else
        error("")
    end
end

function viz_gadget(p::Pattern)
    locs1, g1, pin1 = source_graph(p)
    locs2, g2, pin2 = mapped_graph(p)
    source_locs = join(["$l" for l in locs1], ", ")
    source_bonds = join(["$(e.src)/$(e.dst)" for e in edges(g1)])
    mapped_locs = join(["$l" for l in locs2], ", ")
    dx = max(maximum(x->x[1], locs1), maximum(x->x[1], locs2)) + 2
    dy = max(maximum(x->x[2], locs1), maximum(x->x[2], locs2)) + 2
    return """
\\documentclass[crop,tikz]{standalone}% 'crop' is the default for v1.0, before it was 'preview'
\\makeatletter
\\def\\parsept#1#2#3{%
    \\def\\nospace##1{\\zap@space##1 \\@empty}%
    \\def\\rawparsept(##1,##2){%
        \\edef#1{\\nospace{##1}}%
        \\edef#2{\\nospace{##2}}%
    }%
    \\expandafter\\rawparsept#3%
}
\\makeatother

\\begin{document}

\\begin{tikzpicture}[scale=0.8]
    \\useasboundingbox (-1,-1) rectangle ($dx,$dy);
    \\def\\dx{-0.0};
    \\def\\r{0.2};
    \\def\\dy{0.0};
    $source_nodes
    \foreach \i/\j in {$source_bonds}{
        \draw[thick] (\i) -- (\j);
    }

    \def\dx{6.0};
    \def\r{0.2};
    \def\dy{0.0};
    \draw[step=1cm,gray,very thin] (-2+\dx,-2+\dy) grid (2+\dx,1+\dy);
    \def\nodes{$mapped_locs}
    \foreach \p [count=\i] in \nodes{
        \parsept{\x}{\y}{\p}
        \pgfmathparse{(\x > 1.5 || \x < -1.5 || \y > 0.5 || \y < -1.5 ? 1 : 0)}
        \ifnum\pgfmathresult=1
            \node[fill=red,circle,radius=\r] at (\x+\dx, \y+\dy) (\i) {};
        \else
            \node[fill,circle,radius=\r] at (\x+\dx, \y+\dy) (\i) {};
        \fi
    }
    \foreach \p [count=\i] in \nodes{
        \parsept{\x}{\y}{\p}
        \foreach \q [count=\j] in \nodes{
            \parsept{\u}{\v}{\q}
            \pgfmathparse{(\u-\x)*(\u-\x) + (\y-\v)*(\y-\v) < 1.66^2 ? 1 : 0)}
            \ifnum\pgfmathresult > 0
                \draw[thick] (\i) -- (\j);
            \fi
        }
    }
    \node at (3, 0.0) {$\mathbf{\rightarrow}$};
\end{tikzpicture}

\end{document}
"""
end