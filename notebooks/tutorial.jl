### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 2f721887-6dee-4b53-ae33-2c0a4b79ff37
# ╠═╡ show_logs = false
begin
	using Pkg; Pkg.activate(".")
	using Revise
	using PlutoUI
		# left right layout
	function leftright(a, b; width=600)
		HTML("""
<style>
table.nohover tr:hover td {
   background-color: white !important;
}</style>
			
<table width=$(width)px class="nohover" style="border:none">
<tr>
	<td>$(html(a))</td>
	<td>$(html(b))</td>
</tr></table>
""")
	end
	
	# up down layout
	function updown(a, b; width=nothing)
		HTML("""<table class="nohover" style="border:none" $(width === nothing ? "" : "width=$(width)px")>
<tr>
	<td>$(html(a))</td>
</tr>
<tr>
	<td>$(html(b))</td>
</tr></table>
""")
	end
	PlutoUI.TableOfContents()
end

# ╔═╡ 39bcea18-00b6-42ca-a1f2-53655f31fea7
using UnitDiskMapping, Graphs, GenericTensorNetworks, LinearAlgebra

# ╔═╡ 98459516-4833-4e4a-916f-d5ea3e657ceb
# Visualization setup.
# To make the plots dark-mode friendly, we use white-background color.
using UnitDiskMapping.LuxorGraphPlot.Luxor, LuxorGraphPlot

# ╔═╡ eac6ceda-f5d4-11ec-23db-b7b4d00eaddf
md"# Unit Disk Mapping"

# ╔═╡ bbe26162-1ab7-4224-8870-9504b7c3aecf
md"## Generic Unweighted Mapping
The generic unweighted mapping aims to reduce a generic unweighted Maximum Independent Set (MIS) problem to one on a defected King's graph.
Check [our paper (link to be added)]() for the mapping scheme.
"

# ╔═╡ b23f0215-8751-4105-aa7e-2c26e629e909
md"Let the source graph be the Petersen graph."

# ╔═╡ 7518d763-17a4-4c6e-bff0-941852ec1ccf
graph = smallgraph(:petersen)

# ╔═╡ 0302be92-076a-4ebe-8d6d-4b352a77cfce
LuxorGraphPlot.show_graph(graph)

# ╔═╡ 417b18f6-6a8f-45fb-b979-6ec9d12c6246
md"We can use the `map_graph` function to map the unweighted MIS problem on the Petersen graph to one on a defected King's graph."

# ╔═╡ c7315578-8bb0-40a0-a2a3-685a80674c9c
unweighted_res = map_graph(graph; vertex_order=Branching());

# ╔═╡ 3f605eac-f587-40b2-8fac-8223777d3fad
md"Here, the keyword argument `vertex_order` can be a vector of vertices in a specified order, or the method to compute the path decomposition that generates an order. The `Branching()` method is an exact path decomposition solver, which is suited for small graphs (where number of vertices <= 50). The `Greedy()` method finds the vertex order much faster and works in all cases, but may not be optimal.
A good vertex order can reduce the depth of the mapped graph."

# ╔═╡ e5382b61-6387-49b5-bae8-0389fbc92153
md"The return value contains the following fields:"

# ╔═╡ ae5c8359-6bdb-4a2a-8b54-cd2c7d2af4bd
fieldnames(unweighted_res |> typeof)

# ╔═╡ 56bdcaa6-c8b9-47de-95d4-6e95204af0f2
md"The field `grid_graph` is the mapped grid graph."

# ╔═╡ 520fbc23-927c-4328-8dc6-5b98853fb90d
LuxorGraphPlot.show_graph(unweighted_res.grid_graph)

# ╔═╡ af162d39-2da9-4a06-9cde-8306e811ba7a
unweighted_res.grid_graph.size

# ╔═╡ 96ca41c0-ac77-404c-ada3-0cdc4a426e44
md"The field `lines` is a vector of copy gadgets arranged in a `⊢` shape. These copy gadgets form a *crossing lattice*,  in which two copy lines cross each other whenever their corresponding vertices in the source graph are connected by an edge.
```
    vslot
      ↓
      |          ← vstart
      |
      |-------   ← hslot
      |      ↑   ← vstop
            hstop
```
"

