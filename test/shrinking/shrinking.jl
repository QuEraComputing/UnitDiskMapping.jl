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

    boundary_pts = find_boundary_points(n_list, x_min, x_max, y_min, y_max)
    # check the boundary points
    for p in boundary_pts
        p_x, p_y = p

        for i = -1:1
            (p_x == x_min) && (@test(get_UNode_from_pos((p_x - 1, p_y + i), n_list) == nothing))
            (p_x == x_max) && (@test(get_UNode_from_pos((p_x + 1, p_y + i), n_list) == nothing))

            (p_y == y_min) && (@test(get_UNode_from_pos((p_x + i, p_y - 1), n_list) == nothing))
            (p_x == y_max) && (@test(get_UNode_from_pos((p_x + i, p_y  + 1), n_list) == nothing))
        end
    end

    # check greedy_step: check that still unit disk graph
    n_list2 = greedy_step(n_list, x_min, x_max, y_min, y_max)

    for (i, n) in enumerate(n_list2)
        @test(check_UDG_criteria(n, n.pos, n_list) == false)
        @test(n.vertices == n_list[i].vertices)
    end



    for (i, n) in enumerate(n_list)
        @test(check_UDG_criteria(n, pos[i], n_list) == false)
    end



end
