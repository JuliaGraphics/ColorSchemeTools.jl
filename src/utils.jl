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
"""
    _gaussfilt1d(s::Array, sigma::Real)

Apply a 1D Gaussian filter to `s`. Filtering at
the ends is done using zero padding.

Usage:

    sm = _gaussfilt1d(s::Array, sigma::Real)
"""
function _gaussfilt1d(s::Array, sigma::Real)
    N = length(s)

    r = ceil(Int, 3 * sigma)    # Determine filter size
    fw = 2 * r + 1

    # Construct filter
    f = [exp(-x .^ 2 / (2 * sigma^2)) for x in (-r):r]
    f = f / sum(f)

    sm = zeros(size(s))

    # Filter centre section
    for i in (r + 1):(N - r), k in 1:fw
        sm[i] += f[k] * s[i + k - r - 1]
    end

    # Filter start section of array using 0 padding
    for i in 1:r, k in 1:fw
        ind = i + k - r - 1
        if ind >= 1 && ind <= N
            sm[i] += f[k] * s[ind]
        end
    end

    # Filter end section of array using 0 padding
    for i in (N - r + 1):N, k in 1:fw
        ind = i + k - r - 1
        if ind >= 1 && ind <= N
            sm[i] += f[k] * s[ind]
        end
    end

    return sm
end

"""
    _smooth(L::Array{T,1}, sigma::Real, cyclic::Bool) where {T<:Real}

Smooth an array of values but also ensure end values are
not altered or, if the map is cyclic, ensures smoothing is applied
across the end points in a cyclic manner.

Assume input data is a column vector.
"""
function _smooth(L::Array{T,1}, sigma::Real, cyclic::Bool) where {T<:Real}
    if cyclic
        Le = [L; L; L] # Form a concatenation of 3 repetitions of the array.
        Ls = _gaussfilt1d(Le, sigma)               # Apply smoothing filter
        Ls = Ls[(length(L) + 1):(length(L) + length(L))] # and then return the center section
    else
        # Non-cyclic colormap: Pad out input array L at both ends by 3*sigma
        # with additional values at the same slope.  The aim is to eliminate
        # edge effects in the filtering
        extension = collect(1:ceil(3 * sigma))
        dL1 = L[2] - L[1]
        dL2 = L[end] - L[end - 1]
        Le = [-reverse(dL1 * extension, dims = 1) .+ L[1]; L; dL2 * extension .+ L[end]]
        Ls = _gaussfilt1d(Le, sigma) # Apply smoothing filter
        # Trim off extensions
        Ls = Ls[(length(extension) + 1):(length(extension) + length(L))]
    end

    return Ls
end

"""
    _cie76(L::Array, a::Array, b::Array, W::Array)

Compute weighted Delta E between successive entries in a
colormap using the CIE76 formula + weighting

Usage: 

    deltaE = _cie76(L::Array, a::Array, b::Array, W::Array)
"""
function _cie76(L::Array, a::Array, b::Array, W::Array)
    N = length(L)

    # Compute central differences
    dL = zeros(size(L))
    da = zeros(size(a))
    db = zeros(size(b))

    dL[2:(end - 1)] = (L[3:end] - L[1:(end - 2)]) / 2
    da[2:(end - 1)] = (a[3:end] - a[1:(end - 2)]) / 2
    db[2:(end - 1)] = (b[3:end] - b[1:(end - 2)]) / 2

    # Differences at end points
    dL[1] = L[2] - L[1]
    dL[end] = L[end] - L[end - 1]
    da[1] = a[2] - a[1]
    da[end] = a[end] - a[end - 1]
    db[1] = b[2] - b[1]
    db[end] = b[end] - b[end - 1]

    return deltaE = sqrt.(W[1] * dL .^ 2 + W[2] * da .^ 2 + W[3] * db .^ 2)
end

