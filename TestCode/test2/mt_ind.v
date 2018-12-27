
/////////////////////////////////////////////////////////////////
// Constants Define
/////////////////////////////////////////////////////////////////

`define SPRITE_LEN 32
`define SPRITE_SIZE 16
`define SPRITE_LOG_LEN 5
`define SPRITE_WALK_DELAY 5
`define SPRITE_MOVE_CNT 11    // SPRITE_LOG_LEN + SPRITE_WALK_DELAY + 1
`define TRANSPARENT 12'hCBE

`define MOVE_STOP  3'd0
`define MOVE_DOWN  3'd1
`define MOVE_UP    3'd2

/////////////////////////////////////////////////////////////////
// Module Name: top
/////////////////////////////////////////////////////////////////

module top(
   input clk,
   input rst,
   input BTNU,
   input BTND,
   input sw_map,
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync
    );
	
    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr_map, pixel_addr_player;
    reg [11:0] pixel_player;
	wire [11:0] pixel_map;
    wire valid;
	wire [9:0] h_cnt; //640
	wire [9:0] v_cnt; //480
	
	wire clk_13;
	wire up_pressed, down_pressed;
	clock_divider #(13) clkdiv13(.clk(clk), .clkdiv(clk_13));
	debounce up_deb(.pb_debounced(up_pressed), .pb(BTNU), .clk(clk_13));
	debounce down_deb(.pb_debounced(down_pressed), .pb(BTND), .clk(clk_13));
	
	// me testing
	wire pic_en;
	wire mem_valid;
	wire [9:0] pic_row, pic_col;
	reg [9:0] player_r, player_c, nxt_player_r, nxt_player_c;
	reg [2:0] move_stat, nxt_move_stat;
	reg [`SPRITE_LOG_LEN+`SPRITE_WALK_DELAY:0] move_cnt, nxt_move_cnt;
	
	// dealing with memory
	assign pic_en = (player_r <= v_cnt && v_cnt <= player_r+`SPRITE_LEN && player_c <= h_cnt && h_cnt <= player_c+`SPRITE_LEN)? 1'b1 : 1'b0;
	assign pic_row = (v_cnt - player_r)>>1;
	assign pic_col = (h_cnt - player_c)>>1;
	
	// vga display
	reg [11:0] color;
	assign {vgaRed, vgaGreen, vgaBlue} = color;
	always@(*)begin
		if(valid == 1'b0) color = 12'h0;
		else if(pic_en == 1'b0) color = pixel_map;
		else if(pixel_player == `TRANSPARENT) color = pixel_map;
		else color = pixel_player;
	end
	
	// player position
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			player_r <= 300;
			player_c <= 300;
		end else begin
			player_r <= nxt_player_r;
			player_c <= nxt_player_c;
		end
	end
	always@(*) begin
		case(move_stat)
		`MOVE_STOP: begin
			nxt_player_r = player_r;
			nxt_player_c = player_c;
		end
		`MOVE_UP: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_player_r = player_r-1;
				nxt_player_c = player_c;
			end else begin
				nxt_player_r = player_r;
				nxt_player_c = player_c;
			end
		end
		`MOVE_DOWN: begin
			if(move_cnt[`SPRITE_WALK_DELAY:0] == 0) begin
				nxt_player_r = player_r+1;
				nxt_player_c = player_c;
			end else begin
				nxt_player_r = player_r;
				nxt_player_c = player_c;
			end
		end
		default: begin
			nxt_player_r = player_r;
			nxt_player_c = player_c;
		end
		endcase
	end
	
	// player moving state
	always@(posedge clk_13, posedge rst) begin
		if(rst == 1'b1) begin
			move_stat <= `MOVE_STOP;
			move_cnt <= 0;
		end else begin
			move_stat <= nxt_move_stat;
			move_cnt <= nxt_move_cnt;
		end
	end
	always@(*) begin
		nxt_move_stat = move_stat;
		nxt_move_cnt = move_cnt;
		case(move_stat)
		`MOVE_STOP: begin
			if(up_pressed == 1'b1) begin
				nxt_move_stat = `MOVE_UP;
				nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
			end else if(down_pressed == 1'b1) begin
				nxt_move_stat = `MOVE_DOWN;
				nxt_move_cnt = (1<<`SPRITE_MOVE_CNT)-1;
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
	

    clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22)
    );

    mem_addr_gen_player mem_addr_gen_player_inst(
		.en(pic_en),
		.row(pic_row),
		.col(pic_col),
		.pixel_addr(pixel_addr_player)
    );
 
	// generating pixel of different picture
	wire [11:0] pixel_front, pixel_up0, pixel_up1;
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
    blk_mem_gen_0 blk_mem_gen_front(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr_player),
      .dina(data[11:0]),
      .douta(pixel_front)
    ); 
	blk_mem_gen_1 blk_mem_gen_up0(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr_player),
      .dina(data[11:0]),
      .douta(pixel_up0)
    ); 
	blk_mem_gen_2 blk_mem_gen_up1(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr_player),
      .dina(data[11:0]),
      .douta(pixel_up1)
    ); 
	
	// OuO
	wire [5:0] gen_map_x, gen_map_y;
	wire [2:0] gen_map_return;
	mt map_type(.clk(clk_22),
				.rst(rst),
				.sw_map(sw_map),
				.gen_map_x(gen_map_x),
				.gen_map_y(gen_map_y),
				.gen_map_return(gen_map_return)
			   );
	
	blk_mem_gen_3 blk_mem_gen_map(
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

    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
	
endmodule


/////////////////////////////////////////////////////////////////
// Module Name: mem_addr_gen
/////////////////////////////////////////////////////////////////

module mem_addr_gen_player(
	input en,
	input [9:0] row,
	input [9:0] col,
	output [16:0] pixel_addr
	);

	assign pixel_addr = (en == 1'b1)? row * `SPRITE_SIZE + col : 0;

endmodule

module mt(input clk,
		  input rst,
		  input sw_map,
		  input [5:0] gen_map_x,
		  input [5:0] gen_map_y,
		  output [2:0] gen_map_return);

	reg [2:0] mt [0:9] [0:19];
	
	assign gen_map_return = mt[gen_map_y][gen_map_x];
	
	parameter S0_RESET = 3'b000;
	parameter S1_MAP01 = 3'b001;
	/*parameter S2_SLI = 3'b010;
	parameter S3_BOX = 3'b011;
	parameter S4_SPL = 3'b100;*/
	reg [2:0] state, next_state;
	
	always @(posedge clk) begin
		if (rst == 1'b1) begin
			state = S0_RESET;
		end
		else begin
			state = next_state;
		end
		
		case (state)
			S0_RESET: begin
				
			end
			S1_MAP01: begin
				mt[0][0] = 3'b010;
				mt[0][1] = 3'b010;
				mt[0][2] = 3'b010;
				mt[0][3] = 3'b010;
				mt[0][4] = 3'b010;
				mt[0][5] = 3'b010;
				mt[0][6] = 3'b010;
				mt[0][7] = 3'b010;
				mt[0][8] = 3'b010;
				mt[0][9] = 3'b010;
				mt[0][10] = 3'b010;
				mt[0][11] = 3'b010;
				mt[0][12] = 3'b010;
				mt[0][13] = 3'b010;
				mt[0][14] = 3'b010;
				mt[0][15] = 3'b010;
				mt[0][16] = 3'b010;
				mt[0][17] = 3'b010;
				mt[0][18] = 3'b010;
				mt[0][19] = 3'b010;
				
				mt[1][0] = 3'b010;
				mt[1][1] = 3'b000;
				mt[1][2] = 3'b001;
				mt[1][3] = 3'b001;
				mt[1][4] = 3'b010;
				mt[1][5] = 3'b010;
				mt[1][6] = 3'b010;
				mt[1][7] = 3'b001;
				mt[1][8] = 3'b010;
				mt[1][9] = 3'b010;
				mt[1][10] = 3'b000;
				mt[1][11] = 3'b000;
				mt[1][12] = 3'b001;
				mt[1][13] = 3'b000;
				mt[1][14] = 3'b000;
				mt[1][15] = 3'b001;
				mt[1][16] = 3'b001;
				mt[1][17] = 3'b000;
				mt[1][18] = 3'b000;
				mt[1][19] = 3'b010;
				
				mt[2][0] = 3'b010;
				mt[2][1] = 3'b000;
				mt[2][2] = 3'b010;
				mt[2][3] = 3'b000;
				mt[2][4] = 3'b010;
				mt[2][5] = 3'b010;
				mt[2][6] = 3'b010;
				mt[2][7] = 3'b001;
				mt[2][8] = 3'b001;
				mt[2][9] = 3'b000;
				mt[2][10] = 3'b000;
				mt[2][11] = 3'b010;
				mt[2][12] = 3'b010;
				mt[2][13] = 3'b010;
				mt[2][14] = 3'b011;
				mt[2][15] = 3'b010;
				mt[2][16] = 3'b010;
				mt[2][17] = 3'b010;
				mt[2][18] = 3'b000;
				mt[2][19] = 3'b010;
				
				mt[3][0] = 3'b010;
				mt[3][1] = 3'b001;
				mt[3][2] = 3'b010;
				mt[3][3] = 3'b000;
				mt[3][4] = 3'b000;
				mt[3][5] = 3'b001;
				mt[3][6] = 3'b000;
				mt[3][7] = 3'b010;
				mt[3][8] = 3'b000;
				mt[3][9] = 3'b010;
				mt[3][10] = 3'b010;
				mt[3][11] = 3'b010;
				mt[3][12] = 3'b010;
				mt[3][13] = 3'b010;
				mt[3][14] = 3'b010;
				mt[3][15] = 3'b010;
				mt[3][16] = 3'b001;
				mt[3][17] = 3'b001;
				mt[3][18] = 3'b000;
				mt[3][19] = 3'b010;
				
				mt[4][0] = 3'b010;
				mt[4][1] = 3'b001;
				mt[4][2] = 3'b010;
				mt[4][3] = 3'b001;
				mt[4][4] = 3'b010;
				mt[4][5] = 3'b000;
				mt[4][6] = 3'b010;
				mt[4][7] = 3'b010;
				mt[4][8] = 3'b000;
				mt[4][9] = 3'b010;
				mt[4][10] = 3'b010;
				mt[4][11] = 3'b010;
				mt[4][12] = 3'b010;
				mt[4][13] = 3'b000;
				mt[4][14] = 3'b000;
				mt[4][15] = 3'b001;
				mt[4][16] = 3'b001;
				mt[4][17] = 3'b010;
				mt[4][18] = 3'b010;
				mt[4][19] = 3'b010;
				
				mt[5][0] = 3'b010;
				mt[5][1] = 3'b010;
				mt[5][2] = 3'b010;
				mt[5][3] = 3'b010;
				mt[5][4] = 3'b010;
				mt[5][5] = 3'b001;
				mt[5][6] = 3'b001;
				mt[5][7] = 3'b000;
				mt[5][8] = 3'b000;
				mt[5][9] = 3'b000;
				mt[5][10] = 3'b000;
				mt[5][11] = 3'b001;
				mt[5][12] = 3'b001;
				mt[5][13] = 3'b000;
				mt[5][14] = 3'b010;
				mt[5][15] = 3'b010;
				mt[5][16] = 3'b001;
				mt[5][17] = 3'b001;
				mt[5][18] = 3'b000;
				mt[5][19] = 3'b010;
				
				mt[6][0] = 3'b010;
				mt[6][1] = 3'b000;
				mt[6][2] = 3'b010;
				mt[6][3] = 3'b001;
				mt[6][4] = 3'b000;
				mt[6][5] = 3'b001;
				mt[6][6] = 3'b001;
				mt[6][7] = 3'b010;
				mt[6][8] = 3'b001;
				mt[6][9] = 3'b010;
				mt[6][10] = 3'b010;
				mt[6][11] = 3'b010;
				mt[6][12] = 3'b010;
				mt[6][13] = 3'b001;
				mt[6][14] = 3'b010;
				mt[6][15] = 3'b010;
				mt[6][16] = 3'b010;
				mt[6][17] = 3'b010;
				mt[6][18] = 3'b000;
				mt[6][19] = 3'b010;
				
				mt[7][0] = 3'b010;
				mt[7][1] = 3'b001;
				mt[7][2] = 3'b010;
				mt[7][3] = 3'b000;
				mt[7][4] = 3'b010;
				mt[7][5] = 3'b010;
				mt[7][6] = 3'b000;
				mt[7][7] = 3'b010;
				mt[7][8] = 3'b000;
				mt[7][9] = 3'b001;
				mt[7][10] = 3'b010;
				mt[7][11] = 3'b010;
				mt[7][12] = 3'b000;
				mt[7][13] = 3'b000;
				mt[7][14] = 3'b000;
				mt[7][15] = 3'b000;
				mt[7][16] = 3'b001;
				mt[7][17] = 3'b010;
				mt[7][18] = 3'b001;
				mt[7][19] = 3'b010;
				
				mt[8][0] = 3'b010;
				mt[8][1] = 3'b000;
				mt[8][2] = 3'b000;
				mt[8][3] = 3'b000;
				mt[8][4] = 3'b010;
				mt[8][5] = 3'b010;
				mt[8][6] = 3'b000;
				mt[8][7] = 3'b010;
				mt[8][8] = 3'b010;
				mt[8][9] = 3'b000;
				mt[8][10] = 3'b001;
				mt[8][11] = 3'b001;
				mt[8][12] = 3'b000;
				mt[8][13] = 3'b010;
				mt[8][14] = 3'b010;
				mt[8][15] = 3'b010;
				mt[8][16] = 3'b000;
				mt[8][17] = 3'b000;
				mt[8][18] = 3'b000;
				mt[8][19] = 3'b010;
				
				mt[9][0] = 3'b010;
				mt[9][1] = 3'b010;
				mt[9][2] = 3'b010;
				mt[9][3] = 3'b010;
				mt[9][4] = 3'b010;
				mt[9][5] = 3'b010;
				mt[9][6] = 3'b010;
				mt[9][7] = 3'b010;
				mt[9][8] = 3'b010;
				mt[9][9] = 3'b010;
				mt[9][10] = 3'b010;
				mt[9][11] = 3'b010;
				mt[9][12] = 3'b010;
				mt[9][13] = 3'b010;
				mt[9][14] = 3'b010;
				mt[9][15] = 3'b010;
				mt[9][16] = 3'b010;
				mt[9][17] = 3'b010;
				mt[9][18] = 3'b010;
				mt[9][19] = 3'b010;
				
			end
		endcase
	end
	
	always @* begin
		next_state = S0_RESET;
		case (state)
			S0_RESET: begin
				if (sw_map == 1) begin
					next_state = S1_MAP01;
				end /*else if (btnR == 1) begin
					next_state = S2_SLI;
				end else if (btnL == 1) begin
					next_state = S3_BOX;
				end else if (btnU == 1) begin
					next_state = S4_SPL;
				end */else begin
					next_state = S0_RESET;
				end
			end
			S1_MAP01: begin
				next_state = S1_MAP01;
			end
		endcase
	end
	
endmodule

module mem_addr_gen_map(
	input [9:0] h_cnt,
	input [9:0] v_cnt,
	output [16:0] pixel_addr,
	output [5:0] sx, sy,
	input [2:0] map
	);
	
	wire [9:0] hc, vc;
	assign hc = h_cnt>>1;
	assign vc = v_cnt>>1;
	wire [5:0] sx, sy;
	assign sx = ((hc / 16) < 20) ? (hc / 16) : 19;
	assign sy = ((vc / 16) < 10) ? (vc / 16) : 9;
	wire [12:0] co0, co1, co2, co3;
	assign co0 = (hc % 16      + 32 * (vc % 16));
	assign co1 = (hc % 16 + 16 + 32 * (vc % 16));
	assign co2 = (hc % 16      + 32 * (vc % 16 + 16));
	assign co3 = (hc % 16 + 16 + 32 * (vc % 16 + 16));
	
	//assign pixel_addr = ( hc + 320 * vc ) % 76800;  //640*480 --> 320*240
	
	assign pixel_addr = (!(hc < 320 && vc < 160)) ? 0 :
						( map == 3'b000 ) ? co0 :
						( map == 3'b001 ) ? co1 :
						( map == 3'b010 ) ? co2 :
						( map == 3'b011 ) ? co3 : 0;  //640*480 --> 320*240
	
endmodule


/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////

module vga_controller (
    input wire pclk, reset,
    output wire hsync, vsync, valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );

    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;

    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800; 
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    always @(posedge pclk)
        if (reset)
            pixel_cnt <= 0;
        else
            if (pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            hsync_i <= hsync_default;
        else
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 

    always @(posedge pclk)
        if (reset)
            line_cnt <= 0;
        else
            if (pixel_cnt == (HT -1))
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            vsync_i <= vsync_default; 
        else if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;

endmodule

/////////////////////////////////////////////////////////////////
// Module Name: button related
/////////////////////////////////////////////////////////////////

module debounce(pb_debounced, pb, clk);
	input pb, clk;
	output pb_debounced;
	
	reg [4:0] tmp;
	
	always@(posedge clk) begin
		tmp <= {tmp[3:0], pb};
	end
	
	assign pb_debounced = (tmp == 5'b11111) ? 1'b1 : 1'b0;
endmodule

module one_pulse(pb_pulse, pb_debounced, clk);
	input pb_debounced, clk;
	output reg pb_pulse;
	
	reg pb_delayed;
	
	always@(posedge clk) begin
		pb_pulse <= (pb_debounced == 1'b1 && pb_delayed == 1'b0)? 1'b1 : 1'b0;
		pb_delayed <= pb_debounced;
	end
	
endmodule

/////////////////////////////////////////////////////////////////
// Module Name: clock_divisor
/////////////////////////////////////////////////////////////////

module clock_divisor(clk1, clk, clk22);
input clk;
output clk1;
output clk22;
reg [21:0] num;
wire [21:0] next_num;

always @(posedge clk) begin
  num <= next_num;
end

assign next_num = num + 1'b1;
assign clk1 = num[1];
assign clk22 = num[21];
endmodule

module clock_divider(clk, clkdiv);
	input clk;
	output clkdiv;

	parameter n = 22;

	reg [n-1:0] num;
	wire [n-1:0] next_num;

	always @(posedge clk) begin
		num <= next_num;
	end

	assign next_num = num + 1'b1;
	assign clkdiv = num[n-1];
	
endmodule