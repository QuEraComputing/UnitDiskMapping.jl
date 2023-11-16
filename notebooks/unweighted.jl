### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ f55dbf80-8425-11ee-2e7d-4d1ad4f693af
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

# ╔═╡ be011e30-74e6-49cd-b45a-288972dc5f18
using UnitDiskMapping, Graphs # for mapping graphs to a King's subgraph (KSG)

# ╔═╡ 31250cb9-6f3a-429a-975d-752cb7c07883
using GenericTensorNetworks # for solving the maximum independent sets

# ╔═╡ 9017a42c-9791-4933-84a4-9ff509967323
md"""
# Unweighted KSG reduction of the independent set problem
"""

# ╔═╡ f0e7c030-4e43-4356-a5bb-717a7f382a17
md"This notebook contains examples from the paper, "Computer-Assisted Gadget Design and Problem Reduction of Unweighted Maximum Independent Set"."

# ╔═╡ cb4a9655-6df2-46b3-8969-8b6f2db7c59a
md"""
## Example 1: The 5-vertex graph
The five vertex demo graph in the paper.
"""

# ╔═╡ 956a5c3a-b8c6-4040-9553-3b4e2337b163
md"#### Step 1: Prepare a source graph."

# ╔═╡ d858f57e-1706-4b73-bc23-53f7af073b0c
# the demo graph in the main text
function demograph()
    g = SimpleGraph(5)
    for (i, j) in [(1, 2), (2, 4), (3, 4), (1, 3), (4, 5), (1, 5)]
        add_edge!(g, i, j)
    end
    return g
end

# ╔═╡ a3a86c62-ee6e-4a3b-99b3-c484de3b5220
g5 = demograph()

# ╔═╡ e6170e72-0804-401e-b9e5-65b8ee7d7edb
show_graph(g5)

# ╔═╡ 625bdcf4-e37e-4bb8-bd1a-907cdcc5fe24
md"""
#### Step 2: Map the source graph to an unweighted King's subgraph (KSG)
The vertex order is optimized with the Branching path decomposition algorithm
"""

# ╔═╡ f9e57a6b-1186-407e-a8b1-cb8f31a17bd2
g5res = UnitDiskMapping.map_graph(g5; vertex_order=Branching())

# ╔═╡ e64e7ca4-b297-4c74-8699-bec4b4fbb843
md"Visualize the mapped KSG graph in terminal"

# ╔═╡ 0a860597-0610-48f6-b1ee-711939712de4
print(g5res.grid_graph)

# ╔═╡ eeae7074-ee21-44fc-9605-3555acb84cee
md"or in a plotting plane"

# ╔═╡ 3fa6052b-74c2-453d-a473-68f4b3ca0490
show_graph(g5res.grid_graph)

# ╔═╡ 942e8dfb-b89d-4f2d-b1db-f4636d4e5de6
md"#### Step 3: Solve the MIS size of the mapped graph"

# ╔═╡ 766018fa-81bd-4c37-996a-0cf77b0909af
md"The independent set size can be obtained by solving the `SizeMax()` property using the [generic tensor network](https://github.com/QuEraComputing/GenericTensorNetworks.jl) method."

# ╔═╡ 67fd2dd2-5add-4402-9618-c9b7c7bfe95b
missize_g5_ksg = solve(IndependentSet(SimpleGraph(g5res.grid_graph)), SizeMax())[]

# ╔═╡ aaee9dbc-5b9c-41b1-b0d4-35d2cac7c773
md"The predicted MIS size for the source graph is:"

# ╔═╡ 114e2c42-aaa3-470b-a267-e5a7c6b08607
missize_g5_ksg.n - g5res.mis_overhead

# ╔═╡ e6fa2404-cbe9-4f9b-92a0-0d6fdb649c44
md"""
One of the best solutions can be obtained by solving the `SingleConfigMax()` property.
"""

# ╔═╡ 0142f661-0855-45b4-852a-78f560e98c67
mis_g5_ksg = solve(IndependentSet(SimpleGraph(g5res.grid_graph)), SingleConfigMax())[].c.data

# ╔═╡ fa046f3c-fd7d-4e91-b3f5-fc4591d3cae2
md"Plot the solution"

