using ColorSchemeTools

# code in here is for translating colorschemes from
# https://github.com/matplotlib/matplotlib/blob/master/lib/matplotlib/_cm.py
# into ColorSchemeTools.jl compatible code

# # Gnuplot palette functions
# these are simply translated from Python
_g0(x) = 0
_g1(x) = 0.5
_g2(x) = 1
_g3(x) = x # really
_g4(x) = x^2
_g5(x) = x^3
_g6(x) = x^4
_g7(x) = sqrt(x)
_g8(x) = sqrt(sqrt(x))
_g9(x) = sin(x * π/2)
_g10(x) = cos(x * π/2)
_g11(x) = abs(x - 0.5)
_g12(x) = (2x - 1)^2
_g13(x) = sin(x * π)
_g14(x) = abs(cos(x * π))
_g15(x) = sin(x * 2π)
_g16(x) = cos(x * 2π)
_g17(x) = abs(sin(x * 2π))
_g18(x) = abs(cos(x * 2π))
_g19(x) = abs(sin(x * 4π))
_g20(x) = abs(cos(x * 4π))
_g21(x) = 3x
_g22(x) = 3x - 1
_g23(x) = 3x - 2
_g24(x) = abs(3x - 1)
_g25(x) = abs(3x - 2)
_g26(x) = (3x - 1) / 2
_g27(x) = (3x - 2) / 2
_g28(x) = abs((3x - 1) / 2)
_g29(x) = abs((3x - 2) / 2)
_g30(x) = x / 0.32 - 0.78125
_g31(x) = 2x - 0.84
function _g32(x) # andreas
   ret = zeros(length(x))
       m = (x < 0.25)
       ret[m] = 4 * x[m]
       m = (x >= 0.25) & (x < 0.92)
       ret[m] = -2 * x[m] + 1.84
       m = (x >= 0.92)
       ret[m] = x[m] / 0.08 - 11.5
       return
end
function _g32(x) # kristoffer
    ret = zeros(length(x))
    m = x .< 0.25
    ret[m] = 4 * x[m]
    m = (x .>= 0.25) .& (x .< 0.92)
    ret[m] = -2 .* x[m] .+ 1.84
    m = (x .>= 0.92)
    ret[m] = x[m] ./ 0.08 .- 11.5
    return ret
end

_g33(x) =  abs(2x - 0.5)
_g34(x) =  2x
_g35(x) =  2x - 0.5
_g36(x) =  2x - 1

# Didn't bother with building these functions into gfunc()s
# just pass the functions directly

#
# _gnuplot_data = Dict(
#         :red => gfunc(7),
#         :green => gfunc(5),
#         :blue => gfunc(15))
# =>
gnuplot = make_colorscheme(_g7, _g5, _g15)

#
# _gnuplot2_data = Dict(
#         :red => gfunc(30),
#         :green => gfunc(31),
#         :blue => gfunc(32))
# =>
# this one is the only weird one, so I fudged it thus
wackyblues = _g32(range(0, stop=1, length=100))
gnuplot2 = make_colorscheme(_g30, _g31, (n) -> wackyblues[convert(Int, floor(ColorSchemeTools.lerp(n, 0, 1, 1, 100)))])

#
# _ocean_data = Dict(
#         :red => gfunc(23),
#         :green => gfunc(28),
#         :blue => gfunc(3))
# =>
ocean = make_colorscheme(_g23, _g28, _g3)

#
# _afmhot_data = Dict(
#         :red => gfunc(34),
#         :green => gfunc(35),
#         :blue => gfunc(36))
# =>
afmhot = make_colorscheme(_g34, _g35, _g36)

#
# _rainbow_data = Dict(
#         :red => gfunc(33),
#         :green => gfunc(13),
#         :blue => gfunc(10))
# =>
rainbow = make_colorscheme(_g33, _g13, _g10)

#
# _gist_gray_data = {
#         'red': gfunc[3],
#         'green': gfunc[3],
#         'blue': gfunc[3],
# }
# don't really get this next bit, but it's easy to avoid
# def _gist_yarg(x): return 1 - x
#_gist_yarg_data = {'red': _gist_yarg, 'green': _gist_yarg, 'blue': _gist_yarg} ??
# =>

gist_gray = make_colorscheme(identity, identity, identity)
# tada!
gist_yarg = ColorScheme(reverse(gist_gray.colors))