# ╔═╡ 5dfa8a74-26a5-45c4-a80c-47ba4a6a4ae9
unweighted_res.lines

# ╔═╡ a64c2094-9a51-4c45-b9d1-41693c89a212
md"The field `mapping_history` contains the rewrite rules applied to the crossing lattice. They contain important information for mapping a solution back."

# ╔═╡ 52b904ad-6fb5-4a7e-a3db-ae7aff32be51
unweighted_res.mapping_history

# ╔═╡ ef828107-08ce-4d91-ba56-2b2c7862aa50
md"The field `mis_overhead` is the difference between ``\alpha(G_M) - \alpha(G_S)``, where ``G_M`` and ``G_S`` are the mapped and source graph."

# ╔═╡ acd7107c-c739-4ee7-b0e8-6383c54f714f
unweighted_res.mis_overhead

# ╔═╡ 94feaf1f-77ea-4d6f-ba2f-2f9543e8c1bd
md"We can solve the mapped graph with [`GenericTensorNetworks`](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/)."

# ╔═╡ f084b98b-097d-4b33-a0d3-0d0a981f735e
res = solve(GenericTensorNetwork(IndependentSet(SimpleGraph(unweighted_res.grid_graph))), SingleConfigMax())[]

# ╔═╡ 86457b4e-b83e-4bf5-9d82-b5e14c055b4b
md"You might want to read [the documentation page of `GenericTensorNetworks`](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/) for a detailed explanation on this function. Here, we just visually check the solution configuration."

# ╔═╡ 4abb86dd-67e2-46f4-ae6c-e97952b23fdc
show_config(unweighted_res.grid_graph, res.c.data)

# ╔═╡ 5ec5e23a-6904-41cc-b2dc-659da9556d20
md"By mapping the result back, we get a solution for the original Petersen graph. Its maximum independent set size is 4."

# ╔═╡ 773ce349-ba72-426c-849d-cfb511773756
# The solution obtained by solving the mapped graph
original_configs = map_config_back(unweighted_res, res.c.data)

# ╔═╡ 7d921205-5133-40c0-bfa6-f76713dd4972
# Confirm that the solution from the mapped graph gives us
# a maximum independent set for the original graph
UnitDiskMapping.is_independent_set(graph, original_configs)

# ╔═╡ 3273f936-a182-4ed0-9662-26aab489776b
md"## Generic Weighted Mapping"

# ╔═╡ 5e4500f5-beb6-4ef9-bd42-41dc13b60bce
md"A Maximum Weight Independent Set (MWIS) problem on a general graph can be mapped to one on the defected King's graph. The first step is to do the same mapping as above but adding a new positional argument `Weighted()` as the first argument of `map_graph`. Let us still use the Petersen graph as an example."

# ╔═╡ 2fa704ee-d5c1-4205-9a6a-34ba0195fecf
weighted_res = map_graph(Weighted(), graph; vertex_order=Branching());

# ╔═╡ 27acc8be-2db8-4322-85b4-230fdddac043
md"The return value is similar to that for the unweighted mapping generated above, except each node in the mapped graph can have a weight 1, 2 or 3. Note here, we haven't added the weights in the original graph."

# ╔═╡ b8879b2c-c6c2-47e2-a989-63a00c645676
show_grayscale(weighted_res.grid_graph)

# ╔═╡ 1262569f-d091-40dc-a431-cbbe77b912ab
md"""
The "pins" of the mapped graph have a one-to-one correspondence to the vertices in the source graph.
"""

# ╔═╡ d5a64013-b7cc-412b-825d-b9d8f0737248
show_pins(weighted_res)

# ╔═╡ 3c46e050-0f93-42af-a6ff-1a83e7d0f6da
md"The weights in the original graph can be added to the pins of this grid graph using the `map_weights` function. The added weights must be smaller than 1."

# ╔═╡ 39cbb6fc-1c55-42dd-bbf6-54e06f5c7048
source_weights = rand(10)

# ╔═╡ 41840a24-596e-4d93-9468-35329d57b0ce
mapped_weights = map_weights(weighted_res, source_weights)

