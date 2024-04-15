using Luxor, Colors, ColorSchemes

function draw_rgb_levels(cs::ColorScheme, w = 800, h = 500, filename = "/tmp/rgb-levels.svg")
    # This function is a quick hack to draw swatches and curves in a documenter pass.
    # The diagrams are merely illustrative, not 100% technically precise :(

    dwg = Drawing(w, h, filename)
    origin()
    background("black")
    setlinejoin("bevel")
    # three rows (thin, fat, thin), one wide column
    table = Table([h / 6, 2h / 3, h / 6], w)
    l = length(cs.colors)
    bbox = BoundingBox(box(O, table.colwidths[1], table.rowheights[2], vertices = true)) * 0.85

    # axes and labels in main (second) cell of table
    @layer begin
        translate(table[2])
        setline(0.5)
        fontsize(7)
        box(bbox, :stroke)
        # horizontal lines
        div10 = boxheight(bbox) / 10
        for (ylabel, yy) in enumerate((boxtopcenter(bbox).y):div10:(boxbottomcenter(bbox).y))
            sethue("grey25")
            rule(Point(0, yy), boundingbox = bbox)
            sethue("grey85")
            text(string((11 - ylabel) / 10), Point(boxbottomleft(bbox).x - 10, yy), halign = :right, valign = :middle)
        end
        # vertical lines
        div10 = boxwidth(bbox) / 10
        for (xlabel, xx) in enumerate((boxtopleft(bbox).x):div10:(boxtopright(bbox).x))
            sethue("grey25")
            rule(Point(xx, 0), π / 2, boundingbox = bbox)
            sethue("grey85")
            text(string((xlabel - 1) / 10), Point(xx, boxbottomleft(bbox).y + 10), halign = :center, valign = :bottom)
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
        alphaline = Point[]
        verticalscale = boxheight(bbox)
        stepping = 0.0025
        # TODO better way to examine quantized color values
        for i in 0:stepping:1
            swatch = convert(Int, round(rescale(i, 0, 1, 1, l)))
            c = cs[swatch]
            r = red(c)
            g = green(c)
            b = blue(c)
            a = alpha(c)
            x = rescale(i, 0, 1, -boxwidth(bbox) / 2, boxwidth(bbox) / 2)
            push!(redline, Point(x, boxbottomcenter(bbox).y - verticalscale * r))
            push!(greenline, Point(x, boxbottomcenter(bbox).y - verticalscale * g))
            push!(blueline, Point(x, boxbottomcenter(bbox).y - verticalscale * b))
            push!(alphaline, Point(x, boxbottomcenter(bbox).y - verticalscale * a))
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
        setline(0.6)
        sethue("grey80")
        poly(alphaline, :stroke)
    end

    # top tile, swatches
    @layer begin
        translate(table[1])
        # draw in a single pane
        panes = Tiler(boxwidth(bbox), table.rowheights[1], 1, 1, margin = 0)
        panewidth = panes.tilewidth
        paneheight = panes.tileheight
        # draw the swatches
        swatchwidth = panewidth / l
        for (i, p) in enumerate(cs.colors)
            swatchcenter = Point(boxtopleft(bbox).x - swatchwidth / 2 + (i * swatchwidth), O.y)
            setcolor(p)
            box(swatchcenter, swatchwidth - 1, table.rowheights[1] / 2 - 1, :fill)
            @layer begin
                setline(0.4)
                sethue("grey50")
                box(swatchcenter, swatchwidth - 1, table.rowheights[1] / 2 - 1, :stroke)
            end
        end
    end

    # third tile, continuous sampling
    @layer begin
        setline(0)
        translate(table[3])
        # draw blend
        stepping = 0.001
        boxw = panewidth * stepping
        for i in 0:stepping:1
            c = get(cs, i)
            setcolor(c)
            xpos = rescale(i, 0, 1, O.x - panewidth / 2, O.x + panewidth / 2 - boxw)
            box(Point(xpos + boxw / 2, O.y), boxw, table.rowheights[3] / 2, :fillstroke)
        end
    end
    finish()
    return dwg
end

function draw_transparent(cs::ColorScheme, csa::ColorScheme,
    w = 800, h = 500, filename = "/tmp/transparency-levels.svg",
)
    dwg = Drawing(w, h, filename)
    origin()
    background("black")
    setlinejoin("bevel")

    N = length(csa.colors) * 2
    h = w ÷ 4
    backgroundtiles = Tiler(w, h, 4, N, margin = 0)
    setline(0)
    for (pos, n) in backgroundtiles
        if iseven(backgroundtiles.currentrow + backgroundtiles.currentcol)
            sethue("grey80")
        else
            sethue("grey90")
        end
        box(backgroundtiles, n, :fillstroke)
    end
    referencecolortiles = Tiler(w, h, 2, N ÷ 2, margin = 0)
    for (pos, n) in referencecolortiles[1:(N ÷ 2)]
        setcolor(cs[n])
        box(referencecolortiles, n, :fillstroke)
    end
    for (i, (pos, n)) in enumerate(referencecolortiles[(N ÷ 2 + 1):end])
        setcolor(csa[i])
        box(referencecolortiles, n, :fillstroke)
    end
    finish()
    return dwg
end

function draw_lightness_swatch(cs::ColorScheme, width = 800, height = 150;
    name = "")
    @drawsvg begin
        hmargin = 30
        vmargin = 20
        bb = BoundingBox(Point(-width / 2 + hmargin, -height / 2 + vmargin), Point(width / 2 - hmargin, height / 2 - vmargin))

        background("black")
        fontsize(8)
        sethue("white")
        setline(0.5)
        box(bb, :stroke)

        tickline(boxbottomleft(bb), boxbottomright(bb), major = 9, axis = false,
            major_tick_function = (n, pos; startnumber, finishnumber, nticks) ->
                text(string(n / 10), pos + (0, 12), halign = :center),
        )

        tickline(boxbottomright(bb), boxtopright(bb), major = 9, axis = false,
            major_tick_function = (n, pos; startnumber, finishnumber, nticks) ->
                text(string(10n), pos + (0, 20), angle = π / 2, halign = :right, valign = :middle),
        )

        text("lightness", boxtopleft(bb) + (10, 10), halign = :right, angle = -π / 2)

        fontsize(12)
        L = 70
        sw = width / L
        saved = Point[]
        for i in range(0.0, 1.0, length = L)
            pos = between(boxmiddleleft(bb), boxmiddleright(bb), i)
            color = get(cs, i)
            setcolor(color)
            labcolor = convert(Lab, color)
            lightness = labcolor.l
            lightnesspos = pos + (0, boxheight(bb) / 2 - rescale(labcolor.l, 0, 100, 0, boxheight(bb)))
            push!(saved, lightnesspos)
            circle(lightnesspos, 5, :fill)
        end

        #		setline(1)
        #		sethue("black")
        #		line(saved[1], saved[end], :stroke)
        #		setline(0.8)
        #		line(saved[1], saved[end], :stroke)

        sethue("white")
        text(name, boxtopcenter(bb) + (0, -6), halign = :center)
    end width height
end