"""
    _ciede2000(L::Array, a::Array, b::Array, W::Array)

Compute weighted Delta E between successive entries in a
colormap using the CIEDE2000 formula + weighting

Usage: 

    deltaE = _ciede2000(L::Array, a::Array, b::Array, W::Array)
"""
function _ciede2000(L::Array, a::Array, b::Array, W::Array)
    N = length(L)
    deltaE = zeros(N, 1)
    kl = 1 / W[1]
    kc = 1 / W[2]
    kh = 1 / W[3]

    # Compute deltaE using central differences
    for i in 2:(N - 1)
        deltaE[i] = Colors.colordiff(Colors.Lab(L[i + 1], a[i + 1], b[i + 1]), Colors.Lab(L[i - 1], a[i - 1], b[i - 1]);
            metric = Colors.DE_2000(kl, kc, kh)) / 2
    end

    # Differences at end points
    deltaE[1] = Colors.colordiff(Colors.Lab(L[2], a[2], b[2]), Colors.Lab(L[1], a[1], b[1]);
        metric = Colors.DE_2000(kl, kc, kh))
    deltaE[N] = Colors.colordiff(Colors.Lab(L[N], a[N], b[N]), Colors.Lab(L[N - 1], a[N - 1], b[N - 1]);
        metric = Colors.DE_2000(kl, kc, kh))

    return deltaE
end

"""
    _srgb_to_lab(rgb::AbstractMatrix{T}) where {T}

Convert an Nx3 array of RGB values in a colormap to an Nx3 array of CIELAB
values.  Function can also be used to convert a 3 channel RGB image to a 3
channel CIELAB image Note it appears that the Colors.convert() function uses a
default white point of D65

Usage:

    lab = _srgb_to_lab(rgb)
Argument:

    rgb - A N x 3 array of RGB values or a 3 channel RGB image.

Returns:

     lab - A N x 3 array of Lab values of a 3 channel CIELAB image.

See also: _lab_to_srgb
"""
function _srgb_to_lab(rgb::AbstractMatrix{T}) where {T}
    N = size(rgb, 1)
    lab = zeros(N, 3)
    for i in 1:N
        labval = Colors.convert(Colors.Lab, Colors.RGB(rgb[i, 1], rgb[i, 2], rgb[i, 3]))
        lab[i, 1] = labval.l
        lab[i, 2] = labval.a
        lab[i, 3] = labval.b
    end
    return lab
end

"""
    _srgb_to_lab(rgb::Array{T, 3}) where {T}

Convert a 3 channel RGB image to a 3 channel CIELAB image.

Usage:  

    lab = _srgb_to_lab(rgb)
"""
function _srgb_to_lab(rgb::Array{T,3}) where {T}
    (rows, cols, chan) = size(rgb)
    lab = zeros(size(rgb))

    for r in 1:rows, c in 1:cols
        labval = Colors.convert(Colors.Lab, Colors.RGB(rgb[r, c, 1], rgb[r, c, 2], rgb[r, c, 3]))
        lab[r, c, 1] = labval.l
        lab[r, c, 2] = labval.a
        lab[r, c, 3] = labval.b
    end

    return lab
end

"""
    _srgb_to_lab(rgb::Vector{T}) where {T}
"""
function _srgb_to_lab(rgb::Vector{T}) where {T}
    N = size(rgb, 1)
    lab = zeros(N, 3)
    for i in 1:N
        labval = Colors.convert(Colors.Lab, rgb[i])
        lab[i, 1] = labval.l
        lab[i, 2] = labval.a
        lab[i, 3] = labval.b
    end
    return lab
end

"""
    _lab_to_srgb(lab::AbstractMatrix{T}) where {T}

Convert an Nx3 array of CIELAB values in a colormap to an Nx3 array of RGB
values.  Function can also be used to convert a 3 channel CIELAB image to a 3
channel RGB image Note it appears that the Colors.convert() function uses a
default white point of D65

Usage:

    rgb = _lab_to_srgb(lab)

Argument:

    lab - N x 3 array of CIELAB values of a 3 channel CIELAB image

Returns:

    rgb - N x 3 array of RGB values or a 3 channel RGB image

See also: _srgb_to_lab
"""
function _lab_to_srgb(lab::AbstractMatrix{T}) where {T}
    N = size(lab, 1)
    rgb = zeros(N, 3)
    for i in 1:N
        rgbval = Colors.convert(ColorTypes.RGB, ColorTypes.Lab(lab[i, 1], lab[i, 2], lab[i, 3]))
        rgb[i, 1] = rgbval.r
        rgb[i, 2] = rgbval.g
        rgb[i, 3] = rgbval.b
    end

    return rgb
end

