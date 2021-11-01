struct UGrid
    n::Int
    content::Matrix{Int}
    zoom_level::Int
end

function UGrid(n::Int, zoom_level::Int)
    s = 2*zoom_level
    N = (n-1)*s+1
    u = zeros(Int, N, N)
    for j=n-1:-1:0
        for i=0:n-1
            if i<=j
                u[max(1, s*i-s+3):2:s*i+1, s*j+1] .= 1
                i!=0 && (u[s*i-s+2:2:s*i, s*j+1] .= -1)
            else
                @assert all(==(1), u[s*j+1, s*i+1])
                u[s*j+1, max(1, s*i-s+3):2:s*i-1] .= 1
                u[s*j+1, s*i+1] = 2
                (u[s*j+1, s*i-s+2:2:s*i] .= -1)
            end
        end
    end
    return UGrid(n, u, zoom_level)
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
    ug.content[crossat(ug, i, j)...] = 3
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
    elseif x == 3
        print(io, "◆")
    else
        print(io, "?")
    end
end

function apply_gadgets!(ug::UGrid, ruleset=(
                    Cross{false}(), Cross{true}(), TShape{:H,false}(), TShape{:H,true}(),
                    TShape{:V,false}(), TShape{:V,true}(), Turn(), Corner{true}(), Corner{false}()
                ))
    for j=1:size(ug.content, 2)
        for i=1:size(ug.content, 1)
            for pattern in ruleset
                if match(pattern, ug.content, i, j)
                    apply_gadget!(pattern, ug.content, i, j)
                    break
                end
            end
        end
    end
    return ug
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

