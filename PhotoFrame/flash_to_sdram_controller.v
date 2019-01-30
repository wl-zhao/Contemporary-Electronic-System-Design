// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	Read image data form Flash then write into sdram
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            		:| Mod. Date :| Changes Made:
//   V1.0 :| Johnny Fan				:| 07/06/30  :| Initial Revision
// --------------------------------------------------------------------
module flash_to_sdram_controller(  
					iRST_n,
					iPHOTO_NUM,
					// Flash side
					iF_CLK,
					FL_DQ,			
					oFL_ADDR,		
					oFL_WE_N,		
					oFL_RST_n,		
					oFL_OE_N,		
					oFL_CE_N,		
					// Sdram side
					oSDRAM_WRITE_EN,
					oSDRAM_WRITE,
					oRED,	
					oGREEN,
					oBLUE,
					// Ir side
					iIR_READY,
					iKEY,
					//Other Funtions
					oWRITING,
					iMODE,
					intensity,
					);
//============================================================================
// PARAMETER declarations
//============================================================================
parameter DISP_MODE = 800*480;
//===========================================================================
// PORT declarations
//===========================================================================
input 			iRST_n;					//  System reset
input	[3:0]	iPHOTO_NUM;				//  Picture status
input 			iF_CLK;					//  Flash read clcok
inout	[7:0]	FL_DQ;					//	FLASH Data bus 8 Bits
output	[22:0]	oFL_ADDR;				//	FLASH Address bus 23 Bits
output			oFL_WE_N;				//	FLASH Write Enable
output			oFL_RST_n;				//	FLASH Reset
output			oFL_OE_N;				//	FLASH Output Enable
output			oFL_CE_N;				//	FLASH Chip Enable
output  	  	oSDRAM_WRITE_EN;		//  SDRAM write enable control signal
output     		oSDRAM_WRITE;			//  SDRAM write signal
output 	[7:0] 	oRED;					//  Image red color data to sdram
output 	[7:0] 	oGREEN;					//  Image green color data to sdram
output 	[7:0] 	oBLUE;					//  Image blue color data to sdram	
input					iIR_READY;
input		[7:0]		iKEY;
output 				oWRITING;
input 	[1:0]		iMODE;

wire [11:0] fl_dq_buf;
assign fl_dq_buf[7:0] = FL_DQ;
wire [11:0] fl_dq_adjust = ((intensity[3] == 1) ? (fl_dq_buf << 3) : 0) + 
								  ((intensity[2] == 1) ? (fl_dq_buf << 2) : 0) +
								  ((intensity[1] == 1) ? (fl_dq_buf << 1) : 0) +
								  ((intensity[0] == 1) ? (fl_dq_buf) : 0);
//wire [11:0]  fl_dq_adjust = intensity * fl_dq_buf;
//=============================================================================
// REG/WIRE declarations
//=============================================================================
reg 		  	oSDRAM_WRITE_EN;
reg        		oSDRAM_WRITE;
reg 	[1:0] 	flash_addr_cnt;
reg 	[15:0] 	fl_dq_delay1;
reg 	[15:0] 	fl_dq_delay2;
reg 	[15:0] 	fl_dq_delay3;
reg 	[18:0]	write_cnt ;		
reg		[7:0] 	oRED;	
reg		[7:0] 	oGREEN;
reg		[7:0] 	oBLUE;
wire 		[7:0]		grey1;
wire 		[7:0]		grey2;

reg     [22:0] 	flash_addr_o;
wire    [22:0] 	flash_addr_max;
wire    [22:0] 	flash_addr_min;
wire    [22:0] 	flash_addr_max_n;
wire    [22:0] 	flash_addr_min_n;
reg		[2:0] 	d1_photo_num;
reg		[2:0] 	d2_photo_num;
reg 		[1:0]		d1_mode;
reg		[1:0]		d2_mode;
reg				photo_change;
reg				rgb_sync;
reg				mrgb_sync;
reg		[2:0] ir_ready_detect;
reg				direction;
wire 				new_key;
output reg 	[3:0]		intensity;
reg			[3:0]		last_intensity;

//=============================================================================
// Structural coding
//=============================================================================

assign 	oFL_WE_N  = 1;						
assign 	oFL_RST_n = 1;						
assign 	oFL_OE_N  = 0;						
assign 	oFL_CE_N  = 0;						
assign	oFL_ADDR  = flash_addr_o;
assign	flash_addr_max = 54 + 3*DISP_MODE * (d2_photo_num+1) ; //54(bmp file header)+ 3 x 800x480 (3 800x480 pictures) 
assign	flash_addr_min = 54 + 3*DISP_MODE * iPHOTO_NUM;

