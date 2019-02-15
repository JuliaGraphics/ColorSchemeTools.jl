var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Introduction-to-ColorSchemeTools-1",
    "page": "Introduction",
    "title": "Introduction to ColorSchemeTools",
    "category": "section",
    "text": "This package provides tools for working with color schemes - gradients and color maps.You can extract color schemes from images, and replace an image\'s color scheme with another. There are also functions for creating color schemes from pre-defined lists or Julia functions.This package relies on:Colors.jl\nColorSchemes.jl\nImages.jl\nClustering.jland you might need image-capable Julia packages such as ImageMagick.jl or QuartzImageIO.jl installed, depending on the OS."
},

{
    "location": "index.html#Installation-and-basic-usage-1",
    "page": "Introduction",
    "title": "Installation and basic usage",
    "category": "section",
    "text": "Install the package as follows:] add ColorSchemeToolsTo use it:using ColorSchemeToolsOriginal version by cormullion."
},

{
    "location": "tools.html#",
    "page": "Tools",
    "title": "Tools",
    "category": "page",
    "text": "DocTestSetup = quote\n    using ColorSchemes, ColorSchemeTools, Colors\nend"
},

{
    "location": "tools.html#ColorSchemeTools.extract",
    "page": "Tools",
    "title": "ColorSchemeTools.extract",
    "category": "function",
    "text": "extract(imfile, n=10, i=10, tolerance=0.01; shrink=n)\n\nextract() extracts the most common colors from an image from the image file imfile by finding n dominant colors, using i iterations. You can (and probably should) shrink larger images before running this function.\n\nReturns a ColorScheme.\n\n\n\n\n\n"
},

{
    "location": "tools.html#Extracting-colorschemes-from-images-1",
    "page": "Tools",
    "title": "Extracting colorschemes from images",
    "category": "section",
    "text": "You can extract a colorscheme from an image. For example, here\'s an image of a famous painting:(Image: \"the mona lisa\")Use the extract() function to create a color scheme from the original image:using ColorSchemeTools\nmonalisa = extract(\"monalisa.jpg\", 10, 15, 0.01; shrink=2)which in this example creates a 10-color ColorScheme object (using 15 iterations and with a tolerance of 0.01; the image can be reduced in size, here by 2, before processing, to save time).(Image: \"mona lisa extraction\")ColorSchemes.ColorScheme(ColorTypes.RGB{Float64}[\n    RGB{Float64}(0.0406901,0.0412985,0.0423865),\n    RGB{Float64}(0.823493,0.611246,0.234261),\n    RGB{Float64}(0.374688,0.363066,0.182004),\n    RGB{Float64}(0.262235,0.239368,0.110915),\n    RGB{Float64}(0.614806,0.428448,0.112495),\n    RGB{Float64}(0.139384,0.124466,0.0715472),\n    RGB{Float64}(0.627381,0.597513,0.340734),\n    RGB{Float64}(0.955276,0.775304,0.37135),\n    RGB{Float64}(0.497517,0.4913,0.269587),\n    RGB{Float64}(0.880421,0.851357,0.538013),\n    RGB{Float64}(0.738879,0.709218,0.441082)\n    ], \"\", \"\")(Extracting color schemes from images may require you to install image importing and exporting abilities. These are platform-specific. On Linux/UNIX, ImageMagick.jl can be used for importing and exporting images. Use QuartzImageIO.jl on macOS.)extract"
},

{
    "location": "tools.html#ColorSchemeTools.sortcolorscheme",
    "page": "Tools",
    "title": "ColorSchemeTools.sortcolorscheme",
    "category": "function",
    "text": "sortcolorscheme(colorscheme::ColorScheme, field; kwargs...)\n\nSort (non-destructively) a colorscheme using a field of the LUV colorspace.\n\nThe less than function is lt = (x,y) -> compare_colors(x, y, field).\n\nThe default is to sort by the luminance field :l but could be by :u or :v.\n\nReturns a new ColorScheme.\n\n\n\n\n\n"
},

{
    "location": "tools.html#Sorting-color-schemes-1",
    "page": "Tools",
    "title": "Sorting color schemes",
    "category": "section",
    "text": "Use sortcolorscheme() to sort a scheme non-destructively in the LUV color space:using ColorSchemes\nsortcolorscheme(ColorSchemes.leonardo)\nsortcolorscheme(ColorSchemes.leonardo, rev=true)The default is to sort colors by their LUV luminance value, but you could try specifying the :u or :v LUV fields instead (sorting colors is another problem domain not really addressed in this package...):sortcolorscheme(ColorSchemes.leonardo, :u)sortcolorscheme"
},

