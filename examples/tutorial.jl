# # Unit Disk Mapping

# ## Generic Unweighted Mapping
# The generic unweighted mapping aims to reduce a generic unweighted Maximum Independent Set (MIS) problem to one on a defected King's graph.
# Check [our paper (link to be added)]() for the mapping scheme.

# Let the source graph be the Petersen graph.

using UnitDiskMapping, Graphs, GenericTensorNetworks, LinearAlgebra

# Visualization setup.
# To make the plots dark-mode friendly, we use white-background color.
using LuxorGraphPlot.Luxor, LuxorGraphPlot

graph = smallgraph(:petersen)

LuxorGraphPlot.show_graph(graph)

# We can use the `map_graph` function to map the unweighted MIS problem on the Petersen graph to one on a defected King's graph.

unweighted_res = map_graph(graph; vertex_order=MinhThiTrick());

# Here, the keyword argument `vertex_order` can be a vector of vertices in a specified order, or the method to compute the path decomposition that generates an order. The `MinhThiTrick()` method is an exact path decomposition solver, which is suited for small graphs (where number of vertices <= 50). The `Greedy()` method finds the vertex order much faster and works in all cases, but may not be optimal.
# A good vertex order can reduce the depth of the mapped graph.

# The return value contains the following fields:

fieldnames(unweighted_res |> typeof)

# The field `grid_graph` is the mapped grid graph.

LuxorGraphPlot.show_graph(unweighted_res.grid_graph)

unweighted_res.grid_graph.size

# The field `lines` is a vector of copy gadgets arranged in a `⊢` shape. These copy gadgets form a *crossing lattice*,  in which two copy lines cross each other whenever their corresponding vertices in the source graph are connected by an edge.
# ```
#     vslot
#       ↓
#       |          ← vstart
#       |
#       |-------   ← hslot
#       |      ↑   ← vstop
#             hstop
# ```

unweighted_res.lines

# The field `mapping_history` contains the rewrite rules applied to the crossing lattice. They contain important information for mapping a solution back.

unweighted_res.mapping_history

# The field `mis_overhead` is the difference between ``\alpha(G_M) - \alpha(G_S)``, where ``G_M`` and ``G_S`` are the mapped and source graph.

unweighted_res.mis_overhead

# We can solve the mapped graph with [`GenericTensorNetworks`](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/).

res = solve(GenericTensorNetwork(IndependentSet(SimpleGraph(unweighted_res.grid_graph))), SingleConfigMax())[]

# You might want to read [the documentation page of `GenericTensorNetworks`](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/) for a detailed explanation on this function. Here, we just visually check the solution configuration.

show_config(unweighted_res.grid_graph, res.c.data)

# By mapping the result back, we get a solution for the original Petersen graph. Its maximum independent set size is 4.

# The solution obtained by solving the mapped graph
original_configs = map_config_back(unweighted_res, res.c.data)

# Confirm that the solution from the mapped graph gives us
# a maximum independent set for the original graph
UnitDiskMapping.is_independent_set(graph, original_configs)

# ## Generic Weighted Mapping

# A Maximum Weight Independent Set (MWIS) problem on a general graph can be mapped to one on the defected King's graph. The first step is to do the same mapping as above but adding a new positional argument `Weighted()` as the first argument of `map_graph`. Let us still use the Petersen graph as an example.

weighted_res = map_graph(Weighted(), graph; vertex_order=MinhThiTrick());

# The return value is similar to that for the unweighted mapping generated above, except each node in the mapped graph can have a weight 1, 2 or 3. Note here, we haven't added the weights in the original graph.

show_grayscale(weighted_res.grid_graph)

# The "pins" of the mapped graph have a one-to-one correspondence to the vertices in the source graph.

show_pins(weighted_res)

# The weights in the original graph can be added to the pins of this grid graph using the `map_weights` function. The added weights must be smaller than 1.

source_weights = rand(10)

mapped_weights = map_weights(weighted_res, source_weights)

# Now that we have both the graph and the weights, let us solve the mapped problem!