# ╔═╡ f77293c4-e5c3-4f14-95a2-ac9688fa3ba1
md"Now that we have both the graph and the weights, let us solve the mapped problem!"

# ╔═╡ cf910d3e-3e3c-42ef-acf3-d0990d6227ac
wmap_config = let
	graph, _ = graph_and_weights(weighted_res.grid_graph)
	collect(Int,
		solve(GenericTensorNetwork(IndependentSet(graph, mapped_weights)), SingleConfigMax())[].c.data
	)
end

# ╔═╡ d0648123-65fc-4dd7-8c0b-149b67920d8b
show_config(weighted_res.grid_graph, wmap_config)

# ╔═╡ fdc0fd6f-369e-4f1b-b105-672ae4229f02
md"By reading the configurations of the pins, we obtain a solution for the source graph."

# ╔═╡ 317839b5-3c30-401f-970c-231c204331b5
# The solution obtained by solving the mapped graph
map_config_back(weighted_res, wmap_config)

# ╔═╡ beb7c0e5-6221-4f20-9166-2bd56902be1b
# Directly solving the source graph
collect(Int,
	solve(GenericTensorNetwork(IndependentSet(graph, source_weights)), SingleConfigMax())[].c.data
)

# ╔═╡ cf7e88cb-432e-4e3a-ae8b-8fa12689e485
md"## QUBO problem"

# ╔═╡ d16a6f2e-1ae2-47f1-8496-db6963800fd2
md"### Generic QUBO mapping"

# ╔═╡ b5d95984-cf8d-4bce-a73a-8eb2a7c6b830
md"""
A QUBO problem can be specified as the following energy model:
```math
E(z) = -\sum_{i<j} J_{ij} z_i z_j + \sum_i h_i z_i
```
"""

# ╔═╡ 2d1eb5cb-183d-4c4e-9a14-53fa08cbb156
n = 6

# ╔═╡ 5ce3e8c9-e78e-4444-b502-e91b4bda5678
J = triu(randn(n, n) * 0.001, 1); J += J'

# ╔═╡ 828cf2a9-9178-41ae-86d3-e14d8c909c39
h = randn(n) * 0.001

# ╔═╡ 09db490e-961a-4c64-bcc5-5c111bfd3b7a
md"Now, let us do the mapping on an ``n \times n`` crossing lattice."

# ╔═╡ 081d1eee-96b1-4e76-8b8c-c0d4e5bdbaed
qubo = UnitDiskMapping.map_qubo(J, h);

# ╔═╡ 7974df7d-c390-4706-b7ba-6bde4409510d
md"The mapping result contains two fields, the `grid_graph` and the `pins`. After finding the ground state of the mapped independent set problem, the configuration of the spin glass can be read directly from the pins. The following graph plots the pins in red color."

# ╔═╡ e6aeeeb4-704c-4ba4-abc2-29c4029e276d
qubo_graph, qubo_weights = UnitDiskMapping.graph_and_weights(qubo.grid_graph)

# ╔═╡ 8467e950-7302-4930-8698-8e7b523556a6
show_pins(qubo)

# ╔═╡ 6976c82f-90f0-4091-b13d-af463fe75c8b
md"One can also check the weights using the gray-scale plot."

# ╔═╡ 95539e68-c1ea-4a6c-9406-2696d62b8461
show_grayscale(qubo.grid_graph)

# ╔═╡ 5282ca54-aa98-4d51-aaf9-af20eae5cc81
md"By solving this maximum independent set problem, we will get the following configuration."

# ╔═╡ ef149d9a-6aa9-4f34-b936-201b9d77543c
qubo_mapped_solution = collect(Int, solve(GenericTensorNetwork(IndependentSet(qubo_graph, qubo_weights)), SingleConfigMax())[].c.data)

# ╔═╡ 4ea4f26e-746d-488e-9968-9fc584c04bcf
show_config(qubo.grid_graph, qubo_mapped_solution)

# ╔═╡ b64500b6-99b6-497b-9096-4bab4ddbec8d
md"This solution can be mapped to a solution for the source graph by reading the configurations on the pins."

