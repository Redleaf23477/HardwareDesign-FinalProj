
/////////////////////////////////////////////////////////////////
// Constants Define
/////////////////////////////////////////////////////////////////

module top(
   input clk,
   input rst,                    // btnc : reset button
   input BTNU,                   // btnu : player go up
   input BTND,                   // btnd : player go down
   input BTNL,
   input BTNR,
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
	wire up_pressed, down_pressed, left_pressed, right_pressed;
	
	debounce up_deb(.pb_debounced(up_pressed), .pb(BTNU), .clk(clk_13));
	debounce down_deb(.pb_debounced(down_pressed), .pb(BTND), .clk(clk_13));
	debounce left_deb(.pb_debounced(left_pressed), .pb(BTNL), .clk(clk_13));
	debounce right_deb(.pb_debounced(right_pressed), .pb(BTNR), .clk(clk_13));
	
	// player
	wire [2:0] player_next_step_type;
	wire [9:0] player_next_step_r, player_next_step_c;
	
	player player_inst(
		.clk_13(clk_13),
		.clk_25MHz(clk_25MHz),
		.rst(rst),
		.up_pressed(up_pressed),
		.down_pressed(down_pressed),
		.left_pressed(left_pressed),
		.right_pressed(right_pressed),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt),
		.dest_type(player_next_step_type),
		.dest_r(player_next_step_r),
		.dest_c(player_next_step_c),
		.pixel_player(pixel_player)
	);
	
	// map
	
	wire [16:0] pixel_addr_map;
	wire [5:0] gen_map_x, gen_map_y;
	wire [2:0] gen_map_return;
	wire [11:0] data;
	
	mt map_type(
		.clk(clk_13),
		.rst(rst),
		.sw_map(sw_map),
		.gen_map_x1(gen_map_x),
		.gen_map_y1(gen_map_y),
		.gen_map_return1(gen_map_return),
		.gen_map_x2(player_next_step_c),
		.gen_map_y2(player_next_step_r),
		.gen_map_return2(player_next_step_type)
	);
	
	blk_mem_gen_map blk_mem_gen_map_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_map),
		.dina(data[11:0]),
		.douta(pixel_map)
	);
	
	mem_addr_gen_map mem_addr_gen_map_inst(
	   .h_cnt(h_cnt),
	   .v_cnt(v_cnt),
	   .pixel_addr(pixel_addr_map),
	   .sx(gen_map_x),
	   .sy(gen_map_y),
	   .map(gen_map_return)
	);


endmodule