#
# def _gist_heat_red(x): return 1.5 * x
# def _gist_heat_green(x): return 2 * x - 1
# def _gist_heat_blue(x): return 4 * x - 3
# _gist_heat_data = {
#     'red': _gist_heat_red, 'green': _gist_heat_green, 'blue': _gist_heat_blue}
# =>
gist_heat = make_colorscheme((n) -> 1.5n, (n) -> 2n - 1, (n) -> 4n - 3)

#
coolwarm_dict = Dict(
    :red => (
        (0.0, 0.2298057, 0.2298057),
        (0.03125, 0.26623388, 0.26623388),
        (0.0625, 0.30386891, 0.30386891),
        (0.09375, 0.342804478, 0.342804478),
        (0.125, 0.38301334, 0.38301334),
        (0.15625, 0.424369608, 0.424369608),
        (0.1875, 0.46666708, 0.46666708),
        (0.21875, 0.509635204, 0.509635204),
        (0.25, 0.552953156, 0.552953156),
        (0.28125, 0.596262162, 0.596262162),
        (0.3125, 0.639176211, 0.639176211),
        (0.34375, 0.681291281, 0.681291281),
        (0.375, 0.722193294, 0.722193294),
        (0.40625, 0.761464949, 0.761464949),
        (0.4375, 0.798691636, 0.798691636),
        (0.46875, 0.833466556, 0.833466556),
        (0.5, 0.865395197, 0.865395197),
        (0.53125, 0.897787179, 0.897787179),
        (0.5625, 0.924127593, 0.924127593),
        (0.59375, 0.944468518, 0.944468518),
        (0.625, 0.958852946, 0.958852946),
        (0.65625, 0.96732803, 0.96732803),
        (0.6875, 0.969954137, 0.969954137),
        (0.71875, 0.966811177, 0.966811177),
        (0.75, 0.958003065, 0.958003065),
        (0.78125, 0.943660866, 0.943660866),
        (0.8125, 0.923944917, 0.923944917),
        (0.84375, 0.89904617, 0.89904617),
        (0.875, 0.869186849, 0.869186849),
        (0.90625, 0.834620542, 0.834620542),
        (0.9375, 0.795631745, 0.795631745),
        (0.96875, 0.752534934, 0.752534934),
        (1.0, 0.705673158, 0.705673158)),
    :green => (
        (0.0, 0.298717966, 0.298717966),
        (0.03125, 0.353094838, 0.353094838),
        (0.0625, 0.406535296, 0.406535296),
        (0.09375, 0.458757618, 0.458757618),
        (0.125, 0.50941904, 0.50941904),
        (0.15625, 0.558148092, 0.558148092),
        (0.1875, 0.604562568, 0.604562568),
        (0.21875, 0.648280772, 0.648280772),
        (0.25, 0.688929332, 0.688929332),
        (0.28125, 0.726149107, 0.726149107),
        (0.3125, 0.759599947, 0.759599947),
        (0.34375, 0.788964712, 0.788964712),
        (0.375, 0.813952739, 0.813952739),
        (0.40625, 0.834302879, 0.834302879),
        (0.4375, 0.849786142, 0.849786142),
        (0.46875, 0.860207984, 0.860207984),
        (0.5, 0.86541021, 0.86541021),
        (0.53125, 0.848937047, 0.848937047),
        (0.5625, 0.827384882, 0.827384882),
        (0.59375, 0.800927443, 0.800927443),
        (0.625, 0.769767752, 0.769767752),
        (0.65625, 0.734132809, 0.734132809),
        (0.6875, 0.694266682, 0.694266682),
        (0.71875, 0.650421156, 0.650421156),
        (0.75, 0.602842431, 0.602842431),
        (0.78125, 0.551750968, 0.551750968),
        (0.8125, 0.49730856, 0.49730856),
        (0.84375, 0.439559467, 0.439559467),
        (0.875, 0.378313092, 0.378313092),
        (0.90625, 0.312874446, 0.312874446),
        (0.9375, 0.24128379, 0.24128379),
        (0.96875, 0.157246067, 0.157246067),
        (1.0, 0.01555616, 0.01555616)),
    :blue => (
        (0.0, 0.753683153, 0.753683153),
        (0.03125, 0.801466763, 0.801466763),
        (0.0625, 0.84495867, 0.84495867),
        (0.09375, 0.883725899, 0.883725899),
        (0.125, 0.917387822, 0.917387822),
        (0.15625, 0.945619588, 0.945619588),
        (0.1875, 0.968154911, 0.968154911),
        (0.21875, 0.98478814, 0.98478814),
        (0.25, 0.995375608, 0.995375608),
        (0.28125, 0.999836203, 0.999836203),
        (0.3125, 0.998151185, 0.998151185),
        (0.34375, 0.990363227, 0.990363227),
        (0.375, 0.976574709, 0.976574709),
        (0.40625, 0.956945269, 0.956945269),
        (0.4375, 0.931688648, 0.931688648),
        (0.46875, 0.901068838, 0.901068838),
        (0.5, 0.865395561, 0.865395561),
        (0.53125, 0.820880546, 0.820880546),
        (0.5625, 0.774508472, 0.774508472),
        (0.59375, 0.726736146, 0.726736146),
        (0.625, 0.678007945, 0.678007945),
        (0.65625, 0.628751763, 0.628751763),
        (0.6875, 0.579375448, 0.579375448),
        (0.71875, 0.530263762, 0.530263762),
        (0.75, 0.481775914, 0.481775914),
        (0.78125, 0.434243684, 0.434243684),
        (0.8125, 0.387970225, 0.387970225),
        (0.84375, 0.343229596, 0.343229596),
        (0.875, 0.300267182, 0.300267182),
        (0.90625, 0.259301199, 0.259301199),
        (0.9375, 0.220525627, 0.220525627),
        (0.96875, 0.184115123, 0.184115123),
        (1.0, 0.150232812, 0.150232812))
        )

