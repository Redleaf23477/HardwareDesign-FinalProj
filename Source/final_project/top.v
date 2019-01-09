
/////////////////////////////////////////////////////////////////
// Top Module
/////////////////////////////////////////////////////////////////

module top(
   input clk,
   input rst,                    // btnc : reset button
   input BTNU,                   // btnu : player go up
   input BTND,                   // btnd : player go down
   input BTNL,
   input BTNR,
   input sw_sp_display,
   input sw_map,
   inout PS2_CLK, PS2_DATA,
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

	//KeyboardDecoder
	wire shift_down;
	wire [511:0] key_down;
	wire [8:0] last_change;
	wire been_ready;
	
	KeyboardDecoder key_de (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	//Key Pressed
	wire attack_special_pressed;	//pressed 1
	assign attack_special_pressed = (been_ready && key_down[last_change] == 1'b1) & (last_change == 9'b0_0110_1001);
	
	// vga variables
	wire vga_valid;
	wire [9:0] h_cnt; //640
	wire [9:0] v_cnt; //480
	wire [11:0] pixel_player;    // pixel of player
	wire [11:0] pixel_map;       // pixel of map
	wire [11:0] pixel_arrow;     // pixel of shortest path direction to player
	wire [11:0] pixel_monster0;  // pixel of monster0
	wire [11:0] pixel_attack;	//	pixel of attack
	wire [11:0] pixel_item;		//	pixel of item
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
		.display_sp(sw_sp_display),
		.pixel_arrow(pixel_arrow),
		.pixel_map(pixel_map),
		.pixel_monster0(pixel_monster0),
		.pixel_attack(pixel_attack),
		.pixel_item(pixel_item),
		.pixel(pixel)
	);
	
	// button debounce
	wire up_pressed, down_pressed, left_pressed, right_pressed;
	
	debounce up_deb(.pb_debounced(up_pressed), .pb(BTNU), .clk(clk_13));
	debounce down_deb(.pb_debounced(down_pressed), .pb(BTND), .clk(clk_13));
	debounce left_deb(.pb_debounced(left_pressed), .pb(BTNL), .clk(clk_13));
	debounce right_deb(.pb_debounced(right_pressed), .pb(BTNR), .clk(clk_13));
	
	// player
	wire [9:0] player_r, player_c;
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
		.player_r(player_r),
		.player_c(player_c),
		.pixel_player(pixel_player)
	);
	
	// monster
	
	wire [9:0] monster0_r, monster0_c;
	wire [2:0] dir_monster0_to_player;
	wire [9:0] dist_monster0_to_player;
	
	monster0 monster0_inst(
		.clk_13(clk_13),
		.clk_25MHz(clk_25MHz),
		.rst(rst),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt),
		.monster_r(monster0_r),
		.monster_c(monster0_c),
		.dir_to_player(dir_monster0_to_player),
		.dist_to_player(dist_monster0_to_player),
		.pixel_monster(pixel_monster0)
	);
	
	// debug: display shortest path tree on map
	
	wire [9:0] sp_tree_r, sp_tree_c;
	wire [2:0] sp_tree_dir;
	wire [9:0] sp_tree_dist;
	
	shortest_path_displayer(
		.clk_25MHz(clk_25MHz),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt),
		.pixel_arrow(pixel_arrow),
		.query_r(sp_tree_r),
		.query_c(sp_tree_c),
		.sp_dir(sp_tree_dir)
	);
	
	// shortest path to player
	
	
	wire [2:0] map_state;
	
	assign map_state = 0; // MAP01 = 3'd0
	
	bellman_ford_shortest_path bfsp (
		.clk(clk),
		.rst(rst),
		.player_r(player_r),
		.player_c(player_c),
		.map_stat(map_state),
		// 0th query : display shortest path tree
		.query_r0(sp_tree_r),
		.query_c0(sp_tree_c),
		.sp_dir0(sp_tree_dir),
		.sp_dist0(sp_tree_dist),
		// 1st query : monster0
		.query_r1(monster0_r),
		.query_c1(monster0_c),
		.sp_dir1(dir_monster0_to_player),
		.sp_dist1(dist_monster0_to_player)
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

	wire attacking_special;	//	player is attacking or not
	player_attack player_attack_inst(
		.clk(clk),
		.clk_25MHz(clk_25MHz),
		.rst(rst),
		.attack_special_pressed(attack_special_pressed),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt),
		.player_x(player_c),
		.player_y(player_r),
		.pixel_attack(pixel_attack),
		.attacking_special(attacking_special)
	);
	
	wire item_all_picked;
	item item_inst(
		.clk(clk),
		.clk_25MHz(clk_25MHz),
		.rst(rst),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt),
		.player_x(player_c),
		.player_y(player_r),
		.pixel_item(pixel_item),
		.item_all_picked(item_all_picked)
	);

endmodule