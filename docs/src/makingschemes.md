```@setup drawscheme
using Luxor, Colors, ColorSchemes, ColorSchemeTools
function draw_rgb_levels(cs::ColorScheme, w=800, h=500, filename="/tmp/rgb-levels.svg")
    # This function is a quick hack to draw swatches and curves in a documenter pass.
    # The diagrams are merely illustrative, not 100% technically precise :(
    Drawing(w, h, filename)
    origin()
    background("white")
    setlinejoin("bevel")
    # three rows (thin, fat, thin), one wide column
    table = Table([h/6, 2h/3, h/6], w)
    l = length(cs.colors)
    bbox = BoundingBox(box(O, table.colwidths[1], table.rowheights[2], vertices=true)) * 0.85

    # axes and labels in main (second) cell of table
    @layer begin
        translate(table[2])
        setline(0.5)
        fontsize(7)
        box(bbox, :stroke)
        # horizontal lines
        div10 = boxheight(bbox)/10
        for (ylabel, yy) in enumerate(boxtopcenter(bbox).y:div10:boxbottomcenter(bbox).y)
            sethue("grey85")
            rule(Point(0, yy), boundingbox=bbox)
            sethue("grey55")
            text(string((11 - ylabel)/10), Point(boxbottomleft(bbox).x - 10, yy), halign=:right, valign=:middle)
        end
        # vertical lines
        div10 = boxwidth(bbox)/10
        for (xlabel, xx) in enumerate(boxtopleft(bbox).x:div10:boxtopright(bbox).x)
            sethue("grey85")
            rule(Point(xx, 0), π/2, boundingbox=bbox)
            sethue("grey55")
            text(string((xlabel - 1)/10), Point(xx, boxbottomleft(bbox).y + 10), halign=:center, valign=:bottom)
        end        
    end

    # middle, show 'curves'
    # 'curves'
    # run through color levels in scheme and sample/quantize
    @layer begin
        translate(table[2])
        redline = Point[]
        greenline = Point[]
        blueline = Point[]
        verticalscale=boxheight(bbox)
        stepping = 0.0025
        # TODO better way to examine quantized color values
        for i in 0:stepping:1
            swatch = convert(Int, round(rescale(i, 0, 1, 1, l)))
            c = cs[swatch]
            r = red(c)
            g = green(c)
            b = blue(c)
            x = rescale(i, 0, 1, -boxwidth(bbox)/2, boxwidth(bbox)/2)
            push!(redline, Point(x, boxbottomcenter(bbox).y - verticalscale * r))
            push!(greenline, Point(x, boxbottomcenter(bbox).y - verticalscale * g))
            push!(blueline, Point(x, boxbottomcenter(bbox).y - verticalscale * b))        
        end
        # the idea to make the lines different weights to assist reading overlaps may not be a good one
        setline(1)
        sethue("blue")
        poly(blueline, :stroke)
        setline(0.8)
        sethue("red")
        poly(redline, :stroke)
        setline(0.7)
        sethue("green")
        poly(greenline, :stroke)
    end
    # top tile, swatches
    @layer begin
        translate(table[1])
        # draw in a single pane
        panes = Tiler(boxwidth(bbox), table.rowheights[1], 1, 1, margin=0)
        panewidth = panes.tilewidth
        paneheight = panes.tileheight
        # draw the swatches
        swatchwidth = panewidth/l
        for (i, p) in enumerate(cs.colors)
            swatchcenter = Point(boxtopleft(bbox).x - swatchwidth/2 + (i * swatchwidth) , O.y)
            sethue(p)
            box(swatchcenter, swatchwidth - 1, table.rowheights[1]/2 - 1,  :fill)
            if colordiff(p, colorant"white") < 1
                @layer begin
                    setline(0.4)
                    sethue("grey70")
                    box(swatchcenter, swatchwidth - 1, table.rowheights[1]/2 - 1,  :stroke)
                end
            end
        end
    end
    # third tile, continuous sampling
    @layer begin
        translate(table[3])
        # draw blend
        stepping = 0.0005
        boxw = panewidth * stepping
        for i in 0:stepping:1
            c = get(cs, i)
            sethue(c)
            xpos = rescale(i, 0, 1, O.x - panewidth/2, O.x + panewidth/2 - boxw)
            box(Point(xpos + boxw/2, O.y), boxw, table.rowheights[3]/2, :fillstroke)
        end
    end
    finish()
    nothing
end
```

