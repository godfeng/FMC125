// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.1 (win64) Build 1846317 Fri Apr 14 18:55:03 MDT 2017
// Date        : Mon Oct 23 10:59:51 2017
// Host        : GodFeng running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {d:/Document/FPGA
//               Code/FMC125/FMC125.srcs/sources_1/ip/pll_50Mto160M/pll_50Mto160M_stub.v}
// Design      : pll_50Mto160M
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module pll_50Mto160M(clk_out, clk_in)
/* synthesis syn_black_box black_box_pad_pin="clk_out,clk_in" */;
  output clk_out;
  input clk_in;
endmodule
