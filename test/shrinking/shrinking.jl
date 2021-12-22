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

    # test node_cost
    @test(node_cost((find_center(n_list)), n_list) == 0)
end
