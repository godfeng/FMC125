/******************************************************************************
��飺һ��SPIЭ��ͨ����4�ߵ������ߣ�SDI(��������)��SDO(�������)��SCLK(ʱ��)��CS(Ƭѡ)��
            (1)SDO/MOSI - ���豸������������豸��������;
            (2)SDI/MISO - ���豸�������룬���豸�������;
            (3)SCLK - ʱ���źţ������豸����;
            (4)CS/SS - ���豸ʹ���źţ������豸���ơ�
            (5)SPI�����ִ���ģʽ����CPOL��ʱ�Ӽ��ԣ���CPHA��ʱ����λ������
               �����ء��½��ء�ǰ�ء����ش�������ȻҲ��MSB��LSB���䷽ʽ
            (6)��û�����ݽ�����ʱ�����ǵ�ʱ����Ҫô�Ǳ��ָߵ�ƽҪô�Ǳ��ֵ͵�ƽ
     ����AD9777 �ɱ�̵�ʱ���ڲ��˲��������ʱ�����400Msps
      
�ο����ӣ� https://github.com/simoore/FMC151-driver      
******************************************************************************/
module ad9777_spi_config #(
        parameter  REG_NUM = 4'd1,
        parameter SCLK_TIME = 4         //SPI ʱ�ӷ�Ƶ
        )(
    input wire clk_in,                  //ʱ������ 1MHz
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
       
    reg     [1:0]  status;              //״̬��
    reg     [4:0]  lut_value;           //�Ĵ�������ֵ
    reg     [15:0] lut_data;            //�Ĵ�������
    reg     [15:0] spi_data;            //spi������
    reg     [4:0]  spi_count;           //spi���ݴ��������
    
    //----- ��Ƶ -----//
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