# ╔═╡ cca6e2f8-69c5-4a3a-9f97-699b4868c4b9
# The solution obtained by solving the mapped graph
map_config_back(qubo, collect(Int, qubo_mapped_solution))

# ╔═╡ 80757735-8e73-4cae-88d0-9fe3d3e539c0
md"This solution is consistent with the exact solution:"

# ╔═╡ 7dd900fc-9531-4bd6-8b6d-3aac3d5a2386
# Directly solving the source graph, due to the convention issue, we flip the signs of `J` and `h`
collect(Int, solve(GenericTensorNetwork(spin_glass_from_matrix(-J, -h)), SingleConfigMax())[].c.data)

# ╔═╡ 13f952ce-642a-4396-b574-00ea6584008c
md"### QUBO problem on a square lattice"

# ╔═╡ fcc22a84-011f-48ed-bc0b-41f4058b92fd
md"We define some coupling strengths and onsite energies on a $n \times n$ square lattice."

# ╔═╡ e7be21d1-971b-45fd-aa83-591d43262567
square_coupling = [[(i,j,i,j+1,0.01*randn()) for i=1:n, j=1:n-1]...,
	[(i,j,i+1,j,0.01*randn()) for i=1:n-1, j=1:n]...];

# ╔═╡ 1702a65f-ad54-4520-b2d6-129c0576d708
square_onsite = vec([(i, j, 0.01*randn()) for i=1:n, j=1:n]);

# ╔═╡ 49ad22e7-e859-44d4-8179-e088e1159d04
md"Then we use `map_qubo_square` to reduce the QUBO problem on a square lattice to the MIS problem on a grid graph."

# ╔═╡ 32910090-9a42-475a-8e83-f9712f8fe551
qubo_square = UnitDiskMapping.map_qubo_square(square_coupling, square_onsite);

# ╔═╡ 7b5fcd3b-0f0a-44c3-9bf6-1dc042585322
show_grayscale(qubo_square.grid_graph)

# ╔═╡ 3ce74e3a-43f4-47a5-8dde-1d49e54e7eab
md"You can see each coupling is replaced by the following `XOR` gadget"

# ╔═╡ 8edabda9-c49b-407e-bae8-1a71a1fe19b4
show_grayscale(UnitDiskMapping.gadget_qubo_square(Int), texts=["x$('₀'+i)" for i=1:8])

# ╔═╡ 3ec7c034-4cb6-4b9f-96fb-c6dc428475bb
md"Where dark nodes have weight 2 and light nodes have weight 1. It corresponds to the boolean equation ``x_8 = \neg (x_1 \veebar x_5)``; hence we can add ferromagnetic couplings as negative weights and anti-ferromagnetic couplings as positive weights. On-site terms are added directly to the pins."

# ╔═╡ 494dfca2-af57-4dd9-9825-b28269641359
show_pins(qubo_square)

# ╔═╡ ca1d7917-58e2-4b7d-8671-ced548ccfe89
md"Let us solve the independent set problem on the mapped graph."

# ╔═╡ 30c33553-3b4d-4eff-b34c-7ac0579650f7
square_graph, square_weights = UnitDiskMapping.graph_and_weights(qubo_square.grid_graph);

# ╔═╡ 5c25abb7-e3ee-4104-9a82-eb4aa4e773d2
config_square = collect(Int, solve(GenericTensorNetwork(IndependentSet(square_graph, square_weights)), SingleConfigMax())[].c.data);

# ╔═╡ 4cec7232-8fbc-4ac1-96bb-6c7fea5fe117
md"We will get the following configuration."

# ╔═╡ 9bc9bd86-ffe3-48c1-81c0-c13f132e0dc1
show_config(qubo_square.grid_graph, config_square)

# ╔═╡ 9b0f051b-a107-41f2-b7b9-d6c673b7f93b
md"By reading out the configurations at pins, we can get a solution of the source QUBO problem."

# ╔═╡ d4c5240c-e70f-45f5-859f-1399c57511b0
r1 = map_config_back(qubo_square, config_square)

# ╔═╡ ffa9ad39-64e0-4655-b04e-23f57490d326
md"It can be easily checked by examining the exact result."

