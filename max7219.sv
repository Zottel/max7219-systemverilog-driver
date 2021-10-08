module max7219
#(
	CLOCK_DIVIDER=2,
	SIZE=64
)
(
	input wire clock,
	
	input wire [SIZE-1:0] in_data,
	
	// Output pins to MAX7219 controller.
	output wire out_data,
	output wire out_clock,
	output wire out_load
);

	// Connections between controller and shift register.
	wire [15:0] inner_data;
	wire inner_valid;
	wire inner_ack;
	
	max7219_controller #(.INPUT_SIZE(64), .OUTPUT_SIZE(16))
		control(
			.clock(clock),
			.in_data(in_data),
			.out_data(inner_data),
			.out_valid(inner_valid),
			.out_ack(inner_ack)
		);
	
	max7219_shift #(.CLOCK_DIVIDER(CLOCK_DIVIDER), .SIZE(16))
		shift(
			.clock(clock),
			.in_data(inner_data),
			.in_valid(inner_valid),
			.in_ack(inner_ack),
			.out_data(out_data),
			.out_clock(out_clock),
			.out_load(out_load)
		);
	
	`ifdef FORMAL
		reg [15:0] cycle = 0;
		always @ (posedge clock) begin
			cycle <= cycle+1;
			// assume (inner_data[7:0] != 0 || inner_data[7:0] == 16'h0900);
			cover (cycle == 256);
		end
	`endif

endmodule
