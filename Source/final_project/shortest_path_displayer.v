
/////////////////////////////////////////////////////////////////
// Constants Define
/////////////////////////////////////////////////////////////////

`define SPRITE_LEN 32
`define SPRITE_SIZE 16

`define MOVE_STOP  3'd0
`define MOVE_DOWN  3'd1
`define MOVE_UP    3'd2
`define MOVE_LEFT  3'd3
`define MOVE_RIGHT 3'd4

`define TRANSPARENT 12'hCBE

/////////////////////////////////////////////////////////////////
// player module
/////////////////////////////////////////////////////////////////

module shortest_path_displayer(
	input clk_25MHz,                  // clock for memory ip
	input [9:0] h_cnt,
	input [9:0] v_cnt,
	output [11:0] pixel_arrow,
	output [9:0] query_r,
	output [9:0] query_c,
	input [2:0] sp_dir
);

	assign query_r = v_cnt / `SPRITE_LEN;
	assign query_c = h_cnt / `SPRITE_LEN;
	
	// memory address generate
	wire [9:0] query_v, query_h;
	wire [9:0]  mem_row, mem_col;
	wire [16:0] pixel_addr;
	
	assign query_v = query_r * `SPRITE_LEN;
	assign query_h = query_c * `SPRITE_LEN;
	assign mem_row = (v_cnt - query_v)>>1;
	assign mem_col = (h_cnt - query_h)>>1;
	assign pixel_addr = mem_row * `SPRITE_SIZE + mem_col;
	
	// address to pixel & ip
	wire [11:0] data;
	wire [11:0] pixel_up, pixel_down, pixel_left, pixel_right;
	
	assign pixel_arrow = (query_r > 9)?            `TRANSPARENT :
						 (sp_dir == `MOVE_UP)?     pixel_up     :
						 (sp_dir == `MOVE_DOWN)?   pixel_down   :
						 (sp_dir == `MOVE_LEFT)?   pixel_left   :
						 (sp_dir == `MOVE_RIGHT)?  pixel_right  :
												   `TRANSPARENT ;
	
	blk_mem_gen_arrow_up blk_mem_gen_arrow_up_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel_up)
    ); 
	blk_mem_gen_arrow_down blk_mem_gen_arrow_down_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel_down)
    ); 
	blk_mem_gen_arrow_left blk_mem_gen_arrow_left_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel_left)
    ); 
	blk_mem_gen_arrow_right blk_mem_gen_arrow_right_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel_right)
    ); 
endmodule
