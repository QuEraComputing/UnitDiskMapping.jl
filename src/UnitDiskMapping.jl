# Copyright 2021 QuEra Computing Inc. All rights reserved.

module UnitDiskMapping

using Graphs
using LuxorGraphPlot
using LuxorGraphPlot.Luxor.Colors

# Basic types
export UnWeighted, Weighted
export Cell, AbstractCell, SimpleCell
export Node, WeightedNode, UnWeightedNode
export graph_and_weights, GridGraph, coordinates

# dragon drop methods
export map_factoring, map_qubo, map_qubo_square, map_simple_wmis, solve_factoring, multiplier
export QUBOResult, WMISResult, SquareQUBOResult, FactoringResult

# logic gates
export Gate, gate_gadget

# plotting methods
export show_grayscale, show_pins, show_config

# path-width optimized mapping
export MappingResult, map_graph, map_config_back, map_weights, trace_centers, print_config
export MappingGrid, embed_graph, apply_crossing_gadgets!, apply_simplifier_gadgets!, unapply_gadgets!

# gadgets
export Pattern, Corner, Turn, Cross, TruncatedTurn, EndTurn,
    Branch, TrivialTurn, BranchFix, WTurn, TCon, BranchFixB,
    RotatedGadget, ReflectedGadget, rotated_and_reflected, WeightedGadget
export vertex_overhead, source_graph, mapped_graph, mis_overhead
export @gg

# utils
export is_independent_set, unitdisk_graph

# path decomposition
export pathwidth, PathDecompositionMethod, MinhThiTrick, Greedy

@deprecate Branching MinhThiTrick

include("utils.jl")
include("Core.jl")
include("pathdecomposition/pathdecomposition.jl")
include("copyline.jl")
include("dragondrop.jl")
include("multiplier.jl")
include("logicgates.jl")
include("gadgets.jl")
include("mapping.jl")
include("weighted.jl")
include("simplifiers.jl")
include("extracting_results.jl")
include("visualize.jl")

end