{
    "location": "tools.html#ColorSchemeTools.extract_weighted_colors",
    "page": "Tools",
    "title": "ColorSchemeTools.extract_weighted_colors",
    "category": "function",
    "text": "extract_weighted_colors(imfile, n=10, i=10, tolerance=0.01; shrink = 2)\n\nExtract colors and weights of the clusters of colors in an image file. Returns a ColorScheme and weights.\n\nExample:\n\npal, wts = extract_weighted_colors(imfile, n, i, tolerance; shrink = 2)\n\n\n\n\n\n"
},

{
    "location": "tools.html#ColorSchemeTools.colorscheme_weighted",
    "page": "Tools",
    "title": "ColorSchemeTools.colorscheme_weighted",
    "category": "function",
    "text": "colorscheme_weighted(colorscheme, weights, length)\n\nReturns a new ColorScheme of length length (default 50) where the proportion of each color in colorscheme is represented by the associated weight of each entry.\n\nExamples:\n\ncolorscheme_weighted(extract_weighted_colors(\"hokusai.jpg\")...)\ncolorscheme_weighted(extract_weighted_colors(\"filename00000001.jpg\")..., 500)\n\n\n\n\n\n"
},

{
    "location": "tools.html#Weighted-colorschemes-1",
    "page": "Tools",
    "title": "Weighted colorschemes",
    "category": "section",
    "text": "Sometimes an image is dominated by some colors with others occurring less frequently. For example, there may be much more brown than yellow in a particular image. A colorscheme derived from this image can reflect this. You can extract both a set of colors and a set of numerical values or weights that indicate the proportions of colors in the image.cs, wts = extract_weighted_colors(\"monalisa.jpg\", 10, 15, 0.01; shrink=2)The ColorScheme is now in cs, and wts holds the various weights of each color:wts\n\n    10-element Array{Float64,1}:\n     0.0521126446851636\n     0.20025391828582884\n     0.08954703056671294\n     0.09603605342678319\n     0.09507086696018234\n     0.119987526821047\n     0.08042973071297582\n     0.08863381567908292\n     0.08599068966285295\n     0.09193772319937041With the ColorScheme and the weights, you can make a new color scheme in which the more common colors take up more space in the scheme:len = 50\ncolorscheme_weighted(cs, wts, len)Or in one go:colorscheme_weighted(extract_weighted_colors(\"monalisa.jpg\" # ...Compare the weighted and unweighted versions of schemes extracted from the Hokusai image \"The Great Wave\":(Image: \"unweighted\")(Image: \"weighted\")extract_weighted_colors\ncolorscheme_weighted"
},

{
    "location": "convertingimages.html#",
    "page": "Converting image colors",
    "title": "Converting image colors",
    "category": "page",
    "text": ""
},

{
    "location": "convertingimages.html#Converting-images-1",
    "page": "Converting image colors",
    "title": "Converting images",
    "category": "section",
    "text": ""
},

{
    "location": "convertingimages.html#ColorSchemeTools.convert_to_scheme",
    "page": "Converting image colors",
    "title": "ColorSchemeTools.convert_to_scheme",
    "category": "function",
    "text": "convert_to_scheme(cscheme, img)\n\nConverts img from its current color values to use only the colors defined in the ColorScheme cscheme.\n\nimage = nonTransparentImg\nconvert_to_scheme(ColorSchemes.leonardo, image)\nconvert_to_scheme(ColorSchemes.Paired_12, image)\n\n\n\n\n\n"
},

{
    "location": "convertingimages.html#Convert-image-from-one-scheme-to-another-1",
    "page": "Converting image colors",
    "title": "Convert image from one scheme to another",
    "category": "section",
    "text": "It\'s possible to convert an image using one color scheme to use another.convert_to_scheme(cscheme, img) returns a new image in which each pixel from the provided image is mapped to its closest matching color in the provided scheme. See ColorSchemes\'s getinverse() function for more details on how this works.In the following figure, the Julia logo is converted to use a ColorScheme with no black or white:using FileIO, ColorSchemes, ColorSchemeTools, Images\n\nimg = load(\"julia-logo-square.png\")\nimg_rgb = RGB.(img) # get rid of alpha channel\nconvertedimage = convert_to_scheme(ColorSchemes.PiYG_4, img_rgb)\n\nsave(\"original.png\",  img)\nsave(\"converted.png\", convertedimage)(Image: \"julia logo converted\")Notice how the white was matched by the color right at the boundary of the light purple and pale green.convert_to_scheme"
},

