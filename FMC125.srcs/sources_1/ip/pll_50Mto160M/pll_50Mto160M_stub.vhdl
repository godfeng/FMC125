-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.1 (win64) Build 1846317 Fri Apr 14 18:55:03 MDT 2017
-- Date        : Mon Oct 23 10:59:51 2017
-- Host        : GodFeng running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {d:/Document/FPGA
--               Code/FMC125/FMC125.srcs/sources_1/ip/pll_50Mto160M/pll_50Mto160M_stub.vhdl}
-- Design      : pll_50Mto160M
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pll_50Mto160M is
  Port ( 
    clk_out : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );

end pll_50Mto160M;

architecture stub of pll_50Mto160M is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out,clk_in";
begin
end;
