# this code is adaapted from peterkovesi/PerceptualColourMaps.jl
# https://github.com/peterkovesi/PerceptualColourMaps.jl/
# Because: Peter has retired, and is no longer updating his packages.
# all errors are mine!
# original copyright message

#=----------------------------------------------------------------------------

Copyright (c) 2015-2020 Peter Kovesi
peterkovesi.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

The Software is provided "as is", without warranty of any kind.

----------------------------------------------------------------------------=#
function _equalizecolormap(
    colormodel::Symbol,
    cmap::AbstractMatrix{Float64},
    formula::String = "CIE76",
    W::Array = [1.0, 0.0, 0.0],
    sigma::Real = 0.0,
    cyclic::Bool = false,
    diagnostics::Bool = false)
    N = size(cmap, 1)

    if N / sigma < 25
        @warn "sigma shouldn't be larger than 1/25 of the colormap length"
    end

    formula = uppercase(formula)

    if colormodel === :RGB && (maximum(cmap) > 1.01 || minimum(cmap) < -0.01)
        throw(error("_equalizecolormap(): If map is RGB values should be in the range 0-1"))
    elseif colormodel === :LAB && maximum(abs.(cmap)) < 10
        throw(error("_equalizecolormap(): If map is LAB magnitude of values are expected to be > 10"))
    end

    # If input is RGB, convert colormap to Lab. Also, ensure that we have both
    # RGB and Lab representations of the colormap. Assume the Colors.convert()
    # function uses a default white point of D65
    if colormodel === :RGB
        rgbmap = copy(cmap)
        labmap = _srgb_to_lab(cmap)
        L = labmap[:, 1]
        a = labmap[:, 2]
        b = labmap[:, 3]
    elseif colormodel === :LAB
        labmap = copy(cmap)
        rgbmap = _lab_to_srgb(cmap)
        L = cmap[:, 1]
        a = cmap[:, 2]
        b = cmap[:, 3]
    else
        throw(error("_equalizecolormap(): `colormodel` must be RGB or LAB, not $(colormodel)"))
    end

    # The following section of code computes the locations to interpolate into
    # the colormap in order to achieve equal steps of perceptual contrast.
    # The process is repeated recursively on its own output. This helps overcome
    # the approximations induced by using linear interpolation to estimate the
    # locations of equal perceptual contrast. This is mainly an issue for
    # colormaps with only a few entries.

    initialdeltaE = 0
    initialcumdE = 0
    initialequicumdE = 0
    initialnewN = 0

    for iter in 1:3
        # Compute perceptual colour difference values along the colormap using
        # the chosen formula and weighting vector.
        if formula == "CIE76"
            deltaE = _cie76(L, a, b, W)
        elseif formula == "CIEDE2000"
            deltaE = _ciede2000(L, a, b, W)
        else
            throw(error("_equalizecolormap(): Unknown colour difference formula in $(formula)"))
        end

        # Form cumulative sum of delta E values.  However, first ensure all
        # values are larger than 0.001 to ensure the cumulative sum always
        # increases.
        deltaE[deltaE .< 0.001] .= 0.001
        cumdE = cumsum(deltaE, dims = 1)

        # Form an array of equal steps in cumulative contrast change.
        equicumdE = collect(0:(N - 1)) ./ (N - 1) .* (cumdE[end] - cumdE[1]) .+ cumdE[1]

        # Solve for the locations that would give equal Delta E values.
        newN = _interp1(cumdE, 1:N, equicumdE)

        # newN now represents the locations where we want to interpolate into the
        # colormap to obtain constant perceptual contrast
        Li = interpolate(L, BSpline(Linear()))
        L = [Li(v) for v in newN]

        ai = interpolate(a, BSpline(Linear()))
        a = [ai(v) for v in newN]

        bi = interpolate(b, BSpline(Linear()))
        b = [bi(v) for v in newN]

        # Record initial colour differences for evaluation at the end
        if iter == 1
            initialdeltaE = deltaE
            initialcumdE = cumdE
            initialequicumdE = equicumdE
            initialnewN = newN
        end
    end

    # Apply smoothing of the path in CIELAB space if requested.  The aim is to
    # smooth out sharp lightness/colour changes that might induce the perception
    # of false features.  In doing this there will be some cost to the
    # perceptual contrast at these points.
    if sigma > 0.0
        L = _smooth(L, sigma, cyclic)
        a = _smooth(a, sigma, cyclic)
        b = _smooth(b, sigma, cyclic)
    end

    # Convert map back to RGB
    newlabmap = [L a b]
    newrgbmap = _lab_to_srgb(newlabmap)

    return newrgbmap
end

"""
    equalize(cs::ColorScheme;
        colormodel::Symbol="RGB",
        formula::String="CIE76",
        W::Array=[1.0, 0.0, 0.0],
        sigma::Real=0.0,
        cyclic::Bool=false)

    equalize(ca::Array{Colorant, 1}; 
        # same keywords 
        )

Equalize colors in the colorscheme `cs` or the array of colors `ca` so that they
are more perceptually uniform.

  - `cs` is a ColorScheme

  - `ca` is an array of colors
  - `colormodel`` is `:RGB`or`:LAB`
  - `formula` is "CIE76" or "CIEDE2000"
  - `W` is a vector of three weights to be applied to the lightness, chroma, and hue
    components of the difference equation
  - `sigma` is an optional Gaussian smoothing parameter
  - `cyclic` is a Boolean flag indicating whether the colormap is cyclic

Returns a colorscheme with the colors adjusted.
"""
function equalize(ca::Array{T};
    colormodel::Symbol = :RGB,
    formula::String = "CIE76",
    W::Array = [1.0, 0.0, 0.0],
    sigma::Real = 0.0,
    cyclic::Bool = false) where {T<:Colorant}

    # if colors are RGB or RGBA
    if eltype(ca) <: Colors.RGBA
        rgbdata = _equalizecolormap(colormodel, _RGBA_to_FloatArray(ca), formula, W,
            sigma, cyclic, false)
    else
        rgbdata = _equalizecolormap(colormodel, _RGB_to_FloatArray(ca), formula, W,
            sigma, cyclic, false)
    end
    newcolors = [RGB(rgb...) for rgb in eachrow(rgbdata)]
    return ColorScheme(newcolors)
end

equalize(cs::ColorScheme;
    colormodel::Symbol = :RGB,
    formula::String = "CIE76",
    W::Array = [1.0, 0.0, 0.0],
    sigma::Real = 0.0,
    cyclic::Bool = false) = equalize(cs.colors, colormodel = colormodel, formula = formula, W = W, sigma = sigma, cyclic = cyclic)
