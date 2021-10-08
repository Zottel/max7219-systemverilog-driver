module max7219_controller
#(
	INPUT_SIZE=64,
	OUTPUT_SIZE=16
)
(
	input wire clock,
	input wire [INPUT_SIZE-1:0] in_data,
	
	output wire [OUTPUT_SIZE-1:0] out_data,
	output wire out_valid,
	input wire out_ack
);
	assign out_valid = 1;
	
	wire [7:0] reg_value;
	
	reg [3:0] reg_index = 4'h0c;
	assign out_data = {4'b0000, reg_index, reg_value};
	
	always_comb begin
		case(reg_index)
			4'h00: reg_value = 0;               // No-op
			4'h01: reg_value = in_data[07:00];  // Digit 0
			4'h02: reg_value = in_data[15:08];  // Digit 1
			4'h03: reg_value = in_data[23:16];  // Digit 2
			4'h04: reg_value = in_data[31:24];  // Digit 3
			4'h05: reg_value = in_data[39:32];  // Digit 4
			4'h06: reg_value = in_data[47:40];  // Digit 5
			4'h07: reg_value = in_data[55:48];  // Digit 6
			4'h08: reg_value = in_data[63:56];  // Digit 7
			4'h09: reg_value = 0;  // Decode mode: No decode.
			4'h0a: reg_value = 15; // Intensity: 0 to 15
			4'h0b: reg_value = 7;  // Scan limit: Scan all digits.
			4'h0c: reg_value = 1;  // Shutdown (1 means no).
			4'h0d: reg_value = 0;  // Undefined.
			4'h0e: reg_value = 0;  // Undefined.
			4'h0f: reg_value = 0;  // Display test (everything on).
		endcase
	end
	
	always @ (posedge clock) begin
		if (out_ack) begin
			if (reg_index == 4'h01) begin
				reg_index <= 4'h08;
			end else begin
				reg_index <= reg_index - 1;
			end
		end
	end
	`ifdef FORMAL
		always @ (posedge clock) begin
			assume (reg_index > 4'h08 || reg_value != 0);
			cover (reg_index == 4'h01);
		end
	`endif
endmodule

