```@setup drawscheme
    using Luxor, Colors, ColorSchemes, ColorSchemeTools

    function draw_rgb_levels(cs::ColorScheme, w, h, filename)
    Drawing(w, h, filename)
    origin()
    background("white")
    setlinejoin("bevel")
    # three rows, one column
    table = Table([2h/3, h/6, h/6], w)

    # top cell

    # axes and labels
    @layer begin
        translate(table[1])
        bbox = BoundingBox(box(O, table.colwidths[1], table.rowheights[1], vertices=true)) * 0.8
        setline(0.5)
        fontsize(7)
        sethue("grey80")
        box(bbox, :stroke)
        # horizontal lines
        div10 = boxheight(bbox)/10
        for (ylabel, yy) in enumerate(boxtopcenter(bbox).y:div10:boxbottomcenter(bbox).y)
            rule(Point(0, yy), boundingbox=bbox)
            text(string((11 - ylabel)/10), Point(boxbottomleft(bbox).x - 10, yy), halign=:right, valign=:middle)
        end
        # vertical lines
        div10 = boxwidth(bbox)/10
        for (xlabel, xx) in enumerate(boxtopleft(bbox).x:div10:boxtopright(bbox).x)
            rule(Point(xx, 0), π/2, boundingbox=bbox)
            text(string((xlabel - 1)/10), Point(xx, boxbottomleft(bbox).y + 10), halign=:center, valign=:bottom)
        end        
    end
    # 'curves'
    @layer begin
        translate(table[1])
        setline(1.5)
        l = length(cs.colors)
        redline = Point[]
        greenline = Point[]
        blueline = Point[]
        verticalscale=boxheight(bbox)
        for n in 1:l
            x = rescale(n, 1, l, -boxwidth(bbox)/2, boxwidth(bbox)/2)
            r = red(cs.colors[n])
            g = green(cs.colors[n])
            b = blue(cs.colors[n])
            push!(redline, Point(x, boxbottomcenter(bbox).y - verticalscale * r))
            push!(greenline, Point(x, boxbottomcenter(bbox).y - verticalscale * g))
            push!(blueline, Point(x, boxbottomcenter(bbox).y - verticalscale * b))
        end
        sethue("red")
        prettypoly(redline, :stroke, () -> circle(O, 1.2, :fill))
        sethue("green")
        prettypoly(greenline, :stroke, () -> circle(O, 1.2, :fill))
        sethue("blue")
        prettypoly(blueline, :stroke, () -> circle(O, 1.2, :fill))
    end

    # second tile, swatches
    @layer begin
        translate(table[2])
        # draw in a single pane
        panes = Tiler(boxwidth(bbox), table.rowheights[2], 1, 1)
        panewidth = panes.tilewidth
        paneheight = panes.tileheight

        # draw the swatches
        swatchwidth = panewidth/l
        for (i, p) in enumerate(cs.colors)
            sethue(p)
            box(Point(O.x - panewidth/2 + ((i - 1) * swatchwidth) - swatchwidth/2, O.y), swatchwidth, table.rowheights[2]/2, :fillstroke)
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
    end
    nothing
```

# Making new colorschemes

To make new ColorSchemes, you can use `make_colorscheme()`, and supply information about the color sequences in various formats:

- linearly-segmented dictionary
- 'indexed list'
- defined by three functions

## Linearly-segmented colors

A linearly-segmented color dictionary looks like this:

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

The first number in each tuple for each color increases from 0 to 1, the second
and third determine the color values. (TODO - how exactly?)

To create a new ColorScheme from a suitable dictionary, call `make_colorscheme()`.

```
using Colors, ColorSchemes
scheme = make_colorscheme(dict)
```

By plotting the color components separately it's possible to see how the curves change. This diagram shows both the defined color levels and a continuously-sampled image below it:

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

If you want to save an image of a ColorScheme, use `colorscheme_to_image()`:

```
using ColorSchemes, ColorSchemeTools, FileIO
img = colorscheme_to_image(ColorScheme(scheme), 450, 60)
save("/tmp/linseg.png", img)
```

```@docs
get_linear_segment_color
```

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
terrain = make_colorscheme(terrain_data, length = 20)
draw_rgb_levels(terrain, 800, 200, "assets/figures/terrain.svg") # hide
nothing # hide
```

!["indexed lists scheme"](assets/figures/terrain.svg)

## Functional color schemes

The colors in a 'functional' color scheme are produced by three functions that calculate the color values at each point on the scheme.

The `make_colorscheme()` function applies the first supplied function at each point on the colorscheme for the red values, the second function for the green values, and the third for the blue. You can use defined functions or supply anonymous ones.

### Examples

This example returns a smooth black to white gradient, because the `identity()` function gives back as good as it gets.

```@example drawscheme
fscheme = make_colorscheme(identity, identity, identity)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme1.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme1.svg)

This next example uses the `sin()` function on values from 0 to π to control the red, and the `cos()` function from 0 to π to control the blue.

```@example drawscheme
fscheme = make_colorscheme((n) -> sin(n*π), (n) -> 0, (n) -> cos(n*π))
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme2.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme2.svg)

You can generate stepped gradients by controlling the numbers. Here, each point on the scheme is nudged to the nearest multiple of 0.1.

```@example drawscheme
fscheme = make_colorscheme(
        (n) -> round(n, digits=1),
        (n) -> round(n, digits=1),
        (n) -> round(n, digits=1), length=10)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme3.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme3.svg)

This example sends the red channel from black to red and back again.

```@example drawscheme
fscheme = make_colorscheme(n -> sin(n * π), (n) -> 0, (n) -> 0)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme4.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme4.svg)

This example produces a stripey colorscheme as the rippling sine waves continually change phase:

```@example drawscheme
ripple7(n) = sin(π * 7n)
ripple13(n) = sin(π * 13n)
ripple17(n) = sin(π * 17n)
fscheme = make_colorscheme(ripple7, ripple13, ripple17, length=80)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcscheme5.svg") # hide
nothing # hide
```
!["functional color schemes"](assets/figures/funcscheme5.svg)


```@docs
make_colorscheme
```
