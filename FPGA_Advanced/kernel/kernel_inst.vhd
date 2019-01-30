	component kernel is
		port (
			clk_clk                                : in    std_logic                     := 'X';             -- clk
			ir_receive_0_conduit_end_0_export_ir   : in    std_logic                     := 'X';             -- export_ir
			ir_receive_0_conduit_end_0_export_rr   : out   std_logic;                                        -- export_rr
			ir_receive_0_conduit_end_0_export_led  : out   std_logic;                                        -- export_led
			ir_receive_0_conduit_end_0_export_data : out   std_logic_vector(7 downto 0);                     -- export_data
			ir_receive_0_conduit_end_0_export_buf  : out   std_logic_vector(7 downto 0);                     -- export_buf
			lcd_demo_0_conduit_end_0_export_data   : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- export_data
			lcd_demo_0_conduit_end_0_export_rw     : out   std_logic;                                        -- export_rw
			lcd_demo_0_conduit_end_0_export_en     : out   std_logic;                                        -- export_en
			lcd_demo_0_conduit_end_0_export_rs     : out   std_logic;                                        -- export_rs
			lcd_demo_0_conduit_end_0_export_blon   : out   std_logic;                                        -- export_blon
			lcd_demo_0_conduit_end_0_export_on     : out   std_logic;                                        -- export_on
			new_sdram_controller_0_wire_addr       : out   std_logic_vector(12 downto 0);                    -- addr
			new_sdram_controller_0_wire_ba         : out   std_logic_vector(1 downto 0);                     -- ba
			new_sdram_controller_0_wire_cas_n      : out   std_logic;                                        -- cas_n
			new_sdram_controller_0_wire_cke        : out   std_logic;                                        -- cke
			new_sdram_controller_0_wire_cs_n       : out   std_logic;                                        -- cs_n
			new_sdram_controller_0_wire_dq         : inout std_logic_vector(31 downto 0) := (others => 'X'); -- dq
			new_sdram_controller_0_wire_dqm        : out   std_logic_vector(3 downto 0);                     -- dqm
			new_sdram_controller_0_wire_ras_n      : out   std_logic;                                        -- ras_n
			new_sdram_controller_0_wire_we_n       : out   std_logic;                                        -- we_n
			pio_0_external_connection_export       : out   std_logic;                                        -- export
			pio_0_external_connection_1_export     : in    std_logic                     := 'X';             -- export
			reset_reset_n                          : in    std_logic                     := 'X';             -- reset_n
			user_gio_pwm_0_conduit_end_0_export    : out   std_logic                                         -- export
		);
	end component kernel;

	u0 : component kernel
		port map (
			clk_clk                                => CONNECTED_TO_clk_clk,                                --                          clk.clk
			ir_receive_0_conduit_end_0_export_ir   => CONNECTED_TO_ir_receive_0_conduit_end_0_export_ir,   --   ir_receive_0_conduit_end_0.export_ir
			ir_receive_0_conduit_end_0_export_rr   => CONNECTED_TO_ir_receive_0_conduit_end_0_export_rr,   --                             .export_rr
			ir_receive_0_conduit_end_0_export_led  => CONNECTED_TO_ir_receive_0_conduit_end_0_export_led,  --                             .export_led
			ir_receive_0_conduit_end_0_export_data => CONNECTED_TO_ir_receive_0_conduit_end_0_export_data, --                             .export_data
			ir_receive_0_conduit_end_0_export_buf  => CONNECTED_TO_ir_receive_0_conduit_end_0_export_buf,  --                             .export_buf
			lcd_demo_0_conduit_end_0_export_data   => CONNECTED_TO_lcd_demo_0_conduit_end_0_export_data,   --     lcd_demo_0_conduit_end_0.export_data
			lcd_demo_0_conduit_end_0_export_rw     => CONNECTED_TO_lcd_demo_0_conduit_end_0_export_rw,     --                             .export_rw
			lcd_demo_0_conduit_end_0_export_en     => CONNECTED_TO_lcd_demo_0_conduit_end_0_export_en,     --                             .export_en
			lcd_demo_0_conduit_end_0_export_rs     => CONNECTED_TO_lcd_demo_0_conduit_end_0_export_rs,     --                             .export_rs
			lcd_demo_0_conduit_end_0_export_blon   => CONNECTED_TO_lcd_demo_0_conduit_end_0_export_blon,   --                             .export_blon
			lcd_demo_0_conduit_end_0_export_on     => CONNECTED_TO_lcd_demo_0_conduit_end_0_export_on,     --                             .export_on
			new_sdram_controller_0_wire_addr       => CONNECTED_TO_new_sdram_controller_0_wire_addr,       --  new_sdram_controller_0_wire.addr
			new_sdram_controller_0_wire_ba         => CONNECTED_TO_new_sdram_controller_0_wire_ba,         --                             .ba
			new_sdram_controller_0_wire_cas_n      => CONNECTED_TO_new_sdram_controller_0_wire_cas_n,      --                             .cas_n
			new_sdram_controller_0_wire_cke        => CONNECTED_TO_new_sdram_controller_0_wire_cke,        --                             .cke
			new_sdram_controller_0_wire_cs_n       => CONNECTED_TO_new_sdram_controller_0_wire_cs_n,       --                             .cs_n
			new_sdram_controller_0_wire_dq         => CONNECTED_TO_new_sdram_controller_0_wire_dq,         --                             .dq
			new_sdram_controller_0_wire_dqm        => CONNECTED_TO_new_sdram_controller_0_wire_dqm,        --                             .dqm
			new_sdram_controller_0_wire_ras_n      => CONNECTED_TO_new_sdram_controller_0_wire_ras_n,      --                             .ras_n
			new_sdram_controller_0_wire_we_n       => CONNECTED_TO_new_sdram_controller_0_wire_we_n,       --                             .we_n
			pio_0_external_connection_export       => CONNECTED_TO_pio_0_external_connection_export,       --    pio_0_external_connection.export
			pio_0_external_connection_1_export     => CONNECTED_TO_pio_0_external_connection_1_export,     --  pio_0_external_connection_1.export
			reset_reset_n                          => CONNECTED_TO_reset_reset_n,                          --                        reset.reset_n
			user_gio_pwm_0_conduit_end_0_export    => CONNECTED_TO_user_gio_pwm_0_conduit_end_0_export     -- user_gio_pwm_0_conduit_end_0.export
		);