coolwarm = make_colorscheme(coolwarm_dict, notes="blue to white to red")


# _bwr_data = ((0.0, 0.0, 1.0), (1.0, 1.0, 1.0), (1.0, 0.0, 0.0))
# this is another blue to white to red
# _brg_data = ((0.0, 0.0, 1.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0))
# this is blue to red to green

bwr_data = (
     (0.0,     (0., 0., 1.)),
     (0.5,     (1., 1., 1.)),
     (1.0,     (1., 0., 0.))
     )

bwr = make_colorscheme(bwr_data)

brg_data  = (
      (0.0,     (0., 0., 1.)),
      (0.5,     (1., 0., 0.)),
      (1.0,     (0., 1., 0.))
      )

brg = make_colorscheme(brg_data)

#
# def _flag_red(x): return 0.75 *  np.sin((x * 31.5 + 0.25) * np.pi) + 0.5
# def _flag_green(x): return       np.sin( x * 31.5         * np.pi)
# def _flag_blue(x): return 0.75 * np.sin((x * 31.5 - 0.25) * np.pi) + 0.5
# _flag_data = {'red': _flag_red, 'green': _flag_green, 'blue': _flag_blue}
# they apparently want red->white->blue->black 16 times
# =>

flag = make_colorscheme(
    (n) -> 0.75 * sin((31.5n + 0.25) * π) + 0.5,
    (n) -> sin(31.5n * π),
    (n) -> 0.75 * sin((31.5n - 0.25) * π) + 0.5,
    # length=300 # looks better with more samples, but probably it will be used for continuous sampling
    )

#
# def _prism_red(x): return 0.75   * np.sin((x * 20.9 + 0.25) * np.pi) + 0.67
# def _prism_green(x): return 0.75 * np.sin((x * 20.9 - 0.25) * np.pi) + 0.33
# def _prism_blue(x): return -1.1  * np.sin((x * 20.9)        * np.pi)
# _prism_data = {'red': _prism_red, 'green': _prism_green, 'blue': _prism_blue}
# The (9) colors of the spectrum repeating 11 times...
# =>

prism = make_colorscheme(
    (n) -> 0.75 * sin((20.9n + 0.25) * π) + 0.67,
    (n) -> 0.75 * sin((20.9n - 0.25) * π) + 0.33,
    (n) -> -1.1 * sin(20.9n * π))

#=
# code to output these colorschemes to files

for cs in (:rainbow, :afmhot, :ocean, :gnuplot, :gnuplot2, :gist_gray, :gist_yarg, :gist_heat, :coolwarm, :bwr, :brg, :flag, :prism)
     colorscheme_to_text(Base.eval(Main, cs), String(cs), "/tmp/$(cs).jl")
 end

# assemble
# who needs Unix tools...
open("/tmp/out.jl", "w") do file
     for f in ("/tmp/rainbow.jl",  "/tmp/prism.jl",  "/tmp/flag.jl", "/tmp/brg.jl",  "/tmp/bwr.jl",  "/tmp/coolwarm.jl",  "/tmp/gist_heat.jl", "/tmp/gist_yarg.jl",  "/tmp/gist_gray.jl",  "/tmp/gnuplot2.jl", "/tmp/gnuplot.jl" , "/tmp/ocean.jl",  "/tmp/afmhot.jl")
        write(file, read(f, String))
        write(file, "\n\n")
    end
end
=#
