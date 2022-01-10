# UnitDiskMapping

[![CI](https://github.com/Happy-Diode/UnitDiskMapping.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/Happy-Diode/UnitDiskMapping.jl/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/Happy-Diode/UnitDiskMapping.jl/badge.svg?branch=main&t=H2ReMe)](https://coveralls.io/github/Happy-Diode/UnitDiskMapping.jl?branch=main)

## Installation
<p>
UnitDiskMapping is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://julialang.org/favicon.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package. To install UnitDiskMapping,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press <kbd>]</kbd> key in the REPL to use the package mode, then type the following command
</p>

First add the QuEra Julia registry via

```julia
pkg> registry add https://github.com/Happy-Diode/Miskatonic.git
```

For stable release

```julia
pkg> add UnitDiskMapping
```

For current master

```julia
pkg> add UnitDiskMapping#master
```

## Example 1: Unweighted mapping
#### Step 1: map a Petersen graph to a grid graph
```julia
julia> using Graphs, UnitDiskMapping

julia> g = smallgraph(:petersen)
{10, 15} undirected simple Int64 graph

# `Branching()` is an exact algorithm for finding an optimal vertex ordering
julia> res = map_graph(g, vertex_order=Branching());

julia> res.mis_overhead
89

julia> println(res.grid_graph)
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ● ● ● ● ● ● ● ● ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ⋅ ● ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ● ● ● ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ⋅ ● ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
```

#### Step 2: solve the MIS problem on grid graph with any method you like
In the following, we show how to solve this maximal independent set problem on grid graph with the open source package [`GraphTensorNetworks`](https://github.com/Happy-Diode/GraphTensorNetworks.jl) and map the configurations back.
The generic tensor network approach for solving MIS works best for graphs with small tree width, it can solve this grid graph `G(V,E)` in sub-exponential time `t~2^{sqrt(|V|)}`.

```julia
julia> using GraphTensorNetworks

julia> gp = Independence(SimpleGraph(res.grid_graph); optimizer=TreeSA(ntrials=1, niters=10), simplifier=MergeGreedy());

julia> misconfig = solve(gp, "config max")[].c;

# create a grid mask as the solution, where occupied locations are marked as value 1.
julia> c = zeros(Int, size(res.grid_graph.content));

julia> for (i, loc) in enumerate(findall(!isempty, res.grid_graph.content))
           c[loc] = misconfig.data[i]
       end

julia> print_config(res, c)
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ○ ● ○ ● ○ ● ○ ● ○ ● ○ ⋅ ○ ● ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ● ○ ● ○ ● ⋅ ● ○ ● ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ○ ⋅ ○ ● ○ ● ○ ● ○ ○ ○ ● ○ ○ ○ ● ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ○ ○ ● ○ ● ⋅ ● ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ● ○ ⋅ ○ ● ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ○ ○ ○ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ○ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ● ⋅ ● ○ ○ ○ ○ ○ ○ ○ ○ ○ ● ○ ● ○ ● ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ● ○ ● ⋅ ● ○ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ○ ○ ○ ● ○ ○ ○ ○ ● ○ ● ○ ● ○ ● ○ ● ⋅ ● ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ○ ○ ● ⋅ ⋅ ⋅ ⋅ ⋅ ○ ○ ○ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ○ ○ ○ ○ ● ○ ● ○ ● ○ ● ○ ● ○ ● ○ ● ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ○ ● ⋅ ⋅ ⋅ ⋅ ⋅ ○ ○ ○ ⋅ ○ ○ ○ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ● ○ ● ○ ● ⋅ ● ○ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅
```

#### Step 3: solve the MIS solution back an MIS of the source graph
```julia
julia> original_configs = map_configs_back(res, [c])
1-element Vector{Vector{Int64}}:
 [1, 0, 0, 1, 0, 0, 1, 1, 0, 0]

julia> UnitDiskMapping.is_independent_set(g, original_configs[1])
true
```

One can check this configuration with MIS size 4 is indead a maximal independent set of Petersen graph.
Alternatively, one can use the following weighted mapping.

## Example 2: Weighted mapping
One just add a new argument `Weighted()` for the `map_graph` function in the previous example:
```julia
julia> w_res = map_graph(Weighted(), g, vertex_order=Branching());

julia> println(w_res.grid_graph)
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ● ● ● ● ● ● ● ● ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ⋅ ● ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ● ● ● ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ⋅ ● ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅
```
