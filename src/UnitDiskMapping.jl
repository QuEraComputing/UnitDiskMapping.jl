# Copyright 2021 QuEra Computing Inc. All rights reserved.

module UnitDiskMapping

using Graphs

export UGrid, apply_gadgets!, apply_gadget!, embed_graph, unitdisk_graph
export unapply_gadgets!, unmatch
export TShape, Corner, Turn, Cross, source_graph, mapped_graph

include("mapping.jl")
include("gadgets.jl")

end