# ╔═╡ 0cbcd2a6-b8ae-47ff-8541-963b9dae700a
show_config(g5res.grid_graph, mis_g5_ksg)

# ╔═╡ 4734dc0b-0770-4f84-8046-95a74104936f
md"#### Step 4: Map the KSG solution back"

# ╔═╡ 0f27de9f-2e06-4d5e-b96f-b7c7fdadabca
md"In the following, we will show how to obtain an MIS of the source graph from that of its KSG reduction."

# ╔═╡ fc968df0-832b-44c9-8335-381405b92199
mis_g5 = UnitDiskMapping.map_config_back(g5res, collect(mis_g5_ksg))

# ╔═╡ 29458d07-b2b2-49af-a696-d0cb0ad35481
md"Show that the overhead in the MIS size is correct"

# ╔═╡ fa4888b2-fc67-4285-8305-da655c42a898
md"Verify the result:"

# ╔═╡ e84102e8-d3f2-4f91-87be-dba8e81462fb
# the extracted solution is an independent set
UnitDiskMapping.is_independent_set(g5, mis_g5)

# ╔═╡ 88ec52b3-73fd-4853-a69b-442f5fd2e8f7
# and its size is maximized
count(isone, mis_g5)

# ╔═╡ 5621bb2a-b1c6-4f0d-921e-980b2ce849d5
solve(IndependentSet(g5), SizeMax())[].n

# ╔═╡ 1fe6c679-2962-4c1b-8b12-4ceb77ed9e0f
md"""
## Example 2: The Petersen graph

We just quickly go through a second example, the Petersen graph.
"""

# ╔═╡ ea379863-95dd-46dd-a0a3-0a564904476a
petersen = smallgraph(:petersen)

# ╔═╡ d405e7ec-50e3-446c-8d19-18f1a66c1e3b
show_graph(petersen)

# ╔═╡ 409b03d1-384b-48d3-9010-8079cbf66dbf
md"We first map it to a grid graph (unweighted)."

# ╔═╡ a0e7da6b-3b71-43d4-a1da-f1bd953e4b50
petersen_res = UnitDiskMapping.map_graph(petersen)

# ╔═╡ 4f1f0ca0-dd2a-4768-9b4e-80813c9bb544
md"The MIS size of the petersen graph is 4."

# ╔═╡ bf97a268-cd96-4dbc-83c6-10eb1b03ddcc
missize_petersen = solve(IndependentSet(petersen), SizeMax())[]

# ╔═╡ 2589f112-5de5-4c98-bcd1-138b6143cd30
md" The MIS size of the mapped KSG graph is much larger"

# ╔═╡ 1b946455-b152-4d6f-9968-7dc6e22d171a
missize_petersen_ksg = solve(IndependentSet(SimpleGraph(petersen_res.grid_graph)), SizeMax())[]

# ╔═╡ 4e7f7d9e-fae4-46d2-b95d-110d36b691d9
md"The difference in the MIS size is:"

# ╔═╡ d0e49c1f-457d-4b61-ad0e-347afb029114
petersen_res.mis_overhead

# ╔═╡ 03d8adb3-0bf4-44e6-9b0a-fffc90410cfc
md"Find an MIS of the mapped KSG and map it back an MIS on the source graph."

# ╔═╡ 0d08cb1a-f7f3-4d63-bd70-78103db086b3
mis_petersen_ksg = solve(IndependentSet(SimpleGraph(petersen_res.grid_graph)), SingleConfigMax())[].c.data

# ╔═╡ c27d8aed-c81f-4eb7-85bf-a4ed88c2537f
mis_petersen = UnitDiskMapping.map_config_back(petersen_res, collect(mis_petersen_ksg))

# ╔═╡ 20f81eef-12d3-4f2a-9b91-ccf2705685ad
md"""The obtained solution is an independent set and its size is maximized."""

# ╔═╡ 0297893c-c978-4818-aae8-26e60d8c9e9e
UnitDiskMapping.is_independent_set(petersen, mis_petersen)

# ╔═╡ 5ffe0e4f-bd2c-4d3e-98ca-61673a7e5230
count(isone, mis_petersen)

# ╔═╡ 8c1d46e8-dc36-41bd-9d9b-5a72c380ef26
md"The number printed should be consistent with the MIS size of the petersen graph."

