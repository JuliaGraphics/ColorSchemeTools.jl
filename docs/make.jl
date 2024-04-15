using Documenter, ColorSchemes, ColorSchemeTools, Luxor, Colors

makedocs(
    modules = [ColorSchemeTools],
    sitename = "ColorSchemeTools",
    warnonly = true,
    format = Documenter.HTML(
        size_threshold=nothing,
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/colorschemetools-docs.css"],
        collapselevel=1,
    ),
    pages = [
    "Introduction"               => "index.md",
    "Tools"                      => "tools.md",
    "Converting image colors"    => "convertingimages.md",
    "Making colorschemes"        => "makingschemes.md",
    "Saving colorschemes"        => "output.md",
    "Equalizing colorschemes"    => "equalizing.md",
    "Alphabetical function list" => "functionindex.md"
    ]
    )

deploydocs(
    push_preview = true,
    repo = "github.com/JuliaGraphics/ColorSchemeTools.jl.git",
    target = "build",
    forcepush=true,
)
