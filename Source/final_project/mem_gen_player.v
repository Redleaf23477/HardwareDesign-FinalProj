
/*
	input: player's position
	output: address of player's pixel in memory
*/


module mem_addr_gen_player(
	input en,
	input [9:0] row,
	input [9:0] col,
	output [16:0] pixel_addr
	);

	assign pixel_addr = (en == 1'b1)? row * `SPRITE_SIZE + col : 0;

endmodule