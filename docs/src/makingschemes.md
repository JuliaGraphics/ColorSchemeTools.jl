```@setup drawscheme

using ColorSchemeTools

include(joinpath(dirname(pathof(ColorSchemeTools)), "..", "docs/", "displayschemes.jl"))

#=

ColorSchemeTools/docs/displayschemes.jl defines:

- draw_rgb_levels(cs::ColorScheme, w=800, h=500, filename="/tmp/rgb-levels.svg")

- draw_transparent(cs::ColorScheme, csa::ColorScheme, w=800, h=500, filename="/tmp/transparency-levels.svg")

=# 
```
# Making colorschemes

!!! note

    The diagrams in this section show: the colors of a colorscheme as individual swatches along the top; the changing RGBA curves in the middle; and a continuously-sampled gradient below.

## Making simple colorschemes

Colors.jl provides a method for `range()` that accepts colorants:

```@example drawscheme
using ColorSchemes, Colors # hide
cs = ColorScheme(range(RGB(1, 0, 0), stop = colorant"blue", length=15),
        "gradient", "red to blue 15")
draw_rgb_levels(cs, 800, 200, :svg) # hide
```

You can make a new colorscheme by building an array of colors.

The ColorSchemeTools function [`make_colorscheme()`](@ref) lets you build more elaborate colorschemes. You can supply the color specifications using different methods, depending on the arguments you supply:

- a list of colors and a number specifying the length
- a dictionary of linear segments
- an 'indexed list' of RGB values
- a group of Julia functions that generate values between 0 and 1 for the RGB levels

## List of colors

Given a list of colors, use [`make_colorscheme()`](@ref) to create a new colorscheme with `n` steps.

For example, given an array of various colorants:

```
roygbiv = [
    colorant"red",
    colorant"orange",
    colorant"yellow",
    colorant"green",
    colorant"blue",
    colorant"indigo",
    colorant"violet"
]
```

you can use `make_colorscheme(cols, 10)` to create a colorscheme with 10 steps:

```@example drawscheme
roygbiv = [ # hide
    colorant"red", # hide
    colorant"orange", # hide
    colorant"yellow", # hide
    colorant"green", # hide
    colorant"blue", # hide
    colorant"indigo", # hide
    colorant"violet" # hide
] # hide
scheme = make_colorscheme(roygbiv, 10)
draw_rgb_levels(scheme, 800, 200, :svg) # hide
```

If you increase the number of steps, the interpolations are smoother. Here it is with 200 steps (shown in the top bar):

```@example drawscheme
roygbiv = [ # hide
    colorant"red", # hide
    colorant"orange", # hide
    colorant"yellow", # hide
    colorant"green", # hide
    colorant"blue", # hide
    colorant"indigo", # hide
    colorant"violet" # hide
] # hide
scheme = make_colorscheme(roygbiv, 200)
draw_rgb_levels(scheme, 800, 200, :svg)
```

You can supply the colors in any format, as long as it's a Colorant:

```@example drawscheme
cols = Any[
    RGB(0, 0, 1),
    Gray(0.5),
    HSV(50., 0.7, 1.),
    Gray(0.4),
    LCHab(54, 105, 40),
    HSV(285., 0.9, 0.8),
    colorant"#FFEEFF",
    colorant"hotpink",
]
scheme = make_colorscheme(cols, 8)
draw_rgb_levels(scheme, 800, 200, :svg)
```

The `Any` array was necessary only because of the presence of the `Gray(0..5)` element. If all the elements are colorants, you can use `[]` or `Colorant[]`.

## Linearly-segmented colors

A linearly-segmented color dictionary looks like this:

```julia
cdict = Dict(:red   => ((0.0,  0.0,  0.0),
                        (0.5,  1.0,  1.0),
                        (1.0,  1.0,  1.0)),
             :green => ((0.0,  0.0,  0.0),
                        (0.25, 0.0,  0.0),
                        (0.75, 1.0,  1.0),
                        (1.0,  1.0,  1.0)),
             :blue  => ((0.0,  0.0,  0.0),
                        (0.5,  0.0,  0.0),
                        (1.0,  1.0,  1.0)))
```

This specifies that red increases from 0 to 1 over the bottom half, green does the same over the middle half, and blue over the top half.

The triplets _aren't_ RGB values... For each channel, the first number in each tuple are points on the 0 to 1 brightness scale, and should gradually increase. The second and third values determine the intensity values at that point.

The change of color between point `p1` and `p2` is defined by `b` and `c`:

```julia
:red => (
         ...,
         (p1, a, b),
         (p2, c, d),
         ...
         )
```

If `a` and `b` (or `c` and `d`) aren't the same, the color will abruptly jump. Notice that the very first `a` and the very last `d` aren't used.

To create a new colorscheme from a suitable dictionary in this format, run `make_colorscheme()`.

```@example drawscheme
cdict = Dict(:red  => ((0.0,  0.0,  0.0),
                       (0.5,  1.0,  1.0),
                       (1.0,  1.0,  1.0)),
            :green => ((0.0,  0.0,  0.0),
                       (0.25, 0.0,  0.0),
                       (0.75, 1.0,  1.0),
                       (1.0,  1.0,  1.0)),
            :blue =>  ((0.0,  0.0,  0.0),
                       (0.5,  0.0,  0.0),
                       (1.0,  1.0,  1.0))) # hide
scheme = make_colorscheme(cdict)
draw_rgb_levels(scheme, 800, 200, :svg) # hide
```

## Indexed-list color schemes

The data to define an 'indexed list' colorscheme looks like this:

