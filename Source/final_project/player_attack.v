module player_attack(input clk,
					 input clk_25MHz,
					 input rst,
					 input attack_special_pressed,
					 input [9:0] h_cnt,
					 input [9:0] v_cnt,
					 input [9:0] player_x,	//player_c
					 input [9:0] player_y,	//player_r
					 input player_alive,
					 output reg [11:0] pixel_attack,	//	rgb pixel of attack
					 output attacking_special,	        //	player is attacking or not
					 output [4:0] cd_show
);
	
/////////////////////////////////////////////////////////////////
// preprocessed
/////////////////////////////////////////////////////////////////
	
	reg [16:0] pixel_addr;
	reg pixel_attack_en;
	
	wire [9:0] hc, vc;
	assign hc = h_cnt>>1;
	assign vc = v_cnt>>1;
	wire [5:0] sx, sy;
	assign sx = ((hc / 16) < 20) ? (hc / 16) : 19;
	assign sy = ((vc / 16) < 10) ? (vc / 16) : 9;
	
/////////////////////////////////////////////////////////////////
// FSM
/////////////////////////////////////////////////////////////////

	parameter S0_STAY = 2'b00;
	parameter S1_NORM = 2'b01;
	parameter S2_SPEC = 2'b10;
	parameter S3_INCD = 2'b11;
	reg [1:0] state, next_state;
	
	assign attacking_special = (state == S2_SPEC) ? 1 : 0;
	
	reg [25:0] special_attack_count;	//special attack continue time
	reg special_attack_finished;		//special attack finish
	reg [31:0] cd_count;				//count to 10 billion
	reg [4:0] cd_show;					//count to 10 billion how many times (9 -> 0)
	always @ (posedge clk, posedge rst) begin
		if (rst) begin
			state = S0_STAY;
			special_attack_count = 0;
			special_attack_finished = 0;
			cd_count = 0;
			cd_show = 9;
		end else begin
			if ( next_state == S2_SPEC && state != S2_SPEC ) begin
				special_attack_count = 0;
				special_attack_finished = 0;
			end else if ( next_state == S3_INCD && state != S3_INCD ) begin
				cd_count = 0;
				cd_show = 9;
			end
			state = next_state;
			
			case (state)
				/*S0_STAY: begin
				end*/
				/*S1_NORM: begin
				end*/
				S2_SPEC: begin
					if (special_attack_count == 26'b10_0000_0000_0000_0000_0000_0000) begin
						special_attack_count <= 0;
						special_attack_finished <= 1;
					end else begin
						special_attack_count <= special_attack_count + 1;
					end
					if ( hc >= 320 || vc >= 160 ) begin
						pixel_addr <= 0;
						pixel_attack_en <= 1'b0;
					end else if ( sx == (player_x + 20 + 0) % 20 && sy == (player_y + 10 - 2) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 - 1) % 20 && sy == (player_y + 10 - 1) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 + 0) % 20 && sy == (player_y + 10 - 1) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 + 1) % 20 && sy == (player_y + 10 - 1) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;	
					end else if ( sx == (player_x + 20 - 2) % 20 && sy == (player_y + 10 + 0) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 - 1) % 20 && sy == (player_y + 10 + 0) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 + 1) % 20 && sy == (player_y + 10 + 0) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 + 2) % 20 && sy == (player_y + 10 + 0) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 - 1) % 20 && sy == (player_y + 10 + 1) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 + 0) % 20 && sy == (player_y + 10 + 1) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 + 1) % 20 && sy == (player_y + 10 + 1) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else if ( sx == (player_x + 20 + 0) % 20 && sy == (player_y + 10 + 2) % 10 ) begin
						pixel_addr <= (hc % 16      + 16 * (vc % 16));
						pixel_attack_en <= 1'b1;
					end else begin
						pixel_addr <= 0;
						pixel_attack_en <= 1'b0;
					end
				end
				S3_INCD: begin
					if (cd_count == 100000000) begin
						cd_count <= 0;
						if (cd_show > 0) begin
							cd_show <= cd_show - 1;
						end else begin
							cd_show <= cd_show;
						end
					end else begin
						cd_count <= cd_count + 1;
					end
				end
			endcase
		end
	end
	
	always @* begin
		next_state = S0_STAY;
		case (state)
			S0_STAY: begin
				if (attack_special_pressed == 1'b1 && player_alive == 1'b1) begin	// pressed 1
					next_state = S2_SPEC;
				end else begin
					next_state = S0_STAY;
				end
			end
			/*S1_NORM: begin
			end*/
			S2_SPEC: begin
				if (special_attack_finished == 1) begin
					next_state = S3_INCD;
				end else begin
					next_state = S2_SPEC;
				end
			end
			S3_INCD: begin
				if (cd_show == 0) begin
					next_state = S0_STAY;
				end else begin
					next_state = S3_INCD;
				end
			end
		endcase
	end

/////////////////////////////////////////////////////////////////
// pixel
/////////////////////////////////////////////////////////////////
	
	wire [11:0] pixel_attack_special;
	always @(*) begin
		case (state)
			S0_STAY: begin
			end
			S1_NORM: begin
			end
			S2_SPEC: begin
				pixel_attack = pixel_attack_special;
			end
		endcase
		pixel_attack = (state == S2_SPEC && pixel_attack_en == 1'b1) ? pixel_attack : 12'hCBE;
	end
	
	wire [11:0] data;
	blk_mem_gen_attack_special blk_mem_gen_attack_special_inst(
		.clka(clk_25MHz),
		.wea(0),
		.addra(pixel_addr),
		.dina(data[11:0]),
		.douta(pixel_attack_special)
    );
    
endmodule
/*
			if (been_ready && key_down[last_change] == 1'b1) begin
				
			end
			
				if (last_change == 9'b0_0110_1001) begin
				end else if (last_change == 9'b0_0111_0010) begin
				end else if (last_change == 9'b0_0111_1010) begin
				end
*/