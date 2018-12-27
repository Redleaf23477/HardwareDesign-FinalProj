
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