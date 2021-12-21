module CompressUDG
using Graphs

export UNode, contract_graph, CompressUDGMethod

struct UNode
    vertex::Int # vertex index in original graph
    pos::Tuple{Int, Int}
    neighbors::Vector{Int}
end
function Base.:(==)(x::UNode, y::UNode)
    x.vertex ==  y.vertex  && x.neighbors == y.neighbors
end

# get surrounding neighbor points on UDG
function get_udg_neighbors(pos::Tuple{Int, Int})
    p_x, p_y = pos
    pos_udg_neighbors = Vector{Tuple{Int, Int}}()

    for i = -1:1, j = -1:1
        !(i == 0 && j == 0) && push!(pos_udg_neighbors, (p_x + i, p_y + j))
    end
    return pos_udg_neighbors
end


# find UDNode given a position; return nothing if no node at that position
function get_UNode_from_pos(pos::Tuple{Int, Int}, node_list::Vector{UNode})
    for u in node_list
        (u.pos == pos) && return u
    end
    return nothing
end

# find boundaries of grid graph given list of UNodes
function find_boundaries(node_list::Vector{UNode})
    min_x = typemax(Int)
    min_y = typemax(Int)
    max_x = 0
    max_y = 0

    for u in node_list
        p_x, p_y = u.pos
        (p_x > max_x) && (max_x = p_x)
        (p_x < min_x) && (min_x = p_x)
        (p_y > max_y) && (max_y = p_y)
        (p_y < min_y) && (min_y = p_y)
    end
    return min_x, min_y, max_x, max_y
end

# find points on the boundary that can be moved
function find_boundary_points(node_list::Vector{UNode}, x_min, x_max, y_min, y_max)
    pts_boundary = Vector{UNode}()

    for u in node_list
        p_x, p_y = u.pos
        (p_x == x_min || p_x == x_max || p_y == y_min || p_y == y_max) && push!(pts_boundary, u)
    end

    return pts_boundary
end


# check that the new position of node n satisfies UDG requirements
function check_UDG_criteria(n::UNode, new_pos::Tuple{Int, Int},
    node_list::Vector{UNode})
    # check if new_pos is already occupied
    (get_UNode_from_pos(new_pos, node_list) != nothing) && return false

    p_x, p_y = new_pos
    new_neighbors = Vector{Int}()

    for p in get_udg_neighbors(new_pos)
        unode = get_UNode_from_pos(p, node_list)

        if (unode !== nothing) && (unode.vertex != n.vertex)
            push!(new_neighbors, unode.vertex)
        end
    end

    (issetequal(new_neighbors, n.neighbors) == true) && return true
    return false
end

# move node n to a new position new_pos
function move_node(n::UNode, node_list::Vector{UNode}, candidates::Vector{Tuple{Int, Int}})
    for p in candidates
        if check_UDG_criteria(n, p, node_list)
            node_list[n.vertex] = UNode(n.vertex, p, n.neighbors)
            return node_list
        end
    end
    return node_list
end

# determine candidates to move
function determine_candidates(pos::Tuple{Int, Int}, x_min, x_max, y_min, y_max)
    p_x, p_y = pos

    halfx = (x_max - x_min)/2 + x_min
    halfy = (y_max - y_min)/2 + y_min

    # move boundary vertices such that we can shrink graph from four quadrants
    (p_x == x_min && p_y >= halfy) && return [(p_x + 1, p_y), (p_x + 1, p_y - 1), (p_x, p_y - 1)]
    (p_x == x_min && p_y < halfy) && return [(p_x + 1, p_y), (p_x + 1, p_y + 1), (p_x, p_y + 1)]
    (p_x == x_max && p_y >= halfy) && return [(p_x - 1, p_y), (p_x - 1, p_y - 1), (p_x, p_y - 1)]
    (p_x == x_max && p_y < halfy) && return [(p_x - 1, p_y), (p_x - 1, p_y + 1), (p_x, p_y + 1)]

    (p_x < halfx && p_y == y_min) && return [(p_x, p_y + 1), (p_x + 1, p_y + 1), (p_x + 1, p_y)]
    (p_x >= halfx && p_y == y_min) && return [(p_x, p_y + 1), (p_x - 1, p_y + 1), (p_x - 1, p_y)]
    (p_x < halfx && p_y == y_max) && return [(p_x, p_y - 1), (p_x + 1, p_y - 1), (p_x + 1, p_y)]
    (p_x >= halfx && p_y == y_max) && return [(p_x, p_y - 1), (p_x - 1, p_y - 1), (p_x - 1, p_y)]

end


# one shrinking step
function greedy_step(node_list::Vector{UNode}, min_x::Int, max_x::Int,
    min_y::Int, max_y::Int)

    boundary_pts = find_boundary_points(node_list, min_x, max_x,
    min_y, max_y)

    for p in boundary_pts
        node_list = move_node(p, node_list, determine_candidates(p.pos, min_x, max_x,
        min_y, max_y))
    end

    return node_list
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

# interfaces
abstract type CompressUDGMethod end

"""
    contract_graph(locs::Vector{Tuple{Int, Int}})
Compute a contracted version of input graph node positions and returns a
corresponding layout of new condensed graph
"""
function contract_graph(node_positions::Vector{Tuple{Int, Int}})
    # initiate UNodes

    n_list = Vector{UNode}(undef, size(node_positions)[1])
    g = unitdisk_graph(node_positions, 1.5)

    for (ind, n_pos) in enumerate(node_positions)
        n_list[ind] = UNode(ind, n_pos, neighbors(g, ind))
    end

    xmin, ymin, xmax, ymax = find_boundaries(n_list)


    while (xmax - xmin > 1) && (ymax - ymin > 1)
        n_list = greedy_step(n_list, xmin, xmax, ymin, ymax)

        if xmin < xmax
            xmin += 1
            xmax -= 1
        end

        if ymin < ymax
            ymin += 1
            ymax -= 1
        end

    end

    locs_new = Vector{Tuple{Int, Int}}(undef, size(node_positions)[1])
    for (ind, un) in enumerate(n_list)
        locs_new[ind] = un.pos
    end

    return locs_new
end

end

using .CompressUDG
export UNode, contract_graph, CompressUDGMethod