wmap_config = let
	graph, _ = graph_and_weights(weighted_res.grid_graph)
	collect(Int,
		solve(GenericTensorNetwork(IndependentSet(graph, mapped_weights)), SingleConfigMax())[].c.data
	)
end

show_config(weighted_res.grid_graph, wmap_config)

# By reading the configurations of the pins, we obtain a solution for the source graph.

# The solution obtained by solving the mapped graph
map_config_back(weighted_res, wmap_config)

# Directly solving the source graph
collect(Int,
	solve(GenericTensorNetwork(IndependentSet(graph, source_weights)), SingleConfigMax())[].c.data
)

# ## QUBO problem

# ### Generic QUBO mapping

# A QUBO problem can be specified as the following energy model:
# ```math
# E(z) = -\sum_{i<j} J_{ij} z_i z_j + \sum_i h_i z_i
# ```

n = 6

J = triu(randn(n, n) * 0.001, 1); J += J'

h = randn(n) * 0.001

# Now, let us do the mapping on an ``n \times n`` crossing lattice.

qubo = UnitDiskMapping.map_qubo(J, h);

# The mapping result contains two fields, the `grid_graph` and the `pins`. After finding the ground state of the mapped independent set problem, the configuration of the spin glass can be read directly from the pins. The following graph plots the pins in red color.

qubo_graph, qubo_weights = UnitDiskMapping.graph_and_weights(qubo.grid_graph)

show_pins(qubo)

# One can also check the weights using the gray-scale plot.

show_grayscale(qubo.grid_graph)

# By solving this maximum independent set problem, we will get the following configuration.

qubo_mapped_solution = collect(Int, solve(GenericTensorNetwork(IndependentSet(qubo_graph, qubo_weights)), SingleConfigMax())[].c.data)

show_config(qubo.grid_graph, qubo_mapped_solution)

# This solution can be mapped to a solution for the source graph by reading the configurations on the pins.

# The solution obtained by solving the mapped graph
map_config_back(qubo, collect(Int, qubo_mapped_solution))

# This solution is consistent with the exact solution:

# Directly solving the source graph, due to the convention issue, we flip the signs of `J` and `h`
collect(Int, solve(GenericTensorNetwork(spin_glass_from_matrix(-J, -h)), SingleConfigMax())[].c.data)

# ### QUBO problem on a square lattice

# We define some coupling strengths and onsite energies on a $n \times n$ square lattice.

square_coupling = [[(i,j,i,j+1,0.01*randn()) for i=1:n, j=1:n-1]...,
	[(i,j,i+1,j,0.01*randn()) for i=1:n-1, j=1:n]...];

square_onsite = vec([(i, j, 0.01*randn()) for i=1:n, j=1:n]);

# Then we use `map_qubo_square` to reduce the QUBO problem on a square lattice to the MIS problem on a grid graph.

qubo_square = UnitDiskMapping.map_qubo_square(square_coupling, square_onsite);

show_grayscale(qubo_square.grid_graph)

# You can see each coupling is replaced by the following `XOR` gadget

show_grayscale(UnitDiskMapping.gadget_qubo_square(Int), texts=["x$('₀'+i)" for i=1:8])

# Where dark nodes have weight 2 and light nodes have weight 1. It corresponds to the boolean equation ``x_8 = \neg (x_1 \veebar x_5)``; hence we can add ferromagnetic couplings as negative weights and anti-ferromagnetic couplings as positive weights. On-site terms are added directly to the pins.

show_pins(qubo_square)

# Let us solve the independent set problem on the mapped graph.

square_graph, square_weights = UnitDiskMapping.graph_and_weights(qubo_square.grid_graph);

config_square = collect(Int, solve(GenericTensorNetwork(IndependentSet(square_graph, square_weights)), SingleConfigMax())[].c.data);

# We will get the following configuration.

show_config(qubo_square.grid_graph, config_square)

# By reading out the configurations at pins, we can get a solution of the source QUBO problem.

r1 = map_config_back(qubo_square, config_square)