assign	flash_addr_max_n = 54 + 3*DISP_MODE * (iPHOTO_NUM+1) ; //54(bmp file header)+ 3 x 800x480 (3 800x480 pictures) 
assign	flash_addr_min_n = 54 + 3*DISP_MODE * d2_photo_num;
assign	new_key = (ir_ready_detect == 3'b110);
assign   oWRITING = (write_cnt != 0);

assign	grey1 = (fl_dq_delay1 * 38 + fl_dq_delay2 * 75 + fl_dq_delay3 * 15) >> 7;
assign	grey2 = (fl_dq_delay3 * 38 + fl_dq_delay2 * 75 + fl_dq_delay1 * 15) >> 7;
////////////////////////////////////////////////////

always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			ir_ready_detect <= 3'b0;
		else 
			ir_ready_detect <= {iIR_READY, ir_ready_detect[2], ir_ready_detect[1]};
	end
	
always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			direction <= 0;
		else if (new_key && (iKEY == 8'h1a))
			direction <= 0;
		else if (new_key && (iKEY == 8'h1e))
			direction <= 1;
	end

always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				d1_photo_num <= 0;
				d2_photo_num <= 0;
				d1_mode <= 0;
				d2_mode <= 0;
			end
		else
			begin		
				d1_photo_num <= iPHOTO_NUM;
            d2_photo_num <= d1_photo_num;
				d1_mode <= iMODE;
				d2_mode <= d1_mode;
			end
    end           
// This is photo change detection
always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			photo_change <= 0;
		else if ((d1_photo_num != iPHOTO_NUM) && (write_cnt == 0))
			photo_change <= 1;	
		else if ((d1_mode != iMODE) || (last_intensity != intensity))
			photo_change <= 1;
		else
			photo_change <= 0;
	end		
// If changing photo , flash_addr_min &   flash_addr_max  & flash_addr_owill chagne ,
// if flash_addr_o  < flash_addr_max , starting read flash data
always @(posedge iF_CLK or negedge iRST_n) 
	begin 
		if ( !iRST_n )	
			begin
				if (!direction)
					flash_addr_o <= flash_addr_min ;
				else
					flash_addr_o <= flash_addr_max_n ;
			end
		else if (photo_change)
			begin
				if (!direction)
					flash_addr_o <= flash_addr_min ;	
				else
					flash_addr_o <= flash_addr_max_n ;	
			end
		else
			begin
				if (!direction)
					begin
						if ( flash_addr_o  <  flash_addr_max ) 
							flash_addr_o <= flash_addr_o + 1;
					end
				else
					begin
						if ( flash_addr_o  >  flash_addr_min_n ) 
							flash_addr_o <= flash_addr_o - 1;
					end
			end
	end

/////////////////////// Sdram write enable control  ////////////////////////////
always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)	
			oSDRAM_WRITE_EN <= 0;
		else if (write_cnt < DISP_MODE)
			begin
			if((!direction && (flash_addr_o < flash_addr_max - 1))||
		      (direction && (flash_addr_o > flash_addr_min_n + 1)))	
				oSDRAM_WRITE_EN <= 1;
			else
				oSDRAM_WRITE_EN <= 0;
			end
		else
			oSDRAM_WRITE_EN <= 0;		
	end			
/////////////////////// delay flash data  for aligning RGB data///////////////
always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin	
				fl_dq_delay1 <= 0;
				fl_dq_delay2 <= 0;
				fl_dq_delay3 <= 0;
			end	
		else
			begin
				fl_dq_delay1 <= fl_dq_adjust[10:3];//(fl_dq_buf * intensity) >> 3;
				fl_dq_delay2 <= fl_dq_delay1;
				fl_dq_delay3 <= fl_dq_delay2;
			end	
	end			


always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)	
			flash_addr_cnt <= 0;
		else if ((!direction) && (flash_addr_o < flash_addr_max) ||
						direction && (flash_addr_o > flash_addr_min_n))
		begin
			if (flash_addr_cnt == 2)		
				flash_addr_cnt <= 0;
			else
				flash_addr_cnt <=flash_addr_cnt + 1;
		end			
		else
			flash_addr_cnt <= 0;
	end			

always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				write_cnt <= 0;
				mrgb_sync <= 0;
			end	
			else if (oSDRAM_WRITE_EN)
				begin
				if (flash_addr_cnt == 1)
				begin
					write_cnt <= write_cnt + 1;
					mrgb_sync <= 1;
				end
				else
					mrgb_sync <= 0;
			end

			else
			begin
				write_cnt <= 0;
				mrgb_sync <= 0;
			end	
	end


always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			rgb_sync <= 0;
		else
			rgb_sync <= mrgb_sync;	
	end

always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				oSDRAM_WRITE <= 0;	
				oRED <= 0; 
				oGREEN <= 0;
				oBLUE <= 0;
			end
		else if (rgb_sync)
			begin
				oSDRAM_WRITE <= 1;
				if (iMODE == 1)
					begin
						oRED <= grey1;
						oGREEN <= grey1;
						oBLUE <= grey1;
					end
				else if (iMODE == 0)
				begin
					if (!direction)
						begin
							oRED 	<= fl_dq_delay1; 
							oGREEN 	<= fl_dq_delay2;
							oBLUE 	<= fl_dq_delay3;
						end
					else
						begin
							oBLUE <= fl_dq_delay3;
							oRED <= fl_dq_delay2;
							oGREEN <= fl_dq_delay1;
						end
				end
				else
				begin
					if (!direction)
						begin
							oGREEN <= fl_dq_delay1; 
							oBLUE <= fl_dq_delay2;
							oRED <= fl_dq_delay3;
						end
					else
						begin
							oRED <= fl_dq_delay3;
							oGREEN <= fl_dq_delay2;
							oBLUE <= fl_dq_delay1;
						end
				end
			end
		else
			begin	
				oSDRAM_WRITE <= 0;
				oRED 	<= 0; 
				oGREEN 	<= 0;
				oBLUE 	<= 0;				 
			end				
	end			

//intensity;

always@(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			intensity <= 4'd8;
		else if (new_key)
		begin
			if ((iKEY == 8'h1b) && (intensity < 4'd8))
				intensity <= intensity + 1;
			else if ((iKEY == 8'h1f) && (intensity > 0))
				intensity <= intensity - 1;
		end
	end
	
always @(posedge iF_CLK or negedge iRST_n)
	begin
		if (!iRST_n)
			last_intensity <= 4'd8;
		else
			last_intensity <= intensity;
	end
endmodule