{
    "location": "makingschemes.html#",
    "page": "Making colorschemes",
    "title": "Making colorschemes",
    "category": "page",
    "text": "using Luxor, Colors, ColorSchemes, ColorSchemeTools\nfunction draw_rgb_levels(cs::ColorScheme, w=800, h=500, filename=\"/tmp/rgb-levels.svg\")\n    # This function is a quick hack to draw swatches and curves in a documenter pass.\n    # The diagrams are merely illustrative, not 100% technically precise :(\n    Drawing(w, h, filename)\n    origin()\n    background(\"white\")\n    setlinejoin(\"bevel\")\n    # three rows (thin, fat, thin), one wide column\n    table = Table([h/6, 2h/3, h/6], w)\n    l = length(cs.colors)\n    bbox = BoundingBox(box(O, table.colwidths[1], table.rowheights[2], vertices=true)) * 0.85\n\n    # axes and labels in main (second) cell of table\n    @layer begin\n        translate(table[2])\n        setline(0.5)\n        fontsize(7)\n        box(bbox, :stroke)\n        # horizontal lines\n        div10 = boxheight(bbox)/10\n        for (ylabel, yy) in enumerate(boxtopcenter(bbox).y:div10:boxbottomcenter(bbox).y)\n            sethue(\"grey85\")\n            rule(Point(0, yy), boundingbox=bbox)\n            sethue(\"grey55\")\n            text(string((11 - ylabel)/10), Point(boxbottomleft(bbox).x - 10, yy), halign=:right, valign=:middle)\n        end\n        # vertical lines\n        div10 = boxwidth(bbox)/10\n        for (xlabel, xx) in enumerate(boxtopleft(bbox).x:div10:boxtopright(bbox).x)\n            sethue(\"grey85\")\n            rule(Point(xx, 0), π/2, boundingbox=bbox)\n            sethue(\"grey55\")\n            text(string((xlabel - 1)/10), Point(xx, boxbottomleft(bbox).y + 10), halign=:center, valign=:bottom)\n        end        \n    end\n\n    # middle, show \'curves\'\n    # \'curves\'\n    # run through color levels in scheme and sample/quantize\n    @layer begin\n        translate(table[2])\n        redline = Point[]\n        greenline = Point[]\n        blueline = Point[]\n        verticalscale=boxheight(bbox)\n        stepping = 0.0025\n        # TODO better way to examine quantized color values\n        for i in 0:stepping:1\n            swatch = convert(Int, round(rescale(i, 0, 1, 1, l)))\n            c = cs[swatch]\n            r = red(c)\n            g = green(c)\n            b = blue(c)\n            x = rescale(i, 0, 1, -boxwidth(bbox)/2, boxwidth(bbox)/2)\n            push!(redline, Point(x, boxbottomcenter(bbox).y - verticalscale * r))\n            push!(greenline, Point(x, boxbottomcenter(bbox).y - verticalscale * g))\n            push!(blueline, Point(x, boxbottomcenter(bbox).y - verticalscale * b))        \n        end\n        # the idea to make the lines different weights to assist reading overlaps may not be a good one\n        setline(1)\n        sethue(\"blue\")\n        poly(blueline, :stroke)\n        setline(0.8)\n        sethue(\"red\")\n        poly(redline, :stroke)\n        setline(0.7)\n        sethue(\"green\")\n        poly(greenline, :stroke)\n    end\n    # top tile, swatches\n    @layer begin\n        translate(table[1])\n        # draw in a single pane\n        panes = Tiler(boxwidth(bbox), table.rowheights[1], 1, 1, margin=0)\n        panewidth = panes.tilewidth\n        paneheight = panes.tileheight\n        # draw the swatches\n        swatchwidth = panewidth/l\n        for (i, p) in enumerate(cs.colors)\n            swatchcenter = Point(boxtopleft(bbox).x - swatchwidth/2 + (i * swatchwidth) , O.y)\n            sethue(p)\n            box(swatchcenter, swatchwidth - 1, table.rowheights[1]/2 - 1,  :fill)\n            if colordiff(p, colorant\"white\") < 1\n                @layer begin\n                    setline(0.4)\n                    sethue(\"grey70\")\n                    box(swatchcenter, swatchwidth - 1, table.rowheights[1]/2 - 1,  :stroke)\n                end\n            end\n        end\n    end\n    # third tile, continuous sampling\n    @layer begin\n        translate(table[3])\n        # draw blend\n        stepping = 0.0005\n        boxw = panewidth * stepping\n        for i in 0:stepping:1\n            c = get(cs, i)\n            sethue(c)\n            xpos = rescale(i, 0, 1, O.x - panewidth/2, O.x + panewidth/2 - boxw)\n            box(Point(xpos + boxw/2, O.y), boxw, table.rowheights[3]/2, :fillstroke)\n        end\n    end\n    finish()\n    nothing\nend"
},

