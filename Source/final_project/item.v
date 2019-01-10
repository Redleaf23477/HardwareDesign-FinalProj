module item(input clk,
			input clk_25MHz,
			input rst,
			input [9:0] h_cnt,
			input [9:0] v_cnt,
			input [9:0] player_x,	//player_c
			input [9:0] player_y,	//player_r
			output wire [11:0] pixel_item,	// rgb pixel of attack
			output item_all_picked
);
	
/////////////////////////////////////////////////////////////////
// preprocessed
/////////////////////////////////////////////////////////////////
	
	wire [16:0] pixel_addr;
	
	wire [9:0] hc, vc;
	assign hc = h_cnt>>1;
	assign vc = v_cnt>>1;
	wire [5:0] sx, sy;
	assign sx = ((hc / 16) < 20) ? (hc / 16) : 19;
	assign sy = ((vc / 16) < 10) ? (vc / 16) : 9;
	
/////////////////////////////////////////////////////////////////
// item declare
/////////////////////////////////////////////////////////////////
	
	parameter item1_x = 6'd8;
	parameter item1_y = 6'd7;
	parameter item2_x = 6'd15;
	parameter item2_y = 6'd4;
	reg item1_exist;
	reg item2_exist;
	assign item_all_picked = (item1_exist && item2_exist) ? 1 : 0;

/////////////////////////////////////////////////////////////////
// pixel
/////////////////////////////////////////////////////////////////
	
	always @ (posedge clk, posedge rst) begin
		if (rst) begin
			item1_exist = 1;
			item2_exist = 1;
		end else begin
			if ( player_x == item1_x && player_y == item1_y ) begin
				item1_exist = 0;
			end else if ( player_x == item2_x && player_y == item2_y ) begin
				item2_exist = 0;
			end
		end
	end
	
	assign pixel_addr = (!(hc < 320 && vc < 160)) ? 0 :
						( sx == item1_x && sy == item1_y && item1_exist) ? (hc % 16 + 16 * (vc % 16)) :
						( sx == item2_x && sy == item2_y && item2_exist) ? (hc % 16 + 16 * (vc % 16)) : 0;

						
	wire [11:0] data;
	blk_mem_gen_item1 blk_mem_gen_item1_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel_item)
    );
    
endmodule