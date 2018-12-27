
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
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync
    );
	
	// redleaf code
    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr;
    reg [11:0] pixel;
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
		else if(pic_en == 1'b0) color = 12'hFFF;
		else if(pixel == `TRANSPARENT) color = 12'hFFF;
		else color = pixel;
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

    mem_addr_gen mem_addr_gen_inst(
		.en(pic_en),
		.row(pic_row),
		.col(pic_col),
		.pixel_addr(pixel_addr)
    );
 
	// generating pixel of different picture
	wire [11:0] pixel_front, pixel_up0, pixel_up1;
	always@(*)begin
		case(move_stat)
		`MOVE_STOP: begin
			pixel = pixel_front;
		end
		`MOVE_UP: begin
			if(move_cnt[9:0] < 512) begin
				pixel = pixel_up0;
			end else begin
				pixel = pixel_up1;
			end
		end
		`MOVE_DOWN: begin
			pixel = pixel_front;
		end
		default: begin
			pixel = pixel_front;
		end
		endcase
	end
    blk_mem_gen_0 blk_mem_gen_front(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel_front)
    ); 
	blk_mem_gen_1 blk_mem_gen_up0(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel_up0)
    ); 
	blk_mem_gen_2 blk_mem_gen_up1(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_addr),
      .dina(data[11:0]),
      .douta(pixel_up1)
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

module mem_addr_gen(
	input en,
	input [9:0] row,
	input [9:0] col,
	output [16:0] pixel_addr
	);

	assign pixel_addr = (en == 1'b1)? row * `SPRITE_SIZE + col : 0;

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