# Copyright 2021 QuEra Computing Inc. All rights reserved.

module UnitDiskMapping

using Graphs

export UGrid, apply_crossing_gadgets!, apply_simplifier_gadgets!, apply_gadget!, embed_graph
export unapply_gadgets!, unmatch
export Pattern, Corner, Turn, Cross, source_graph, mapped_graph, TruncatedTurn
export mapped_entry_to_compact, source_entry_to_configs, map_config_back, mis_overhead
export UNode, contract_graph, compress_graph

include("utils.jl")
include("gadgets.jl")
include("simplifiers.jl")
include("mapping.jl")
include("extracting_results.jl")
include("pathdecomposition/pathdecomposition.jl")
#include("shrinking/compressUDG.jl")

end
