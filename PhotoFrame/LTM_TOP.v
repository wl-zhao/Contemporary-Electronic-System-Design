module LTM_TOP(
       //Global signals
       CLOCK_50,
       RST,
       ////////////LTM_GPIO port
       LTM_ADC_BUSY,
       LTM_ADC_DCLK,
       LTM_ADC_DIN,
       LTM_ADC_DOUT,
       LTM_ADC_PENIRQ_n,
       LTM_B,
       LTM_DEN,
       LTM_G,
       LTM_GREST,
       LTM_HD,
       LTM_NCLK,
       LTM_R,
       LTM_SCEN,
       LTM_SDA,
       LTM_VD,
       ///7-segs
       HEX0,							//	Seven Segment Digit 0
	   HEX1,							//	Seven Segment Digit 1
	   HEX2,							//	Seven Segment Digit 2
	   HEX3,							//	Seven Segment Digit 3
	   HEX4,							//	Seven Segment Digit 4
	   HEX5,							//	Seven Segment Digit 5
	   HEX6,							//	Seven Segment Digit 6
	   HEX7,                            //	Seven Segment Digit 7
	   //flash
	   FL_ADDR,
	   FL_CE_N,
	   FL_DQ,
	   FL_OE_N,
	   FL_RST_N,
	   FL_RY,
	   FL_WE_N,
	   FL_WP_N,
	   //sdram
	   DRAM_ADDR,
	   DRAM_BA,
	   DRAM_CAS_N,
	   DRAM_CKE,
	   DRAM_CLK,
	   DRAM_CS_N,
	   DRAM_DQ,
	   DRAM_DQM,
	   DRAM_RAS_N,
	   DRAM_WE_N,
		//ir
		IR_READY,
		IR_KEY,
		WRITING,
		MODE,
		MENU,
		INT,
       );
///port declaration
input                       CLOCK_50;
input                       RST;
input		          		LTM_ADC_BUSY;
output		          		LTM_ADC_DCLK;
output		          		LTM_ADC_DIN;
input		          		LTM_ADC_DOUT;
input		          		LTM_ADC_PENIRQ_n;
output		     [7:0]		LTM_B;
output		          		LTM_DEN;
output		     [7:0]		LTM_G;
output		          		LTM_GREST;
output		          		LTM_HD;
output		          		LTM_NCLK;
output		     [7:0]		LTM_R;
output		          		LTM_SCEN;
inout		          		LTM_SDA;
output		          		LTM_VD;
///
output	[6:0]	HEX0;					//	Seven Segment Digit 0
output	[6:0]	HEX1;					//	Seven Segment Digit 1
output	[6:0]	HEX2;					//	Seven Segment Digit 2
output	[6:0]	HEX3;					//	Seven Segment Digit 3
output	[6:0]	HEX4;					//	Seven Segment Digit 4
output	[6:0]	HEX5;					//	Seven Segment Digit 5
output	[6:0]	HEX6;					//	Seven Segment Digit 6
output	[6:0]	HEX7;					//	Seven Segment Digit 7
//////////// SDRAM //////////
output		    [12:0]		DRAM_ADDR;
output		     [1:0]		DRAM_BA;
output		          		DRAM_CAS_N;
output		          		DRAM_CKE;
output		          		DRAM_CLK;
output		          		DRAM_CS_N;
inout		    [31:0]		DRAM_DQ;
output		     [3:0]		DRAM_DQM;
output		          		DRAM_RAS_N;
output		          		DRAM_WE_N;
//////////// Flash //////////
output		    [22:0]		FL_ADDR;
output		          		FL_CE_N;
inout		     [7:0]		FL_DQ;
output		          		FL_OE_N;
output		          		FL_RST_N;
input		          		FL_RY;
output		          		FL_WE_N;
output		          		FL_WP_N;
/////////// IR /////////////
input 							IR_READY;
input 	[7:0]					IR_KEY;
output 							WRITING;
output 	[1:0]						MODE;
output 							MENU;
output [3:0]			INT;
///wire reg declaration
// LTM Config//
wire			ltm_sclk;		
wire			ltm_sda;		
wire			ltm_scen;
wire 			ltm_3wirebusy_n;

wire	[11:0] 	x_coord;
wire	[11:0] 	y_coord;
wire			new_coord;	
wire	[2:0]	photo_cnt;
// clock
wire 			F_CLK;// flash read clock
reg 	[31:0] 	div;
// sdram to touch panel timing
wire			mRead;
wire	[31:0]	Read_DATA;
//wire	[15:0]	Read_DATA2;	
//  flash to sdram sdram
wire	[7:0]   sRED;// flash to sdram red pixel data		
wire	[7:0]	sGREEN;// flash to sdram green pixel data
wire	[7:0]	sBLUE;// flash to sdram blue pixel data
wire			sdram_write_en; // flash to sdram write control
wire			sdram_write; // sdram write signal
// system reset
wire			DLY0;
wire			DLY1;
wire			DLY2;


wire adc_cs,adc_dclk;
wire	sleep;
wire [1:0]  mode;
//=======================================================
//  Structural coding
//=======================================================
////////////////////////////////////////
assign MODE = mode;
assign LTM_GREST		= sleep;
assign F_CLK 		= div[3];
assign LTM_ADC_DCLK	= ( adc_dclk & ltm_3wirebusy_n )  |  ( ~ltm_3wirebusy_n & ltm_sclk );
always @( posedge CLOCK_50 )
	begin
		div <= div+1;
	end	
///////
assign FL_WP_N  = 1'b1;
///////////////////////////////////////////////////////////////
lcd_spi_cotroller    u1	   (	
							// Host Side
							.iCLK(CLOCK_50),
							.iRST_n(DLY0),
							// 3 wire Side
							.o3WIRE_SCLK(ltm_sclk),
							.io3WIRE_SDAT(LTM_SDA),
							.o3WIRE_SCEN(LTM_SCEN),
							.o3WIRE_BUSY_n(ltm_3wirebusy_n)
							);	
							
