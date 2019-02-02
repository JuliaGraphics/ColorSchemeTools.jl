# Converting images

## Convert image from one scheme to another

Using the ColorSchemes function `getinverse()` it's possible to convert an image using one colorscheme to use another.

`convert_to_scheme(cscheme, img)` returns a new image in which each pixel from the provided image is mapped to its closest matching color in the provided scheme.

In the following figure, the Julia logo is converted to use a ColorScheme with no black or white:

```
using FileIO, ColorSchemes, ColorSchemeTools, Images

img = load("julia-logo-square.png")
img_rgb = RGB.(img) # get rid of alpha channel
convertedimage = convert_to_scheme(ColorSchemes.PiYG_4, img_rgb)

save("original.png",  img)
save("converted.png", convertedimage)
```

!["julia logo converted"](assets/figures/logosconverted.png)

```@docs
convert_to_scheme
```