{
    "location": "makingschemes.html#Making-new-colorschemes-1",
    "page": "Making colorschemes",
    "title": "Making new colorschemes",
    "category": "section",
    "text": "To make new ColorSchemes, you can quickly build arrays of colors; refer the ColorSchemes.jl documentation. You can also use the ColorSchemeTools function make_colorscheme(), and supply information about the color sequences you want.The following formats are possible:a dictionary of linear segments\nan \'indexed list\' of RGB values\nthree Julia functions that generate values between 0 and 1 for the RGB levels"
},

{
    "location": "makingschemes.html#Linearly-segmented-colors-1",
    "page": "Making colorschemes",
    "title": "Linearly-segmented colors",
    "category": "section",
    "text": "A linearly-segmented color dictionary looks like this:cdict = Dict(:red   => ((0.0,  0.0,  0.0),\n                        (0.5,  1.0,  1.0),\n                        (1.0,  1.0,  1.0)),\n             :green => ((0.0,  0.0,  0.0),\n                        (0.25, 0.0,  0.0),\n                        (0.75, 1.0,  1.0),\n                        (1.0,  1.0,  1.0)),\n             :blue  => ((0.0,  0.0,  0.0),\n                        (0.5,  0.0,  0.0),\n                        (1.0,  1.0,  1.0)))This specifies that red increases from 0 to 1 over the bottom half, green does the same over the middle half, and blue over the top half.The triplets aren\'t RGB values... For each channel, the first number in each tuple are points on the 0 to 1 brightness scale, and should gradually increase. The second and third values determine the intensity values at that point.The change of color between point p1 and p2 is defined by b and c::red => (\n         ...,\n         (p1, a, b),\n         (p2, c, d),\n         ...\n         )If a and b (or c and d) aren\'t the same, the color will abruptly jump. Notice that the very first a and the very last d aren\'t used.To create a new ColorScheme from a suitable dictionary in this format, run make_colorscheme().using Colors, ColorSchemes\nscheme = make_colorscheme(dict)By plotting the color components separately it\'s possible to see how the curves change. This diagram shows both the defined color levels as swatches along the top, and a continuously-sampled image below:cdict = Dict(:red  => ((0.0,  0.0,  0.0),\n                       (0.5,  1.0,  1.0),\n                       (1.0,  1.0,  1.0)),\n            :green => ((0.0,  0.0,  0.0),\n                       (0.25, 0.0,  0.0),\n                       (0.75, 1.0,  1.0),\n                       (1.0,  1.0,  1.0)),\n            :blue =>  ((0.0,  0.0,  0.0),\n                       (0.5,  0.0,  0.0),\n                       (1.0,  1.0,  1.0))) # hide\nscheme = make_colorscheme(cdict)\ndraw_rgb_levels(scheme, 800, 200, \"assets/figures/curves.svg\") # hide\nnothing # hide(Image: \"showing linear segmented colorscheme\")"
},