adc_spi_controller	u2		(
							.iCLK(CLOCK_50),
							.iRST_n(DLY0),
							.oADC_DIN(LTM_ADC_DIN),
							.oADC_DCLK(adc_dclk),
							.oADC_CS(),
							.iADC_DOUT(LTM_ADC_DOUT),
							.iADC_BUSY(LTM_ADC_BUSY),
							.iADC_PENIRQ_n(LTM_ADC_PENIRQ_n),
							.oX_COORD(x_coord),
							.oY_COORD(y_coord),
							.oNEW_COORD(new_coord),
							 );

photo_manager	u3	(
							.iCLK(CLOCK_50),
							.iRST_n(DLY0),
							.iX_COORD(x_coord),
							.iY_COORD(y_coord),
							.iNEW_COORD(new_coord),
							.iIR_READY(IR_READY),
							.iKEY(IR_KEY),
							.iSDRAM_WRITE_EN(sdram_write_en),
							.oPHOTO_CNT(photo_cnt),
							.oSLEEP(sleep),
							.oMODE(mode),
							.oMENU(MENU)
							);

flash_to_sdram_controller 	u4	   (
							.iPHOTO_NUM(photo_cnt),
							.iRST_n(DLY1) ,
							.iF_CLK(F_CLK),
							.FL_DQ(FL_DQ),				
							.oFL_ADDR(FL_ADDR) ,			
							.oFL_WE_N(FL_WE_N) ,				
							.oFL_RST_n(FL_RST_N),			
							.oFL_OE_N(FL_OE_N) ,				
							.oFL_CE_N(FL_CE_N) ,				
							.oSDRAM_WRITE_EN(sdram_write_en),
							.oSDRAM_WRITE(sdram_write),
							.oRED(sRED),
							.oGREEN(sGREEN),
							.oBLUE(sBLUE),
							.iIR_READY(IR_READY),
							.iKEY(IR_KEY),
							.oWRITING(WRITING),
							.iMODE(mode),
							.intensity(INT)
							);

SEG7_LUT_8 			u5		(	
							.oSEG0(HEX0),			
							.oSEG1(HEX1),	
							.oSEG2(HEX2),	
							.oSEG3(HEX3),	
							.oSEG4(HEX4),	
							.oSEG5(HEX5),	
							.oSEG6(HEX6),	
							.oSEG7(HEX7),	
							.iDIG({4'h0,x_coord,4'h0,y_coord}),
							.ON_OFF(8'b01110111) 
							);

lcd_timing_controller	u6  ( 
							.iCLK(LTM_NCLK),
							.iRST_n(DLY2),
							// sdram side
							.iREAD_DATA(Read_DATA),
							//.iREAD_DATA2(Read_DATA2),
							.oREAD_SDRAM_EN(mRead),
							// lcd side
							.oLCD_R(LTM_R),
							.oLCD_G(LTM_G),
							.oLCD_B(LTM_B), 
							.oHD(LTM_HD),
							.oVD(LTM_VD),
							.oDEN(LTM_DEN)	
							);
							
//	SDRAM frame buffer
Sdram_Control_2Port	u7	(	//	HOST Side
						    .REF_CLK(CLOCK_50),
							.RESET_N(1'b1),
							//	FIFO Write Side 1
						    .WR_DATA({sRED,sGREEN,sBLUE,8'h0}),
							.WR(sdram_write),
							.WR_FULL(WR_FULL),
							.WR_ADDR(0),
							.WR_MAX_ADDR(800*480),		
							.WR_LENGTH(9'h80),
							.WR_LOAD(!DLY0),
							.WR_CLK(F_CLK),
							/*/	FIFO Write Side 2
							
						    .WR2_DATA({8'h0,sBLUE}),
							.WR2(sdram_write),
							.WR2_ADDR(22'h100000),
							.WR2_MAX_ADDR(22'h100000+800*480),
							.WR2_LENGTH(9'h80),
							.WR2_LOAD(!DLY0),
							.WR2_CLK(F_CLK),*/
							
							//	FIFO Read Side 1
						    .RD_DATA(Read_DATA),
				        	.RD(mRead),
				        	.RD_ADDR(0),			
							.RD_MAX_ADDR(800*480),
							.RD_LENGTH(9'h80),
				        	.RD_LOAD(!DLY0),
							.RD_CLK(LTM_NCLK),
							/*/	FIFO Read Side 2
						   
							.RD2_DATA(Read_DATA2),
				        	.RD2(mRead),
							.RD2_ADDR(22'h100000),			
							.RD2_MAX_ADDR(22'h100000+800*480),
							.RD2_LENGTH(9'h80),
				        	.RD2_LOAD(!DLY0),
							.RD2_CLK(ltm_nclk),*/
							
							//	SDRAM Side
						    .SA(DRAM_ADDR),
						    .BA(DRAM_BA),
						    .CS_N(DRAM_CS_N),
						    .CKE(DRAM_CKE),
						    .RAS_N(DRAM_RAS_N),
				            .CAS_N(DRAM_CAS_N),
				            .WE_N(DRAM_WE_N),
						    .DQ(DRAM_DQ),
				            .DQM(DRAM_DQM),
							.SDR_CLK(DRAM_CLK),
							.CLK_33(LTM_NCLK)
								);
								

Reset_Delay			u8	   (.iCLK(CLOCK_50),
							.iRST(RST),
							.oRST_0(DLY0),
							.oRST_1(DLY1),
							.oRST_2(DLY2)
							);
endmodule
