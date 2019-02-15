"""
This package provides some tools for working with ColorSchemes:

    colorscheme_to_image(), colorscheme_to_text(), colorscheme_weighted(),
    compare_colors(), extract(), extract_weighted_colors(), convert_to_scheme(),
    image_to_swatch(), sortcolorscheme(), get_linear_segment_color(),
    make_colorscheme(), get_indexed_list_color()
"""
module ColorSchemeTools

using Images, ColorSchemes, Colors, Clustering, FileIO, Dates

import Base.get

export
    colorscheme_to_image,
    colorscheme_to_text,
    colorscheme_weighted,
    compare_colors,
    extract,
    extract_weighted_colors,
    convert_to_scheme,
    image_to_swatch,
    sortcolorscheme,
    make_colorscheme,
    get_linear_segment_color,
    get_indexed_list_color

"""
    extract(imfile, n=10, i=10, tolerance=0.01; shrink=n)

`extract()` extracts the most common colors from an image from the image file
`imfile` by finding `n` dominant colors, using `i` iterations. You can (and
probably should) shrink larger images before running this function.

Returns a ColorScheme.
"""
function extract(imfile, n=10, i=10, tolerance=0.01; kwargs...)
    ewc = extract_weighted_colors(imfile, n, i, tolerance; kwargs...)[1] # throw away the weights
    return ewc
end

"""
    extract_weighted_colors(imfile, n=10, i=10, tolerance=0.01; shrink = 2)

Extract colors and weights of the clusters of colors in an image file. Returns a
ColorScheme and weights.

Example:

```
pal, wts = extract_weighted_colors(imfile, n, i, tolerance; shrink = 2)
```
"""
function extract_weighted_colors(imfile, n=10, i=10, tolerance=0.01; shrink = 2.0)
    img = load(imfile)
    # TODO this is the wrong to do errors
    (!@isdefined img) && error("Can't load the image file \"$imfile\"")
    w, h = size(img)
    neww = round(Int, w/shrink)
    newh = round(Int, h/shrink)
    smaller_image = Images.imresize(img, (neww, newh))
    w, h = size(smaller_image)
    imdata = convert(Array{Float64}, channelview(smaller_image))

    !any(n -> n == 3, size(imdata)) && error("Image file \"$imfile\" doesn't have three color channels; perhaps it has an alpha channel as well?")

    d = reshape(imdata, 3, :)
    R = kmeans(d, n, maxiter=i, tol=tolerance)
    cols = RGB{Float64}[]
    for i in 1:3:length(R.centers)
        push!(cols, RGB(R.centers[i], R.centers[i+1], R.centers[i+2]))
    end
    return ColorScheme(cols), R.cweights/sum(R.cweights)
end

"""
    colorscheme_weighted(colorscheme, weights, length)

Returns a new ColorScheme of length `length` (default 50) where the proportion
of each color in `colorscheme` is represented by the associated weight of each
entry.

Examples:

```
colorscheme_weighted(extract_weighted_colors("hokusai.jpg")...)
colorscheme_weighted(extract_weighted_colors("filename00000001.jpg")..., 500)
```
"""
function colorscheme_weighted(cscheme::ColorScheme, weights, l = 50)
    iweights = map(n -> convert(Integer, round(n * l)), weights)
    #   adjust highest or lowest so that length of result is exact
    while sum(iweights) < l
        val, ix = findmin(iweights)
        iweights[ix]=val+1
    end
    while sum(iweights) > l
        val,ix = findmax(iweights)
        iweights[ix]=val-1
    end
    a = Array{RGB{Float64}}(undef, 0)
    for n in 1:length(cscheme)
        a = vcat(a, repeat([cscheme[n]], iweights[n]))
    end
    return ColorScheme(a)
end

