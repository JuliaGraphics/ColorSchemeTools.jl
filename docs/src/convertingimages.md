# Converting images

## Convert image from one scheme to another

Using `getinverse()` it's possible to convert an image from one colorscheme to another.

`convert_to_scheme(cscheme, img)` returns a new image in which each pixel from the provided image is mapped to its closest matching color in the provided scheme.

```
using FileIO
# image created in the ColorSchemes documentation
img = load("ColorSchemeTools/docs/src/assets/figures/heatmap1.png")
```

!["heatmap 1"](assets/figures/heatmap1.png)

Here, the original image is converted to use the `GnBu_9` scheme.

```
img1 = save("/tmp/t.png", convert_to_scheme(ColorSchemes.GnBu_9, img))
```

!["heatmap converted"](assets/figures/heatmapconverted.png)

```@docs
convert_to_scheme
```
