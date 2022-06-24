# Copyright 2021 QuEra Computing Inc. All rights reserved.

module UnitDiskMapping

using Graphs

export UGrid, apply_crossing_gadgets!, apply_simplifier_gadgets!, apply_gadget!, embed_graph
export unapply_gadgets!, unmatch
export Pattern, Corner, Turn, Cross, source_graph, mapped_graph, TruncatedTurn, EndTurn
export mapped_entry_to_compact, source_entry_to_configs, map_config_back, mis_overhead
export UNode, contract_graph, compress_graph
export UnWeighted, Weighted
export Cell, AbstractCell

include("utils.jl")
include("Core.jl")
include("pathdecomposition/pathdecomposition.jl")
include("copyline.jl")
include("qubo.jl")
include("multiplier.jl")
include("gadgets.jl")
include("mapping.jl")
include("weighted.jl")
include("simplifiers.jl")
include("extracting_results.jl")

end