# ╔═╡ dfd4418e-19f0-42f2-87c5-69eacf2024ac
let
	# solve QUBO directly
	g2 = SimpleGraph(n*n)
	Jd = Dict{Tuple{Int,Int}, Float64}()
	for (i,j,i2,j2,J) in square_coupling
		edg = (i+(j-1)*n, i2+(j2-1)*n)
		Jd[edg] = J
		add_edge!(g2, edg...)
	end
	
	Js, hs = Float64[], zeros(Float64, nv(g2))
	for e in edges(g2)
		push!(Js, Jd[(e.src, e.dst)])
	end
	for (i,j,h) in square_onsite
		hs[i+(j-1)*n] = h
	end
	collect(Int, solve(GenericTensorNetwork(SpinGlass(g2, -Js, -hs)), SingleConfigMax())[].c.data)
end

# ╔═╡ 9db831d6-7f10-47be-93d3-ebc892c4b3f2
md"## Factorization problem"

# ╔═╡ e69056dd-0052-4d1e-aef1-30411d416c82
md"The building block of the array multiplier can be mapped to the following gadget:"

# ╔═╡ 13e3525b-1b8e-4f65-8742-21d8ba4fdbe3
let
	graph, pins = UnitDiskMapping.multiplier()
	texts = fill("", length(graph.nodes))
	texts[pins] .= ["x$i" for i=1:length(pins)]
	show_grayscale(graph)
end

# ╔═╡ 025b38e1-d334-46b6-bf88-f7b426e8dc97
md"""
Let us denote the input and output pins as ``x_{1-8} \in \{0, 1\}``. The above gadget implements the following equations:
```math
\begin{align}
x_1 + x_2 x_3 + x_4 = x_5 + 2 x_7,\\
x_2 = x_6,\\
x_3 = x_8.
\end{align}
```
"""

# ╔═╡ 76ab8044-78ec-41b5-b11a-df4e7e009e64
md"One can call `map_factoring(M, N)` to map a factoring problem to the array multiplier grid of size (M, N). In the following example of (2, 2) array multiplier, the input integers are ``p = 2p_2+p_1`` and ``q= 2q_2+q_1``, and the output integer is ``m = 4m_3+2m_2+m_1``. The maximum independent set corresponds to the solution of ``pq = m``"

# ╔═╡ b3c5283e-15fc-48d6-b58c-b26d70e5f5a4
mres = UnitDiskMapping.map_factoring(2, 2);

# ╔═╡ adbae5f0-6fe9-4a97-816b-004e47b15593
show_pins(mres)

# ╔═╡ 2e13cbad-8110-4cbc-8890-ecbefe1302dd
md"To solve this factoring problem, one can use the following statement:"

# ╔═╡ e5da7214-0e69-4b5a-a65e-ed92d0616c71
multiplier_output = UnitDiskMapping.solve_factoring(mres, 6) do g, ws
	collect(Int, solve(GenericTensorNetwork(IndependentSet(g, ws)), SingleConfigMax())[].c.data)
end

# ╔═╡ 9dc01591-5c37-4d83-b640-83280513941e
md"This function consists of the following steps:"

# ╔═╡ 41d9b8fd-dd18-4270-803f-bd6206845788
md"1. We first modify the graph by inspecting the fixed values, i.e., the output `m` and `0`s:
    * If a vertex is fixed to 1, remove it and its neighbors,
    * If a vertex is fixed to 0, remove this vertex.

The resulting grid graph is
"

# ╔═╡ b8b5aff0-2ed3-4237-9b9d-9eb0bf2f2878
mapped_grid_graph, remaining_vertices = let
	g, ws = graph_and_weights(mres.grid_graph)
	mg, vmap = UnitDiskMapping.set_target(g, [mres.pins_zeros..., mres.pins_output...], 6 << length(mres.pins_zeros))
	GridGraph(mres.grid_graph.size, mres.grid_graph.nodes[vmap], mres.grid_graph.radius), vmap
end;

# ╔═╡ 97cf8ee8-dba3-4b0b-b0ba-97002bc0f028
show_graph(mapped_grid_graph)

# ╔═╡ 0a8cec9c-7b9d-445b-abe3-237f16fdd9ad
md"2. Then, we solve this new grid graph."

