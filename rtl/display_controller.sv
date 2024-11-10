//////////////////////////////////////////////////////////////////////////////////
// Introduction:
// This module implements a 4-digit 7-segment display controller with parameterized
// configuration. It takes BCD inputs for each digit position and generates the
// appropriate segment patterns and digit enable signals for multiplexed display.
// The display refreshes at a configurable rate and supports customizable segment
// patterns for each digit value.
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date: 11/06/2024 07:58:29 PM
// Design Name: LED Counter to 1903
// Module Name: LED
// Project Name:
// Target Devices: 
// Tool Versions:
// Description: Counts from 0000 to 1881 on a 4-digit seven-segment display.
//              When the count reaches 1881, the LED display flashes.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Suggested better module name: SevenSegmentController or DisplayDriver
//
//////////////////////////////////////////////////////////////////////////////////

// Segment patterns for each decimal digit (active low)
typedef enum logic [6:0]{
    ZERO  = 7'b000_0001, // Pattern for digit 0 (segments: abcdef-)
    ONE   = 7'b100_1111, // Pattern for digit 1 (segments: -bc----)
    TWO   = 7'b001_0010, // Pattern for digit 2 (segments: ab-de-g)
    THREE = 7'b000_0110, // Pattern for digit 3 (segments: abcd--g)
    FOUR  = 7'b100_1100, // Pattern for digit 4 (segments: -bc--fg)
    FIVE  = 7'b010_0100, // Pattern for digit 5 (segments: a-cd-fg)
    SIX   = 7'b010_0000, // Pattern for digit 6 (segments: a-cdefg)
    SEVEN = 7'b000_1111, // Pattern for digit 7 (segments: abc----)
    EIGHT = 7'b000_0000, // Pattern for digit 8 (segments: abcdefg)
    NINE  = 7'b000_0100  // Pattern for digit 9 (segments: abcd-fg)
} segment_pattern_t;

// Main display controller module
module display_controller #(
    parameter DISPLAY_COUNT = 4,           // Number of display digits
    parameter SEGMENT_COUNT = 7,           // Number of segments per digit
    parameter REFRESH_RATE = 50_000,       // Clock cycles between digit refreshes
    parameter TIMER_WIDTH = 16             // Width of refresh counter
)(
    input  logic                        clk_100MHz,     // Main system clock
    input  logic                        reset,          // System reset (active high)
    input  logic [3:0]                  ones,          // Value for rightmost digit
    input  logic [3:0]                  tens,          // Value for tens digit
    input  logic [3:0]                  hundreds,      // Value for hundreds digit
    input  logic [3:0]                  thousands,     // Value for leftmost digit
    output logic [SEGMENT_COUNT-1:0]    seg,           // Segment control signals
    output logic [DISPLAY_COUNT-1:0]    an             // Digit enable signals
);

    // Internal signals for display multiplexing
    logic [1:0] digit_select;              // Current active digit position
    logic [TIMER_WIDTH-1:0] refresh_timer; // Counter for digit refresh timing
    
    // Display refresh control logic
    always_ff @(posedge clk_100MHz or posedge reset) begin
        if(reset) begin
            digit_select <= '0;            // Reset to first digit
            refresh_timer <= '0;           // Reset timer
        end
        else begin
            if(refresh_timer == REFRESH_RATE) begin
                digit_select <= digit_select + 1'b1;  // Move to next digit
                refresh_timer <= '0;                  // Reset timer
            end
            else begin
                refresh_timer <= refresh_timer + 1;   // Increment timer
            end
        end
    end
    
    // Segment pattern and digit enable control logic
    always_comb begin
        case(digit_select)
            2'b00 : begin
                an = 4'b1110;       // Enable rightmost digit (ones)
                        case(ones)  // Select pattern based on ones value
                            4'b0000 : seg = ZERO;
                            4'b0001 : seg = ONE;
                            4'b0010 : seg = TWO;
                            4'b0011 : seg = THREE;
                            4'b0100 : seg = FOUR;
                            4'b0101 : seg = FIVE;
                            4'b0110 : seg = SIX;
                            4'b0111 : seg = SEVEN;
                            4'b1000 : seg = EIGHT;
                            4'b1001 : seg = NINE;
                        endcase
                    end
                    
            2'b01 : begin
                an = 4'b1101;       // Enable tens digit
                        case(tens)  // Select pattern based on tens value
                            4'b0000 : seg = ZERO;
                            4'b0001 : seg = ONE;
                            4'b0010 : seg = TWO;
                            4'b0011 : seg = THREE;
                            4'b0100 : seg = FOUR;
                            4'b0101 : seg = FIVE;
                            4'b0110 : seg = SIX;
                            4'b0111 : seg = SEVEN;
                            4'b1000 : seg = EIGHT;
                            4'b1001 : seg = NINE;
                        endcase
                    end
                    
            2'b10 : begin
                an = 4'b1011;       // Enable hundreds digit
                        case(hundreds)  // Select pattern based on hundreds value
                            4'b0000 : seg = ZERO;
                            4'b0001 : seg = ONE;
                            4'b0010 : seg = TWO;
                            4'b0011 : seg = THREE;
                            4'b0100 : seg = FOUR;
                            4'b0101 : seg = FIVE;
                            4'b0110 : seg = SIX;
                            4'b0111 : seg = SEVEN;
                            4'b1000 : seg = EIGHT;
                            4'b1001 : seg = NINE;
                        endcase
                    end
                    
            2'b11 : begin
                an = 4'b0111;       // Enable leftmost digit (thousands)
                        case(thousands)  // Select pattern based on thousands value
                            4'b0000 : seg = ZERO;
                            4'b0001 : seg = ONE;
                            4'b0010 : seg = TWO;
                            4'b0011 : seg = THREE;
                            4'b0100 : seg = FOUR;
                            4'b0101 : seg = FIVE;
                            4'b0110 : seg = SIX;
                            4'b0111 : seg = SEVEN;
                            4'b1000 : seg = EIGHT;
                            4'b1001 : seg = NINE;
                        endcase
                    end
        endcase
    end
endmodule
