
/*
input:
	pixel from all instances: player, map, monster, ... etc.
	
output:
	color to be sent to {vgaRed, vgaGreen, vgaBlue}
	(i.e. {vgaRed, vgaGreen, vgaBlue} = pixel = color)
*/

/////////////////////////////////////////////////////////////////
// Constants Define
/////////////////////////////////////////////////////////////////

// colors

`define TRANSPARENT 12'hCBE
`define BLACK 12'h0

/////////////////////////////////////////////////////////////////
// VGA display module
/////////////////////////////////////////////////////////////////

module vga_displayer(
	input vga_valid,
	input [11:0] pixel_player,
	input [11:0] pixel_map,
	output [11:0] pixel
);

	// combine several layer to one
	reg [11:0] color;
	always@(*) begin
		if(vga_valid == 1'b0) color = `BLACK;
		else if(pixel_player == `TRANSPARENT) color = pixel_map;
		else color = pixel_player;
	end

	assign pixel = color;

endmodule