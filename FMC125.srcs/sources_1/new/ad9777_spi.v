/******************************************************************************
简介：一、SPI协议通常有4线单向串行线，SDI(数据输入)，SDO(数据输出)，SCLK(时钟)，CS(片选)。
            (1)SDO/MOSI - 主设备数据输出，从设备数据输入;
            (2)SDI/MISO - 主设备数据输入，从设备数据输出;
            (3)SCLK - 时钟信号，由主设备产生;
            (4)CS/SS - 从设备使能信号，由主设备控制。
            (5)SPI有四种传输模式，由CPOL（时钟极性）和CPHA（时钟相位）控制
               上升沿、下降沿、前沿、后沿触发。当然也有MSB和LSB传输方式
            (6)当没有数据交流的时候我们的时钟线要么是保持高电平要么是保持低电平
     二、AD9777 可编程的时钟内插滤波器，最大时钟输出400Msps
      
参考链接： https://github.com/simoore/FMC151-driver      
******************************************************************************/
module ad9777_spi_config #(
        parameter  REG_NUM = 4'd1,
        parameter SCLK_TIME = 4         //SPI 时钟分频
        )(
    input wire clk_in,                  //时钟输入 1MHz
    input wire rst,                     //reset
    output reg ad9777_cs,              
    output wire ad9777_sclk,
    input wire ad9777_sdo,              //  spi_sdi(fpga)<--spi_sdo(fmc125)
    output reg ad9777_sdi               //  spi_sdo(fpga)-->spi_sdi(fmc125)
    );
    //=================  parameter ===================//
    //          0   16 15  I4~I0    D7~D0             //
    //         R/W  N1 N0  ADDRESS  D7~D0             //
    localparam      AD9777_ad00H_data = 16'b0_00_00000_00000100,
                    AD9777_ad01H_data = 16'b0_00_00001_00000100,//{BIT7,BIT6}=00 X1 MODE  DATA[0]=1  DATACLK_EN POSETIVE
                    AD9777_ad02H_data = 16'b0_00_00010_01000000,
                    AD9777_ad03H_data = 16'b0_00_00011_00000001,
                    AD9777_ad04H_data = 16'b0_00_00100_10000000,
                    AD9777_ad05H_data = 16'b0_00_00110_11111111,
                    AD9777_ad06H_data = 16'b0_00_00110_11111111,
                    AD9777_ad07H_data = 16'b1_01_01010_10101010,
                    AD9777_ad08H_data = 16'b1_01_01010_10101010,
                    AD9777_ad09H_data = 16'b1_01_01010_10101010,
                    AD9777_ad0aH_data = 16'b0_00_01010_11111111,
                    AD9777_ad0bH_data = 16'b1_01_01010_10101010,
                    AD9777_ad0cH_data = 16'b1_01_01010_10101010,                                            
                    AD9777_ad0dH_data = 16'b1_01_01010_10101010;
                    
    localparam  READY   = 3'b001,
                SENDING = 3'b010,
                FINISH  = 3'b100;       
       
    reg     [1:0]  status;              //状态机
    reg     [4:0]  lut_value;           //寄存器索引值
    reg     [15:0] lut_data;            //寄存器数据
    reg     [15:0] spi_data;            //spi缓存器
    reg     [4:0]  spi_count;           //spi数据传输计数器
    
    //----- 分频 -----//
    reg  [20:0] clk_cnt;
    always@ (posedge clk_in)
    if(!rst)
        clk_cnt<=20'd0;
    else
        clk_cnt<=clk_cnt+1'b1;    
     
    assign ad9777_sclk = (ad9777_cs) ? 1:clk_cnt[SCLK_TIME];
    
    //---- AD9777_SCLK ------//
    always@(negedge ad9777_sclk) begin
        if(!rst)    begin
            lut_value   <= 0;
            status      <= 0;
            spi_count   <= 5'd16;
            ad9777_cs   <= 1;
        end
        else if(lut_value < REG_NUM)    begin
            case(status)
                READY:  
                    begin
                        if(lut_value< REG_NUM) begin
                            spi_count     <= 5'd16;
                            spi_data      <= lut_data;
                            status         <= SENDING;
                        end
                        else 
                            status        <= READY;
                    end      
                SENDING:   
                    begin
                        if(spi_count>0) begin
                            ad9777_cs      <= 0;
                            ad9777_sdi     <= spi_data[15];
                            spi_data[15:1] <= spi_data[14:0];
                            spi_count      <=    spi_count-1;
                            status         <=    SENDING;
                        end
                        else begin
                            status    <=    FINISH;
                            ad9777_cs <=    1;
                        end
                    end
                FINISH:    
                    begin
                        lut_value <=  lut_value+1;
                        status    <=  READY;    
                    end                  
                default :  status <=  READY;
                endcase
            end
    end
    
    always @(*)
    begin
        case(lut_value)
        0    :   lut_data <=  AD9777_ad00H_data;
        1    :   lut_data <=  AD9777_ad01H_data;
        2    :   lut_data <=  AD9777_ad02H_data;
        3    :   lut_data <=  AD9777_ad03H_data;
        4    :   lut_data <=  AD9777_ad04H_data;
        5    :   lut_data <=  AD9777_ad05H_data;
        6    :   lut_data <=  AD9777_ad06H_data;
        7    :   lut_data <=  AD9777_ad07H_data;
        8    :   lut_data <=  AD9777_ad08H_data;
        9    :   lut_data <=  AD9777_ad09H_data;
        10   :   lut_data <=  AD9777_ad0aH_data;
        11   :   lut_data <=  AD9777_ad0bH_data;
        12   :   lut_data <=  AD9777_ad0cH_data;
        13   :   lut_data <=  AD9777_ad0dH_data;
        default : lut_data<=  AD9777_ad00H_data; 
        endcase
    end  
endmodule
