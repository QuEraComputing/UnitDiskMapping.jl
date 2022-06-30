### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 2f721887-6dee-4b53-ae33-2c0a4b79ff37
using Pkg; Pkg.activate()

# ╔═╡ 39bcea18-00b6-42ca-a1f2-53655f31fea7
using Revise, UnitDiskMapping, Graphs, GenericTensorNetworks, PlutoUI, LinearAlgebra, Colors

# ╔═╡ 6a837c94-73e9-4093-988d-33a3633185f5
using GenericTensorNetworks.LuxorGraphPlot.Luxor

# ╔═╡ eac6ceda-f5d4-11ec-23db-b7b4d00eaddf
md"# Unit Disk Mapping"

# ╔═╡ b44f7ece-c031-487f-a44b-326cc6c279ea
PlutoUI.TableOfContents()

# ╔═╡ bbe26162-1ab7-4224-8870-9504b7c3aecf
md"## Generic Unweighted Mapping
The generic unweighted mapping aims to reduce a generic unweighted maximum independent set (MIS) problem to one on a defected King's graph.
Check [our paper (link to be added)]() for the mapping scheme.
"

# ╔═╡ b23f0215-8751-4105-aa7e-2c26e629e909
md"Let the source graph be the Petersen graph."

# ╔═╡ 7518d763-17a4-4c6e-bff0-941852ec1ccf
graph = smallgraph(:petersen)

# ╔═╡ 0302be92-076a-4ebe-8d6d-4b352a77cfce
show_graph(graph)

# ╔═╡ 417b18f6-6a8f-45fb-b979-6ec9d12c6246
md"We can use `map_graph` function to map the unweighted MIS problem on Petersen graph to one on a defected King's graph."

# ╔═╡ c7315578-8bb0-40a0-a2a3-685a80674c9c
unweighted_res = map_graph(graph; vertex_order=Branching());

# ╔═╡ 3f605eac-f587-40b2-8fac-8223777d3fad
md"Here, the key word argument `vertex_order` can be a vector of vertices in a specified order, or the method to compute the path decomposition that generates an order. The `Branching()` method is an exact path decomposition solver, which is suited for small graphs (number of vertices smaller <= 50). The `Greedy()` method is finds the vertex order much faster and works in all cases, but is not optimal.
A good vertex order can reduce the depth of the mapped graph."

# ╔═╡ e5382b61-6387-49b5-bae8-0389fbc92153
md"The return value contains the following fields:"

# ╔═╡ ae5c8359-6bdb-4a2a-8b54-cd2c7d2af4bd
fieldnames(unweighted_res |> typeof)

# ╔═╡ 56bdcaa6-c8b9-47de-95d4-6e95204af0f2
md"The field `grid_graph` is the mapped grid graph."

# ╔═╡ 520fbc23-927c-4328-8dc6-5b98853fb90d
show_graph(unweighted_res.grid_graph)

# ╔═╡ 96ca41c0-ac77-404c-ada3-0cdc4a426e44
md"The field `lines` is a vector of copy gadgets are arranged in `⊢` shape. These copy gadgets form a crossing lattice.
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
md"THe field `maping_history` is the mapping history, which contains the rewrite rules applied to the crossing lattice. They are important information for mapping a solution back."

# ╔═╡ 52b904ad-6fb5-4a7e-a3db-ae7aff32be51
unweighted_res.mapping_history

# ╔═╡ ef828107-08ce-4d91-ba56-2b2c7862aa50
md"The field `mis_overhead` is difference between ``\alpha(G_M) - \alpha(G_S)``, where ``G_M`` and ``G_S`` are mapped and source graph."

# ╔═╡ acd7107c-c739-4ee7-b0e8-6383c54f714f
unweighted_res.mis_overhead

# ╔═╡ 94feaf1f-77ea-4d6f-ba2f-2f9543e8c1bd
md"We can solve the mapped graph with `GenericTensorNetworks`."

# ╔═╡ f084b98b-097d-4b33-a0d3-0d0a981f735e
res = solve(IndependentSet(SimpleGraph(unweighted_res.grid_graph)), SingleConfigMax())[]

# ╔═╡ 86457b4e-b83e-4bf5-9d82-b5e14c055b4b
md"You might want to read [the documentation page of `GenericTensorNetworks`](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/) for a detailed explaination about this function. Here, we just visually check the solution configuration."

