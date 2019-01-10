module item(input clk,
			input clk_25MHz,
			input rst,
			input [9:0] h_cnt,
			input [9:0] v_cnt,
			input [9:0] player_x,	//player_c
			input [9:0] player_y,	//player_r
			output wire [11:0] pixel_item,	// rgb pixel of attack
			output [4:0] item_picked_cnt
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
	
	parameter item1_y = 6'd7;
	parameter item1_x = 6'd8;
	parameter item2_y = 6'd4;
	parameter item2_x = 6'd15;
	parameter item3_y = 6'd4;
	parameter item3_x = 6'd1;
	parameter item4_y = 6'd6;
	parameter item4_x = 6'd1;
	parameter item5_y = 6'd1;
	parameter item5_x = 6'd7;
	parameter item6_y = 6'd8;
	parameter item6_x = 6'd6;
	parameter item7_y = 6'd1;
	parameter item7_x = 6'd13;
	parameter item8_y = 6'd8;
	parameter item8_x = 6'd16;
	reg item1_exist;
	reg item2_exist;
	reg item3_exist;
	reg item4_exist;
	reg item5_exist;
	reg item6_exist;
	reg item7_exist;
	reg item8_exist;
	reg [4:0] item_picked_cnt;

/////////////////////////////////////////////////////////////////
// pixel	item_picked_cnt
/////////////////////////////////////////////////////////////////
	
	always @ (posedge clk, posedge rst) begin
		if (rst) begin
			item1_exist = 1;
			item2_exist = 1;
			item3_exist = 1;
			item4_exist = 1;
			item5_exist = 1;
			item6_exist = 1;
			item7_exist = 1;
			item8_exist = 1;
			item_picked_cnt = 0;
		end else begin
			if ( player_x == item1_x && player_y == item1_y ) begin
				if (item1_exist == 0) begin
					item_picked_cnt <= item_picked_cnt;
				end else begin
					item1_exist <= 0;
					item_picked_cnt <= item_picked_cnt + 1;
				end
			end else if ( player_x == item2_x && player_y == item2_y ) begin
				if (item2_exist == 0) begin
					item_picked_cnt <= item_picked_cnt;
				end else begin
					item2_exist <= 0;
					item_picked_cnt <= item_picked_cnt + 1;
				end
			end else if ( player_x == item3_x && player_y == item3_y ) begin
				if (item3_exist == 0) begin
					item_picked_cnt <= item_picked_cnt;
				end else begin
					item3_exist <= 0;
					item_picked_cnt <= item_picked_cnt + 1;
				end
			end else if ( player_x == item4_x && player_y == item4_y ) begin
				if (item4_exist == 0) begin
					item_picked_cnt <= item_picked_cnt;
				end else begin
					item4_exist <= 0;
					item_picked_cnt <= item_picked_cnt + 1;
				end
			end else if ( player_x == item5_x && player_y == item5_y ) begin
				if (item5_exist == 0) begin
					item_picked_cnt <= item_picked_cnt;
				end else begin
					item5_exist <= 0;
					item_picked_cnt <= item_picked_cnt + 1;
				end
			end else if ( player_x == item6_x && player_y == item6_y ) begin
				if (item6_exist == 0) begin
					item_picked_cnt <= item_picked_cnt;
				end else begin
					item6_exist <= 0;
					item_picked_cnt <= item_picked_cnt + 1;
				end
			end else if ( player_x == item7_x && player_y == item7_y ) begin
				if (item7_exist == 0) begin
					item_picked_cnt <= item_picked_cnt;
				end else begin
					item7_exist <= 0;
					item_picked_cnt <= item_picked_cnt + 1;
				end
			end else if ( player_x == item8_x && player_y == item8_y ) begin
				if (item8_exist == 0) begin
					item_picked_cnt <= item_picked_cnt;
				end else begin
					item8_exist <= 0;
					item_picked_cnt <= item_picked_cnt + 1;
				end
			end else begin
				item_picked_cnt <= item_picked_cnt;
			end
		end
	end
	
	assign pixel_addr = (!(hc < 320 && vc < 160)) ? 0 :
						( sx == item1_x && sy == item1_y && item1_exist) ? (hc % 16 + 16 * (vc % 16)) :
						( sx == item2_x && sy == item2_y && item2_exist) ? (hc % 16 + 16 * (vc % 16)) :
						( sx == item3_x && sy == item3_y && item3_exist) ? (hc % 16 + 16 * (vc % 16)) :
						( sx == item4_x && sy == item4_y && item4_exist) ? (hc % 16 + 16 * (vc % 16)) :
						( sx == item5_x && sy == item5_y && item5_exist) ? (hc % 16 + 16 * (vc % 16)) :
						( sx == item6_x && sy == item6_y && item6_exist) ? (hc % 16 + 16 * (vc % 16)) :
						( sx == item7_x && sy == item7_y && item7_exist) ? (hc % 16 + 16 * (vc % 16)) :
						( sx == item8_x && sy == item8_y && item8_exist) ? (hc % 16 + 16 * (vc % 16)) : 0;

						
	wire [11:0] data;
	blk_mem_gen_item1 blk_mem_gen_item1_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel_item)
    );
    
endmodule