/******************************************************************************
简介：一、
     
      
      
参考链接： 
******************************************************************************/
module ad9777_spi_init(
	input CLK_IN,
	input RST,
	output	reg ad9777_SDIO=0,
	output	reg ad9777_SCSB=1'b1,
	output	reg ad9777_SCLK=0,
	output   reg ad9777_SRST=1'b1
    );
	
//==================   待配置属性，可根据要求修改   ===================// 
parameter  REG00h = 16'b00000000_00000000 ;
/*  bit7=1 set ad9777_SDIO output;	bit6=0 MSB first;	bit5=1 software reset;	bit4=1 sleep mode;
    bit3=1 powerdown;	bit2=0 2R mode;	bit1 Pll lock indicator;  */
parameter  REG01h = 16'b00000001_01000101 ;
/*  (bit7,bit6)=(00) interpolation rate = 1x;	(bit5,bit4)=(00) modulation mode = none;	bit3=0 no zero stuffing;	
    bit2=1 real mix mode; bit1=0 rejection of the higher frequency image;	bit0=1 pin8 acts as DATACLK;  */
parameter  REG02h = 16'b00000010_00100000 ;
/*  bit7=0 signed data input;	bit6=0 two port input mode;	bit5=1 enhance DATACLK driver strengeh; bit4=0 DATACLK no invert; 
    bit2=0 ONEPORTCLK no invert;	bit1=0 IQSEL no invert;	bit0=0 I first;	   */
parameter  REG03h = 16'b00000011_00000001 ;
/*  bit7=0 refer to P30 in datasheet;	(bit1,bit0)=(01) PLL predivder = 2;	  */
parameter  REG04h = 16'b00000100_10000000 ;
/*  bit7=1 PLL on;	bit6=0 automatic charge pump control;	(bit2,bit1,bit0)=() charge pump control */
parameter  REG05h = 16'b00000101_00000000 ;
/*  (bit7:bit0) IDAC fine gain adjustment;      */
parameter  REG06h = 16'b00000110_00000000 ;
/*  (bit3:bit0) IDAC coarse gain adjustment;    */
parameter  REG07h = 16'b00000111_00000000 ;
/*  (bit7:bit0) IDAC offset adjustment (9:2);   */
parameter  REG08h = 16'b00001000_00000000 ;
/*  bit7 IDAC Ioffset direction; (bit1,bit0) IDAC offset adjustment (1:0);  */
parameter  REG09h = 16'b00001001_00000000 ;
/*  (bit7:bit0) QDAC fine gain adjustment;      */
parameter  REG0Ah = 16'b00001010_00000000 ;
/*  (bit3:bit0) QDAC coarse gain adjustment;    */
parameter  REG0Bh = 16'b00001011_00000000 ;
/*  (bit7:bit0) QDAC offset adjustment (9:2);   */
parameter  REG0Ch = 16'b00001100_00000000 ;
/*  bit7 QDAC Ioffset direction; (bit1,bit0) QDAC offset adjustment (1:0);  */
reg [207:0] ini_value = {REG00h,REG01h,REG02h,REG03h,REG04h,REG05h,REG06h,REG07h,REG08h,REG09h,REG0Ah,REG0Bh,REG0Ch};

//===========         开始通信      =================//
reg [7:0] counter_1 =0;
reg [3:0] counter_2 =0;
reg ad9777_ini_done = 1'b0;
always@(posedge CLK_IN)begin
	if(RST)begin
		ad9777_ini_done <= 1'b0;
		counter_1 <= 8'b0;
		counter_2 <= 4'b0;
		ad9777_SCSB <= 1'b1;
		ad9777_SRST <= 1'b1;
		ini_value <= {REG00h,REG01h,REG02h,REG03h,REG04h,REG05h,REG06h,REG07h,REG08h,REG09h,REG0Ah,REG0Bh,REG0Ch};
	end
	else if(!ad9777_ini_done)  begin
		ad9777_SCLK <= ~ad9777_SCLK;
		counter_2 <= counter_2 + 1 ;
		if(counter_2 == 4'b1111)begin
			ad9777_SRST <= 1'b0;
		end	
		if(ad9777_SCLK)begin
			if(!ad9777_SRST)begin
				ad9777_SCSB <= 1'b0;
				counter_1 <= counter_1 + 1'b1 ;
				ad9777_SDIO <= ini_value[207] ;
				ini_value <= {ini_value[206:0],ini_value[207]};
				if(counter_1 == 208)begin
					ad9777_ini_done <= 1'b1;
					ad9777_SCSB <= 1'b1;
			   end
		   end
	   end
	end
end
endmodule