{
    "location": "makingschemes.html#Indexed-list-color-schemes-1",
    "page": "Making colorschemes",
    "title": "Indexed-list color schemes",
    "category": "section",
    "text": "The data to define an \'indexed list\' color scheme looks like this:terrain = (\n           (0.00, (0.2, 0.2,  0.6)),\n           (0.15, (0.0, 0.6,  1.0)),\n           (0.25, (0.0, 0.8,  0.4)),\n           (0.50, (1.0, 1.0,  0.6)),\n           (0.75, (0.5, 0.36, 0.33)),\n           (1.00, (1.0, 1.0,  1.0))\n          )The first item of each element is the location between 0 and 1, the second specifies the RGB values at that point.The make_colorscheme(indexedlist) function makes a new ColorScheme from such an indexed list.For example:terrain_data = (\n        (0.00, (0.2, 0.2, 0.6)),\n        (0.15, (0.0, 0.6, 1.0)),\n        (0.25, (0.0, 0.8, 0.4)),\n        (0.50, (1.0, 1.0, 0.6)),\n        (0.75, (0.5, 0.36, 0.33)),\n        (1.00, (1.0, 1.0, 1.0)))\nterrain = make_colorscheme(terrain_data, length = 50)\ndraw_rgb_levels(terrain, 800, 200, \"assets/figures/terrain.svg\") # hide\nnothing # hide(Image: \"indexed lists scheme\")"
},

{
    "location": "makingschemes.html#Functional-color-schemes-1",
    "page": "Making colorschemes",
    "title": "Functional color schemes",
    "category": "section",
    "text": "The colors in a \'functional\' color scheme are produced by three functions that calculate the color values at each point on the scheme.The make_colorscheme() function applies the first supplied function at each point on the colorscheme for the red values, the second function for the green values, and the third for the blue. You can use defined functions or supply anonymous ones.Values produced by the functions are clamped to 0.0 and 1.0 before they\'re converted to RGB values."
},

{
    "location": "makingschemes.html#ColorSchemeTools.make_colorscheme",
    "page": "Making colorschemes",
    "title": "ColorSchemeTools.make_colorscheme",
    "category": "function",
    "text": "make_colorscheme(dict;\n    length=100,\n    category=\"\",\n    notes=\"\")\n\nMake a new ColorScheme from a dictionary of linear-segment information. Calls get_linear_segment_color(dict, n) with n for every length value between 0 and 1.\n\n\n\n\n\nmake_colorscheme(indexedlist;\n    length=100,\n    category=\"\",\n    notes=\"\")\n\nMake a ColorScheme using an \'indexed list\' like this:\n\ngist_rainbow = (\n       (0.000, (1.00, 0.00, 0.16)),\n       (0.030, (1.00, 0.00, 0.00)),\n       (0.215, (1.00, 1.00, 0.00)),\n       (0.400, (0.00, 1.00, 0.00)),\n       (0.586, (0.00, 1.00, 1.00)),\n       (0.770, (0.00, 0.00, 1.00)),\n       (0.954, (1.00, 0.00, 1.00)),\n       (1.000, (1.00, 0.00, 0.75))\n)\n\nmake_colorscheme(gist_rainbow)\n\nThe first element of each item is the point on the color scheme.\n\n\n\n\n\nmake_colorscheme_new(f1::Function, f2::Function, f3::Function;\n    model    = :RGB,\n    length   = 100,\n    category = \"\",\n    notes    = \"functional ColorScheme\")\n\nMake a ColorScheme using functions. Each function should take a value between 0 and 1 and return for that color component at each point on the ColorScheme, depending on the color model.\n\nThe default color model is :RGB, and the functions should return values in the appropriate range:\n\nf1 - [0.0 - 1.0]   - red\nf2 - [0.0 - 1.0]   - green\nf3 - [0.0 - 1.0]   - blue\n\nFor the :HSV color model:\n\nf1 - [0.0 - 360.0] - hue\nf2 - [0.0 - 1.0]   - saturataion\nf3 - [0.0 - 1.0]   - value (brightness)\n\nFor the :LCHab color model:\n\nf1 - [0.0 - 100.0] - luminance\nf2 - [0.0 - 100.0] - chroma\nf3 - [0.0 - 360.0] - hue\n\n\n\n\n\n"
},

