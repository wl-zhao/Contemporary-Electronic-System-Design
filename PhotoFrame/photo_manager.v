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
// Major Functions:	This function will detect the x and y coordinate form 
//                  the touch_spi , if the coordinates fit the picture changing
//					area , this funtionn will output the new displayed photo number
//                  to flash2sdram module   
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            		:| Mod. Date :| Changes Made:
//   V1.0 :| Johnny Fan				:| 07/06/30  :| Initial Revision
// --------------------------------------------------------------------
module photo_manager	(
					iCLK,
					iRST_n,
					iX_COORD,
					iY_COORD,
					iNEW_COORD,
					iIR_READY,
					iKEY,
					iSDRAM_WRITE_EN,
					oPHOTO_CNT,
					oSLEEP,
					oMODE,
					oMENU,
					);
					
//============================================================================
// PARAMETER declarations
//============================================================================					
parameter	PHOTO_NUM = 6;  // total photo numbers 
parameter	NEXT_PIC_XBD1 = 12'h0;
parameter	NEXT_PIC_XBD2 = 12'h300;
parameter	NEXT_PIC_YBD1 = 12'he00;
parameter	NEXT_PIC_YBD2 = 12'hfff;
parameter	PRE_PIC_XBD1 = 12'hd00;
parameter	PRE_PIC_XBD2 = 12'hfff;
parameter	PRE_PIC_YBD1 = 12'h000;
parameter	PRE_PIC_YBD2 = 12'h200;   

parameter	MODE_XBD1 = 12'h600;
parameter	MODE_XBD2 = 12'hb00;
parameter	A_YBD1 = 12'ha50;
parameter	A_YBD2 = 12'he50; 
parameter	B_YBD1 = 12'h600; 
parameter	B_YBD2 = 12'ha50; 
parameter	C_YBD1 = 12'h200; 
parameter	C_YBD2 = 12'h600;                          
//===========================================================================
// PORT declarations
//===========================================================================                      
input			iCLK;				// system clock 50Mhz
input			iRST_n;				// system reset
input	[11:0]	iX_COORD;			// X coordinate form touch panel
input	[11:0]	iY_COORD;			// Y coordinate form touch panel
input			iNEW_COORD;			// new coordinates indicate
input			iSDRAM_WRITE_EN;	// sdram write enable
output	[2:0]	oPHOTO_CNT;			// displaed photo number
input 		iIR_READY;				//IR Ready signal
input 	[7:0] iKEY;					//IR Key Code
output         oSLEEP;
output	[1:0]		oMODE;
output oMENU = menu;
//=============================================================================
// REG/WIRE declarations
//=============================================================================
reg				mnew_coord;
wire			nextpic_en;
wire			prepic_en;
reg				nextpic_set;
reg				prepic_set;
reg				a_set;
reg				b_set;
reg				c_set;
reg		[2:0]	photo_cnt;
reg		[2:0]	last_photo_cnt;
reg		[3:0]	ir_ready_detect;
reg 				autoplay;
reg 	[27:0]	autoplay_cnt;
reg   [27:0]	autoplay_cmp;
reg				autoplay_next;
wire				new_key;
reg 				oSLEEP;
reg				menu;
reg	[1:0]		oMODE; 
//=============================================================================
// Structural coding
//=============================================================================

// if incoming x and y coordinates fit next picture command area , nextpic_en goes high
assign	nextpic_en = ((iX_COORD > NEXT_PIC_XBD1) && (iX_COORD <  NEXT_PIC_XBD2)  &&
					  (iY_COORD > NEXT_PIC_YBD1) && (iY_COORD <  NEXT_PIC_YBD2))
					  ?1:0;
// if incoming x and y coordinates fit previous picture command area , nextpic_en goes high
assign	prepic_en = ((iX_COORD > PRE_PIC_XBD1) && (iX_COORD <  PRE_PIC_XBD2)  &&
					  (iY_COORD > PRE_PIC_YBD1) && (iY_COORD <  PRE_PIC_YBD2))
					  ?1:0;
					  
assign 	A_en = ((iX_COORD > MODE_XBD1) && (iX_COORD <  MODE_XBD2)  &&
					  (iY_COORD > A_YBD1) && (iY_COORD <  A_YBD2))
					  ?1:0;
					  
assign 	B_en = ((iX_COORD > MODE_XBD1) && (iX_COORD <  MODE_XBD2)  &&
					  (iY_COORD > B_YBD1) && (iY_COORD <  B_YBD2))
					  ?1:0;
					  
assign 	C_en = ((iX_COORD > MODE_XBD1) && (iX_COORD <  MODE_XBD2)  &&
					  (iY_COORD > C_YBD1) && (iY_COORD <  C_YBD2))
					  ?1:0;
