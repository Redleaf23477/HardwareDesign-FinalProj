
/////////////////////////////////////////////////////////////////
// Constants Define
/////////////////////////////////////////////////////////////////

// sprite related

`define SPRITE_LEN 32
`define SPRITE_SIZE 16
`define SPRITE_LOG_LEN 5
`define SPRITE_WALK_DELAY 5
`define SPRITE_MOVE_CNT 11    // SPRITE_LOG_LEN + SPRITE_WALK_DELAY + 1

// map constants

`define MAP_WALL    3'b010
`define MAP_ROAD0   3'b000
`define MAP_ROAD1   3'b001
`define MAP_STAIRS  3'b011

`define MAP0_START_R 3
`define MAP0_START_C 3

`define MAP0  3'd0

// move state

`define MOVE_STOP  3'd0
`define MOVE_DOWN  3'd1
`define MOVE_UP    3'd2
`define MOVE_LEFT  3'd3
`define MOVE_RIGHT 3'd4

// hp

`define HP_FULL_PLAYER  5
`define DAMAGE_MONSTER0 1

// color

`define TRANSPARENT 12'hCBE

/////////////////////////////////////////////////////////////////
// player module
/////////////////////////////////////////////////////////////////

module player(
	input clk_13,                     // clock same as pb_debounce
	input clk_25MHz,                  // clock for memory ip
	input rst,
	input up_pressed,
	input down_pressed,
	input left_pressed,
	input right_pressed,
	
	input [9:0] h_cnt,                // from vga controller
	input [9:0] v_cnt,
	
	input      [2:0] dest_type,       // next step type (wall, road, ...)
	output reg [9:0] dest_r,          // next step r position
	output reg [9:0] dest_c,          // next step c position
	
	output reg [9:0] player_r,        // position of player on map
	output reg [9:0] player_c,
	output [4:0] player_hp,
	output player_alive,
	
	input [2:0] map_idx,
	
	input [9:0] monster0_r,
	input [9:0] monster0_c,
	input monster0_alive,
	input [9:0] monster1_r,
	input [9:0] monster1_c,
	input monster1_alive,
	input [9:0] monster2_r,
	input [9:0] monster2_c,
	input monster2_alive,
	input [9:0] monster3_r,
	input [9:0] monster3_c,
	input monster3_alive,
	
	output reg [11:0] pixel_player	// rgb pixel of player
	
	
);

	reg [2:0] move_stat, nxt_move_stat;
	reg [2:0] pressed, nxt_pressed;
	reg [`SPRITE_LOG_LEN+`SPRITE_WALK_DELAY:0] move_cnt, nxt_move_cnt;
	reg [9:0] nxt_player_r, nxt_player_c;                        // player position on map
	reg [9:0] player_v, player_h, nxt_player_v, nxt_player_h;    // player position on vga, v = 32*r, h = 23*c;

	// player position on vga
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			player_v <= `MAP0_START_R * `SPRITE_LEN;
			player_h <= `MAP0_START_C * `SPRITE_LEN;
		end else begin
			player_v <= nxt_player_v;
			player_h <= nxt_player_h;
		end
	end
	always@(*) begin
		case(move_stat)
		`MOVE_STOP: begin
			nxt_player_v = player_v;
			nxt_player_h = player_h;
		end
		`MOVE_UP: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_player_v = player_v-1;
				nxt_player_h = player_h;
			end else begin
				nxt_player_v = player_v;
				nxt_player_h = player_h;
			end
		end
		`MOVE_DOWN: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_player_v = player_v+1;
				nxt_player_h = player_h;
			end else begin
				nxt_player_v = player_v;
				nxt_player_h = player_h;
			end
		end
		`MOVE_LEFT: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_player_v = player_v;
				nxt_player_h = player_h-1;
			end else begin
				nxt_player_v = player_v;
				nxt_player_h = player_h;
			end
		end
		`MOVE_RIGHT: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_player_v = player_v;
				nxt_player_h = player_h+1;
			end else begin
				nxt_player_v = player_v;
				nxt_player_h = player_h;
			end
		end
		default: begin
			nxt_player_v = player_v;
			nxt_player_h = player_h;
		end
		endcase
	end
	
	// player moving state / position on map
	wire dest_is_valid;
	assign dest_is_valid = (dest_type == `MAP_ROAD0 || dest_type == `MAP_ROAD1 || dest_type == `MAP_STAIRS)? 1'b1 : 1'b0;
	
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			player_r <= `MAP0_START_R;
			player_c <= `MAP0_START_C;
			move_stat <= `MOVE_STOP;
			pressed <= `MOVE_STOP;
			move_cnt <= 0;
		end else begin
			player_r <= nxt_player_r;
			player_c <= nxt_player_c;
			move_stat <= nxt_move_stat;
			pressed <= nxt_pressed;
			move_cnt <= nxt_move_cnt;
		end
	end
	always@(*) begin
		nxt_move_stat = move_stat;
		nxt_pressed = pressed;
		nxt_move_cnt = move_cnt;
		dest_r = player_r;
		dest_c = player_c;
		nxt_player_r = player_r;
		nxt_player_c = player_c;
		case(move_stat)
		`MOVE_STOP: begin
			if (hp > 0) begin				
				if(up_pressed == 1'b1) begin
					nxt_pressed = `MOVE_UP;
					dest_r = player_r - 1;
					dest_c = player_c;
					if(dest_is_valid == 1'b1) begin
						nxt_move_stat = `MOVE_UP;
						nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
						nxt_player_r = dest_r;
						nxt_player_c = dest_c;
					end else begin
						nxt_move_stat = `MOVE_STOP;
						nxt_move_cnt = 0;
					end
				end else if(down_pressed == 1'b1) begin
					nxt_pressed = `MOVE_DOWN;
					dest_r = player_r + 1;
					dest_c = player_c;
					if(dest_is_valid == 1'b1) begin
						nxt_move_stat = `MOVE_DOWN;
						nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
						nxt_player_r = dest_r;
						nxt_player_c = dest_c;
					end else begin
						nxt_move_stat = `MOVE_STOP;
						nxt_move_cnt = 0;
					end
				end else if(left_pressed == 1'b1) begin
					nxt_pressed = `MOVE_LEFT;
					dest_r = player_r;
					dest_c = player_c - 1;
					if(dest_is_valid == 1'b1) begin
						nxt_move_stat = `MOVE_LEFT;
						nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
						nxt_player_r = dest_r;
						nxt_player_c = dest_c;
					end else begin
						nxt_move_stat = `MOVE_STOP;
						nxt_move_cnt = 0;
					end
				end else if(right_pressed == 1'b1) begin
					nxt_pressed = `MOVE_RIGHT;
					dest_r = player_r;
					dest_c = player_c + 1;
					if(dest_is_valid == 1'b1) begin
						nxt_move_stat = `MOVE_RIGHT;
						nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
						nxt_player_r = dest_r;
						nxt_player_c = dest_c;
					end else begin
						nxt_move_stat = `MOVE_STOP;
						nxt_move_cnt = 0;
					end
				end
			end
		end
		`MOVE_UP: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
				nxt_player_r = player_r-1;
				nxt_player_c = player_c;
			end else begin
				nxt_move_cnt = move_cnt-1;
			end
		end
		`MOVE_DOWN: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
				nxt_player_r = player_r+1;
				nxt_player_c = player_c;
			end else begin
				nxt_move_cnt = move_cnt-1;
			end
		end
		`MOVE_LEFT: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
				nxt_player_r = player_r;
				nxt_player_c = player_c-1;
			end else begin
				nxt_move_cnt = move_cnt-1;
			end
		end
		`MOVE_RIGHT: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
				nxt_player_r = player_r;
				nxt_player_c = player_c+1;
			end else begin
				nxt_move_cnt = move_cnt-1;
			end
		end
		default: begin
			nxt_move_stat = `MOVE_STOP;
			nxt_move_cnt = 0;
		end
		endcase
	end
	

	// player hp, maybe need faster clock?
	reg [4:0] hp;
	reg [19:0] prv_monster0_pos, prv_monster1_pos, prv_monster2_pos, prv_monster3_pos;
	wire touch_monster0, touch_monster1, touch_monster2, touch_monster3;

	assign player_alive = (hp > 0)? 1'b1 : 1'b0;
	assign touch_monster0 = (map_idx == `MAP0 && monster0_alive == 1'b1 && prv_monster0_pos != {monster0_r, monster0_c} && {monster0_r, monster0_c} == {player_r, player_c})? 1'b1 : 1'b0;
	assign touch_monster1 = (map_idx == `MAP0 && monster1_alive == 1'b1 && prv_monster1_pos != {monster1_r, monster1_c} && {monster1_r, monster1_c} == {player_r, player_c})? 1'b1 : 1'b0;
	assign touch_monster2 = (map_idx == `MAP0 && monster2_alive == 1'b1 && prv_monster2_pos != {monster2_r, monster2_c} && {monster2_r, monster2_c} == {player_r, player_c})? 1'b1 : 1'b0;
	assign touch_monster3 = (map_idx == `MAP0 && monster3_alive == 1'b1 && prv_monster3_pos != {monster3_r, monster3_c} && {monster3_r, monster3_c} == {player_r, player_c})? 1'b1 : 1'b0;
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			hp <= `HP_FULL_PLAYER;
			prv_monster0_pos <= {monster0_r, monster0_c};
			prv_monster1_pos <= {monster1_r, monster1_c};
			prv_monster2_pos <= {monster2_r, monster2_c};
			prv_monster3_pos <= {monster3_r, monster3_c};
		end else begin
			hp <= nxt_hp(hp, touch_monster0, touch_monster1, touch_monster2, touch_monster3);
			prv_monster0_pos <= {monster0_r, monster0_c};
			prv_monster1_pos <= {monster1_r, monster1_c};
			prv_monster2_pos <= {monster2_r, monster2_c};
			prv_monster3_pos <= {monster3_r, monster3_c};
		end
	end
	
	// player display
	wire [11:0] data;
	wire [9:0]  mem_row, mem_col;
	wire [16:0] pixel_addr_player;
	wire [11:0] pixel_up0, pixel_up1, pixel_up2;
	wire [11:0] pixel_down0, pixel_down1, pixel_down2;
	wire [11:0] pixel_left0, pixel_left1, pixel_left2;
	wire [11:0] pixel_right0, pixel_right1, pixel_right2;
	wire player_display_en;         // whether (h_cnt, v_cnt) is inside player
	
	assign player_display_en = (player_v <= v_cnt && v_cnt <= player_v+`SPRITE_LEN && player_h <= h_cnt && h_cnt <= player_h+`SPRITE_LEN)? 1'b1 : 1'b0;
	assign mem_row = (v_cnt - player_v)>>1;
	assign mem_col = (h_cnt - player_h)>>1;
	
	always@(*)begin
		case(move_stat)
		`MOVE_STOP: begin
			if(pressed == `MOVE_UP) begin
				pixel_player = pixel_up0;
			end else if(pressed == `MOVE_DOWN) begin
				pixel_player = pixel_down0;
			end else if(pressed == `MOVE_LEFT) begin
				pixel_player = pixel_left0;
			end else if(pressed == `MOVE_RIGHT) begin
				pixel_player = pixel_right0;
			end else begin
				pixel_player = pixel_down0;
			end
		end
		`MOVE_UP: begin
			if(move_cnt[9:0] < 512) begin
				pixel_player = pixel_up1;
			end else begin
				pixel_player = pixel_up2;
			end
		end
		`MOVE_DOWN: begin
			if(move_cnt[9:0] < 512) begin
				pixel_player = pixel_down1;
			end else begin
				pixel_player = pixel_down2;
			end
		end
		`MOVE_LEFT: begin
			if(move_cnt[9:0] < 512) begin
				pixel_player = pixel_left1;
			end else begin
				pixel_player = pixel_left2;
			end
		end
		`MOVE_RIGHT: begin
			if(move_cnt[9:0] < 512) begin
				pixel_player = pixel_right1;
			end else begin
				pixel_player = pixel_right2;
			end
		end
		default: begin
			pixel_player = pixel_down0;
		end
		endcase
		pixel_player = (player_alive == 1'b1 && player_display_en == 1'b1)? pixel_player : `TRANSPARENT;
	end
	mem_addr_gen_player mem_addr_gen_player_inst(
		.en(player_display_en),
		.row(mem_row),
		.col(mem_col),
		.pixel_addr(pixel_addr_player)
	);
	blk_mem_gen_player_up0 blk_mem_gen_player_up0_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_up0)
    ); 
	blk_mem_gen_player_up1 blk_mem_gen_player_up1_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_up1)
    ); 
	blk_mem_gen_player_up2 blk_mem_gen_player_up2_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_up2)
    ); 
	blk_mem_gen_player_down0 blk_mem_gen_player_down0_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_down0)
    ); 
	blk_mem_gen_player_down1 blk_mem_gen_player_down1_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_down1)
    ); 
	blk_mem_gen_player_down2 blk_mem_gen_player_down2_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_down2)
    ); 
	blk_mem_gen_player_left0 blk_mem_gen_player_left0_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_left0)
    ); 
	blk_mem_gen_player_left1 blk_mem_gen_player_left1_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_left1)
    ); 
	blk_mem_gen_player_left2 blk_mem_gen_player_left2_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_left2)
    ); 
	blk_mem_gen_player_right0 blk_mem_gen_player_right0_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_right0)
    ); 
	blk_mem_gen_player_right1 blk_mem_gen_player_right1_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_right1)
    ); 
	blk_mem_gen_player_right2 blk_mem_gen_player_right2_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_right2)
    ); 
	
	function [4:0] nxt_hp;
		input [4:0] hp;
		input touch_monster0, touch_monster1, touch_monster2, touch_monster3;
		reg [4:0] acc0, acc1, acc2, acc3;
		begin
			acc0 = (touch_monster0 == 1'b1)? 1 : 0;
			acc1 = (touch_monster1 == 1'b1)? acc0+1 : acc0;
			acc2 = (touch_monster2 == 1'b1)? acc1+1 : acc1;
			acc3 = (touch_monster3 == 1'b1)? acc2+1 : acc2;
			nxt_hp = (hp > acc3)? hp - acc3 : 0;
		end
	endfunction

endmodule

/////////////////////////////////////////////////////////////////
// memory address generator for player
/////////////////////////////////////////////////////////////////

module mem_addr_gen_player(
	input en,
	input [9:0] row,
	input [9:0] col,
	output [16:0] pixel_addr
);

	assign pixel_addr = (en == 1'b1)? row * `SPRITE_SIZE + col : `TRANSPARENT;     //TODO

endmodule