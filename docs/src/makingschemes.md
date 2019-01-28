# Making new colorschemes

There are a few functions that can make new ColorSchemes:

- make_linear_segment_colorscheme
- make_indexed_list_colorscheme
- make_functional_colorscheme

## Linearly-segmented colors

A linearly-segmented color dictionary looks like this:

```
hsv = Dict(:red =>    ((0., 1., 1.),
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
and third determine the color values. To create a new ColorScheme from this,
decide on a sampling rate, then call `get_linear_segment_color()` and keep the
sampled values.

```
using Colors, ColorSchemes

scheme = RGB[]

for i in 0:0.01:1
    push!(scheme, RGB(get_linear_segment_color(_hsv, i)...))
end

ColorScheme(scheme)
```

Make an image from this scheme:

```
using ColorSchemes, FileIO
img = colorscheme_to_image(ColorScheme(scheme), 450, 60)
save("/tmp/linseg.png", img)
```

!["linear segmented colorscheme"](assets/figures/linearsegmentedcolors.png)

```@docs
get_linear_segment_color
```

## Indexed-list color schemes

An 'indexed list' color scheme looks like this:

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
```

The first element in each is the point on the color scheme, the second specifies the RGB values at that point.

The `make_indexed_list_colorscheme(indexedlist)` function makes a new ColorScheme from an indexed list.

```
make_indexed_list_colorscheme(gist_rainbow)
```

## Functional color schemes

The colors in a 'functional' color scheme are produced by three functions that calculate the color values at each point on the scheme.

The `make_functional_colorscheme()` function takes three functions and applies them at each point on the colorscheme.

```
make_functional_colorscheme(sqrt, log, (n) -> n/2)
```
