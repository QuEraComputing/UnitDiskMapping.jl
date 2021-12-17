using UnitDiskMapping, Test
using Graphs

# test method "get_udg_neighbors"
# test "get_UNode_from_pos"
@testset "test neighbors" begin
    # test on gadgets
    g = smallgraph(:house)
    # map to udg
    pos = coordinates(map_graph(g).grid_graph)
    ud_g = unitdisk_graph(pos, 1.5)

    # list of UNodes
    n_list = Vector{UNode}(undef, size(pos)[1])
    # check that all neighbors of udg map in "get_udg_neighbors"
    for (i, v) in enumerate(vertices(ud_g))
        for j in neighbors(ud_g, v)
            @test(pos[j] in get_udg_neighbors(pos[i]))
        end
        # initiate unodes
        unode = UNode(v, pos[i], neighbors(ud_g, v))
        n_list[i] = unode
    end

    # find the boundaries given n_list
    x_min, y_min, x_max, y_max = find_boundaries(n_list)
    for p in pos
        p_x, p_y = p
        @test(x_max >= p_x >= x_min)
        @test(y_max >= p_y >= y_min)
    end

    # test 'get_UNode_from_pos'
    for (i, p) in enumerate(pos)
        @test n_list[i] == get_UNode_from_pos(p, n_list)
    end

    pts_xmin_upper, pts_xmin_lower, pts_xmax_upper, pts_xmax_lower,
    pts_ymin_right, pts_ymin_left, pts_ymax_right, pts_ymax_left =
    find_boundary_points(n_list, x_min, x_max, y_min, y_max)


    for v in pts_xmin_upper
    # make sure that there are no points to the left of this point
        px, py = v.pos
        for i = -1:1
            @ get_UNode_from_pos((px - 1, py + i), n_list) == nothing
        end
        @test py >= (y_max - y_min)/2 + y_min
    end


    for v in pts_xmin_lower
    # make sure that there are no points to the left of this point
        px, py = v.pos
        for i = -1:1
            @test get_UNode_from_pos((px - 1, py + i), n_list) == nothing
        end
        @test py <= (y_max - y_min)/2 + y_min
    end

    for v in pts_xmax_upper
    # make sure that there are no points to the left of this point
        px, py = v.pos
        for i = -1:1
            @test get_UNode_from_pos((px + 1, py + i), n_list) == nothing
        end
        @test py >= (y_max - y_min)/2 + y_min
    end

    for v in pts_xmax_lower
    # make sure that there are no points to the left of this point
        px, py = v.pos
        for i = -1:1
            @test get_UNode_from_pos((px + 1, py + i), n_list) == nothing
        end
        @test py <= (y_max - y_min)/2 + y_min
    end

    for v in pts_ymin_right
    # make sure that there are no points to the left of this point
        px, py = v.pos
        for i = -1:1
            @test get_UNode_from_pos((px + i, py - 1), n_list) == nothing
        end
        @test px >= (x_max - x_min)/2 + x_min
    end

    for v in pts_ymin_left
    # make sure that there are no points to the left of this point
        px, py = v.pos
        for i = -1:1
            @test get_UNode_from_pos((px + i , py- 1), n_list) == nothing
        end
        @test px <= (x_max - x_min)/2 + x_min
    end

    for v in pts_ymax_right
    # make sure that there are no points to the left of this point
        px, py = v.pos
        for i = -1:1
            @test get_UNode_from_pos((px +i, py + 1), n_list) == nothing
        end
        @test px >= (x_max - x_min)/2 + x_min
    end

    for v in pts_ymax_left
    # make sure that there are no points to the left of this point
        px, py = v.pos
        for i = -1:1
            @test get_UNode_from_pos((px +i, py + 1), n_list) == nothing
        end
        @test px <= (x_max - x_min)/2 + x_min
    end

    for (i, n) in enumerate(n_list)
        @assert(check_UDG_criteria(n, pos[i], n_list) == false)
    end

end
