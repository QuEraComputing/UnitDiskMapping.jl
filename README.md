# UnitDiskMapping

[![CI](https://github.com/Happy-Diode/UnitDiskMapping.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/Happy-Diode/UnitDiskMapping.jl/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/Happy-Diode/UnitDiskMapping.jl/badge.svg?branch=main&t=H2ReMe)](https://coveralls.io/github/Happy-Diode/UnitDiskMapping.jl?branch=main)

## Installation
<p>
<code>UnitDiskMapping</code> is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package for reducing a <a href="https://en.wikipedia.org/wiki/Independent_set_(graph_theory)">generic (weighted) maximum independent set problem</a>, <a href="https://en.wikipedia.org/wiki/Quadratic_unconstrained_binary_optimization">QUBO problem</a> or <a href="https://en.wikipedia.org/wiki/Integer_factorization">integer factoring problem</a> to a maximum independent set problem on a unit disk grid graph (or hardcore lattice gas in physics). To install <code>UnitDiskMapping</code>,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press <kbd>]</kbd> key in the REPL to use the package mode, then type the following command
</p>

For installing the current master branch, please type

```julia
pkg> add https://github.com/QuEraComputing/UnitDiskMapping.jl.git
```

For stable release (not yet ready)

```julia
pkg> add UnitDiskMapping
```

## Examples

Please check this [notebook](https://refactored-spork-2b31d0c0.pages.github.io/notebooks/tutorial.html), which contains the following examples

* Generic Unweighted Mapping
* Generic Weighted Mapping
* QUBO problem
    * Generic QUBO mapping
    * QUBO problem on a square lattice
* Factoring

To run the notebook locally you will need the [Pluto](https://github.com/fonsp/Pluto.jl) and [GenericTensorNetworks](https://github.com/QuEraComputing/GenericTensorNetworks.jl) Julia packages installed. You can run the following after entering Package mode:

```
pkg> add Pluto
pkg> add GenericTensorNetworks
```

and returning to the Julia REPL (you can do this by hitting Backspace in Package mode) run:

```
julia> import Pluto; Pluto.run()
```
in the `notebooks` directory of this project. At this point your browser should automatically launch and display a list of available notebooks you can run. You should just see `tutorial.jl` listed.


## Supporting and Citing
Much of the software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use our software as part of your research, teaching, or other activities, we would be grateful if you could cite our work. The [CITATION.bib](CITATION.bib) file in the root of this repository lists the relevant papers.
