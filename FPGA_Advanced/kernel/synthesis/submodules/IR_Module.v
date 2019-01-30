module IR_Module(
				//--------------Avalon-------------//
				csi_clk,		//100MHz
				csi_reset_n,
				avs_chipselect,
				avs_address,
				avs_read,
				avs_readdata,
				avs_write,
				avs_writedata,
				//------------IR Interface-----------//
				coe_IRDA_RXD,
				coe_RR,
				coe_RR_led,
				coe_Data,
				coe_Buf,
);
//Avalon
input						csi_clk;		     //100MHz
input						csi_reset_n;     //Low-Level Work
input						avs_chipselect;
input [3:0]				avs_address;
input						avs_read;
output reg [31:0]		avs_readdata;
input						avs_write;
input [31:0]			avs_writedata;

//IR
input 					coe_IRDA_RXD;
wire	[31:0]			mData;
wire						mDataReady;
reg						CLOCK_50;
reg	[2:0]				mDataReadyDetect;
reg	[31:0]			mDataBuf;

//debug
output 					coe_RR;
output 					coe_RR_led;
output [7:0]			coe_Data;
output [7:0]			coe_Buf;

assign					coe_RR = mDataReady;
assign					coe_RR_led = mDataReady;
assign					coe_Data = mData[23:16];
assign					coe_Buf = mDataBuf[23:16];
//CLOCK_50
always@(posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n)
		CLOCK_50 <= 0;
	else
		CLOCK_50 <= ~CLOCK_50;
end

//store data
always@(posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n)
		mDataReadyDetect <= 2'b00;
	else
	begin
		mDataReadyDetect <= {mDataReady, mDataReadyDetect[2], mDataReadyDetect[1],};
		if (mDataReadyDetect == 3'b110)//posedge
			mDataBuf <= mData;
	end
end

//readdata
always@(posedge csi_clk or negedge csi_reset_n)
begin
	if (!csi_reset_n)
		avs_readdata <= 32'b0;
	else if ((avs_chipselect == 1) && (avs_read == 1))
	begin
		avs_readdata <= {mDataReady, mDataBuf[30:0]};
	end
end

IR_RECEIVE(
					.iCLK(CLOCK_50),         //clk 50MHz
					.iRST_n(csi_reset_n),       //reset					
					.iIRDA(coe_IRDA_RXD),        //IR code input
					.oDATA_READY(mDataReady),  //data ready
					.oDATA(mData)         //decode data output
					);

endmodule