"""
    _lab_to_srgb(lab::Array{T,3}) where {T}

Convert a 3 channel Lab image to a 3 channel RGB image.

Usage:

    rgb = _lab_to_srgb(lab)
"""
function _lab_to_srgb(lab::Array{T,3}) where {T}
    (rows, cols, chan) = size(lab)
    rgb = zeros(size(lab))
    for r in 1:rows, c in 1:cols
        rgbval = Colors.convert(ColorTypes.RGB, ColorTypes.Lab(lab[r, c, 1], lab[r, c, 2], lab[r, c, 3]))
        rgb[r, c, 1] = rgbval.r
        rgb[r, c, 2] = rgbval.g
        rgb[r, c, 3] = rgbval.b
    end
    return rgb
end

"""
    _RGBA_to_UInt32(rgb)

Convert an array of RGB values to an array of UInt32 values
for use as a colormap.

Usage:

    uint32rgb = _RGBA_to_UInt32(rgbmap)

Argument:

    rgbmap - Vector of ColorTypes.RGBA values

Returns:

    uint32rgb, an array of UInt32 values packed with the 8 bit RGB values.
"""
function _RGBA_to_UInt32(rgb)
    N = length(rgb)
    uint32rgb = zeros(UInt32, N)

    for i in 1:N
        r = round(UInt32, rgb[i].r * 255)
        g = round(UInt32, rgb[i].g * 255)
        b = round(UInt32, rgb[i].b * 255)
        uint32rgb[i] = r << 16 + g << 8 + b
    end

    return uint32rgb
end

"""
    _linearrgbmap(C::Array, N::Int=256)

Linear RGB colourmap from black to a specified color.

Usage:

    cmap = _linearrgbmap(C, N)

Arguments:

    C - 3-vector specifying RGB colour

    N - Number of colourmap elements, defaults to 256

Returns

    cmap - an N element ColorTypes.RGBA colourmap ranging from [0 0 0] to RGB colour C.

You should pass the result through equalize() to obtain uniform steps in perceptual lightness.
"""
function _linearrgbmap(C::Array, N::Int = 256)
    if length(C) != 3
        throw(error("_linearrgbmap(): Colour must be a 3 element array"))
    end

    rgbmap = zeros(N, 3)
    ramp = (0:(N - 1)) / (N - 1)

    for n in 1:3
        rgbmap[:, n] = C[n] * ramp
    end

    return _FloatArray_to_RGBA(rgbmap)
end

"""
     _FloatArray_to_RGB(cmap)

Convert Nx3 Float64 array to N array of ColorTypes.RGB{Float64}.
"""
function _FloatArray_to_RGB(cmap)
    (N, cols) = size(cmap)
    if cols != 3
        throw(error("_FloatArray_to_RGB(): data must be N x 3"))
    end

    rgbmap = Array{Colors.RGB{Float64},1}(undef, N)
    for i in 1:N
        rgbmap[i] = Colors.RGB(cmap[i, 1], cmap[i, 2], cmap[i, 3])
    end

    return rgbmap
end

"""
    _FloatArray_to_RGBA(cmap)

Convert Nx3 Float64 array to array of N ColorTypes.RGBA{Float64}.
"""
function _FloatArray_to_RGBA(cmap)
    (N, cols) = size(cmap)
    if cols != 3
        throw(error("_FloatArray_to_RGB(): data must be N x 3"))
    end

    rgbmap = Array{Colors.RGBA{Float64},1}(undef, N)
    for i in 1:N
        rgbmap[i] = Colors.RGBA(cmap[i, 1], cmap[i, 2], cmap[i, 3], 1.0)
    end

    return rgbmap
end

"""
    _RGB_to_FloatArray(rgbmap)

Convert array of N RGB{Float64} to Nx3 Float64 array.
"""
function _RGB_to_FloatArray(rgbmap)
    N = length(rgbmap)

    cmap = Array{Float64}(undef, N, 3)
    for i in 1:N
        cmap[i, :] = [rgbmap[i].r rgbmap[i].g rgbmap[i].b]
    end

    return cmap
end

"""
    _RGBA_to_FloatArray(rgbmap)

Convert array of N RGBA{Float64} to Nx3 Float64 array
"""
function _RGBA_to_FloatArray(rgbmap)
    N = length(rgbmap)

    cmap = Array{Float64}(undef, N, 3)
    for i in 1:N
        cmap[i, :] = [rgbmap[i].r rgbmap[i].g rgbmap[i].b]
    end

    return cmap