# ╔═╡ 4abb86dd-67e2-46f4-ae6c-e97952b23fdc
show_config(unweighted_res.grid_graph, res.c.data)

# ╔═╡ 5ec5e23a-6904-41cc-b2dc-659da9556d20
md"By mapping the result back, we get a solution for the original Petersen graph. Its maximum independent set size is 4"

# ╔═╡ 773ce349-ba72-426c-849d-cfb511773756
# The solution obtained by solving the mapped graph
original_configs = map_config_back(unweighted_res, res.c.data)

# ╔═╡ 7d921205-5133-40c0-bfa6-f76713dd4972
# Directly solving the source graph
UnitDiskMapping.is_independent_set(graph, original_configs)

# ╔═╡ 3273f936-a182-4ed0-9662-26aab489776b
md"## Generic Weighted Mapping"

# ╔═╡ 5e4500f5-beb6-4ef9-bd42-41dc13b60bce
md"A weighted independent set problem on a general graph can be mapped to one on the defected King's graph. The first step is do the same mapping as above but adding a new positional argument `Weighted()` as the first argument of `map_graph`. Let us still use the Petersen graph as an example."

# ╔═╡ 2fa704ee-d5c1-4205-9a6a-34ba0195fecf
weighted_res = map_graph(Weighted(), graph; vertex_order=Branching());

# ╔═╡ 27acc8be-2db8-4322-85b4-230fdddac043
md"The return value is similar to that for the unweighted mapping, except each node in the mapped graph can have a weight 1, 2 or 3. Note here, we haven't add the weights in the original graph."

# ╔═╡ b8879b2c-c6c2-47e2-a989-63a00c645676
show_grayscale(weighted_res.grid_graph)

# ╔═╡ 1262569f-d091-40dc-a431-cbbe77b912ab
md"""
The "pins" of the mapped graph has one to one correspondence to the vertices in the source graph.
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
md"Now we have both graph and weights, let us solve the mapped problem!"

# ╔═╡ cf910d3e-3e3c-42ef-acf3-d0990d6227ac
wmap_config = let
	graph, _ = graph_and_weights(weighted_res.grid_graph)
	collect(Int,
		solve(IndependentSet(graph; weights=mapped_weights), SingleConfigMax())[].c.data
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
	solve(IndependentSet(graph; weights=source_weights), SingleConfigMax())[].c.data
)

# ╔═╡ cf7e88cb-432e-4e3a-ae8b-8fa12689e485
md"## QUBO problem"

# ╔═╡ b5d95984-cf8d-4bce-a73a-8eb2a7c6b830
md"""
A QUBO problem can be specified as the following energy model
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
md"Now, let us do the mapping on a ``n \times n`` crossing lattice."

# ╔═╡ 081d1eee-96b1-4e76-8b8c-c0d4e5bdbaed
qubo = UnitDiskMapping.map_qubo(J, h);

# ╔═╡ 7974df7d-c390-4706-b7ba-6bde4409510d
md"The mapping result contains two fields, the `grid_graph` and the `pins`. After finding the ground state of the mapped independent set problem, the configuration of spin glass can be read directly from the pins. The following graph plots the pins in red color."

# ╔═╡ e6aeeeb4-704c-4ba4-abc2-29c4029e276d
qubo_graph, qubo_weights = UnitDiskMapping.graph_and_weights(qubo.grid_graph)

# ╔═╡ 8467e950-7302-4930-8698-8e7b523556a6
show_pins(qubo)

# ╔═╡ 6976c82f-90f0-4091-b13d-af463fe75c8b
md"One can also check the weights using the gray scale plot."

# ╔═╡ 95539e68-c1ea-4a6c-9406-2696d62b8461
show_grayscale(qubo.grid_graph)

# ╔═╡ 5282ca54-aa98-4d51-aaf9-af20eae5cc81
md"By solving this maximum independent set problem, we will get the following configuration."

# ╔═╡ ef149d9a-6aa9-4f34-b936-201b9d77543c
qubo_mapped_solution = collect(Int, solve(IndependentSet(qubo_graph; weights=qubo_weights), SingleConfigMax())[].c.data)

