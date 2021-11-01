# UnitDiskMapping

[![Build Status](https://github.com/Happy-Diode/UnitDiskMapping.jl/workflows/CI/badge.svg)](https://github.com/Happy-Diode/UnitDiskMapping.jl/actions)

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

## Example
```julia
julia> using Graphs, UnitDiskMapping

julia> g = smallgraph(:bull)
{5, 5} undirected simple Int64 graph

julia> eg = embed_graph(g, 3)
● ○ ● ○ ● ○ ◆ ○ ● ○ ● ○ ◆ ○ ● ○ ● ○ ◉ ○ ● ○ ● ○ ◉ 
            ○           ○           ○           ○ 
            ●           ●           ●           ● 
            ○           ○           ○           ○ 
            ●           ●           ●           ● 
            ○           ○           ○           ○ 
            ● ○ ● ○ ● ○ ◆ ○ ● ○ ● ○ ◆ ○ ● ○ ● ○ ◉ 
                        ○           ○           ○ 
                        ●           ●           ● 
                        ○           ○           ○ 
                        ●           ●           ● 
                        ○           ○           ○ 
                        ● ○ ● ○ ● ○ ◉ ○ ● ○ ● ○ ◆ 
                                    ○           ○ 
                                    ●           ● 
                                    ○           ○ 
                                    ●           ● 
                                    ○           ○ 
                                    ● ○ ● ○ ● ○ ◉ 
                                                ○ 
                                                ● 
                                                ○ 
                                                ● 
                                                ○ 
                                                ● 

julia> apply_gadgets!(copy(eg))
● ○ ● ○ ● ○   ○ ● ○ ● ○   ○ ● ○ ● ○ ○ ○ ● ○ ●     
            ○           ○                         
            ●           ●           ●           ● 
            ○           ○           ○           ○ 
            ●         ○           ○             ● 
              ○     ○ ○ ○       ○ ○ ○           ○ 
                ● ○   ○   ○ ● ○   ○   ○ ● ○ ●   ○ 
                      ○           ○             ○ 
                        ●           ●           ● 
                        ○           ○           ○ 
                        ●           ●           ● 
                          ○         ○           ○ 
                            ● ○ ● ○ ○ ○ ● ○ ● ○   
                                  ○ ○ ○         ○ 
                                    ●           ● 
                                    ○           ○ 
                                    ●           ● 
                                      ○         ○ 
                                        ● ○ ●   ○ 
                                                ○ 
                                                ● 
                                                ○ 
                                                ● 
                                                ○ 
                                                ● 
```