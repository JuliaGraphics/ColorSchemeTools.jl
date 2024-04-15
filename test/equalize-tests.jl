using Test
using ColorSchemeTools
using ColorSchemes
using Colors

cs = ColorScheme([colorant"yellow",  colorant"red"])

# basic dispatch
@test equalize(cs) isa ColorScheme
@test equalize(cs, W = [0, 0, 0]) isa ColorScheme

# with linear interpolation this is not perceptually uniform
get(cs, 0:0.01:1)

# so generate corrected colors
ncs = equalize(cs.colors, colormodel=:RGB, formula="CIEDE2000", W=[1, 0, 0])

get(ncs, 0:0.01:1)

# Generate an array in Lab space with an uneven
# ramp in lightness and check that this is corrected
labmap = zeros(256, 3)
labmap[1:127, 1] = range(0, stop=40, length=127)
labmap[128:256, 1] = range(40, stop=100, length=129)

rgb_lab_array = [convert(RGB, Lab(l...)) for l in eachrow(labmap)]

afterscheme = equalize(rgb_lab_array, 
    colormodel=:RGB, 
    formula="CIE76",
    W=[1, 0, 0],
    sigma = 1)

# Convert to Nx3 array and then back to lab space. Then check that dL
# is roughly constant

labmap2 = ColorSchemeTools._srgb_to_lab(afterscheme.colors)

dL = labmap2[2:end, 1] - labmap2[1:end-1, 1]

@test maximum(dL[2:end-1]) - minimum(dL[2:end-1]) < 1e-1
