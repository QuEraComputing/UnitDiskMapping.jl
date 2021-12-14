using UnitDiskMapping.TikzGraph, Test

@testset "commands" begin
    n = Node(0.2, 0.5)
    @test command(n) isa String
    m = Node(0.6, 0.5)
    @test command(n) isa String
    l = Line(m, n)
    @test command(n) isa String
    b = BoundingBox(0, 10, 0, 10)
    @test command(b) isa String
    g = Mesh(0, 10, 0, 10)
    @test command(g) isa String
    s = StringElement("jajaja")
    @test command(s) == "jajaja"
    s = PlainText(20.0, 3.0, "jajaja")
    @test command(s) isa String
end

@testset "canvas" begin
    res = canvas() do c
        Node(0.2, 0.5; draw=rgbcolor!(c, 21, 42, 36)) >> c
        "jajaja" >> c
    end
    @test res isa Canvas
    @test generate_standalone(res) isa String
    write("test.tex", res)
    @test isfile("test.tex")
    rm("test.tex")
end