# ╔═╡ Cell order:
# ╟─f55dbf80-8425-11ee-2e7d-4d1ad4f693af
# ╟─9017a42c-9791-4933-84a4-9ff509967323
# ╟─f0e7c030-4e43-4356-a5bb-717a7f382a17
# ╠═be011e30-74e6-49cd-b45a-288972dc5f18
# ╠═31250cb9-6f3a-429a-975d-752cb7c07883
# ╟─cb4a9655-6df2-46b3-8969-8b6f2db7c59a
# ╟─956a5c3a-b8c6-4040-9553-3b4e2337b163
# ╠═d858f57e-1706-4b73-bc23-53f7af073b0c
# ╠═a3a86c62-ee6e-4a3b-99b3-c484de3b5220
# ╠═e6170e72-0804-401e-b9e5-65b8ee7d7edb
# ╟─625bdcf4-e37e-4bb8-bd1a-907cdcc5fe24
# ╠═f9e57a6b-1186-407e-a8b1-cb8f31a17bd2
# ╟─e64e7ca4-b297-4c74-8699-bec4b4fbb843
# ╠═0a860597-0610-48f6-b1ee-711939712de4
# ╟─eeae7074-ee21-44fc-9605-3555acb84cee
# ╠═3fa6052b-74c2-453d-a473-68f4b3ca0490
# ╟─942e8dfb-b89d-4f2d-b1db-f4636d4e5de6
# ╟─766018fa-81bd-4c37-996a-0cf77b0909af
# ╠═67fd2dd2-5add-4402-9618-c9b7c7bfe95b
# ╟─aaee9dbc-5b9c-41b1-b0d4-35d2cac7c773
# ╠═114e2c42-aaa3-470b-a267-e5a7c6b08607
# ╟─e6fa2404-cbe9-4f9b-92a0-0d6fdb649c44
# ╠═0142f661-0855-45b4-852a-78f560e98c67
# ╟─fa046f3c-fd7d-4e91-b3f5-fc4591d3cae2
# ╠═0cbcd2a6-b8ae-47ff-8541-963b9dae700a
# ╟─4734dc0b-0770-4f84-8046-95a74104936f
# ╟─0f27de9f-2e06-4d5e-b96f-b7c7fdadabca
# ╠═fc968df0-832b-44c9-8335-381405b92199
# ╟─29458d07-b2b2-49af-a696-d0cb0ad35481
# ╟─fa4888b2-fc67-4285-8305-da655c42a898
# ╠═e84102e8-d3f2-4f91-87be-dba8e81462fb
# ╠═88ec52b3-73fd-4853-a69b-442f5fd2e8f7
# ╠═5621bb2a-b1c6-4f0d-921e-980b2ce849d5
# ╟─1fe6c679-2962-4c1b-8b12-4ceb77ed9e0f
# ╠═ea379863-95dd-46dd-a0a3-0a564904476a
# ╠═d405e7ec-50e3-446c-8d19-18f1a66c1e3b
# ╟─409b03d1-384b-48d3-9010-8079cbf66dbf
# ╠═a0e7da6b-3b71-43d4-a1da-f1bd953e4b50
# ╟─4f1f0ca0-dd2a-4768-9b4e-80813c9bb544
# ╠═bf97a268-cd96-4dbc-83c6-10eb1b03ddcc
# ╟─2589f112-5de5-4c98-bcd1-138b6143cd30
# ╠═1b946455-b152-4d6f-9968-7dc6e22d171a
# ╟─4e7f7d9e-fae4-46d2-b95d-110d36b691d9
# ╠═d0e49c1f-457d-4b61-ad0e-347afb029114
# ╟─03d8adb3-0bf4-44e6-9b0a-fffc90410cfc
# ╠═0d08cb1a-f7f3-4d63-bd70-78103db086b3
# ╠═c27d8aed-c81f-4eb7-85bf-a4ed88c2537f
# ╟─20f81eef-12d3-4f2a-9b91-ccf2705685ad
# ╠═0297893c-c978-4818-aae8-26e60d8c9e9e
# ╠═5ffe0e4f-bd2c-4d3e-98ca-61673a7e5230
# ╟─8c1d46e8-dc36-41bd-9d9b-5a72c380ef26
