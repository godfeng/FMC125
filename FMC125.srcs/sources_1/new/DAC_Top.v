`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// 
//////////////////////////////////////////////////////////////////////////////////
module ADDA_Top(
    // 系统信号
    input SYSCLK,           // 50MHz
    input SYSRST,
    // spi控制ad9777信号
    input spi_sdi,
    output spi_sdo,
    output spi_cs,
    output spi_sclk,
    
    //adc数据输入信号
    input [13:0] LTM_DA,    // ad 14bit
    input [13:0] LTM_DB,
    input LTM_CLK,
    
    //dac数据输出
    output reg [15:0] cose_data,
    output reg [15:0] sine_data,
    output dac_clk_p,
    output dac_clk_n 
    );
    
    wire clk_160MHz;
    reg[13:0] LTM_DA_r                      /*synthesis syn_preserve=1*/;    //ad 14bit
    reg[13:0] LTM_DB_r                      /*synthesis syn_preserve=1*/;    //ad 14bit
    (* KEEP= "TRUE" *)reg [15:0] cose_r=0  /*synthesis syn_preserve=1*/;
    (* KEEP= "TRUE" *)reg [15:0] sine_r=0  /*synthesis syn_preserve=1*/;
    //----- 分频 50MHz -> 1MHz --------//
    reg [5:0] clk_cnt = 6'b000000;
    reg clk_1MHz = 0;
    always @(posedge SYSCLK)
    begin
        clk_cnt <= clk_cnt + 1;
        if(clk_cnt == 49) begin 
            clk_1MHz <= ~clk_1MHz;
            clk_cnt <= 6'b000000;
        end 
    end
    
    //----- 倍频 50MHz 到 160MHz ------//
     pll_50Mto160M uu0(
     .clk_out(clk_160MHz), 
     .clk_in(SYSCLK)
     );
     
   //-------  时钟差分输出  --------//
   OBUFDS uu1(
   .O(dac_clk_p),
   .OB(dac_clk_n),
   .I(clk_160MHz)
   );
   
   //------- ad9777 配置 --------//
   ad9777_spi_config uu2(
        .clk_in(clk_1MHz),
        .rst(SYSRST),
        .ad9777_sdo(),
        .ad9777_cs(spi_cs),
        .ad9777_sclk(spi_sclk),
        .ad9777_sdi(spi_sdo)
   );
   
   //-----  产生波形  --------//
   always @(posedge clk_160MHz) begin
        sine_r[15:0] <= sine_r + 256;
        cose_r[15:0] <= cose_r + 256;
        sine_data <= sine_r;
        cose_data <= cose_r;
   end
   
   //----- 数据输出 -------//
   always@(posedge	LTM_CLK)
       begin
           LTM_DA_r    <=    LTM_DA;
           LTM_DB_r    <=    LTM_DB;
       end
endmodule
