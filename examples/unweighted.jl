# # Unweighted KSG reduction of the independent set problem

# This page contains examples from the paper, "Computer-Assisted Gadget Design and Problem Reduction of Unweighted Maximum Independent Set".

using UnitDiskMapping, Graphs # for mapping graphs to a King's subgraph (KSG)
using GenericTensorNetworks # for solving the maximum independent sets
using GenericTensorNetworks.ProblemReductions

# ## Example 1: The 5-vertex graph
# The five vertex demo graph in the paper.

# #### Step 1: Prepare a source graph.

# the demo graph in the main text
function demograph()
    g = SimpleGraph(5)
    for (i, j) in [(1, 2), (2, 4), (3, 4), (1, 3), (4, 5), (1, 5)]
        add_edge!(g, i, j)
    end
    return g
end

g5 = demograph()

show_graph(g5)

# #### Step 2: Map the source graph to an unweighted King's subgraph (KSG)
# The vertex order is optimized with the Branching path decomposition algorithm (MinhThi's Trick)

g5res = UnitDiskMapping.map_graph(g5; vertex_order=MinhThiTrick())

# Visualize the mapped KSG graph in terminal

print(g5res.grid_graph)

# or in a plotting plane

show_graph(g5res.grid_graph)

# #### Step 3: Solve the MIS size of the mapped graph

# The independent set size can be obtained by solving the `SizeMax()` property using the [generic tensor network](https://github.com/QuEraComputing/GenericTensorNetworks.jl) method.

missize_g5_ksg = solve(GenericTensorNetwork(IndependentSet(SimpleGraph(g5res.grid_graph))), SizeMax())[]

# The predicted MIS size for the source graph is:

missize_g5_ksg.n - g5res.mis_overhead

# One of the best solutions can be obtained by solving the `SingleConfigMax()` property.

mis_g5_ksg = solve(GenericTensorNetwork(IndependentSet(SimpleGraph(g5res.grid_graph))), SingleConfigMax())[].c.data

# Plot the solution

show_config(g5res.grid_graph, mis_g5_ksg)

# #### Step 4: Map the KSG solution back

# In the following, we will show how to obtain an MIS of the source graph from that of its KSG reduction.

mis_g5 = UnitDiskMapping.map_config_back(g5res, collect(mis_g5_ksg))

# Show that the overhead in the MIS size is correct

# Verify the result:

# the extracted solution is an independent set
UnitDiskMapping.is_independent_set(g5, mis_g5)

# and its size is maximized
count(isone, mis_g5)

solve(GenericTensorNetwork(IndependentSet(g5)), SizeMax())[].n

# ## Example 2: The Petersen graph

# We just quickly go through a second example, the Petersen graph.

petersen = smallgraph(:petersen)

show_graph(petersen)

# We first map it to a grid graph (unweighted).

petersen_res = UnitDiskMapping.map_graph(petersen)

# The MIS size of the petersen graph is 4.

missize_petersen = solve(GenericTensorNetwork(IndependentSet(petersen)), SizeMax())[]

# The MIS size of the mapped KSG graph is much larger

missize_petersen_ksg = solve(GenericTensorNetwork(IndependentSet(SimpleGraph(petersen_res.grid_graph))), SizeMax())[]

# The difference in the MIS size is:

petersen_res.mis_overhead

# Find an MIS of the mapped KSG and map it back an MIS on the source graph.

mis_petersen_ksg = solve(GenericTensorNetwork(IndependentSet(SimpleGraph(petersen_res.grid_graph))), SingleConfigMax())[].c.data

mis_petersen = UnitDiskMapping.map_config_back(petersen_res, collect(mis_petersen_ksg))

# The obtained solution is an independent set and its size is maximized.

UnitDiskMapping.is_independent_set(petersen, mis_petersen)

count(isone, mis_petersen)

# The number printed should be consistent with the MIS size of the petersen graph.

# ## Extension: ProblemReductions
# Unit-disk mapping implements the unified interface for reduction in package [ProblemReductions.jl](https://github.com/GiggleLiu/ProblemReductions.jl) as an extension.

# Step 1: perform the problem reduction.

source_problem = IndependentSet(smallgraph(:petersen))

# the Independent set problem with 2D GridGraph topology, unweighted.
target_problem_type = IndependentSet{ProblemReductions.GridGraph{2}, Int, UnitWeight}

# the result not only contains the target problem, but also the intermediate information
reduction_result = reduceto(target_problem_type, source_problem)

target_problem(reduction_result)

# Step 2: solve the target problem.

# get single maximum independent set of the mapped problem
config = solve(GenericTensorNetwork(target_problem(reduction_result)), SingleConfigMax())[].c.data

# Step 3. Extract the solution back

extracted_config = extract_solution(reduction_result, config)

# finally, we check the validity of the solution.
UnitDiskMapping.is_independent_set(source_problem.graph, extracted_config)
