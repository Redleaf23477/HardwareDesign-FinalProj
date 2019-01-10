module item(input clk,
			input clk_25MHz,
			input rst,
			input [2:0] map_idx,
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
	
	parameter item1_1_y = 6'd7;
	parameter item1_1_x = 6'd8;
	parameter item1_2_y = 6'd4;
	parameter item1_2_x = 6'd15;
	parameter item1_3_y = 6'd4;
	parameter item1_3_x = 6'd1;
	parameter item1_4_y = 6'd6;
	parameter item1_4_x = 6'd1;
	parameter item1_5_y = 6'd1;
	parameter item1_5_x = 6'd7;
	parameter item1_6_y = 6'd8;
	parameter item1_6_x = 6'd6;
	parameter item1_7_y = 6'd1;
	parameter item1_7_x = 6'd13;
	parameter item1_8_y = 6'd8;
	parameter item1_8_x = 6'd16;
	reg item1_1_exist, item1_2_exist, item1_3_exist, item1_4_exist, item1_5_exist, item1_6_exist, item1_7_exist, item1_8_exist;
	
	parameter item2_1_y = 6'd3;
	parameter item2_1_x = 6'd1;
	parameter item2_2_y = 6'd3;
	parameter item2_2_x = 6'd5;
	parameter item2_3_y = 6'd3;
	parameter item2_3_x = 6'd15;
	parameter item2_4_y = 6'd7;
	parameter item2_4_x = 6'd1;
	parameter item2_5_y = 6'd4;
	parameter item2_5_x = 6'd9;
	parameter item2_6_y = 6'd2;
	parameter item2_6_x = 6'd2;
	parameter item2_7_y = 6'd8;
	parameter item2_7_x = 6'd8;
	parameter item2_8_y = 6'd1;
	parameter item2_8_x = 6'd18;
	reg item2_1_exist, item2_2_exist, item2_3_exist, item2_4_exist, item2_5_exist, item2_6_exist, item2_7_exist, item2_8_exist;

	reg [4:0] item_picked_cnt;

/////////////////////////////////////////////////////////////////
// pixel	item_picked_cnt
/////////////////////////////////////////////////////////////////
	
	always @ (posedge clk, posedge rst) begin
		if (rst) begin
			item1_1_exist = 1;
			item1_2_exist = 1;
			item1_3_exist = 1;
			item1_4_exist = 1;
			item1_5_exist = 1;
			item1_6_exist = 1;
			item1_7_exist = 1;
			item1_8_exist = 1;
			
			item2_1_exist = 1;
			item2_2_exist = 1;
			item2_3_exist = 1;
			item2_4_exist = 1;
			item2_5_exist = 1;
			item2_6_exist = 1;
			item2_7_exist = 1;
			item2_8_exist = 1;
			
			item_picked_cnt = 0;
		end else begin
			if (map_idx == 1'b0) begin
				if ( player_x == item1_1_x && player_y == item1_1_y ) begin
					if (item1_1_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item1_1_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item1_2_x && player_y == item1_2_y ) begin
					if (item1_2_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item1_2_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item1_3_x && player_y == item1_3_y ) begin
					if (item1_3_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item1_3_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item1_4_x && player_y == item1_4_y ) begin
					if (item1_4_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item1_4_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item1_5_x && player_y == item1_5_y ) begin
					if (item1_5_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item1_5_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item1_6_x && player_y == item1_6_y ) begin
					if (item1_6_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item1_6_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item1_7_x && player_y == item1_7_y ) begin
					if (item1_7_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item1_7_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item1_8_x && player_y == item1_8_y ) begin
					if (item1_8_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item1_8_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else begin
					item_picked_cnt <= item_picked_cnt;
				end
			end else if (map_idx == 1'b1) begin
				if ( player_x == item2_1_x && player_y == item2_1_y ) begin
					if (item2_1_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item2_1_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item2_2_x && player_y == item2_2_y ) begin
					if (item2_2_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item2_2_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item2_3_x && player_y == item2_3_y ) begin
					if (item2_3_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item2_3_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item2_4_x && player_y == item2_4_y ) begin
					if (item2_4_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item2_4_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item2_5_x && player_y == item2_5_y ) begin
					if (item2_5_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item2_5_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item2_6_x && player_y == item2_6_y ) begin
					if (item2_6_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item2_6_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item2_7_x && player_y == item2_7_y ) begin
					if (item2_7_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item2_7_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else if ( player_x == item2_8_x && player_y == item2_8_y ) begin
					if (item2_8_exist == 0) begin
						item_picked_cnt <= item_picked_cnt;
					end else begin
						item2_8_exist <= 0;
						item_picked_cnt <= item_picked_cnt + 1;
					end
				end else begin
					item_picked_cnt <= item_picked_cnt;
				end
			end
		end
	end
	
	assign pixel_addr = (!(hc < 320 && vc < 160)) ? 0 :
						( map_idx == 1'b0 && sx == item1_1_x && sy == item1_1_y && item1_1_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b0 && sx == item1_2_x && sy == item1_2_y && item1_2_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b0 && sx == item1_3_x && sy == item1_3_y && item1_3_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b0 && sx == item1_4_x && sy == item1_4_y && item1_4_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b0 && sx == item1_5_x && sy == item1_5_y && item1_5_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b0 && sx == item1_6_x && sy == item1_6_y && item1_6_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b0 && sx == item1_7_x && sy == item1_7_y && item1_7_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b0 && sx == item1_8_x && sy == item1_8_y && item1_8_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						
						( map_idx == 1'b1 && sx == item2_1_x && sy == item2_1_y && item2_1_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b1 && sx == item2_2_x && sy == item2_2_y && item2_2_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b1 && sx == item2_3_x && sy == item2_3_y && item2_3_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b1 && sx == item2_4_x && sy == item2_4_y && item2_4_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b1 && sx == item2_5_x && sy == item2_5_y && item2_5_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b1 && sx == item2_6_x && sy == item2_6_y && item2_6_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b1 && sx == item2_7_x && sy == item2_7_y && item2_7_exist ) ? (hc % 16 + 16 * (vc % 16)) :
						( map_idx == 1'b1 && sx == item2_8_x && sy == item2_8_y && item2_8_exist ) ? (hc % 16 + 16 * (vc % 16)) : 0;

	wire [11:0] data;
	blk_mem_gen_item1 blk_mem_gen_item1_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel_item)
    );
    
endmodule