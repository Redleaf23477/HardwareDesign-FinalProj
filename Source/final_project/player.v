
/////////////////////////////////////////////////////////////////
// Constants Define
/////////////////////////////////////////////////////////////////

`define SPRITE_LEN 32
`define SPRITE_SIZE 16
`define SPRITE_LOG_LEN 5
`define SPRITE_WALK_DELAY 5
`define SPRITE_MOVE_CNT 11    // SPRITE_LOG_LEN + SPRITE_WALK_DELAY + 1

`define MAP_WALL 3'b000
`define MAP_ROAD 3'b001

`define MOVE_STOP  3'd0
`define MOVE_DOWN  3'd1
`define MOVE_UP    3'd2

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
	
	input [9:0] h_cnt,                // from vga controller
	input [9:0] v_cnt,
	
	input      [2:0] dest_type,       // next step type (wall, road, ...)
	output reg [9:0] dest_r,          // next step r position
	output reg [9:0] dest_c,          // next step c position
	
	output reg [11:0] pixel_player    // rgb pixel of player
);

	reg [2:0] move_stat, nxt_move_stat;
	reg [`SPRITE_LOG_LEN+`SPRITE_WALK_DELAY:0] move_cnt, nxt_move_cnt;
	reg [9:0] player_r, player_c, nxt_player_r, nxt_player_c;    // player position on map
	reg [9:0] player_v, player_h, nxt_player_v, nxt_player_h;    // player position on vga, v = 32*r, h = 23*c;

	// player position on vga
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			player_v <= 10 * `SPRITE_SIZE;
			player_h <= 10 * `SPRITE_SIZE;
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
		default: begin
			nxt_player_v = player_v;
			nxt_player_h = player_h;
		end
		endcase
	end
	
	// player moving state / position on map
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			player_r <= 10;
			player_c <= 10;
			move_stat <= `MOVE_STOP;
			move_cnt <= 0;
		end else begin
			player_r <= nxt_player_r;
			player_c <= nxt_player_c;
			move_stat <= nxt_move_stat;
			move_cnt <= nxt_move_cnt;
		end
	end
	always@(*) begin
		nxt_move_stat = move_stat;
		nxt_move_cnt = move_cnt;
		dest_r = player_r;
		dest_c = player_c;
		nxt_player_r = player_r;
		nxt_player_c = player_c;
		case(move_stat)
		`MOVE_STOP: begin
			if(up_pressed == 1'b1) begin
				dest_r = player_r - 1;
				dest_c = player_c;
				if(dest_type == `MAP_ROAD) begin
					nxt_move_stat = `MOVE_UP;
					nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
				end else begin
					nxt_move_stat = `MOVE_STOP;
					nxt_move_cnt = 0;
				end
			end else if(down_pressed == 1'b1) begin
				dest_r = player_r + 1;
				dest_c = player_c;
				if(dest_type == `MAP_ROAD) begin
					nxt_move_stat = `MOVE_DOWN;
					nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
					nxt_player_r = dest_r;
					nxt_player_c = dest_c;
				end else begin
					nxt_move_stat = `MOVE_STOP;
					nxt_move_cnt = 0;
				end
			end
		end
		`MOVE_UP: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
			end else begin
				nxt_move_cnt = move_cnt-1;
			end
		end
		`MOVE_DOWN: begin
			if(move_cnt == 0) begin
			 	nxt_move_stat = `MOVE_STOP;
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
	
	// player display
	wire [11:0] data;
	wire [9:0]  mem_row, mem_col;
	wire [16:0] pixel_addr_player;
	wire [11:0] pixel_front, pixel_up0, pixel_up1;
	wire player_display_en;         // whether (h_cnt, v_cnt) is inside player
	assign player_display_en = (player_v <= v_cnt && v_cnt <= player_v+`SPRITE_LEN && player_h <= h_cnt && h_cnt <= player_h+`SPRITE_LEN)? 1'b1 : 1'b0;
	assign mem_row = (v_cnt - player_v)>>1;
	assign mem_col = (h_cnt - player_h)>>1;
	always@(*)begin
		case(move_stat)
		`MOVE_STOP: begin
			pixel_player = pixel_front;
		end
		`MOVE_UP: begin
			if(move_cnt[9:0] < 512) begin
				pixel_player = pixel_up0;
			end else begin
				pixel_player = pixel_up1;
			end
		end
		`MOVE_DOWN: begin
			pixel_player = pixel_front;
		end
		default: begin
			pixel_player = pixel_front;
		end
		endcase
	end
	mem_addr_gen_player mem_addr_gen_player_inst(
		.en(player_display_en),
		.row(mem_row),
		.col(mem_col),
		.pixel_addr(pixel_addr_player)
	);
	blk_mem_gen_player_front blk_mem_gen_player_front_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr_player),
		.dina(data[11:0]),
		.douta(pixel_front)
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

	assign pixel_addr = (en == 1'b1)? row * `SPRITE_SIZE + col : `TRANSPARENT;

endmodule