# It can be easily checked by examining the exact result.

let
	## solve QUBO directly
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

# ## Factorization problem

# The building block of the array multiplier can be mapped to the following gadget:

let
	graph, pins = UnitDiskMapping.multiplier()
	texts = fill("", length(graph.nodes))
	texts[pins] .= ["x$i" for i=1:length(pins)]
	show_grayscale(graph)
end

# Let us denote the input and output pins as ``x_{1-8} \in \{0, 1\}``. The above gadget implements the following equations:
# ```math
# \begin{align}
# x_1 + x_2 x_3 + x_4 = x_5 + 2 x_7,\\
# x_2 = x_6,\\
# x_3 = x_8.
# \end{align}
# ```

# One can call `map_factoring(M, N)` to map a factoring problem to the array multiplier grid of size (M, N). In the following example of (2, 2) array multiplier, the input integers are ``p = 2p_2+p_1`` and ``q= 2q_2+q_1``, and the output integer is ``m = 4m_3+2m_2+m_1``. The maximum independent set corresponds to the solution of ``pq = m``

mres = UnitDiskMapping.map_factoring(2, 2);

show_pins(mres)

# To solve this factoring problem, one can use the following statement:

multiplier_output = UnitDiskMapping.solve_factoring(mres, 6) do g, ws
	collect(Int, solve(GenericTensorNetwork(IndependentSet(g, ws)), SingleConfigMax())[].c.data)
end

# This function consists of the following steps:

# 1. We first modify the graph by inspecting the fixed values, i.e., the output `m` and `0`s:
#     * If a vertex is fixed to 1, remove it and its neighbors,
#     * If a vertex is fixed to 0, remove this vertex.
# 
# The resulting grid graph is

mapped_grid_graph, remaining_vertices = let
	g, ws = graph_and_weights(mres.grid_graph)
	mg, vmap = UnitDiskMapping.set_target(g, [mres.pins_zeros..., mres.pins_output...], 6 << length(mres.pins_zeros))
	GridGraph(mres.grid_graph.size, mres.grid_graph.nodes[vmap], mres.grid_graph.radius), vmap
end;

show_graph(mapped_grid_graph)

# 2. Then, we solve this new grid graph.

config_factoring6 = let
	mg, mw = graph_and_weights(mapped_grid_graph)
	solve(GenericTensorNetwork(IndependentSet(mg, mw)), SingleConfigMax())[].c.data
end;

show_config(mapped_grid_graph, config_factoring6)

# 3. It is straightforward to read out the results from the above configuration. The solution should be either (2, 3) or (3, 2).

let
	cfg = zeros(Int, length(mres.grid_graph.nodes))
	cfg[remaining_vertices] .= config_factoring6
	bitvectors = cfg[mres.pins_input1], cfg[mres.pins_input2]
	UnitDiskMapping.asint.(bitvectors)
end

# ## Logic Gates

# 1. NOT gate: ``y_1 =\neg x_1``

show_pins(Gate(:NOT))

#

show_grayscale(gate_gadget(Gate(:NOT))[1], wmax=2)

# 2. NXOR gate: ``y_1 =\neg (x_1 \veebar x_2)``. Notice this negated XOR gate is used in the square lattice QUBO mapping.

show_pins(Gate(:NXOR))

#

show_grayscale(gate_gadget(Gate(:NXOR))[1], wmax=2)

# 3. NOR gate: ``y_1 =\neg (x_1 \vee x_2)``

show_pins(Gate(:NOR))

#

show_grayscale(gate_gadget(Gate(:NOR))[1], wmax=2)

# 4. AND gate: ``y_1 =x_1 \wedge x_2``

show_pins(Gate(:AND))

#

show_grayscale(gate_gadget(Gate(:AND))[1], wmax=2)

# Since most logic gates have 3 pins, it is natural to embed a circuit to a 3D unit disk graph by taking the z direction as the time. In a 2D grid, one needs to do the general weighted mapping in order to create a unit disk boolean circuit.
