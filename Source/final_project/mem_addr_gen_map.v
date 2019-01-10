module mem_addr_gen_map(
	input show_fake_wall,
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
						( map == 3'b011 ) ? co3 :
						( show_fake_wall == 1'b0 )? co2 : co0;  //640*480 --> 320*240
	
endmodule