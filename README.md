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
In the following, we show how to solve this maximal independent set problem on grid graph with the open source package [`GenericTensorNetworks`](https://github.com/Happy-Diode/GenericTensorNetworks.jl) and map the configurations back.
The generic tensor network approach for solving MIS works best for graphs with small tree width, it can solve this grid graph `G(V,E)` in sub-exponential time `t~2^{sqrt(|V|)}`.

```julia
julia> using GenericTensorNetworks

julia> gp = IndependentSet(SimpleGraph(res.grid_graph); optimizer=TreeSA(ntrials=1, niters=10), simplifier=MergeGreedy());

julia> misconfig = solve(gp, SingleConfigMax())[].c.data
10110001000110000111000001010101011000001111000001101010101010000101110100000010010101010101010001000000100111010000001001101000101010001110010001000101110100111010100010110100100110101010110100011100101010101010100011

# create a grid mask as the solution, where occupied locations are marked as value 1.
julia> c = zeros(Int, size(res.grid_graph.content));

julia> for (i, loc) in enumerate(findall(!isempty, res.grid_graph.content))
           c[loc] = misconfig[i]
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
julia> original_configs = map_configs_back(res, [misconfig])
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
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ● ● ● ⋅ ● ● ● ● ● ● ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ○ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ▴ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ● ● ● ● ● ● ● ● ● ● ⋅ ● ● ● ● ● ● ○ ⋅ ● ⋅ ⋅ ● ⋅ ● ○ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ○ ⋅ ⋅ ● ● ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ○ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ⋅ ● ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ○ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ● ○ ⋅ ● ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ● ⋅ ● ● ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ○ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ○ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ● ⋅ ● ● ● ● ● ● ● ● ● ● ○ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ● ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ 
```

Here, `▴` is a vertex having weight 3, `●` is a vertex having weight 2 and `○` is a vertex having weight 1.
One can add some weights in range 0~1 by typing

```julia
julia> source_weights = 0.05:0.1:0.95
0.05:0.1:0.95

julia> mapped_weights = map_weights(w_res, source_weights)
218-element Vector{Float64}:
 1.85
 2.0
 1.95
 2.0
 2.0
 2.0
 1.0
 ⋮
 2.0
 2.0
 2.0
 2.0
 1.0
 2.0
```

One can easily check the correctness
```julia
julia> wr1 = solve(IndependentSet(g; weights=collect(source_weights)), SingleConfigMax())[]
(2.2, ConfigSampler{10, 1, 1}(0100100110))ₜ

julia> wr2 = solve(IndependentSet(SimpleGraph(w_res.grid_graph); weights=mapped_weights), SingleConfigMax())[].c.data
(178.2, ConfigSampler{218, 1, 4}(10001110100000111000110101000100010110010010110010010001010101100010011001010000101000100010101010010100001001101100000110010001010101010001100000110110010010111011000001111000010110101011010010101010101010101010100101))ₜ

julia> wr2.n - w_res.mis_overhead
2.1999999999999886

julia> map_configs_back(w_res, [wr2])
1-element Vector{Vector{Int64}}:
 [0, 1, 0, 0, 1, 0, 0, 1, 1, 0]
```

Yep! We get exactly the same ground state.