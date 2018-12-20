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