{
    "location": "makingschemes.html#ColorSchemeTools.get_linear_segment_color",
    "page": "Making colorschemes",
    "title": "ColorSchemeTools.get_linear_segment_color",
    "category": "function",
    "text": "get_linear_segment_color(dict, n)\n\nGet the RGB color for value n from a dictionary of linear color segments.\n\nThis following is a dictionary where red increases from 0 to 1 over the bottom half, green does the same over the middle half, and blue over the top half:\n\ncdict = Dict(:red  => ((0.0,  0.0,  0.0),\n                       (0.5,  1.0,  1.0),\n                       (1.0,  1.0,  1.0)),\n            :green => ((0.0,  0.0,  0.0),\n                       (0.25, 0.0,  0.0),\n                       (0.75, 1.0,  1.0),\n                       (1.0,  1.0,  1.0)),\n            :blue =>  ((0.0,  0.0,  0.0),\n                       (0.5,  0.0,  0.0),\n                       (1.0,  1.0,  1.0)))\n\nThe value of RGB component at every value of n is defined by a set of tuples. In each tuple, the first number is x. Colors are linearly interpolated in bands between consecutive values of x; if the first tuple is given by (Z, A, B) and the second tuple by (X, C, D), the color of a point n between Z and X will be given by (n - Z) / (X - Z) * (C - B) + B.\n\nFor example, given an entry like this:\n\n:red  => ((0.0, 0.0, 0.0),\n          (0.5, 1.0, 1.0),\n          (1.0, 1.0, 1.0))\n\nand if n = 0.75, we return 1.0; 0.75 is between the second and third segments, but we\'d already reached 1.0 (segment 2) when n was 0.5.\n\n\n\n\n\n"
},

{
    "location": "makingschemes.html#Examples-1",
    "page": "Making colorschemes",
    "title": "Examples",
    "category": "section",
    "text": "The first example returns a smooth black to white gradient, because the identity() function gives back as good as it gets.fscheme = make_colorscheme(identity, identity, identity)\ndraw_rgb_levels(fscheme, 800, 200, \"assets/figures/funcscheme1.svg\") # hide\nnothing # hide(Image: \"functional color schemes\")The next example uses the sin() function on values from 0 to π to control the red, and the cos() function from 0 to π to control the blue. The green channel is flat-lined.fscheme = make_colorscheme(n -> sin(n*π), n -> 0, n -> cos(n*π))\ndraw_rgb_levels(fscheme, 800, 200, \"assets/figures/funcscheme2.svg\") # hide\nnothing # hide(Image: \"functional color schemes\")You can generate stepped gradients by controlling the numbers. Here, each point on the scheme is nudged to the nearest multiple of 0.1.fscheme = make_colorscheme(\n        n -> round(n, digits=1),\n        n -> round(n, digits=1),\n        n -> round(n, digits=1), length=10)\ndraw_rgb_levels(fscheme, 800, 200, \"assets/figures/funcscheme3.svg\") # hide\nnothing # hide(Image: \"functional color schemes\")The next example sinusoidally sends the red channel from black to red and back again.fscheme = make_colorscheme(n -> sin(n * π), n -> 0, n -> 0)\ndraw_rgb_levels(fscheme, 800, 200, \"assets/figures/funcscheme4.svg\") # hide\nnothing # hide(Image: \"functional color schemes\")The next example produces a striped colorscheme as the rippling sine waves continually change phase:ripple7(n)  = sin(π * 7n)\nripple13(n) = sin(π * 13n)\nripple17(n) = sin(π * 17n)\nfscheme = make_colorscheme(ripple7, ripple13, ripple17, length=80)\ndraw_rgb_levels(fscheme, 800, 200, \"assets/figures/funcscheme5.svg\") # hide\nnothing # hide(Image: \"functional color schemes\")If you\'re creating a scheme by generating LCHab colors, your functions should convert values between 0 and 1 to values between 0 and 100 (luminance and chroma) or 0 to 360 (hue).\nf1(n) = 180 + 180sin(2π * n)\nf2(n) = 50 + 20(0.5 - abs(n - 0.5))\nfscheme = make_colorscheme(n -> 50, f2, f1,\n    length=80,\n    model=:LCHab)\ndraw_rgb_levels(fscheme, 800, 200, \"assets/figures/funcscheme6.svg\") # hide\nnothing # hide(Image: \"functional color schemes\")make_colorscheme\nget_linear_segment_color"
},

{
    "location": "output.html#",
    "page": "Saving colorschemes",
    "title": "Saving colorschemes",
    "category": "page",
    "text": ""
},

{
    "location": "output.html#Saving-colorschemes-1",
    "page": "Saving colorschemes",
    "title": "Saving colorschemes",
    "category": "section",
    "text": ""
},

