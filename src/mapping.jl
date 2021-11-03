struct UGrid
    n::Int
    content::Matrix{Int}
    zoom_level::Int
end

Base.:(==)(ug::UGrid, ug2::UGrid) = ug.n == ug2.n && ug.zoom_level == ug2.zoom_level && ug.content == ug2.content

function UGrid(n::Int, zoom_level::Int)
    s = 2*zoom_level
    N = (n-1)*s+1
    u = zeros(Int, N, N)
    for j=n-1:-1:0
        for i=0:n-1
            if i<=j
                u[max(1, s*i-s+3):2:s*i+1, s*j+1] .= 1
                #i!=0 && (u[s*i-s+2:2:s*i, s*j+1] .= -1)
                i!=0 && (u[s*i-s+2:2:s*i, s*j+1] .= 1)
            else
                @assert all(==(1), u[s*j+1, s*i+1])
                u[s*j+1, max(1, s*i-s+3):2:s*i-1] .= 1
                u[s*j+1, s*i+1] = 2
                #(u[s*j+1, s*i-s+2:2:s*i] .= -1)
                (u[s*j+1, s*i-s+2:2:s*i] .= 1)
            end
        end
    end
    return UGrid(n, u, zoom_level)
end

function SimpleGraph(ug::UGrid)
    if any(x->abs(x)>1, ug.content)
        error("This mapping is not done yet!")
    end
    return unitdisk_graph([ci.I for ci in findall(!iszero, ug.content)], 1.6)
end

function Base.show(io::IO, ug::UGrid)
    for i=1:size(ug.content, 1)
        for j=1:size(ug.content, 2)
            showitem(io, ug.content[i,j])
            print(io, " ")
        end
        if i!=size(ug.content, 1)
            println(io)
        end
    end
end
Base.copy(ug::UGrid) = UGrid(ug.n, copy(ug.content), ug.zoom_level)
function crossat(ug::UGrid, i, j)
    s = ug.zoom_level * 2
    return (i-1)*s+1, (j-1)*s+1
end
function Graphs.add_edge!(ug::UGrid, i, j)
    ug.content[crossat(ug, i, j)...] = -2
    return ug
end

function showitem(io, x)
    if x == 1
        print(io, "●")
    elseif x == 0
        print(io, " ")
    elseif x == -1
        print(io, "○")
    elseif x == 2
        print(io, "◉")
    elseif x == -2
        print(io, "◆")
    else
        print(io, "?")
    end
end

# TODO:
# 1. check if the resulting graph is a unit-disk
# 2. other simplification rules
function apply_gadgets!(ug::UGrid, ruleset=(
                    Cross{false}(), Cross{true}(), TShape{:H,false}(), TShape{:H,true}(),
                    TShape{:V,false}(), TShape{:V,true}(), Turn(), Corner{true}(), Corner{false}()
                ))
    tape = Tuple{Pattern,Int,Int}[]
    for j=0:size(ug.content, 2)  # start from 0 because there can be one empty padding column/row.
        for i=0:size(ug.content, 1)
            for pattern in ruleset
                if match(pattern, ug.content, i, j)
                    apply_gadget!(pattern, ug.content, i, j)
                    push!(tape, (pattern, i, j))
                    break
                end
            end
        end
    end
    return ug, tape
end

function unapply_gadgets!(ug::UGrid, tape, configurations)
    for (pattern, i, j) in Base.Iterators.reverse(tape)
        @assert unmatch(pattern, ug.content, i, j)
        for c in configurations
            map_config_back!(pattern, i, j, c)
        end
        unapply_gadget!(pattern, ug.content, i, j)
    end
    cfgs = map(configurations) do c
        map_config_copyback!(ug.n, c, ug.zoom_level)
    end
    return ug, cfgs
end

function unitdisk_graph(locs::AbstractVector, unit::Real)
    n = length(locs)
    g = SimpleGraph(n)
    for i=1:n, j=i+1:n
        if sum(abs2, locs[i] .- locs[j]) < unit ^ 2
            add_edge!(g, i, j)
        end
    end
    return g
end

# returns a vector of configurations
function _map_config_back(s::Pattern, config)
    d1 = mapped_entry_to_compact(s)
    d2 = source_entry_to_configs(s)
    # get the pin configuration
    bc = mapped_boundary_config(s, config)
    return d2[d1[bc]]
end

function map_config_back!(p::Pattern, i, j, configuration)
    m, n = size(p)
    locs, graph, pins = mapped_graph(p)
    config = [configuration[i+loc[1]-1, j+loc[2]-1] for loc in locs]
    newconfig = rand(_map_config_back(p, config))
    # clear canvas
    for i_=i:i+m-1, j_=j:j+n-1
        safe_set!(configuration,i_,j_, 0)
    end
    locs0, graph0, pins0 = source_graph(p)
    for (k, loc) in enumerate(locs0)
        configuration[i+loc[1]-1,j+loc[2]-1] += newconfig[k]
    end
    return configuration
end

function map_config_copyback!(n, c, zoom_level::Int)
    store = copy(c)
    s = 2*zoom_level
    res = zeros(Int, n)
    for j=1:n
        for i=1:(n-1)*s + 1
            J = (j-1)*s + 1
            if i > (j-1)*s+1
                J += i-(j-1)*s-1
                I = (j-1)*s + 1
                # bits belong to horizontal lines
                if i%s != 1 || (safe_get(c, I, J-1) == 0 && safe_get(c, I, J+1) == 0)
                    if store[I, J] != 0
                        res[j] += 1
                        store[I, J] -= 1
                    end
                end
            else
                # bits belong to vertical lines
                if i%s != 1 || (safe_get(c, i-1, J) == 0 && safe_get(c, i+1, J) == 0)
                    if store[i, J] != 0
                        res[j] += 1
                        store[i, J] -= 1
                    end
                end
            end
        end
    end
    return map(res) do x
        if x == zoom_level*(n-1)
            false
        elseif x == zoom_level*(n-1) + 1
            true
        else
            error("mapping back fail! got $x (overhead = $((n-1)*zoom_level))")
        end
    end
end

export is_independent_set
function is_independent_set(g::SimpleGraph, config)
    for e in edges(g)
        if config[e.src] == config[e.dst] == 1
            return false
        end
    end
    return true
end