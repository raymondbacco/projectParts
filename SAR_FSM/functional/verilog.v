//Verilog HDL for "ee140_proj", "SAR_FSM" "functional"

module SAR_FSM (
	input clk,
	input run_conversion,

	input adc_done,

	output clk_dff,
	output reg clk_pga,
	output reg adc_resetb,
	output reg adc_convert );

localparam [1:0] S_IDLE 			= 2'b00;
localparam [1:0] S_CONVERTING 	= 2'b01;
localparam [1:0] S_CLEAR 			= 2'b10;

reg [1:0] state;

// State progression logic
always @(posedge clk) begin
	if (~run_conversion) state <= S_IDLE;
	case (state)
		// Waits until signal to start conversion
		S_IDLE: 			if (run_conversion) state <= S_CLEAR;
		// Clears any prior data only just before next conversion
		S_CLEAR: 		state <= S_CONVERTING;
		// Running ADC conversion
		S_CONVERTING: 	if (adc_done) state <= S_IDLE;
	endcase
end

// Output logic
always @(*) begin
	adc_resetb = 1'b1;
	adc_convert = 1'b0;
	clk_pga = 1'b1;
	case (state)
		S_CLEAR: begin
			adc_resetb = 1'b0;
			clk_pga = 1'b0;
		end
		S_CONVERTING: begin
			adc_convert = 1'b1;
			// clk_pga = adc_done ? 1'b1 : 1'b0;
		end
	endcase
end

assign clk_dff = clk & adc_convert;

endmodule