# Making new colorschemes

To make new ColorSchemes, you can quickly build arrays of colors; refer the ColorSchemes.jl documentation. You can also use the ColorSchemeTools function `make_colorscheme()`, and supply information about the color sequences you want.

The following formats are possible:

- a dictionary of linear segments
- an 'indexed list' of RGB values
- three Julia functions that generate values between 0 and 1 for the RGB levels

## Linearly-segmented colors

A linearly-segmented color dictionary looks like this:

```
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

```
:red => (
         ...,
         (p1, a, b),
         (p2, c, d),
         ...
         )
```

If `a` and `b` (or `c` and `d`) aren't the same, the color will abruptly jump. Notice that the very first `a` and the very last `d` aren't used.

To create a new ColorScheme from a suitable dictionary in this format, run `make_colorscheme()`.

```
using Colors, ColorSchemes
scheme = make_colorscheme(dict)
```

By plotting the color components separately it's possible to see how the curves change. This diagram shows both the defined color levels as swatches along the top, and a continuously-sampled image below:

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
draw_rgb_levels(scheme, 800, 200, "assets/figures/curves.svg") # hide
nothing # hide
```

!["showing linear segmented colorscheme"](assets/figures/curves.svg)

## Indexed-list color schemes

The data to define an 'indexed list' color scheme looks like this:

```
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

The `make_colorscheme(indexedlist)` function makes a new ColorScheme from such an indexed list.

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
draw_rgb_levels(terrain, 800, 200, "assets/figures/terrain.svg") # hide
nothing # hide
```

!["indexed lists scheme"](assets/figures/terrain.svg)

## Functional color schemes

The colors in a 'functional' color scheme are produced by three functions that calculate the color values at each point on the scheme.

The `make_colorscheme()` function applies the first supplied function at each point on the colorscheme for the red values, the second function for the green values, and the third for the blue. You can use defined functions or supply anonymous ones.

Values produced by the functions are clamped to 0.0 and 1.0 before they're converted to RGB values.

### Examples

The first example returns a smooth black to white gradient, because the `identity()` function gives back as good as it gets.

```@example drawscheme
fscheme = make_colorscheme(identity, identity, identity)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme1.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme1.svg)

The next example uses the `sin()` function on values from 0 to π to control the red, and the `cos()` function from 0 to π to control the blue. The green channel is flat-lined.

```@example drawscheme
fscheme = make_colorscheme(n -> sin(n*π), n -> 0, n -> cos(n*π))
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme2.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme2.svg)

You can generate stepped gradients by controlling the numbers. Here, each point on the scheme is nudged to the nearest multiple of 0.1.

```@example drawscheme
fscheme = make_colorscheme(
        n -> round(n, digits=1),
        n -> round(n, digits=1),
        n -> round(n, digits=1), length=10)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme3.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme3.svg)

The next example sinusoidally sends the red channel from black to red and back again.

```@example drawscheme
fscheme = make_colorscheme(n -> sin(n * π), n -> 0, n -> 0)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme4.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme4.svg)

The next example produces a striped colorscheme as the rippling sine waves continually change phase:

```@example drawscheme
ripple7(n)  = sin(π * 7n)
ripple13(n) = sin(π * 13n)
ripple17(n) = sin(π * 17n)
fscheme = make_colorscheme(ripple7, ripple13, ripple17, length=80)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme5.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme5.svg)

If you're creating a scheme by generating LCHab colors, your functions should convert values between 0 and 1 to values between 0 and 100 (luminance and chroma) or 0 to 360 (hue).

```@example drawscheme

f1(n) = 180 + 180sin(2π * n)
f2(n) = 50 + 20(0.5 - abs(n - 0.5))
fscheme = make_colorscheme(n -> 50, f2, f1,
    length=80,
    model=:LCHab)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme6.svg") # hide
nothing # hide
```

!["functional color schemes"](assets/figures/funcscheme6.svg)


```@docs
make_colorscheme
get_linear_segment_color
```
