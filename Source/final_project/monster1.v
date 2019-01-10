
/////////////////////////////////////////////////////////////////
// Constants Define
/////////////////////////////////////////////////////////////////

// sprite related

`define SPRITE_LEN 32
`define SPRITE_SIZE 16
`define SPRITE_LOG_LEN 5
`define SPRITE_WALK_DELAY 6
`define SPRITE_MOVE_CNT 12    // SPRITE_LOG_LEN + SPRITE_WALK_DELAY + 1

`define CATCH_THRESHOLD 10    // will run after player when shortest path distance <= CATCH_THRESHOLD

// map constants

`define MAP_WALL    3'b010
`define MAP_ROAD0   3'b000
`define MAP_ROAD1   3'b001
`define MAP_STAIRS  3'b011

`define MAP0_START_R 1
`define MAP0_START_C 14

`define MAP0   3'd0

// move state

`define MOVE_STOP  3'd0
`define MOVE_DOWN  3'd1
`define MOVE_UP    3'd2
`define MOVE_LEFT  3'd3
`define MOVE_RIGHT 3'd4

// hp

`define HP_FULL_monster1      3'd5
`define DAMAGE_PLAYER_SKILL 3'd5

// color

`define TRANSPARENT 12'hCBE

/////////////////////////////////////////////////////////////////
// monster module
/////////////////////////////////////////////////////////////////

module monster1(
	input clk_13,                     // clock same as pb_debounce
	input clk_25MHz,                  // clock for memory ip
	input rst,
	
	input [9:0] h_cnt,                // from vga controller
	input [9:0] v_cnt,
	
	output reg [9:0] monster_r,        // position of monster on map
	output reg [9:0] monster_c,
	
	input player_use_skill,
	output monster_alive,
	
	input [9:0] player_r,
	input [9:0] player_c,
	
	input [2:0] map_idx,
	input [2:0] dir_to_player,         // shortest path direction to player
	input [9:0] dist_to_player,        // shortest path distance to player
	
	output reg [11:0] pixel_monster    // rgb pixel of monster
);

	reg [2:0] move_stat, nxt_move_stat;
	reg [`SPRITE_LOG_LEN+`SPRITE_WALK_DELAY:0] move_cnt, nxt_move_cnt;
	reg [9:0] nxt_monster_r, nxt_monster_c;                        // monster position on map
	reg [9:0] monster_v, monster_h, nxt_monster_v, nxt_monster_h;    // monster position on vga, v = 32*r, h = 23*c;

	// monster position on vga
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			monster_v <= `MAP0_START_R * `SPRITE_LEN;
			monster_h <= `MAP0_START_C * `SPRITE_LEN;
		end else begin
			monster_v <= nxt_monster_v;
			monster_h <= nxt_monster_h;
		end
	end
	always@(*) begin
		case(move_stat)
		`MOVE_STOP: begin
			nxt_monster_v = monster_v;
			nxt_monster_h = monster_h;
		end
		`MOVE_UP: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_monster_v = monster_v-1;
				nxt_monster_h = monster_h;
			end else begin
				nxt_monster_v = monster_v;
				nxt_monster_h = monster_h;
			end
		end
		`MOVE_DOWN: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_monster_v = monster_v+1;
				nxt_monster_h = monster_h;
			end else begin
				nxt_monster_v = monster_v;
				nxt_monster_h = monster_h;
			end
		end
		`MOVE_LEFT: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_monster_v = monster_v;
				nxt_monster_h = monster_h-1;
			end else begin
				nxt_monster_v = monster_v;
				nxt_monster_h = monster_h;
			end
		end
		`MOVE_RIGHT: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_monster_v = monster_v;
				nxt_monster_h = monster_h+1;
			end else begin
				nxt_monster_v = monster_v;
				nxt_monster_h = monster_h;
			end
		end
		default: begin
			nxt_monster_v = monster_v;
			nxt_monster_h = monster_h;
		end
		endcase
	end
	
	// monster moving state / position on map
	
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			monster_r <= `MAP0_START_R;
			monster_c <= `MAP0_START_C;
			move_stat <= `MOVE_STOP;
			move_cnt <= 0;
		end else begin
			monster_r <= nxt_monster_r;
			monster_c <= nxt_monster_c;
			move_stat <= nxt_move_stat;
			move_cnt <= nxt_move_cnt;
		end
	end
	always@(*) begin
		nxt_move_stat = move_stat;
		nxt_move_cnt = move_cnt;
		nxt_monster_r = monster_r;
		nxt_monster_c = monster_c;
		case(move_stat)
		`MOVE_STOP: begin
			if(dist_to_player <= `CATCH_THRESHOLD) begin
				nxt_move_stat = dir_to_player;
				nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
			end
		end
		`MOVE_UP: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
				nxt_monster_r = monster_r - 1;
				nxt_monster_c = monster_c;
			end else begin
				nxt_move_cnt = move_cnt-1;
			end
		end
		`MOVE_DOWN: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
				nxt_monster_r = monster_r + 1;
				nxt_monster_c = monster_c;
			end else begin
				nxt_move_cnt = move_cnt-1;
			end
		end
		`MOVE_LEFT: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
				nxt_monster_r = monster_r;
				nxt_monster_c = monster_c - 1;
			end else begin
				nxt_move_cnt = move_cnt-1;
			end
		end
		`MOVE_RIGHT: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
				nxt_monster_r = monster_r;
				nxt_monster_c = monster_c + 1;
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
	
	// monster alive
	
	reg [4:0] hp, nxt_hp;
	reg [9:0] dr, dc;
	assign monster_alive = (hp > 0)? 1'b1 : 1'b0;
	
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			hp <= `HP_FULL_monster1;
		end else begin
			hp <= nxt_hp;
		end
	end
	always@(*) begin
		nxt_hp = hp;
		dr = (player_r > monster_r)? player_r - monster_r : monster_r - player_r;
		dc = (player_c - monster_c)? player_c - monster_c : monster_c - player_c;
		if(hp > 0 && player_use_skill == 1'b1 && dr+dc <= 2) begin
			nxt_hp = (hp > `DAMAGE_PLAYER_SKILL)? hp - `DAMAGE_PLAYER_SKILL : 0;
		end
	end
	
	// monster display
	wire [11:0] data;
	wire [9:0]  mem_row, mem_col;
	wire [16:0] pixel_addr_monster;
	wire [11:0] pixel_monster1;
	wire monster_display_en;         // whether (h_cnt, v_cnt) is inside monster
	
	assign monster_display_en = (map_idx == `MAP0 && monster_v <= v_cnt && v_cnt <= monster_v+`SPRITE_LEN && monster_h <= h_cnt && h_cnt <= monster_h+`SPRITE_LEN)? 1'b1 : 1'b0;
	assign mem_row = (v_cnt - monster_v)>>1;
	assign mem_col = (h_cnt - monster_h)>>1;
	
	always@(*)begin
		pixel_monster = (monster_alive == 1'b1 && monster_display_en == 1'b1)? pixel_monster1 : `TRANSPARENT;
	end
	
	mem_addr_gen_monster1 mem_addr_gen_monster1_inst(
		.en(monster_display_en),
		.row(mem_row),
		.col(mem_col),
		.pixel_addr(pixel_addr_monster)
	);
	blk_mem_gen_monster1 blk_mem_gen_monster1_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_monster),
		.dina(data[11:0]),
		.douta(pixel_monster1)
    ); 

endmodule

/////////////////////////////////////////////////////////////////
// memory address generator for monster
/////////////////////////////////////////////////////////////////

module mem_addr_gen_monster1(
	input en,
	input [9:0] row,
	input [9:0] col,
	output [16:0] pixel_addr
);

	assign pixel_addr = (en == 1'b1)? row * `SPRITE_SIZE + col : `TRANSPARENT;     //TODO

endmodule