"""
    compare_colors(color_a, color_b, field = :l)

Compare two colors, using the Luv colorspace. `field` defaults to luminance `:l`
but could be `:u` or `:v`. Return true if the specified field of `color_a` is
less than `color_b`.
"""
function compare_colors(color_a, color_b, field = :l)
    if 1 < color_a.r < 255
        fac = 255
    else
        fac = 1
    end
    luv1 = convert(Luv, RGB(color_a.r/fac, color_a.g/fac, color_a.b/fac))
    luv2 = convert(Luv, RGB(color_b.r/fac, color_b.g/fac, color_b.b/fac))
    return getfield(luv1, field) < getfield(luv2, field)
end

"""
    sortcolorscheme(colorscheme::ColorScheme, field; kwargs...)

Sort (non-destructively) a colorscheme using a field of the LUV colorspace.

The less than function is `lt = (x,y) -> compare_colors(x, y, field)`.

The default is to sort by the luminance field `:l` but could be by `:u` or `:v`.

Returns a new ColorScheme.
"""
function sortcolorscheme(colorscheme::ColorScheme, field = :l; kwargs...)
    cols = sort(colorscheme.colors, lt = (x,y) -> compare_colors(x, y, field); kwargs...)
    return ColorScheme(cols)
end

"""
    convert_to_scheme(cscheme, img)

Converts `img` from its current color values to use only the colors defined in the ColorScheme `cscheme`.

```
image = nonTransparentImg
convert_to_scheme(ColorSchemes.leonardo, image)
convert_to_scheme(ColorSchemes.Paired_12, image)
```
"""
convert_to_scheme(cscheme::ColorScheme,img) =
    map(c->get(cscheme, getinverse(cscheme, c)), img)

"""
    colorscheme_to_image(cs, nrows=50, tilewidth=5)

Make an image from a ColorScheme by repeating the colors in `nrows` rows, repeating each pixel `tilewidth` times.

Returns the image as an array.

Examples:

```
using FileIO

img = colorscheme_to_image(ColorSchemes.leonardo, 50, 200)
save("/tmp/cs_image.png", img)

save("/tmp/blackbody.png", colorscheme_to_image(ColorSchemes.blackbody, 10, 100))
```
"""
function colorscheme_to_image(cs::ColorScheme, nrows=50, tilewidth=5)
    ncols = tilewidth * length(cs)
    a = Array{RGB{Float64}}(undef, nrows, ncols)
    for row in 1:nrows
        for col in 1:ncols
            a[row, col] = cs.colors[div(col-1, tilewidth) + 1]
        end
    end
    return a
end

"""
    image_to_swatch(imagefilepath, samples, destinationpath;
        nrows=50,
        tilewidth=5)

Extract a ColorsSheme from the image in `imagefilepath` to a swatch image PNG in
`destinationpath`. This just runs `sortcolorscheme()`, `colorscheme_to_image()`,
and `save()` in sequence.

Specify the number of colors. You can also specify the number of rows, and how
many times each color is repeated.

```
image_to_swatch("monalisa.jpg", 10, "/tmp/monalisaswatch.png")
```
"""
function image_to_swatch(imagefilepath, n::Int64, destinationpath;
    nrows=50,
    tilewidth=5)
    tempcs = sortcolorscheme(extract(imagefilepath, n))
    img = colorscheme_to_image(tempcs, nrows, tilewidth)
    save(destinationpath, img)
end

"""
    colorscheme_to_text(cscheme::ColorScheme, schemename, filename;
        category="dutch painters",   # category
        notes="it's not really lost" # notes
    )

Write a ColorScheme to a Julia text file.

## Example

```
colorscheme_to_text(ColorSchemes.vermeer,
    "the_lost_vermeer",          # name
    "/tmp/the_lost_vermeer.jl",  # file
    category="dutch painters",   # category
    notes="it's not really lost" # notes
    )
```

and read it back in with:

```
include("/tmp/the_lost_vermeer.jl")
```
"""
function colorscheme_to_text(cs::ColorScheme, schemename::String, file::String;
        category="",
        notes="")
    fhandle = open(file, "w")
    write(fhandle, string("loadcolorscheme(:$(schemename), [\n"))
    for c in cs.colors
        write(fhandle, string("\tColors.$(c), \n"))
    end
    write(fhandle, string("], \"$(category)\", \"$(notes)\")"))
    close(fhandle)
