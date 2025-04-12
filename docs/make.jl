using UnitDiskMapping
using Documenter
using Literate
using DocThemeIndigo

# Literate
for each in readdir(pkgdir(UnitDiskMapping, "examples"))
    input_file = pkgdir(UnitDiskMapping, "examples", each)
    endswith(input_file, ".jl") || continue
    @info "building" input_file
    output_dir = pkgdir(UnitDiskMapping, "docs", "src", "generated")
    Literate.markdown(input_file, output_dir; name=each[1:end-3], execute=false)
end

DocMeta.setdocmeta!(UnitDiskMapping, :DocTestSetup, :(using UnitDiskMapping); recursive=true)
indigo = DocThemeIndigo.install(UnitDiskMapping)

makedocs(;
    modules=[UnitDiskMapping],
    authors="GiggleLiu and contributors",
    sitename="UnitDiskMapping.jl",
    format=Documenter.HTML(;
        canonical="https://QuEraComputing.github.io/UnitDiskMapping.jl",
        edit_link="main",
        assets=String[indigo],
    ),
    doctest = ("doctest=true" in ARGS),
    pages=[
        "Home" => "index.md",
        "Examples" => [
            "generated/tutorial.md",
            "generated/unweighted.md"
        ],
        "Reference" => "ref.md",
    ],
    warnonly=[:missing_docs]
)

deploydocs(;
    repo="github.com/QuEraComputing/UnitDiskMapping.jl",
    devbranch="main",
)