```julia
terrain = (
           (0.00, (0.2, 0.2,  0.6)),
           (0.15, (0.0, 0.6,  1.0)),
           (0.25, (0.0, 0.8,  0.4)),
           (0.50, (1.0, 1.0,  0.6)),
           (0.75, (0.5, 0.36, 0.33)),
           (1.00, (1.0, 1.0,  1.0))
          )
```

The first item of each element is the location between 0 and 1, the second specifies the RGB values at that point.

The `make_colorscheme(indexedlist)` function makes a new colorscheme from such an indexed list.

Use the `length` keyword to specify how many colors are used in the colorscheme.

For example:

```@example drawscheme
terrain_data = (
        (0.00, (0.2, 0.2, 0.6)),
        (0.15, (0.0, 0.6, 1.0)),
        (0.25, (0.0, 0.8, 0.4)),
        (0.50, (1.0, 1.0, 0.6)),
        (0.75, (0.5, 0.36, 0.33)),
        (1.00, (1.0, 1.0, 1.0)))
terrain = make_colorscheme(terrain_data, length = 50)
draw_rgb_levels(terrain, 800, 200, :svg)
```

## Functional color schemes

The colors in a ‘functional’ colorscheme are produced by three functions that calculate the color values at each point on the colorscheme.

The [`make_colorscheme()`](@ref) function applies the first supplied function at each point on the colorscheme for the red values, the second function for the green values, and the third for the blue. You can use defined functions or supply anonymous ones.

Values produced by the functions are clamped to 0.0 and 1.0 before they’re converted to RGB values.

### Examples

The first example returns a smooth black to white gradient, because the `identity()` function gives back as good as it gets.

```@example drawscheme
fscheme = make_colorscheme(identity, identity, identity)
draw_rgb_levels(fscheme, 800, 200, :svg)
```

The next example uses the `sin()` function on values from 0 to π to control the red, and the `cos()` function from 0 to π to control the blue. The green channel is flat-lined.

```@example drawscheme
fscheme = make_colorscheme(n -> sin(n*π), n -> 0, n -> cos(n*π))
draw_rgb_levels(fscheme, 800, 200, :svg)
```

You can generate stepped gradients by controlling the numbers. Here, each point on the scheme is nudged to the nearest multiple of 0.1.

```@example drawscheme
fscheme = make_colorscheme(
        n -> round(n, digits=1),
        n -> round(n, digits=1),
        n -> round(n, digits=1), length=10)
draw_rgb_levels(fscheme, 800, 200, :svg)
```

The next example sinusoidally sends the red channel from black to red and back again.

```@example drawscheme
fscheme = make_colorscheme(n -> sin(n * π), n -> 0, n -> 0)
draw_rgb_levels(fscheme, 800, 200, :svg)
```

The next example produces a striped colorscheme as the rippling sine waves continually change phase:

```@example drawscheme
ripple7(n)  = sin(π * 7n)
ripple13(n) = sin(π * 13n)
ripple17(n) = sin(π * 17n)
fscheme = make_colorscheme(ripple7, ripple13, ripple17, length=80)
draw_rgb_levels(fscheme, 800, 200, :svg)
```

If you're creating a scheme by generating LCHab colors, your functions should convert values between 0 and 1 to values between 0 and 100 (luminance and chroma) or 0 to 360 (hue).

```@example drawscheme

f1(n) = 180 + 180sin(2π * n)
f2(n) = 50 + 20(0.5 - abs(n - 0.5))
fscheme = make_colorscheme(n -> 50, f2, f1,
    length=80,
    model=:LCHab)
draw_rgb_levels(fscheme, 800, 200, :svg)
```

## Alpha opacity colorschemes

Usually, colorschemes are RGB values with no alpha values.
Use [`add_alpha()`](@ref) to add alpha opacity values to the colors in the colorschemes. 

In the illustrations, the top row shows the original colorscheme, the bottom row shows the modified colorscheme drawn over a checkerboard pattern to show the alpha opacity.

You can make a new colorscheme where every color now has a specific alpha opacity value:

```@example drawscheme
cs = ColorSchemes.PRGn_10
csa = add_alpha(cs, 0.8)
draw_transparent(cs, csa, 800, 200, :svg) # hide
```
```@example drawscheme
cs = ColorSchemes.PRGn_10 # hide
csa = add_alpha(cs, 0.8)  # hide
draw_rgb_levels(csa, 800, 200, :svg) # hide
```

You can specify alpha values using a range:

```@example drawscheme
cs = ColorSchemes.lisbon10
csa = add_alpha(cs, 0.3:0.1:1.0)
draw_transparent(cs, csa, 800, 200, :svg)  # hide
```
```@example drawscheme
cs = ColorSchemes.lisbon10 # hide
csa = add_alpha(cs, 0.3:0.1:1.0) # hide
draw_rgb_levels(csa, 800, 200, :svg) # hide
```

Or you can specify alpha values using a function that returns a value for every value between 0 and 1. In the next example the opacity varies from 1.0 to 0.0 and back to 1.0 again, as the colorscheme index goes from 0 to 1; at point 0.5, `abs(cos(0.5 * π))` is 0.0, so the colorscheme is completely transparent at that point.

```@example drawscheme
cs = ColorSchemes.PuOr
csa = add_alpha(cs, (n) -> abs(cos(n * π)))
draw_transparent(cs, csa, 700, 200, :svg)
```
```@example drawscheme
cs = ColorSchemes.PuOr # hide
csa = add_alpha(cs, (n) -> abs(cos(n * π))) # hide
draw_rgb_levels(csa, 800, 200, :svg) # hide
```
