using Documenter, ColorSchemes, ColorSchemeTools, Luxor, Colors

makedocs(
    modules = [ColorSchemeTools],
    sitename = "ColorSchemeTools",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/colorschemetools-docs.css"]),
    pages    = Any[
    "Introduction"             => "index.md",
    "Tools"                    => "tools.md",
    "Converting image colors"  => "convertingimages.md",
    "Making colorschemes"      => "makingschemes.md",
    "Saving colorschemes"      => "output.md",
    "Index"                    => "functionindex.md"
    ]
    )

deploydocs(
    push_preview = true,
    repo = "github.com/JuliaGraphics/ColorSchemeTools.jl.git",
    target = "build"
    )