assign   new_key = (ir_ready_detect == 3'b110);
//update ir_ready_detect signal
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			ir_ready_detect <= 3'b0;
		else
			ir_ready_detect <= {iIR_READY, ir_ready_detect[2], ir_ready_detect[1]};
	end
	
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			mnew_coord<= 0;
		else
			mnew_coord<= iNEW_COORD;	
	end
	
// menu
//always@(posedge iCLK or negedge iRST_n)
//	begin
//		if (!iRST_n)
//			menu <= 0;
//		else if (new_key)
//			if (iKEY == 8'h11)
//				menu <= ~menu;
//			else if (menu)
//			begin
//				case(iKEY)
//				8'h0f:	oMODE <= 0;
//				8'h13:	oMODE <= 1;
//				8'h10:	oMODE <= 2;
//				endcase
//			end
//	end

//always@(posedge iCLK or negedge iRST_n)
//	begin
//		if (!iRST_n)
//			last_photo_cnt <= 0;
//		else if (!menu)
//			last_photo_cnt <= photo_cnt;
//	end
//next or pre pic set

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				nextpic_set <= 0;
				prepic_set <= 0;
			end
		else if (mnew_coord &&(!iSDRAM_WRITE_EN))	
			begin
				if (nextpic_en)
					nextpic_set <= 1;
				else if (prepic_en)
					prepic_set <= 1;
				else
					begin
						prepic_set <= 0;
						nextpic_set <= 0;
					end
				if (A_en)
					a_set <= 1;
				else if (B_en)
					b_set <= 1;
				else if (C_en)
					c_set <= 1;
				else
					begin
						a_set <= 0;
						b_set <= 0;
						c_set <= 0;
					end
			end
		else if (new_key && !autoplay)
			begin
				if (iKEY == 8'h14)
					prepic_set <= 1;
				else if (iKEY == 8'h18)
					nextpic_set <= 1;
				else
					begin
						prepic_set <= 0;
						nextpic_set <= 0;
					end
			end
		else
			begin
				prepic_set <= 0;
				nextpic_set <= 0;
				a_set <= 0;
				b_set <= 0;
				c_set <= 0;
			end
	end	
	
//auto play
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			autoplay <= 0;
		else if (new_key && (iKEY == 8'h16))
			autoplay <= ~autoplay;
		else if (new_key && ((iKEY == 8'h12) || (iKEY == 8'h0c) || (iKEY == 8'h11)))
			autoplay <= 0;
	end
	
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			autoplay_cmp <= 27'd90000000;
		else if (new_key && autoplay)
			begin
				if (iKEY == 8'h14 && autoplay_cmp < 28'd200000000)
					autoplay_cmp <= autoplay_cmp +  28'd020000000;
				else if (iKEY == 8'h18 && autoplay_cmp > 27'd30000000)
					autoplay_cmp <= autoplay_cmp - 28'd020000000;
			end
	end
	
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				autoplay_cnt <= 0;
				autoplay_next <= 0;
			end
		else if (autoplay_cnt < autoplay_cmp)
			begin
				autoplay_cnt <= autoplay_cnt + 1;
				autoplay_next <= 0;
			end
		else
			begin
				autoplay_cnt <= 26'b0;
				autoplay_next <= 1;
			end
	end

//all functions about photo_change
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
				photo_cnt <= 0;
		else
			begin
				begin
				if (!menu && (nextpic_set || (autoplay_next && autoplay)))
					begin
						if(photo_cnt == (PHOTO_NUM-1))
							photo_cnt <= 0;
						else
							photo_cnt <= photo_cnt + 1;	
					end		
				else if (!menu && prepic_set)
					begin
						if(photo_cnt == 0)
							photo_cnt <= (PHOTO_NUM-1);
						else
							photo_cnt <= photo_cnt - 1;	
					end
				else if (a_set)
					oMODE <= 0;
				else if (b_set)
					oMODE <= 1;
				else if (c_set)
					oMODE <= 2;
				else if (new_key)
					begin
						if ((iKEY <= PHOTO_NUM) && (iKEY >= 1))
						begin
							photo_cnt <= iKEY - 1;
							menu <= 0;
						end
						else 
						case (iKEY)
						8'h17:
						begin
							photo_cnt <= 0;
							menu <= 0;
						end
						8'h12:
							begin
								oSLEEP <= ~oSLEEP;
								photo_cnt <= 0;
								menu <= 0;
							end
						8'h0c:
							oSLEEP <= ~oSLEEP;
						8'h11:
						begin
							menu <= ~menu;
							if (!menu)
								begin
									photo_cnt <= PHOTO_NUM;
									last_photo_cnt <= photo_cnt;
								end
							else
								photo_cnt <= last_photo_cnt;
						end
						8'h0f:
							oMODE <= menu ? 0 : oMODE;
						8'h13:
							oMODE <= menu ? 1 : oMODE;
						8'h10:	
							oMODE <= menu ? 2 : oMODE;
						endcase
					end
				end
			end
	end		
		
assign	oPHOTO_CNT = photo_cnt;


endmodule




								