end

"""
    _interp1(x, y, xi)

Simple 1D linear interpolation of an array of data

Usage:  

    yi = _interp1(x, y, xi)

Arguments:  

    x - Array of coordinates at which y is defined

    y - Array of values at coordinates x

    xi - Coordinate locations at which you wish to interpolate y values

Returns:   

    yi - Values linearly interpolated from y at xi

Interpolates y, defined at values x, at locations xi and returns the
corresponding values as yi. 

x is assumed increasing but not necessarily equi-spaced.
xi values do not need to be sorted.

If any xi are outside the range of x, then the corresponding value of
yi is set to the appropriate end value of y.
"""
function _interp1(x, y, xi)
    N = length(xi)
    yi = zeros(size(xi))

    minx = minimum(x)
    maxx = maximum(x)

    for i in 1:N
        # Find interval in x that each xi lies within and interpolate its value

        if xi[i] <= minx
            yi[i] = y[1]

        elseif xi[i] >= maxx
            yi[i] = y[end]

        else
            left = maximum(findall(x .<= xi[i]))
            right = minimum(findall(x .> xi[i]))

            yi[i] = y[left] + (xi[i] - x[left]) / (x[right] - x[left]) * (y[right] - y[left])
        end
    end
    return yi
end

"""
    _normalize_array(img::Array)
    
Offsets and rescales elements of `image` so that the minimum value is 0 and the
maximum value is 1.
"""
function _normalize_array(img::Array)
    lo, hi = extrema(img)
    if !isapprox(lo, hi)
        n = img .- lo
        return n / maximum(n)
    else
        # no NaNs please
        return img .- lo
    end
end

"""
    sineramp(rows, cols;
            amplitude = 12.5,
            wavelength = 8,
            p = 2)

Generate a `rows × cols` array of values which show a sine wave with
decreasing amplitude from top to bottom.

Usage:

```julia
using Images
scheme = ColorSchemes.dracula
img = Gray.(sineramp(256, 512, amp = 12.5, wavelen = 8, p = 2))
cimg = zeros(RGB, 256, 512)
for e in eachindex(img)
    cimg[e] = get(mscheme, img[e])
end
cimg
```

The default wavelength is 8 pixels. On a computer monitor with a nominal pixel
pitch of 0.25mm this corresponds to a wavelength of 2mm. With a monitor viewing
distance of 600mm this corresponds to 0.19 degrees of viewing angle or
approximately 5.2 cycles per degree. This falls within the range of spatial
frequencies (3-7 cycles per degree) at which most people have maximal contrast
sensitivity to a sine wave grating (this varies with mean luminance). A
wavelength of 8 pixels is also sufficient to provide a reasonable discrete
representation of a sine wave. The aim is to present a stimulus that is well
matched to the performance of the human visual system so that what we are
primarily evaluating is the colorscheme's perceptual contrast and not the visual
performance of the viewer.

The default amplitude is set at 12.5, so that from peak to trough we have a
local feature of magnitude 25. This is approximately 10% of the 256 levels in a
typical colorscheme. It is not uncommon for colorschemes to have perceptual flat
spots that can hide features of this magnitude.

The width of the image is adjusted so that we have an integer number of cycles
of the sinewave. This helps should one be using the test image to evaluate a
cyclic colorscheme. However you will still see a slight cyclic discontinuity at
the top of the image, though this will disappear at the bottom.
"""
function sineramp(rows, cols;
    amplitude = 12.5,
    wavelength = 8,
    p = 2)
    cycles = round(cols / wavelength)
    cols = cycles * wavelength

    # Sine wave
    x = collect(0:(cols - 1))'
    fx = amplitude * sin.(1.0 / wavelength * 2 * pi * x)

    # Vertical modulating function
    A = (collect((rows - 1):-1:0)' / (rows - 1)) .^ float(p)
    img = A' * fx

    # Add ramp
    ramp = [c / (cols - 1) for r in 1:rows, c in 0:(cols - 1)]
    img = img + ramp * (255.0 - 2 * amplitude)

    # Now normalise each row so that it spans the full data range from 0 to 255.
    # Again, this is important for evaluation of cyclic colour maps though a
    # small cyclic discontinuity will remain at the top of the test image.
    for r in 1:rows
        img[r, :] = _normalize_array(img[r, :])
    end
    return img
end
