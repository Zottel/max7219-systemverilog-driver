module max7219_shift
#(
	CLOCK_DIVIDER=2,
	SIZE=16
)
(
	input wire clock,
	input wire [SIZE-1:0] in_data,
	input wire in_valid,
	output wire in_ack,
	output wire out_data,
	output wire out_clock,
	output wire out_load
);
	localparam DIVIDER_BITS = $clog2(CLOCK_DIVIDER);
//
	// Output clock, toggled every CLOCK_DIVIDER/2 cycles.
	reg out_clock_state = 0;
	reg [SIZE-1:0] data = 0;
	reg [$clog2(SIZE+1)-1:0] remaining_bits = 0;
	
	// After entire register has been transmitted, hold this high while the
	// out_clock is low.
	reg out_load_reg = 0;
	// Prohibit loading twice.
	reg out_was_loaded = 1;
	
	assign out_clock = out_clock_state;
	assign out_data = data[SIZE-1];
	assign out_load = out_load_reg;
	
	// Gives one ack pulse after all data has been transmitted.
	reg in_ack_reg = 0;
	assign in_ack = in_ack_reg;
	
	reg [DIVIDER_BITS-1:0] divider = 0;
	
	always @ (posedge clock) begin
		if (divider[DIVIDER_BITS-1]) begin
			if (out_clock_state) begin // Output clock falling.
				if (remaining_bits > 0) begin
					data <= {data[SIZE-2:0], 1'b0};
					remaining_bits <= remaining_bits - 1;
					out_was_loaded <= 0;
				end else begin
					// Send "load" signal to max7219, and remember we have done so.
					// Need to remember because we may be stuck in "empty" state for time.
					if (!out_was_loaded) begin
						out_load_reg <= 1;
						out_was_loaded <= 1;
					end
					
					if (in_valid) begin
						data <= in_data;
						remaining_bits <= SIZE-1;
						in_ack_reg <= 1;
					end else begin
						data <= {data[SIZE-2:0], 1'b0};
					end
				end
			end else begin
				out_load_reg <= 0;
			end
			
			out_clock_state <= !out_clock_state;
			divider <= 1;
		end else begin
			divider <= divider + 1;
		end
		
		if (in_ack_reg) begin
			in_ack_reg <= 0;
		end
	end
	
	`ifdef FORMAL
		reg [15:0] cycle = 0;
		always @ (posedge clock) begin
			cycle <= cycle+1;
			assume property (in_data != 0);
			assume property (in_data == $past(in_data) || in_data == cycle + 13);
			assume property (!$past(in_valid && !in_ack) || in_valid);
			cover (cycle > 64 && out_load);
			
			even_divider: assert property ((CLOCK_DIVIDER % 2) == 0);
			existing_divider: assert property (CLOCK_DIVIDER > 0);
			divider_limit: assert property (divider <= CLOCK_DIVIDER);
			no_double_ack: assert property ($past(!in_ack) || !in_ack);
		end
	`endif
endmodule
