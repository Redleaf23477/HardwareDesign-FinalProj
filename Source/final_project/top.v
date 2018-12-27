
/////////////////////////////////////////////////////////////////
// Constants Define
/////////////////////////////////////////////////////////////////

`define MAP_ROAD 3'b001

module top(
   input clk,
   input rst,                    // btnc : reset button
   input BTNU,                   // btnu : player go up
   input BTND,                   // btnd : player go down
   input sw_map,
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync
);

	// clocks
	wire clk_13;
	wire clk_22;
	wire clk_25MHz;
	
	clock_divisor clk_wiz_0_inst(
		.clk(clk),
		.clk1(clk_25MHz),
		.clk13(clk_13),
		.clk22(clk_22)
    );
	
	// vga variables
	wire vga_valid;
	wire [9:0] h_cnt; //640
	wire [9:0] v_cnt; //480
	wire [11:0] pixel_player;    // pixel of player
	wire [11:0] pixel_map;       // pixel of map
	wire [11:0] pixel;           // final pixel to display
	
	assign pixel_map = 12'hfff;
	assign {vgaRed, vgaGreen, vgaBlue} = pixel;
	
	vga_controller vga_controller_inst(
		.pclk(clk_25MHz),
		.reset(rst),
		.hsync(hsync),
		.vsync(vsync),
		.valid(vga_valid),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt)
    );
	
	vga_displayer vga_displayer_inst(
		.vga_valid(vga_valid),
		.pixel_player(pixel_player),
		.pixel_map(pixel_map),
		.pixel(pixel)
	);
	
	// button debounce
	wire up_pressed, down_pressed;
	
	debounce up_deb(.pb_debounced(up_pressed), .pb(BTNU), .clk(clk_13));
	debounce down_deb(.pb_debounced(down_pressed), .pb(BTND), .clk(clk_13));
	
	// player
	wire [2:0] player_next_step_type;
	wire [9:0] player_next_step_r, player_next_step_c;
	
	assign player_next_step_type = `MAP_ROAD;
	
	player player_inst(
		.clk_13(clk_13),
		.clk_25MHz(clk_25MHz),
		.rst(rst),
		.up_pressed(up_pressed),
		.down_pressed(down_pressed),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt),
		.dest_type(player_next_step_type),
		.dest_r(player_next_step_type_r),
		.dest_c(player_next_step_type_c),
		.pixel_player(pixel_player)
	);


endmodule