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

## Examples

Please check this [notebook](https://refactored-spork-2b31d0c0.pages.github.io/notebooks/tutorial.html), which contains the following examples

* Generic Unweighted Mapping
* Generic Weighted Mapping
* QUBO problem
    * Generic QUBO mapping
    * QUBO problem on a square lattice
* Factoring
