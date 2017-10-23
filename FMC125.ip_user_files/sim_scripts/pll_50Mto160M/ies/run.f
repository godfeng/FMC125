-makelib ies/xil_defaultlib -sv \
  "D:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies/xpm \
  "D:/Xilinx/Vivado/2017.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../FMC125.srcs/sources_1/ip/pll_50Mto160M/pll_50Mto160M_clk_wiz.v" \
  "../../../../FMC125.srcs/sources_1/ip/pll_50Mto160M/pll_50Mto160M.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