# ╔═╡ 57f7e085-9589-4a6c-ac14-488ea9924692
config_factoring6 = let
	mg, mw = graph_and_weights(mapped_grid_graph)
	solve(GenericTensorNetwork(IndependentSet(mg, mw)), SingleConfigMax())[].c.data
end;

# ╔═╡ 4c7d72f1-688a-4a70-8ce6-a4801127bb9a
show_config(mapped_grid_graph, config_factoring6)

# ╔═╡ 77bf7e4a-1237-4b24-bb31-dc8a30756834
md"3. It is straightforward to read out the results from the above configuration. The solution should be either (2, 3) or (3, 2)."

# ╔═╡ 5a79eba5-3031-4e21-836e-961a9d939862
let
	cfg = zeros(Int, length(mres.grid_graph.nodes))
	cfg[remaining_vertices] .= config_factoring6
	bitvectors = cfg[mres.pins_input1], cfg[mres.pins_input2]
	UnitDiskMapping.asint.(bitvectors)
end

# ╔═╡ 27c2ba44-fcee-4647-910e-ae16f430b87d
md"## Logic Gates"

# ╔═╡ d577e515-f3cf-4f27-b0b5-a94cb38abf1a
md"Let us define a helper function for visualization."

# ╔═╡ c17bca17-a00a-4118-a212-d21da09af9b5
parallel_show(gate) = leftright(show_pins(Gate(gate)), show_grayscale(gate_gadget(Gate(gate))[1], wmax=2));

# ╔═╡ 6aee2288-1934-4fc5-9a9c-f45b7ce4e767
md"1. NOT gate: ``y_1 =\neg x_1``"

# ╔═╡ fadded74-8a89-4348-88f6-50d12cde6234
parallel_show(:NOT)

# ╔═╡ 0b28fab8-eb04-46d9-aa19-82e4bab45eb9
md"2. NXOR gate: ``y_1 =\neg (x_1 \veebar x_2)``. Notice this negated XOR gate is used in the square lattice QUBO mapping."

# ╔═╡ 791b9fde-1df2-4239-8372-2e3dd36d6f34
parallel_show(:NXOR)

# ╔═╡ 60ef4369-831d-413e-bcc2-e088697b6ba4
md"3. NOR gate: ``y_1 =\neg (x_1 \vee x_2)``"

# ╔═╡ f46c3993-e01d-47fb-873a-c608e0d49d83
parallel_show(:NOR)

# ╔═╡ d3779618-f61f-4874-93f1-94e78bb21c94
md"4. AND gate: ``y_1 =x_1 \wedge x_2``"

# ╔═╡ 330a5f6c-601f-47e6-8294-e6af89818d7d
parallel_show(:AND)

# ╔═╡ 36173fe2-784f-472a-9cab-03f2a0a2b725
md"Since most logic gates have 3 pins, it is natural to embed a circuit to a 3D unit disk graph by taking the z direction as the time. In a 2D grid, one needs to do the general weighted mapping in order to create a unit disk boolean circuit."