{
    "location": "output.html#ColorSchemeTools.colorscheme_to_image",
    "page": "Saving colorschemes",
    "title": "ColorSchemeTools.colorscheme_to_image",
    "category": "function",
    "text": "colorscheme_to_image(cs, nrows=50, tilewidth=5)\n\nMake an image from a ColorScheme by repeating the colors in nrows rows, repeating each pixel tilewidth times.\n\nReturns the image as an array.\n\nExamples:\n\nusing FileIO\n\nimg = colorscheme_to_image(ColorSchemes.leonardo, 50, 200)\nsave(\"/tmp/cs_image.png\", img)\n\nsave(\"/tmp/blackbody.png\", colorscheme_to_image(ColorSchemes.blackbody, 10, 100))\n\n\n\n\n\n"
},

{
    "location": "output.html#ColorSchemeTools.image_to_swatch",
    "page": "Saving colorschemes",
    "title": "ColorSchemeTools.image_to_swatch",
    "category": "function",
    "text": "image_to_swatch(imagefilepath, samples, destinationpath;\n    nrows=50,\n    tilewidth=5)\n\nExtract a ColorsSheme from the image in imagefilepath to a swatch image PNG in destinationpath. This just runs sortcolorscheme(), colorscheme_to_image(), and save() in sequence.\n\nSpecify the number of colors. You can also specify the number of rows, and how many times each color is repeated.\n\nimage_to_swatch(\"monalisa.jpg\", 10, \"/tmp/monalisaswatch.png\")\n\n\n\n\n\n"
},

{
    "location": "output.html#Saving-colorschemes-as-images-1",
    "page": "Saving colorschemes",
    "title": "Saving colorschemes as images",
    "category": "section",
    "text": "Sometimes you want to save a colorscheme, which is usually just a pixel thick, as a swatch or image. You can do this with colorscheme_to_image(). The second argument is the number of rows. The third argument is the number of times each pixel is repeated in the row. The function returns an image which you can save using FileIO\'s save():using FileIO, ColorSchemeTools, Images, Colors\n\n# 20 pixels for each color, 150 rows\nimg = colorscheme_to_image(ColorSchemes.vermeer, 150, 20)\n\nsave(\"/tmp/cs_vermeer-150-20.png\", img)(Image: \"vermeer swatch\")The image_to_swatch() function (a shortcut) extracts a n-color scheme from a supplied image and saves it as a swatch in a PNG.image_to_swatch(\"/tmp/input.png\", 10, \"/tmp/output.png\")colorscheme_to_image\nimage_to_swatch"
},

{
    "location": "output.html#ColorSchemeTools.colorscheme_to_text",
    "page": "Saving colorschemes",
    "title": "ColorSchemeTools.colorscheme_to_text",
    "category": "function",
    "text": "colorscheme_to_text(cscheme::ColorScheme, schemename, filename;\n    category=\"dutch painters\",   # category\n    notes=\"it\'s not really lost\" # notes\n)\n\nWrite a ColorScheme to a Julia text file.\n\nExample\n\ncolorscheme_to_text(ColorSchemes.vermeer,\n    \"the_lost_vermeer\",          # name\n    \"/tmp/the_lost_vermeer.jl\",  # file\n    category=\"dutch painters\",   # category\n    notes=\"it\'s not really lost\" # notes\n    )\n\nand read it back in with:\n\ninclude(\"/tmp/the_lost_vermeer.jl\")\n\n\n\n\n\n"
},

{
    "location": "output.html#Saving-colorschemes-to-text-files-1",
    "page": "Saving colorschemes",
    "title": "Saving colorschemes to text files",
    "category": "section",
    "text": "You can save a ColorScheme as a (Julia) text file with the imaginatively-titled colorscheme_to_text() function.Remember to make the name a Julia-friendly one, because it may eventually become a symbol and a dictionary key if the Julia file is include-d.colorscheme_to_text(ColorSchemes.vermeer,\n        \"the_lost_vermeer\",           # name\n        \"/tmp/the_lost_vermeer.jl\",   # filename\n        category=\"dutch painters\",    # category\n        notes=\"it\'s not really lost\"  # notes\n        )Of course, if you just want the color definitions, you can simply type:map(println, ColorSchemes.vermeer.colors);colorscheme_to_text"
},

{
    "location": "functionindex.html#",
    "page": "Index",
    "title": "Index",
    "category": "page",
    "text": ""
},

{
    "location": "functionindex.html#Index-1",
    "page": "Index",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