end

"""
    get_linear_segment_color(dict, n)

Get the RGB color for value `n` from a dictionary of linear color segments.

This following is a dictionary where red increases from 0 to 1 over the bottom
half, green does the same over the middle half, and blue over the top half:

```
cdict = Dict(:red  => ((0.0,  0.0,  0.0),
                       (0.5,  1.0,  1.0),
                       (1.0,  1.0,  1.0)),
            :green => ((0.0,  0.0,  0.0),
                       (0.25, 0.0,  0.0),
                       (0.75, 1.0,  1.0),
                       (1.0,  1.0,  1.0)),
            :blue =>  ((0.0,  0.0,  0.0),
                       (0.5,  0.0,  0.0),
                       (1.0,  1.0,  1.0)))
```

The value of RGB component at every value of `n` is defined by a set of tuples.
In each tuple, the first number is `x`. Colors are linearly interpolated in
bands between consecutive values of `x`; if the first tuple is given by `(Z, A,
B)` and the second tuple by `(X, C, D)`, the color of a point `n` between Z and
X will be given by `(n - Z) / (X - Z) * (C - B) + B`.

For example, given an entry like this:

```
:red  => ((0.0, 0.0, 0.0),
          (0.5, 1.0, 1.0),
          (1.0, 1.0, 1.0))
```

and if `n` = 0.75, we return 1.0; 0.75 is between the second and third segments,
but we'd already reached 1.0 (segment 2) when `n` was 0.5.

"""
function get_linear_segment_color(dict, n)
    result = Float64[]
    for c in [:red, :green, :blue]
        listoftuples = dict[c]
        n = clamp(n, 0.0, 1.0)
        upper = max(2, findfirst(f -> n <= first(f), listoftuples))
        lower = max(1, upper - 1)
        lowersegment = listoftuples[lower]
        uppersegment = listoftuples[upper]
        Z, A, B = lowersegment
        X, C, D = uppersegment
        if X > Z
            color_at_n = (n - Z)/(X - Z) * (C - B) + B
        else
            color_at_n = 0.0
        end
        push!(result, color_at_n)
    end
    return result
end

"""
    lerp((x, from_min, from_max, to_min=0.0, to_max=1.0)

Linear interpolation of `x` between `from_min` and `from_max`.

Example

```
ColorSchemeTools.lerp(128, 0, 256)
0.5
```
"""
function lerp(x, from_min, from_max, to_min=0.0, to_max=1.0)
   if !isapprox(from_max, from_min)
       return ((x - from_min) / (from_max - from_min)) * (to_max - to_min) + to_min
   else
       return from_max
   end
end

"""
    get_indexed_list_color(indexedlist, n)

Get the color at a point `n` given an indexed list of triples like this:

```
gist_rainbow = (
       (0.000,   (1.00, 0.00, 0.16)),
       (0.030,   (1.00, 0.00, 0.00)),
       (0.215,   (1.00, 1.00, 0.00)),
       (0.400,   (0.00, 1.00, 0.00)),
       (0.586,   (0.00, 1.00, 1.00)),
       (0.770,   (0.00, 0.00, 1.00)),
       (0.954,   (1.00, 0.00, 1.00)),
       (1.000,   (1.00, 0.00, 0.75))
    )
```

To make a ColorScheme from this type of list, use:

```
make_colorscheme(gist_rainbow)
```
"""
function get_indexed_list_color(indexedlist, n)
   m = clamp(n, 0.0, 1.0)
   upper = max(2, findfirst(f -> m <= first(first(f)), indexedlist))
   lower = max(1, upper - 1)
   lowercolorvalues = last(indexedlist[lower])
   uppercolorvalues = last(indexedlist[upper])
   lowerv = first(indexedlist[lower])
   upperv = first(indexedlist[upper])
   lr, lg, lb = lowercolorvalues
   ur, ug, ub = uppercolorvalues
   r = lerp(m, lowerv, upperv, lr, ur)
   g = lerp(m, lowerv, upperv, lg, ug)
   b = lerp(m, lowerv, upperv, lb, ub)
   return round.((r, g, b), digits=6)