# ╔═╡ Cell order:
# ╟─eac6ceda-f5d4-11ec-23db-b7b4d00eaddf
# ╟─2f721887-6dee-4b53-ae33-2c0a4b79ff37
# ╠═39bcea18-00b6-42ca-a1f2-53655f31fea7
# ╠═98459516-4833-4e4a-916f-d5ea3e657ceb
# ╟─bbe26162-1ab7-4224-8870-9504b7c3aecf
# ╟─b23f0215-8751-4105-aa7e-2c26e629e909
# ╠═7518d763-17a4-4c6e-bff0-941852ec1ccf
# ╠═0302be92-076a-4ebe-8d6d-4b352a77cfce
# ╟─417b18f6-6a8f-45fb-b979-6ec9d12c6246
# ╠═c7315578-8bb0-40a0-a2a3-685a80674c9c
# ╟─3f605eac-f587-40b2-8fac-8223777d3fad
# ╟─e5382b61-6387-49b5-bae8-0389fbc92153
# ╠═ae5c8359-6bdb-4a2a-8b54-cd2c7d2af4bd
# ╟─56bdcaa6-c8b9-47de-95d4-6e95204af0f2
# ╠═520fbc23-927c-4328-8dc6-5b98853fb90d
# ╠═af162d39-2da9-4a06-9cde-8306e811ba7a
# ╟─96ca41c0-ac77-404c-ada3-0cdc4a426e44
# ╠═5dfa8a74-26a5-45c4-a80c-47ba4a6a4ae9
# ╟─a64c2094-9a51-4c45-b9d1-41693c89a212
# ╠═52b904ad-6fb5-4a7e-a3db-ae7aff32be51
# ╟─ef828107-08ce-4d91-ba56-2b2c7862aa50
# ╠═acd7107c-c739-4ee7-b0e8-6383c54f714f
# ╟─94feaf1f-77ea-4d6f-ba2f-2f9543e8c1bd
# ╠═f084b98b-097d-4b33-a0d3-0d0a981f735e
# ╟─86457b4e-b83e-4bf5-9d82-b5e14c055b4b
# ╠═4abb86dd-67e2-46f4-ae6c-e97952b23fdc
# ╟─5ec5e23a-6904-41cc-b2dc-659da9556d20
# ╠═773ce349-ba72-426c-849d-cfb511773756
# ╠═7d921205-5133-40c0-bfa6-f76713dd4972
# ╟─3273f936-a182-4ed0-9662-26aab489776b
# ╟─5e4500f5-beb6-4ef9-bd42-41dc13b60bce
# ╠═2fa704ee-d5c1-4205-9a6a-34ba0195fecf
# ╟─27acc8be-2db8-4322-85b4-230fdddac043
# ╠═b8879b2c-c6c2-47e2-a989-63a00c645676
# ╟─1262569f-d091-40dc-a431-cbbe77b912ab
# ╠═d5a64013-b7cc-412b-825d-b9d8f0737248
# ╟─3c46e050-0f93-42af-a6ff-1a83e7d0f6da
# ╠═39cbb6fc-1c55-42dd-bbf6-54e06f5c7048
# ╠═41840a24-596e-4d93-9468-35329d57b0ce
# ╟─f77293c4-e5c3-4f14-95a2-ac9688fa3ba1
# ╠═cf910d3e-3e3c-42ef-acf3-d0990d6227ac
# ╠═d0648123-65fc-4dd7-8c0b-149b67920d8b
# ╟─fdc0fd6f-369e-4f1b-b105-672ae4229f02
# ╠═317839b5-3c30-401f-970c-231c204331b5
# ╠═beb7c0e5-6221-4f20-9166-2bd56902be1b
# ╟─cf7e88cb-432e-4e3a-ae8b-8fa12689e485
# ╟─d16a6f2e-1ae2-47f1-8496-db6963800fd2
# ╟─b5d95984-cf8d-4bce-a73a-8eb2a7c6b830
# ╠═2d1eb5cb-183d-4c4e-9a14-53fa08cbb156
# ╠═5ce3e8c9-e78e-4444-b502-e91b4bda5678
# ╠═828cf2a9-9178-41ae-86d3-e14d8c909c39
# ╟─09db490e-961a-4c64-bcc5-5c111bfd3b7a
# ╠═081d1eee-96b1-4e76-8b8c-c0d4e5bdbaed
# ╟─7974df7d-c390-4706-b7ba-6bde4409510d
# ╠═e6aeeeb4-704c-4ba4-abc2-29c4029e276d
# ╠═8467e950-7302-4930-8698-8e7b523556a6
# ╟─6976c82f-90f0-4091-b13d-af463fe75c8b
# ╠═95539e68-c1ea-4a6c-9406-2696d62b8461
# ╟─5282ca54-aa98-4d51-aaf9-af20eae5cc81
# ╠═ef149d9a-6aa9-4f34-b936-201b9d77543c
# ╠═4ea4f26e-746d-488e-9968-9fc584c04bcf
# ╟─b64500b6-99b6-497b-9096-4bab4ddbec8d
# ╠═cca6e2f8-69c5-4a3a-9f97-699b4868c4b9
# ╟─80757735-8e73-4cae-88d0-9fe3d3e539c0
# ╠═7dd900fc-9531-4bd6-8b6d-3aac3d5a2386
# ╟─13f952ce-642a-4396-b574-00ea6584008c
# ╟─fcc22a84-011f-48ed-bc0b-41f4058b92fd
# ╠═e7be21d1-971b-45fd-aa83-591d43262567
# ╠═1702a65f-ad54-4520-b2d6-129c0576d708
# ╟─49ad22e7-e859-44d4-8179-e088e1159d04
# ╠═32910090-9a42-475a-8e83-f9712f8fe551
# ╠═7b5fcd3b-0f0a-44c3-9bf6-1dc042585322
# ╟─3ce74e3a-43f4-47a5-8dde-1d49e54e7eab
# ╠═8edabda9-c49b-407e-bae8-1a71a1fe19b4
# ╟─3ec7c034-4cb6-4b9f-96fb-c6dc428475bb
# ╠═494dfca2-af57-4dd9-9825-b28269641359
# ╟─ca1d7917-58e2-4b7d-8671-ced548ccfe89
# ╠═30c33553-3b4d-4eff-b34c-7ac0579650f7
# ╠═5c25abb7-e3ee-4104-9a82-eb4aa4e773d2
# ╟─4cec7232-8fbc-4ac1-96bb-6c7fea5fe117
# ╠═9bc9bd86-ffe3-48c1-81c0-c13f132e0dc1
# ╟─9b0f051b-a107-41f2-b7b9-d6c673b7f93b
# ╠═d4c5240c-e70f-45f5-859f-1399c57511b0
# ╟─ffa9ad39-64e0-4655-b04e-23f57490d326
# ╠═dfd4418e-19f0-42f2-87c5-69eacf2024ac
# ╟─9db831d6-7f10-47be-93d3-ebc892c4b3f2
# ╟─e69056dd-0052-4d1e-aef1-30411d416c82
# ╠═13e3525b-1b8e-4f65-8742-21d8ba4fdbe3
# ╟─025b38e1-d334-46b6-bf88-f7b426e8dc97
# ╟─76ab8044-78ec-41b5-b11a-df4e7e009e64
# ╠═b3c5283e-15fc-48d6-b58c-b26d70e5f5a4
# ╠═adbae5f0-6fe9-4a97-816b-004e47b15593
# ╟─2e13cbad-8110-4cbc-8890-ecbefe1302dd
# ╠═e5da7214-0e69-4b5a-a65e-ed92d0616c71
# ╟─9dc01591-5c37-4d83-b640-83280513941e
# ╟─41d9b8fd-dd18-4270-803f-bd6206845788
# ╠═b8b5aff0-2ed3-4237-9b9d-9eb0bf2f2878
# ╠═97cf8ee8-dba3-4b0b-b0ba-97002bc0f028
# ╟─0a8cec9c-7b9d-445b-abe3-237f16fdd9ad
# ╠═57f7e085-9589-4a6c-ac14-488ea9924692
# ╠═4c7d72f1-688a-4a70-8ce6-a4801127bb9a
# ╟─77bf7e4a-1237-4b24-bb31-dc8a30756834
# ╠═5a79eba5-3031-4e21-836e-961a9d939862
# ╟─27c2ba44-fcee-4647-910e-ae16f430b87d
# ╟─d577e515-f3cf-4f27-b0b5-a94cb38abf1a
# ╠═c17bca17-a00a-4118-a212-d21da09af9b5
# ╟─6aee2288-1934-4fc5-9a9c-f45b7ce4e767
# ╠═fadded74-8a89-4348-88f6-50d12cde6234
# ╟─0b28fab8-eb04-46d9-aa19-82e4bab45eb9
# ╠═791b9fde-1df2-4239-8372-2e3dd36d6f34
# ╟─60ef4369-831d-413e-bcc2-e088697b6ba4
# ╠═f46c3993-e01d-47fb-873a-c608e0d49d83
# ╟─d3779618-f61f-4874-93f1-94e78bb21c94
# ╠═330a5f6c-601f-47e6-8294-e6af89818d7d
# ╟─36173fe2-784f-472a-9cab-03f2a0a2b725
