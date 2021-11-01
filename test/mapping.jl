using UnitDiskMapping, Test
using Graphs

@testset "crossing connect count" begin
    g = smallgraph(:bull)
    ug = embed_graph(g, 3)
    for (s, c) in zip((Cross{false}(), Cross{true}(), TShape{:V, true}(), TShape{:V,false}(),
            TShape{:H,true}(), TShape{:H, false}(), Turn(), Corner{true}(), Corner{false}()), (1,2,1,2,2,1,3,0,1))
        @test sum(match.(Ref(s), Ref(ug.content), (1:size(ug.content, 1))', 1:size(ug.content,2))) == c
    end
end