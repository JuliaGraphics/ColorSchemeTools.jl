```@setup drawscheme
    using Luxor, Colors, ColorSchemes, ColorSchemeTools

    function draw_rgb_levels(cs::ColorScheme, w, h, filename)
    Drawing(w, h, filename)
    origin()
    background("white")

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
        div10 = boxheight(bbox)/10
        for (ylabel, yy) in enumerate(boxtopcenter(bbox).y:div10:boxbottomcenter(bbox).y)
            rule(Point(0, yy), boundingbox=bbox)
            text(string((11 - ylabel)/10), Point(boxbottomleft(bbox).x - 10, yy), halign=:right, valign=:middle)
        end
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
        poly(redline, :stroke)
        sethue("green")
        poly(greenline, :stroke)
        sethue("blue")
        poly(blueline, :stroke)
    end

    # second tile, swatches
    @layer begin
        translate(table[2])
        # draw in a single pane, to get margins etc.
        panes = Tiler(boxwidth(bbox), table.rowheights[2], 1, 1, margin=5)
        panewidth = panes.tilewidth
        paneheight = panes.tileheight

        # draw the swatches
        swatchwidth = panewidth/l
        for (i, p) in enumerate(cs.colors)
            sethue(p)
            box(Point(O.x - panewidth/2 + (i * swatchwidth) - swatchwidth/2, O.y #- (paneheight/3)
            ),
                swatchwidth, table.rowheights[2]/2, :fillstroke)
        end
    end
    # third tile
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

There are a few functions that can make new ColorSchemes:

- `make_linear_segment_colorscheme()`
- `make_indexed_list_colorscheme()`
- `make_functional_colorscheme()`

## Linearly-segmented colors

A linearly-segmented color dictionary looks like this:

```
hsvdict = Dict(:red => ((0., 1., 1.),
                       (0.158730, 1.000000, 1.000000),
                       (0.174603, 0.968750, 0.968750),
                       (0.333333, 0.031250, 0.031250),
                       (0.349206, 0.000000, 0.000000),
                       (0.666667, 0.000000, 0.000000),
                       (0.682540, 0.031250, 0.031250),
                       (0.841270, 0.968750, 0.968750),
                       (0.857143, 1.000000, 1.000000),
                       (1.0, 1.0, 1.0)),
             :green => ((0., 0., 0.),
                       (0.158730, 0.937500, 0.937500),
                       (0.174603, 1.000000, 1.000000),
                       (0.507937, 1.000000, 1.000000),
                       (0.666667, 0.062500, 0.062500),
                       (0.682540, 0.000000, 0.000000),
                       (1.0, 0., 0.)),
             :blue =>  ((0., 0., 0.),
                       (0.333333, 0.000000, 0.000000),
                       (0.349206, 0.062500, 0.062500),
                       (0.507937, 1.000000, 1.000000),
                       (0.841270, 1.000000, 1.000000),
                       (0.857143, 0.937500, 0.937500),
                       (1.0, 0.09375, 0.09375)))
```

The first number in each tuple for each color increases from 0 to 1, the second
and third determine the color values. (TODO - how exactly?)

To create a new ColorScheme from this, call `make_linear_segment_colorscheme()`.

```
using Colors, ColorSchemes
scheme = make_linear_segment_colorscheme(hsvdict)
```

Save an image of this:

```
using ColorSchemes, FileIO
img = colorscheme_to_image(ColorScheme(scheme), 450, 60)
save("/tmp/linseg.png", img)
```

!["linear segmented colorscheme"](assets/figures/linearsegmentedcolors.png)

By plotting the color components separately it's possible to see how the curves change. This is what the `hsv` scheme looks like:

```@example drawscheme
draw_rgb_levels(ColorSchemes.hsv, 800, 200, "assets/figures/hsvcurves.svg") #hide
nothing # hide
```

!["hsv linear segmented colorscheme"](assets/figures/hsvcurves.svg)

```@docs
get_linear_segment_color
```

## Indexed-list color schemes

An 'indexed list' color scheme looks like this:

```
_terrain = (
        (0.00, (0.2, 0.2, 0.6)),
        (0.15, (0.0, 0.6, 1.0)),
        (0.25, (0.0, 0.8, 0.4)),
        (0.50, (1.0, 1.0, 0.6)),
        (0.75, (0.5, 0.36, 0.33)),
        (1.00, (1.0, 1.0, 1.0)))
```

The first element in each is the point on the color scheme, the second specifies the RGB values at that point.

The `make_indexed_list_colorscheme(indexedlist)` function makes a new ColorScheme from an indexed list.

```
make_indexed_list_colorscheme(_terrain)
```

```@example drawscheme
_terrain = (
        (0.00, (0.2, 0.2, 0.6)),
        (0.15, (0.0, 0.6, 1.0)),
        (0.25, (0.0, 0.8, 0.4)),
        (0.50, (1.0, 1.0, 0.6)),
        (0.75, (0.5, 0.36, 0.33)),
        (1.00, (1.0, 1.0, 1.0)))
terrain = make_indexed_list_colorscheme(_terrain)
draw_rgb_levels(terrain, 800, 200, "assets/figures/terrain.svg") # hide
nothing # hide
```

!["indexed lists scheme"](assets/figures/terrain.svg)

```@docs
make_indexed_list_colorscheme
```

## Functional color schemes

The colors in a 'functional' color scheme are produced by three functions that calculate the color values at each point on the scheme.

The `make_functional_colorscheme()` function takes three functions and applies them at each point on the colorscheme.

```@example drawscheme
fscheme = make_functional_colorscheme(sqrt, sin, cos)
draw_rgb_levels(fscheme, 800, 200, "assets/figures/funcschemecurves.svg") # hide
nothing # hide
```

!["functional color schemes"](assets/figures/funcschemecurves.svg)

```@docs
make_functional_colorscheme
```
