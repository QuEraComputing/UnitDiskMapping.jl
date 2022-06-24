using UnitDiskMapping, UnitDiskMapping.TikzGraph
using UnitDiskMapping: safe_get
using GenericTensorNetworks, Graphs

function all_configurations(p::Pattern)
    mlocs, mg, mpins = mapped_graph(p)
    gp = IndependentSet(mg, openvertices=mpins)
    res = solve(gp, ConfigsMax())
    configs = []
    for element in res
        for bs in element.c.data
            push!(configs, bs)
        end
    end
    mats = Matrix{Int}[]
    @show configs
    for config in configs
        m, n = size(p)
        mat = zeros(Int, m, n)
        for (loc, c) in zip(mlocs, config)
            if !iszero(c)
                mat[loc.x, loc.y] = true
            end
        end
        if rotr90(mat) ∉ mats && rotl90(mat) ∉ mats && rot180(mat) ∉ mats &&
                mat[end:-1:1,:] ∉ mats && mat[:,end:-1:1] ∉ mats &&    # reflect x, y
                Matrix(mat') ∉ mats && mat[end:-1:1,end:-1:1] ∉ mats    # reflect diag, offdiag
            push!(mats, mat)
        end
    end
    return mats
end

function viz_matrix!(c, mat0, mat, dx, dy)
    m, n = size(mat)
    for i=1:m
        for j=1:n
            x, y = j+dx, i+dy
            cell = mat0[i,j]
            if isempty(cell)
                #Node(x, y; fill="black", minimum_size="0.01cm") >> c
            elseif cell.doubled
                filled = iszero(safe_get(mat, i,j-1)) && iszero(safe_get(mat,i,j+1))
                Node(x+0.4, y; fill=filled ? "black" : "white", minimum_size="0.4cm") >> c
                filled = iszero(safe_get(mat, i-1,j)) && iszero(safe_get(mat,i+1,j))
                Node(x, y+0.4; fill=filled ? "black" : "white", minimum_size="0.4cm") >> c
            else
                Node(x, y; fill=mat[i,j] > 0 ? "black" : "white", minimum_size="0.4cm") >> c
            end
        end
    end
end

function vizback(p; filename)
    configs = all_configurations(p)
    smat = source_matrix(p)
    mmat = mapped_matrix(p)
    slocs, sg, spins = source_graph(p)
    mlocs, mg, mpins = mapped_graph(p)
    m, n = size(p)
    img = canvas() do c
        for (ic, mconfig) in enumerate(configs)
            if ic % 2 == 0
                dx = 2n+3
            else
                dx = 0
            end
            dy = -(m+1)*((ic-1) ÷ 2 -1)
            Mesh(1+dx, n+dx, 1+dy, m+dy) >> c
            viz_bonds!(c, mlocs, mg, dx, dy)
            viz_matrix!(c, mmat, mconfig, dx, dy)
            PlainText(n+1+dx, m/2+0.5+dy, "\$\\rightarrow\$") >> c
            sconfig = UnitDiskMapping.map_config_back!(p, 1, 1, mconfig)
            dx += n+1
            Mesh(1+dx, n+dx, 1+dy, m+dy) >> c
            viz_bonds!(c, slocs, sg, dx, dy)
            viz_matrix!(c, smat, sconfig, dx, dy)
        end
    end
    writepdf(filename, img)
end
function viz_bonds!(c, locs, g, dx, dy)
    for e in edges(g)
        a = locs[e.src]
        b = locs[e.dst]
        Line((a.y+dx, a.x+dy), (b.y+dx, b.x+dy); line_width="2pt") >> c
    end
end
