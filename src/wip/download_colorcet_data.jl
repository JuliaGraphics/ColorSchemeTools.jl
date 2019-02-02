url = "https://raw.githubusercontent.com/pyviz/colorcet/master/assets/CETperceptual_csv_0_1/"

filelist = [
"cyclic_grey_15-85_c0_n256.csv",
"cyclic_grey_15-85_c0_n256_s25.csv",
"cyclic_mrybm_35-75_c68_n256.csv",
"cyclic_mrybm_35-75_c68_n256_s25.csv",
"cyclic_mygbm_30-95_c78_n256.csv",
"cyclic_mygbm_30-95_c78_n256_s25.csv",
"cyclic_wrwbw_40-90_c42_n256.csv",
"cyclic_wrwbw_40-90_c42_n256_s25.csv",
"diverging-isoluminant_cjm_75_c23_n256.csv",
"diverging-isoluminant_cjm_75_c24_n256.csv",
"diverging-isoluminant_cjo_70_c25_n256.csv",
"diverging-linear_bjr_30-55_c53_n256.csv",
"diverging-linear_bjy_30-90_c45_n256.csv",
"diverging-rainbow_bgymr_45-85_c67_n256.csv",
"diverging_bkr_55-10_c35_n256.csv",
"diverging_bky_60-10_c30_n256.csv",
"diverging_bwr_40-95_c42_n256.csv",
"diverging_bwr_55-98_c37_n256.csv",
"diverging_cwm_80-100_c22_n256.csv",
"diverging_gkr_60-10_c40_n256.csv",
"diverging_gwr_55-95_c38_n256.csv",
"diverging_gwv_55-95_c39_n256.csv",
"isoluminant_cgo_70_c39_n256.csv",
"isoluminant_cgo_80_c38_n256.csv",
"isoluminant_cm_70_c39_n256.csv",
"linear_bgy_10-95_c74_n256.csv",
"linear_bgyw_15-100_c67_n256.csv",
"linear_bgyw_15-100_c68_n256.csv",
"linear_blue_5-95_c73_n256.csv",
"linear_blue_95-50_c20_n256.csv",
"linear_bmw_5-95_c86_n256.csv",
"linear_bmw_5-95_c89_n256.csv",
"linear_bmy_10-95_c71_n256.csv",
"linear_bmy_10-95_c78_n256.csv",
"linear_gow_60-85_c27_n256.csv",
"linear_gow_65-90_c35_n256.csv",
"linear_green_5-95_c69_n256.csv",
"linear_grey_0-100_c0_n256.csv",
"linear_grey_10-95_c0_n256.csv",
"linear_kry_5-95_c72_n256.csv",
"linear_kry_5-98_c75_n256.csv",
"linear_kryw_0-100_c71_n256.csv",
"linear_kryw_5-100_c64_n256.csv",
"linear_kryw_5-100_c67_n256.csv",
"linear_ternary-blue_0-44_c57_n256.csv",
"linear_ternary-green_0-46_c42_n256.csv",
"linear_ternary-red_0-50_c52_n256.csv",
"rainbow_bgyr_35-85_c72_n256.csv",
"rainbow_bgyr_35-85_c73_n256.csv",
"rainbow_bgyrm_35-85_c69_n256.csv",
"rainbow_bgyrm_35-85_c71_n256.csv"]

function getdatafiles()
	filedata = []
	for fname in filelist
		tempfile = download(url * fname)
		fcontents = open(tempfile) do f
			push!(filedata, (fname, read(f, String)))
		end
	end
	return filedata
end

function build_colorschemes(io, colorcetdata)
	for i in 1:length(colorcetdata)
		schemename = colorcetdata[i][1]
		schemename = replace(schemename, "-" => "_")
		schemename = replace(schemename, ".csv" => "")
		rawcolorvalues = colorcetdata[i][2]
		println(io, "loadcolorscheme(:$(schemename), [")
		for l in split(rawcolorvalues, "\n")
		    !isempty(l) && println(io, "\tRGB($l),")
		end
		println(io, "], \"colorcet\", \"\")\n")
	end
end

# colorcetdata = getdatafiles()

build_colorschemes(stdin, colorcetdata)

open("/tmp/colorcetdata.jl", "w") do f
	build_colorschemes(f, colorcetdata)
end
