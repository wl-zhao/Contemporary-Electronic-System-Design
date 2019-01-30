
module kernel (
	clk_clk,
	ir_receive_0_conduit_end_0_export_ir,
	ir_receive_0_conduit_end_0_export_rr,
	ir_receive_0_conduit_end_0_export_led,
	ir_receive_0_conduit_end_0_export_data,
	ir_receive_0_conduit_end_0_export_buf,
	lcd_demo_0_conduit_end_0_export_data,
	lcd_demo_0_conduit_end_0_export_rw,
	lcd_demo_0_conduit_end_0_export_en,
	lcd_demo_0_conduit_end_0_export_rs,
	lcd_demo_0_conduit_end_0_export_blon,
	lcd_demo_0_conduit_end_0_export_on,
	new_sdram_controller_0_wire_addr,
	new_sdram_controller_0_wire_ba,
	new_sdram_controller_0_wire_cas_n,
	new_sdram_controller_0_wire_cke,
	new_sdram_controller_0_wire_cs_n,
	new_sdram_controller_0_wire_dq,
	new_sdram_controller_0_wire_dqm,
	new_sdram_controller_0_wire_ras_n,
	new_sdram_controller_0_wire_we_n,
	pio_0_external_connection_export,
	pio_0_external_connection_1_export,
	reset_reset_n,
	user_gio_pwm_0_conduit_end_0_export);	

	input		clk_clk;
	input		ir_receive_0_conduit_end_0_export_ir;
	output		ir_receive_0_conduit_end_0_export_rr;
	output		ir_receive_0_conduit_end_0_export_led;
	output	[7:0]	ir_receive_0_conduit_end_0_export_data;
	output	[7:0]	ir_receive_0_conduit_end_0_export_buf;
	inout	[7:0]	lcd_demo_0_conduit_end_0_export_data;
	output		lcd_demo_0_conduit_end_0_export_rw;
	output		lcd_demo_0_conduit_end_0_export_en;
	output		lcd_demo_0_conduit_end_0_export_rs;
	output		lcd_demo_0_conduit_end_0_export_blon;
	output		lcd_demo_0_conduit_end_0_export_on;
	output	[12:0]	new_sdram_controller_0_wire_addr;
	output	[1:0]	new_sdram_controller_0_wire_ba;
	output		new_sdram_controller_0_wire_cas_n;
	output		new_sdram_controller_0_wire_cke;
	output		new_sdram_controller_0_wire_cs_n;
	inout	[31:0]	new_sdram_controller_0_wire_dq;
	output	[3:0]	new_sdram_controller_0_wire_dqm;
	output		new_sdram_controller_0_wire_ras_n;
	output		new_sdram_controller_0_wire_we_n;
	output		pio_0_external_connection_export;
	input		pio_0_external_connection_1_export;
	input		reset_reset_n;
	output		user_gio_pwm_0_conduit_end_0_export;
endmodule
