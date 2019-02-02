# Introduction to ColorSchemeTools

This package provides tools for working with color schemes - gradients and color maps.

You can extract color schemes from images, and replace an image's color scheme with another. There are also functions for creating color schemes from pre-defined lists or Julia functions.

This package relies on:

- [Colors.jl](https://github.com/JuliaGraphics/Colors.jl)
- [ColorSchemes.jl](https://github.com/JuliaGraphics/ColorSchemes.jl)
- [Images.jl](https://github.com/JuliaImages/Images.jl)
- [Clustering.jl](https://github.com/JuliaStats/Clustering.jl)

and you might need image-capable Julia packages such as ImageMagick.jl or QuartzImageIO.jl installed, depending on the OS.

## Installation and basic usage

Install the package as follows:

```
] add ColorSchemeTools
```

To use it:

```
using ColorSchemeTools
```

Original version by [cormullion](https://github.com/cormullion).
