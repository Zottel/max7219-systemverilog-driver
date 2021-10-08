module top(
	input clk,
	output spi_data,
	output spi_cs,
	output spi_clk
);
	// Power LED?
	assign D5 = 1;
	
	reg ready = 0;
	reg [23:0] divider;
	
	wire feedback;
	reg [31:0] lfsr;
	
	// 1 0000 0000 0100 0000 0000 0000 0000 0111
	//assign feedback = lfsr[22] ^ lfsr[2] ^ lfsr[1] ^ lfsr[0];
	
	// 1 1100 0000 0000 0000 0000 0100 0000 0001
	assign feedback = lfsr[31] ^ lfsr[30] ^ lfsr[10] ^ lfsr[0];
	
	always @(posedge clk) begin
		if (ready) begin
			//if (divider == 12000000) begin
			if (divider == 12000000) begin
				divider <= 0;
				lfsr <= {feedback, lfsr[31:1]};
			end else
				divider <= divider + 1;
		end else begin
			ready <= 1;
			// lfsr <= 8'b00000001;
			lfsr <= 1;
			divider <= 0;
		end
	end
	
	wire [63:0] segment_bits;
	
	hexfont #(.SIZE(32)) font (.in(lfsr),.out(segment_bits));
	
	max7219 #( .CLOCK_DIVIDER(16), .SIZE(64) )
		seven_segment_driver ( .clock(clk), .in_data(segment_bits),
			.out_data(spi_data), .out_clock(spi_clk), .out_load(spi_cs));
	
	
endmodule // top

