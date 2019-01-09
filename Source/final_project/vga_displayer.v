
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
	input display_sp,
	input [11:0] pixel_player,
	input [11:0] pixel_monster0,
	input [11:0] pixel_arrow,
	input [11:0] pixel_map,
	input [11:0] pixel_attack,
	output [11:0] pixel
);

	// combine several layer to one
	/* Layers:
		- player
		- monster0
		- arrow (shortest path tree)
		- map
	*/
	reg [11:0] color;
	always@(*) begin
		if(vga_valid == 1'b0) color = `BLACK;
		else if (pixel_attack != `TRANSPARENT) color = pixel_attack;
		else if(pixel_player != `TRANSPARENT) color = pixel_player;
		else if(pixel_monster0 != `TRANSPARENT) color = pixel_monster0;
		else if(display_sp == 1'b1 && pixel_arrow != `TRANSPARENT) color = pixel_arrow;
		else color = pixel_map;
	end

	assign pixel = color;

endmodule