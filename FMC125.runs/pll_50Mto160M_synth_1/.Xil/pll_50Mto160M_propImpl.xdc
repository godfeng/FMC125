set_property SRC_FILE_INFO {cfile:{d:/Document/FPGA Code/FMC125/FMC125.srcs/sources_1/ip/pll_50Mto160M/pll_50Mto160M.xdc} rfile:../../../FMC125.srcs/sources_1/ip/pll_50Mto160M/pll_50Mto160M.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in]] 0.2