# ╔═╡ 4ea4f26e-746d-488e-9968-9fc584c04bcf
show_config(qubo.grid_graph, qubo_mapped_solution)

# ╔═╡ b64500b6-99b6-497b-9096-4bab4ddbec8d
md"This solution can be mapped to a solution of the source graph by reading the configurations on pins."

# ╔═╡ cca6e2f8-69c5-4a3a-9f97-699b4868c4b9
# The solution obtained by solving the mapped graph
map_config_back(qubo, collect(Int, qubo_mapped_solution))

# ╔═╡ 80757735-8e73-4cae-88d0-9fe3d3e539c0
md"This solution is consistent with the exact solution:"

# ╔═╡ 7dd900fc-9531-4bd6-8b6d-3aac3d5a2386
# Directly solving the source graph
collect(Int, solve(SpinGlass(J, h), SingleConfigMax())[].c.data)

# ╔═╡ 9db831d6-7f10-47be-93d3-ebc892c4b3f2
md"## Factoring"

# ╔═╡ e69056dd-0052-4d1e-aef1-30411d416c82
md"The building block of the array multiplier can be mapped to the following gadget"

# ╔═╡ 13e3525b-1b8e-4f65-8742-21d8ba4fdbe3
let
	graph, pins = UnitDiskMapping.multiplier()
	texts = fill("", length(graph.nodes))
	texts[pins] .= ["x$i" for i=1:length(pins)]
	show_grayscale(graph; unit=20, texts)
end

# ╔═╡ 025b38e1-d334-46b6-bf88-f7b426e8dc97
md"""
Let us denote the input and output pins as ``x_{1-8} \in \{0, 1\}``, the above gadget implements the following equations
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
show_pins(mres; unit=20)

# ╔═╡ 2e13cbad-8110-4cbc-8890-ecbefe1302dd
md"To solve this factoring problem, one can use the following statement"

# ╔═╡ e5da7214-0e69-4b5a-a65e-ed92d0616c71
multiplier_output = UnitDiskMapping.solve_factoring(mres, 6) do g, ws
	collect(Int, solve(IndependentSet(g; weights=ws), SingleConfigMax())[].c.data)
end

# ╔═╡ 9dc01591-5c37-4d83-b640-83280513941e
md"This function consists of the following steps:"

# ╔═╡ 41d9b8fd-dd18-4270-803f-bd6206845788
md"1. We first modify the graph by inspecting the fixed values, i.e. the output `m` and `0`s:
    * If a vertex is fixed to 1, remove a and its neighbors,
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
show_graph(mapped_grid_graph; unit=20)

# ╔═╡ 0a8cec9c-7b9d-445b-abe3-237f16fdd9ad
md"2. Then we solve this new grid graph."

# ╔═╡ 57f7e085-9589-4a6c-ac14-488ea9924692
config_factoring6 = let
	mg, mw = graph_and_weights(mapped_grid_graph)
	solve(IndependentSet(mg; weights=mw), SingleConfigMax())[].c.data
end;

# ╔═╡ 4c7d72f1-688a-4a70-8ce6-a4801127bb9a
show_config(mapped_grid_graph, config_factoring6; unit=20)

# ╔═╡ 77bf7e4a-1237-4b24-bb31-dc8a30756834
md"3. It is straight forward to readout the results from the above configuration. The solution should be either (2, 3) or (3, 2)."

# ╔═╡ 5a79eba5-3031-4e21-836e-961a9d939862
let
	cfg = zeros(Int, length(mres.grid_graph.nodes))
	cfg[remaining_vertices] .= config_factoring6
	bitvectors = cfg[mres.pins_input1], cfg[mres.pins_input2]
	UnitDiskMapping.asint.(bitvectors)
end

# ╔═╡ Cell order:
# ╟─eac6ceda-f5d4-11ec-23db-b7b4d00eaddf
# ╠═2f721887-6dee-4b53-ae33-2c0a4b79ff37
# ╠═39bcea18-00b6-42ca-a1f2-53655f31fea7
# ╠═b44f7ece-c031-487f-a44b-326cc6c279ea
# ╟─bbe26162-1ab7-4224-8870-9504b7c3aecf
# ╠═6a837c94-73e9-4093-988d-33a3633185f5
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