end

"""
    make_colorscheme(dict;
        length=100,
        category="",
        notes="")

Make a new ColorScheme from a dictionary of linear-segment information. Calls
`get_linear_segment_color(dict, n)` with `n` for every `length` value between 0 and 1.
"""
function make_colorscheme(dict::Dict;
        length=100,
        category="",
        notes="")
    cs = ColorScheme([RGB(get_linear_segment_color(dict, i)...)
        for i in range(0, stop=1, length=length)],
        category, notes)
    return cs
end

"""
    make_colorscheme(indexedlist;
        length=100,
        category="",
        notes="")

Make a ColorScheme using an 'indexed list' like this:

```
gist_rainbow = (
       (0.000, (1.00, 0.00, 0.16)),
       (0.030, (1.00, 0.00, 0.00)),
       (0.215, (1.00, 1.00, 0.00)),
       (0.400, (0.00, 1.00, 0.00)),
       (0.586, (0.00, 1.00, 1.00)),
       (0.770, (0.00, 0.00, 1.00)),
       (0.954, (1.00, 0.00, 1.00)),
       (1.000, (1.00, 0.00, 0.75))
)

make_colorscheme(gist_rainbow)
```

The first element of each item is the point on the color scheme.
"""
function make_colorscheme(indexedlist::Tuple;
        length=100,
        category="",
        notes="indexed list")
    cs = ColorScheme([RGB(get_indexed_list_color(indexedlist, i)...)
        for i in range(0, stop=1, length=length)],
        category, notes)
    return cs
end

"""
    make_colorscheme_new(f1::Function, f2::Function, f3::Function;
        model    = :RGB,
        length   = 100,
        category = "",
        notes    = "functional ColorScheme")

Make a ColorScheme using functions. Each function should take a value between 0
and 1 and return for that color component at each point on the ColorScheme,
depending on the color model.

The default color model is `:RGB`, and the functions should return values in the
appropriate range:

- f1 - [0.0 - 1.0]   - red
- f2 - [0.0 - 1.0]   - green
- f3 - [0.0 - 1.0]   - blue

For the `:HSV` color model:

- f1 - [0.0 - 360.0] - hue
- f2 - [0.0 - 1.0]   - saturataion
- f3 - [0.0 - 1.0]   - value (brightness)

For the `:LCHab` color model:

- f1 - [0.0 - 100.0] - luminance
- f2 - [0.0 - 100.0] - chroma
- f3 - [0.0 - 360.0] - hue
"""
function make_colorscheme(f1::Function, f2::Function, f3::Function;
        model    = :RGB,
        length   = 100,
        category = "",
        notes    = "functional ColorScheme")
    # output is always RGB for the moment
    cs = RGB[]
    if model == :LCHab
        clamp1 = (0.0, 100.0) #
        clamp2 = (0.0, 100.0) #
        clamp3 = (0.0, 360.0) # Hue is 0-360
    elseif model == :HSV
        clamp1 = (0.0, 360.0) # Hue is 0-360
        clamp2 = (0.0, 1.0) #
        clamp3 = (0.0, 1.0) #
    elseif model == :RGB
        clamp1 = (0.0, 1.0) #
        clamp2 = (0.0, 1.0) #
        clamp3 = (0.0, 1.0) #
    end
    counter = 0
    for i in range(0.0, stop=1.0, length=length)
        raw1, raw2, raw3 = f1(i), f2(i), f3(i)
        final1           = clamp(raw1, clamp1...)
        final2           = clamp(raw2, clamp2...)
        final3           = clamp(raw3, clamp3...)
        if model == :LCHab
            push!(cs, convert(RGB, LCHab(final1, final2, final3)))
        elseif model == :RGB
            push!(cs, RGB(final1, final2, final3))
        elseif model == :HSV
            push!(cs, convert(RGB, HSV(final1, final2, final3)))
        end
    end
    return ColorScheme(cs, category, notes)
end

end
