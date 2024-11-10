`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2024
// Design Name: 
// Module Name: clock_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Clock divider module that takes an input clock and divides its
//              frequency by a parameterizable value. Can be used to generate
//              slower clock signals from a faster input clock.
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Parameterized version of clock divider module
// Formula: output_freq = input_freq / (2 * DIVISION_VALUE)
module clock_divider #(
    parameter COUNTER_WIDTH = 26,              // Width of the counter
    parameter DIVISION_VALUE = 50_000_000      // Division value for 1Hz output with 100MHz input
)(
    input  logic                        input_clock,    // Input clock signal
    input  logic                        reset_n,        // Active high reset
    output logic                        output_clock    // Divided output clock
);
    
    // Counter to keep track of clock cycles
    logic [COUNTER_WIDTH-1:0] cycle_counter;
    
    // Clock division logic
    always_ff @(posedge input_clock) begin
        if (reset_n) begin
            // Reset counter and output clock
            cycle_counter <= '0;
            output_clock <= '0;
        end
        else begin
            if (cycle_counter == DIVISION_VALUE) begin
                // Toggle output clock when counter reaches division value
                output_clock <= ~output_clock;
                cycle_counter <= '0;
            end
            else begin
                // Increment counter
                cycle_counter <= cycle_counter + 1'b1;
            end
        end
    end
    
endmodule
