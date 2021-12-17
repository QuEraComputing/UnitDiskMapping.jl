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
# divide region into 4 and move nodes greedily closer to center
function find_boundary_points(node_list::Vector{UNode}, x_min, x_max, y_min, y_max)
    half_x = (x_max - x_min)/2 + x_min
    half_y = (y_max - y_min)/2 + y_min

    pts_xmin_upper = UNode[]
    pts_xmax_upper = Vector{UNode}()
    pts_xmin_lower = Vector{UNode}()
    pts_xmax_lower = Vector{UNode}()

    pts_ymin_left = Vector{UNode}()
    pts_ymax_left = Vector{UNode}()
    pts_ymin_right = Vector{UNode}()
    pts_ymax_right = Vector{UNode}()

    for u in node_list
        p_x, p_y = u.pos

        (p_x == x_min && p_y >= half_y) && push!(pts_xmin_upper, u)
        (p_x == x_min && p_y < half_y) && push!(pts_xmin_lower, u)
        (p_x == x_max && p_y >= half_y) && push!(pts_xmax_upper, u)
        (p_x == x_max && p_y < half_y) && push!(pts_xmax_lower, u)
        (p_x >= half_x && p_y == y_min) && push!(pts_ymin_right, u)
        (p_x < half_x && p_y == y_min) && push!(pts_ymin_left, u)
        (p_x >= half_x && p_y == y_max) && push!(pts_ymax_right, u)
        (p_x < half_x && p_y == y_max) && push!(pts_ymax_left, u)
    end

    return pts_xmin_upper, pts_xmin_lower, pts_xmax_upper, pts_xmax_lower,
    pts_ymin_right, pts_ymin_left, pts_ymax_right, pts_ymax_left
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

    (issetequal(new_neighbors, n.neighbors) == true) & return true
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

# determine candidates
function candidates_xmin_upper(pos::Tuple{Int, Int})
    p_x, p_y = pos
    return [(p_x + 1, p_y), (p_x + 1, p_y - 1), (p_x, p_y - 1)]
end

function candidates_xmin_lower(pos::Tuple{Int, Int})
    p_x, p_y = pos
    return [(p_x + 1, p_y), (p_x + 1, p_y + 1), (p_x, p_y + 1)]
end


function candidates_xmax_upper(pos::Tuple{Int, Int})
    p_x, p_y = pos
    return [(p_x - 1, p_y), (p_x - 1, p_y - 1), (p_x, p_y - 1)]
end


function candidates_xmax_lower(pos::Tuple{Int, Int})
    p_x, p_y = pos
    return [(p_x - 1, p_y), (p_x - 1, p_y + 1), (p_x, p_y + 1)]
end


function candidates_ymin_left(pos::Tuple{Int, Int})
    p_x, p_y = pos
    return [(p_x, p_y + 1), (p_x + 1, p_y + 1), (p_x + 1, p_y)]
end

function candidates_ymin_right(pos::Tuple{Int, Int})
    p_x, p_y = pos
    return [(p_x, p_y + 1), (p_x - 1, p_y + 1), (p_x - 1, p_y)]
end

function candidates_ymax_left(pos::Tuple{Int, Int})
    p_x, p_y = pos
    return [(p_x, p_y - 1), (p_x + 1, p_y - 1), (p_x + 1, p_y)]
end

function candidates_ymax_right(pos::Tuple{Int, Int})
    p_x, p_y = pos
    return [(p_x, p_y - 1), (p_x - 1, p_y - 1), (p_x - 1, p_y)]
end

# one shrinking step
function greedy_step(node_list::Vector{UNode}, min_x::Int, max_x::Int,
    min_y::Int, max_y::Int)

    xmin_upper, xmin_lower, xmax_upper, xmax_lower, ymin_right, ymin_left,
    ymax_right, ymax_left = find_boundary_points(node_list, min_x, max_x,
    min_y, max_y)

    for p in xmin_upper
        node_list = move_node(p, node_list, candidates_xmin_upper(p.pos))
    end
    for p in xmin_lower
        node_list = move_node(p, node_list, candidates_xmin_lower(p.pos))
    end
    for p in xmax_upper
        node_list = move_node(p, node_list, candidates_xmax_upper(p.pos))
    end
    for p in xmax_lower
        node_list = move_node(p, node_list, candidates_xmax_lower(p.pos))
    end

    for p in ymin_left
        node_list = move_node(p, node_list, candidates_ymin_left(p.pos))
    end
    for p in ymin_right
        node_list = move_node(p, node_list, candidates_ymin_right(p.pos))
    end
    for p in ymax_left
        node_list = move_node(p, node_list, candidates_ymax_left(p.pos))
    end
    for p in ymax_right
        node_list = move_node(p, node_list, candidates_ymax_right(p.pos))
    end

    return node_list
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
