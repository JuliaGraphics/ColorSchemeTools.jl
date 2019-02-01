using Test, ColorSchemes, ColorSchemeTools, FileIO, Colors

function run_all_tests()

    @testset "basic functions" begin
        # load existing scheme from ColorSchemes.jl
        hok = ColorSchemes.hokusai

        @test length(hok) == 32

        # image file located here in the test directory

        # create a colorscheme from image file, default is 10
        hokusai_test = ColorSchemeTools.extract(dirname(@__FILE__) * "/hokusai.jpg")

        @test length(hokusai_test) == 10

        # extract colors and weights
        c, w =  ColorSchemeTools.extract_weighted_colors(dirname(@__FILE__) * "/hokusai.jpg", 10, 10, 0.01; shrink = 4)

        @test length(c) == 10
        @test length(w) == 10

        # test that sampling schemes yield different values
        @test get(hokusai_test, 0.0) != get(hokusai_test, 0.5)

        # test sort
        @test ColorSchemeTools.sortcolorscheme(hokusai_test, rev=true) != ColorSchemeTools.sortcolorscheme(hokusai_test)

        # create weighted palette; there is some unpredictability here... :)
        csw = colorscheme_weighted(c, w, 37)
        @test 36 <= length(csw) <= 38

        # default is 50
        csw = colorscheme_weighted(c, w)
        @test length(csw) == 50

        # save as Julia text file
        colorscheme_to_text(ColorSchemes.hokusai, "hokusai_test_version", "hokusai_as_text.jl")

        # and read it in as text
        open("hokusai_as_text.jl") do f
            lines = readlines(f)
            @test occursin("loadcolorscheme(", lines[1])
            @test occursin("Colors.RGB{Float64}(0.1112499123425623", lines[4])
        end
    end

    @testset "getinverse tests" begin
        getinverse(ColorSchemes.colorschemes[:leonardo], RGB(1, 0, 0))
        getinverse(ColorScheme([Colors.RGB(0,0,0), Colors.RGB(1,1,1)]),  Colors.RGB(.5,.5,.5))
        cs = ColorScheme(range(Colors.RGB(0,0,0), stop=Colors.RGB(1,1,1), length=5))
        gi = getinverse(cs, cs[3])
        @test gi == 0.5
    end

    @testset "convert to scheme tests" begin
        # Add color to a grayscale image.
        # now using ColorScheme objects and .colors accessors
        red_cs = ColorScheme(range(RGB(0,0,0), stop=RGB(1,0,0), length=11))
        gray_cs = ColorScheme(range(RGB(0,0,0), stop=RGB(1,1,0), length=11))
        vs = [getinverse(gray_cs, p) for p in red_cs.colors]
        cs = ColorScheme([RGB(v, v, v) for v in vs])
        rcs = [get(red_cs, p) for p in vs]

        new_img = convert_to_scheme(red_cs, gray_cs.colors)
        # TODO
        # This is broken.. It should be way more specific. See next test.
        @test all(.≈(new_img, red_cs.colors, atol=0.5))

        # Should be able to uniquely match each increasing color with the next
        # increasing color in the new scale.
        red_cs = ColorScheme(range(RGB(0,0,0), stop=RGB(1,1,1)))
        blue_scale_img = range(RGB(0,0,0), stop=RGB(0,0,1))
        new_img = convert_to_scheme(red_cs, blue_scale_img)
        @test_broken unique(new_img) == new_img
    end

    # TODO Test all make-colorscheme functionality
    @testset "make_colorscheme tests" begin

    end
end

function run_minimum_tests()

    @testset "basic minimum tests" begin
        # load scheme
        hok = ColorSchemes.hokusai

        @test length(hok) == 32

        # test sort
        @test ColorSchemeTools.sortcolorscheme(hok, rev=true) != ColorSchemeTools.sortcolorscheme(hok)

        # save as text
        ColorSchemeTools.colorscheme_to_text(hok, "hokusai_test_version", "hokusai_as_text.jl")

        @test filesize("hokusai_as_text.jl") > 2000

        open("hokusai_as_text.jl") do f
            lines = readlines(f)
            @test occursin("Colors.RGB{Float64}(0.1112499123425623", lines[4])
        end

        # convert an Array{T,2} to an RGB image
        tmp = get(ColorSchemes.leonardo, rand(10, 10))
        @test typeof(tmp) == Array{ColorTypes.RGB{Float64}, 2}

        # test conversion with default clamp
        x = [0.0 1.0 ; -1.0 2.0]
        y = get(ColorSchemes.leonardo, x)
        @test y[1,1] == y[2,1]
        @test y[1,2] == y[2,2]

        # test conversion with symbol clamp
        y2 = get(ColorSchemes.leonardo, x, :clamp)
        @test y2 == y

        # test conversion with symbol extrema
        y2 = get(ColorSchemes.leonardo, x, :extrema)
        @test y2[2,1] == y[1,1]   # Minimum now becomes one edge of ColorScheme
        @test y2[2,2] == y[1,2]   # Maximum now becomes other edge of ColorScheme
        @test y2[1,1] !== y2[2,1] # Inbetween values or now different

        # test conversion with manually supplied range
        y3 = get(ColorSchemes.leonardo, x, (-1.0, 2.0))
        @test y3 == y2

        # test with steplen (#17)
        r  = range(0, stop=5, length=10)
        y  = get(ColorSchemes.leonardo, r)
        y2 = get(ColorSchemes.leonardo, collect(r))
        @test y == y2

        # test for specific value
        val = 0.2
        y   = get(ColorSchemes.leonardo, [val])
        y2  = get(ColorSchemes.leonardo, val)
        @test y2 == y[1]
        end
end

if get(ENV, "ColorSchemeTools_KEEP_TEST_RESULTS", false) == "true"
    cd(mktempdir())
    @info("running tests in: $(pwd())")
    @info("...Keeping the results")
    @info("..running minimum tests")
    run_minimum_tests()
    @info("..running all tests")
    run_all_tests()
    @info("Test images saved in: $(pwd())")
else
    mktempdir() do tmpdir
    cd(tmpdir) do
        @info("running tests in: $(pwd())")
        @info("but not keeping the results")
        @info("because you didn't do: ENV[\"ColorSchemeTools_KEEP_TEST_RESULTS\"] = \"true\"")
        @info("..running minimum tests")
        run_minimum_tests()
        @info("..running all tests")
        run_all_tests()
        @info("Test images weren't saved. To see the test images, next time do this before running:")
        @info(" ENV[\"ColorSchemeTools_KEEP_TEST_RESULTS\"] = \"true\"")
        end
    end
end
