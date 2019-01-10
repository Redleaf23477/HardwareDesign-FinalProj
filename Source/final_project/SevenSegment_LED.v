module SevenSegment_LED(
	output reg [6:0] display,
	output reg [3:0] digit,
	output reg [15:0] led,
	input wire rst,
	input wire clk,
	input wire [4:0] led_picked,
	input wire [4:0] seg7_cd,
	input wire [4:0] seg7_hp
);
    
    reg [15:0] clk_divider;
    reg [4:0] display_num;
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 15'b0;
    	end else begin
    		clk_divider <= clk_divider + 15'b1;
    	end
    end
    
	wire [4:0] BCD0, BCD1, BCD2, BCD3;
	assign BCD3 = seg7_cd;
	assign BCD0 = seg7_hp;
	
    always @ (posedge clk_divider[15], posedge rst) begin
    	if (rst) begin
    		display_num <= 5'b00000;
    		digit <= 4'b1111;
    	end else begin
    		case (digit)
    			4'b1110 : begin
    					display_num <= BCD1;
    					digit <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= BCD2;
						digit <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= BCD3;
						digit <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= BCD0;
						digit <= 4'b1110;
					end
    			default : begin
						display_num <= BCD0;
						digit <= 4'b1110;
					end				
    		endcase
			case (led_picked) 
				0: begin
					led = 16'b0000_0000_0000_0000;
				end
				1: begin
					led = 16'b0000_0000_0000_0001;
				end
				2: begin
					led = 16'b0000_0000_0000_0011;
				end
				3: begin
					led = 16'b0000_0000_0000_0111;
				end
				4: begin
					led = 16'b0000_0000_0000_1111;
				end
				5: begin
					led = 16'b0000_0000_0001_1111;
				end
				6: begin
					led = 16'b0000_0000_0011_1111;
				end
				7: begin
					led = 16'b0000_0000_0111_1111;
				end
				8: begin
					led = 16'b0000_0000_1111_1111;
				end
				9: begin
					led = 16'b0000_0001_1111_1111;
				end
				10: begin
					led = 16'b0000_0011_1111_1111;
				end
				11: begin
					led = 16'b0000_0111_1111_1111;
				end
				12: begin
					led = 16'b0000_1111_1111_1111;
				end
				13: begin
					led = 16'b0001_1111_1111_1111;
				end
				14: begin
					led = 16'b0011_1111_1111_1111;
				end
				15: begin
					led = 16'b0111_1111_1111_1111;
				end
				16: begin
					led = 16'b1111_1111_1111_1111;
				end
				default: begin
					led = 16'b0000_0000_0000_0000;
				end
			endcase
    	end
    end
    
    always @ (*) begin
    	case (display_num)
    		0 : display = 7'b1000000;	//0
			1 : display = 7'b1111001;   //1
			2 : display = 7'b0100100;   //2
			3 : display = 7'b0110000;   //3
			4 : display = 7'b0011001;   //4
			5 : display = 7'b0010010;   //5
			6 : display = 7'b0000010;   //6
			7 : display = 7'b1111000;   //7
			8 : display = 7'b0000000;   //8
			9 : display = 7'b0010000;	//9
			10:	display = 7'b0111111;	//-
			default : display = 7'b1111111;
    	endcase
    end
    
endmodule
