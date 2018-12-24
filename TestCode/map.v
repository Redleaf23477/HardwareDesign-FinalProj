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

module mem_addr_gen(
	input clk,
	input rst,
	input [9:0] h_cnt,
	input [9:0] v_cnt,
	output [16:0] pixel_addr,
	output valid,
	input btnC/*,
	input btnR,
	input btnL,
	input btnU*/
	);
	
	parameter S0_RESET = 3'b000;
	parameter S1_MAP01 = 3'b001;
	/*parameter S2_SLI = 3'b010;
	parameter S3_BOX = 3'b011;
	parameter S4_SPL = 3'b100;*/
	reg [2:0] state, next_state;
	/*
	reg [2:0] m00ap00, m00ap01, m00ap02, m00ap03, m00ap04, m00ap05, m00ap06, m00ap07, m00ap08, m00ap09, m00ap10, m00ap11, m00ap12, m00ap13, m00ap14; 
	reg [2:0] m01ap00, m01ap01, m01ap02, m01ap03, m01ap04, m01ap05, m01ap06, m01ap07, m01ap08, m01ap09, m01ap10, m01ap11, m01ap12, m01ap13, m01ap14; 
	reg [2:0] m02ap00, m02ap01, m02ap02, m02ap03, m02ap04, m02ap05, m02ap06, m02ap07, m02ap08, m02ap09, m02ap10, m02ap11, m02ap12, m02ap13, m02ap14; 
	reg [2:0] m03ap00, m03ap01, m03ap02, m03ap03, m03ap04, m03ap05, m03ap06, m03ap07, m03ap08, m03ap09, m03ap10, m03ap11, m03ap12, m03ap13, m03ap14; 
	reg [2:0] m04ap00, m04ap01, m04ap02, m04ap03, m04ap04, m04ap05, m04ap06, m04ap07, m04ap08, m04ap09, m04ap10, m04ap11, m04ap12, m04ap13, m04ap14;
	reg [2:0] m05ap00, m05ap01, m05ap02, m05ap03, m05ap04, m05ap05, m05ap06, m05ap07, m05ap08, m05ap09, m05ap10, m05ap11, m05ap12, m05ap13, m05ap14; 
	reg [2:0] m06ap00, m06ap01, m06ap02, m06ap03, m06ap04, m06ap05, m06ap06, m06ap07, m06ap08, m06ap09, m06ap10, m06ap11, m06ap12, m06ap13, m06ap14; 
	reg [2:0] m07ap00, m07ap01, m07ap02, m07ap03, m07ap04, m07ap05, m07ap06, m07ap07, m07ap08, m07ap09, m07ap10, m07ap11, m07ap12, m07ap13, m07ap14; 
	reg [2:0] m08ap00, m08ap01, m08ap02, m08ap03, m08ap04, m08ap05, m08ap06, m08ap07, m08ap08, m08ap09, m08ap10, m08ap11, m08ap12, m08ap13, m08ap14; 
	reg [2:0] m09ap00, m09ap01, m09ap02, m09ap03, m09ap04, m09ap05, m09ap06, m09ap07, m09ap08, m09ap09, m09ap10, m09ap11, m09ap12, m09ap13, m09ap14; 
	*/
	reg [2:0] mt [0:9] [0:19];
	
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
				if (btnC == 1) begin
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
	
	assign pixel_addr = ( mt[sy][sx] == 3'b000 ) ? co0 :
						( mt[sy][sx] == 3'b001 ) ? co1 :
						( mt[sy][sx] == 3'b010 ) ? co2 :
						( mt[sy][sx] == 3'b011 ) ? co3 : 0;  //640*480 --> 320*240
	assign valid = (state == S0_RESET) ? 0 :
				   (hc < 320 && vc < 160) ? 1 : 0;
	
endmodule

module map(input clk,
		   input rst,
		   input btnC,/* btnR, btnL, btnU,*/
		   output [3:0] vgaRed,
		   output [3:0] vgaGreen,
		   output [3:0] vgaBlue,
		   output hsync,
		   output vsync
		   );

    wire [11:0] data;
    
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt;	//640
    wire [9:0] v_cnt;	//480

	wire mem_valid;
	assign {vgaRed, vgaGreen, vgaBlue} = (mem_valid == 1'b1 && valid == 1'b1) ? pixel : 12'h0;

	wire clk_25MHz, clk_22;
    clock_divisor clk_wiz_0_inst(.clk(clk),
								 .clk1(clk_25MHz),
								 .clk22(clk_22)
								);

    mem_addr_gen mem_addr_gen_inst(.clk(clk_22),
								   .rst(rst),
								   .h_cnt(h_cnt),
								   .v_cnt(v_cnt),
								   .pixel_addr(pixel_addr),
								   .valid(mem_valid),
								   .btnC(btnC)/*,
								   .btnL(btnL),
								   .btnR(btnR),
								   .btnU(btnU)*/
								   );

    blk_mem_gen_0 blk_mem_gen_0_inst(.clka(clk_25MHz),
									 .wea(0),
									 .addra(pixel_addr),
									 .dina(data[11:0]),
									 .douta(pixel)
									);

    vga_controller vga_inst(.pclk(clk_25MHz),
							.reset(rst),
							.hsync(hsync),
							.vsync(vsync),
							.valid(valid),
							.h_cnt(h_cnt),
							.v_cnt(v_cnt)
						   );
	
endmodule
