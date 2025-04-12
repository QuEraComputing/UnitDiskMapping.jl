# UnitDiskMapping

[![CI](https://github.com/QuEraComputing/UnitDiskMapping.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/QuEraComputing/UnitDiskMapping.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/github/QuEraComputing/UnitDiskMapping.jl/branch/main/graph/badge.svg?token=fwlEQnQICw)](https://codecov.io/github/QuEraComputing/UnitDiskMapping.jl)

## Installation
<p>
<code>UnitDiskMapping</code> is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package for reducing a <a href="https://en.wikipedia.org/wiki/Independent_set_(graph_theory)">generic maximum (weighted) independent set problem</a>, <a href="https://en.wikipedia.org/wiki/Quadratic_unconstrained_binary_optimization"> quadratic unconstrained binary optimization (QUBO) problem</a> or <a href="https://en.wikipedia.org/wiki/Integer_factorization">integer factorization problem</a> to a maximum independent set problem on a unit disk grid graph (or hardcore lattice gas in physics), which can then be naturally encoded in neutral-atom quantum computers. To install <code>UnitDiskMapping</code>,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press the <kbd>]</kbd> key in the REPL to use the package mode, and then type the command below:
</p>

```julia
pkg> add UnitDiskMapping
```

## Supporting and Citing
Much of the software in this ecosystem was developed as a part of an academic research project. If you would like to help support it, please star the repository. If you use our software as part of your research, teaching, or other activities, we would like to request you to cite our [work](https://arxiv.org/abs/2209.03965). The [CITATION.bib](CITATION.bib) file in the root of this repository lists the relevant papers.
