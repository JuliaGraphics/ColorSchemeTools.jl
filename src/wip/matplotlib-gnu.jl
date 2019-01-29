using ColorSchemeTools


_g0(x) = 0
_g1(x) = 0.5
_g2(x) = 1
_g3(x) = x
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
function _g32(x)
   ret = zeros(length(x))
       m = (x < 0.25)
       ret[m] = 4 * x[m]
       m = (x >= 0.25) & (x < 0.92)
       ret[m] = -2 * x[m] + 1.84
       m = (x >= 0.92)
       ret[m] = x[m] / 0.08 - 11.5
       return
end

_g33(x) =  abs(2x - 0.5)
_g34(x) =  2x
_g35(x) =  2x - 0.5
_g36(x) =  2x - 1

# _gnuplot_data = Dict(
#         :red => gfunc(7),
#         :green => gfunc(5),
#         :blue => gfunc(15))

gnuplot = make_colorscheme(_g7, _g5, _g15)

# _gnuplot2_data = Dict(
#         :red => gfunc(30),
#         :green => gfunc(31),
#         :blue => gfunc(32))

gnuplot2 = make_colorscheme(_g30, _g31, _g31)

# _ocean_data = Dict(
#         :red => gfunc(23),
#         :green => gfunc(28),
#         :blue => gfunc(3))

ocean = make_colorscheme(_g23, _g28, _g3)


# _afmhot_data = Dict(
#         :red => gfunc(34),
#         :green => gfunc(35),
#         :blue => gfunc(36))

afmhot = make_colorscheme(_g34, _g35, _g36)


# _rainbow_data = Dict(
#         :red => gfunc(33),
#         :green => gfunc(13),
#         :blue => gfunc(10))


rainbow = make_colorscheme(_g33, _g13, _g10)
