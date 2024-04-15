```@setup drawscheme
using ColorSchemeTools
include(joinpath(dirname(pathof(ColorSchemeTools)), "..", "docs/", "displayschemes.jl"))
#=
this provides defines:
- draw_rgb_levels(cs::ColorScheme, w=800, h=500, filename="/tmp/rgb-levels.svg")
- draw_transparent(cs::ColorScheme, csa::ColorScheme, w=800, h=500, filename="/tmp/transparency-levels.svg")
draw_lightness_swatch(cs::ColorScheme, width = 800, height = 150; name = "")
=# 
```
#  Equalizing color constrasts

The `equalize()` function equalizes the contrasts between colors of a colorscheme.

!!! note

    This function is derived from the work of Peter Kovesi in 
    [PerceptualColorMaps](https://github.com/peterkovesi/PerceptualColourMaps.jl). You can find the original code there.
    It's copied here because Peter has retired from coding, and the package is not being maintained.

In the following example, the first image is the original colorscheme sampled 101 times. The second image shows the colors after they've been passed through `equalize()`.

```julia
cs = ColorScheme([colorant"yellow", colorant"red"]) 
# sample 
origcolors = get(cs, 0:0.01:1)
# return a new colorscheme based on the colors in cs 
newcs = equalize(origcolors) 
# sample
newcolors = get(newcs, 0:0.01:1)
```

```@example drawscheme
cs = ColorScheme([colorant"yellow", colorant"red"]) # hide
# linear interpolation, not perceptually uniform # hide
origcolors = get(cs, 0:0.01:1) # hide
```

```@example drawscheme
cs = ColorScheme([colorant"yellow", colorant"red"]) # hide
# linear interpolation, not perceptually uniform # hide
origcolors = get(cs, 0:0.01:1)  # hide
# generate corrected colormap: # hide
newcs = equalize(origcolors, colormodel=:RGB, sigma=0.0, formula="CIEDE2000", W=[1, 0, 0]) # hide
newcolors = get(newcs, 0:0.01:1) # hide
```

You should be able to see the difference between the two images: the original
colorscheme (top) uses simple linear interpolation, the modified scheme (below)
shows the adjusted scheme, with smoother transitions in the red shades.

# Testing a colorscheme with `sineramp()`

Ideally, for a colorscheme to be effective, the perceptual contrast along the
colors should be constant. Some colorschemes are better than others!

Try testing your favourite colorscheme on the image generated with `sineramp()`. This function generates an array where the values consist of a sine wave superimposed on a ramp function. The amplitude of the sine wave is modulated from its full value at the top
of the array to 0 at the bottom.

When a colorscheme is used to render the array as a color image, we're hoping to see the sine wave uniformly visible across the image from left to right. We also want the contrast level, the distance down the image at which the sine wave remains discernible,
to be uniform across the image. At the very bottom of the image, where
the sine wave amplitude is 0, we just have a linear ramp which simply
reproduces the colors in the colorscheme. Here the underlying data is a
featureless ramp, so we should not perceive any identifiable features
across the bottom of the image.

Here's a comparison between the `jet` and the `rainbow_bgyr_35_85_c72_n256` colorschemes:

```@example
using Images, ColorSchemes, ColorSchemeTools # hide
scheme = ColorSchemes.jet
img = Gray.(sineramp(150, 800, amplitude = 12.5, wavelength=8, p=2)) 
cimg = zeros(RGB, 150, 800)
for e in eachindex(img)
    cimg[e] = get(scheme, img[e])
end
cimg
```

```@example
using Images, ColorSchemes, ColorSchemeTools # hide
scheme = ColorSchemes.rainbow_bgyr_35_85_c72_n256
img = Gray.(sineramp(150, 800, amplitude = 12.5, wavelength=8, p=2)) 
cimg = zeros(RGB, 150, 800)
for e in eachindex(img)
    cimg[e] = get(scheme, img[e])
end
cimg
```

You can hopefully see that the `jet` image is patchy; the `rainbow_bgyr_35_85_c72_n256` shows the sinuous rippling consistently.

#  Options for `equalize()`

The `equalize` function's primary use is for the correction of colorschemes. 

The perceptual contrast is very much dominated by the contrast in colour lightness
values along the map. This function attempts to equalise the chosen perceptual
contrast measure along a colorscheme by stretching and/or compressing sections
of the colorscheme.

There are limitations to what this function can correct.  When applied to some colorschemes such as `jet`, `hsv`, and `cool`, you might see colour discontinuity artifacts, because these colorschemes have segments that are nearly constant in lightness. 

However, the function can succesfully fix up `hot`, `winter`, `spring` and `autumn`
colorschemes. If you do see colour discontinuities in the resulting colorscheme,
try changing W from [1, 0, 0] to [1, 1, 1], or some intermediate weighting of
[1, 0.5, 0.5], say.

The `equalize()` function takes either a ColorScheme argument or an array of colors. The following keyword arguments are available:

- `colormodel` is `:RGB` or `:LAB` indicating the type of data (use `:RGB` unless the ColorScheme contains LAB color definitions)

- `formula` is "CIE76" or "CIEDE2000"

- `W` is 3-vector of weights to be applied to the lightness, chroma and hue components of the difference equation

- `sigma` is an optional Gaussian smoothing parameter

- `cyclic` is a Boolean flag indicating whether the colormap is cyclic. This affects how smoothing is applied at the end points.

## Formulae

The CIE76 and CIEDE2000 colour difference formulae were developed for
much lower spatial frequencies than we are typically interested in.
Neither is ideal for our application. The main thing to note is that
at *fine* spatial frequencies perceptual contrast is dominated by
*lightness* difference, chroma and hue are relatively unimportant.

Neither CIE76 or CIEDE2000 difference measures are ideal
for the high spatial frequencies that we are interested in.  Empirically I
find that CIEDE2000 seems to give slightly better results on colormaps where
there is a significant lightness gradient (this applies to most colormaps).
In this case you would be using a weighting vector W = [1, 0, 0].  For
isoluminant, or low lightness gradient colormaps where one is using a
weighting vector W = [1, 1, 1] CIE76 should be used as the CIEDE2000 chroma
correction is inapropriate for the spatial frequencies we are interested in.

# The Weighting vector W

The CIEDE2000 colour difference formula incorporates the
scaling parameters kL, kC, kH in the demonimator of the lightness, chroma, and
hue difference components respectively. The 3 components of W correspond to
the reciprocal of these 3 parameters. (I do not know why they chose to put
kL, kC, kH in the denominator. If you wanted to ignore, say, the chroma
component you would have to set kC to Inf, rather than setting W[2] to 0 which
seems more sensible to me). If you are using CIE76 then W[2] amd W[3] are
applied to the differences in a and b.  In this case you should ensure W[2] =
W[3].  

In general, for the spatial frequencies of interest to us, lightness
differences are overwhelmingly more important than chroma or hue and W should
be set to [1, 0, 0]

For colormaps with a significant range of lightness, use:

- formula = "CIE76" or "CIEDE2000"

- W = [1, 0, 0] Only correct for lightness

- sigma = 5 - 7

For isoluminant or low lightness gradient colormaps use:

- formula = "CIE76"

- W = [1, 1, 1]  Correct for colour and lightness
 
- sigma = 5 - 7

#  Smoothing parameter sigma

The output will have lightness values of constant slope magnitude.
However, it is possible that the sign of the slope may change, for example at
the midpoint of a bilateral colorscheme.  This slope discontinuity of lightness
can induce a false apparent feature in the colorscheme.  A smaller effect is
also occurs for slope discontinuities in a and b.  For such colorschemes it can
be useful to introduce a small amount of _smoothing of the Lab values to soften
the transition of sign in the slope to remove this apparent feature.  However
in doing this one creates a small region of suppressed luminance contrast in
the colorscheme which induces a 'blind spot' that compromises the visibility of
features should they fall in that data range.  ccordingly the smoothing
should be kept to a minimum. A value of sigma in the range 5 to 7 in a 256
element colorscheme seems about right.  As a guideline sigma should not be more
than about 1/25 of the number of entries in the colormap, preferably less.


Reference: Peter Kovesi. Good ColorMaps: How to Design Them. [arXiv:1509.03700 [cs.GR] 2015](https://arXiv:1509.03700)
