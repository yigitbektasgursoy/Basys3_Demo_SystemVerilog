`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: BcdCounter
// Description: This module implements a 4-digit counter that counts from 0000 to 1903.
//              Each digit is controlled separately and follows BCD counting rules.
//              The counter increments on each positive edge of the divided clock.
//              When maximum value (1881) is reached, the counter stops.
//////////////////////////////////////////////////////////////////////////////////

module digit_counter #(
    parameter DIGIT_WIDTH = 4,      // Width of each digit counter
    parameter MAX_ONES = 1,         // Maximum value for ones digit
    parameter MAX_TENS = 8,         // Maximum value for tens digit 
    parameter MAX_HUNDREDS = 8,     // Maximum value for hundreds digit
    parameter MAX_THOUSANDS = 1     // Maximum value for thousands digit
)(
    input  logic                        div_clock,    // Divided clock input
    input  logic                        reset,      // Active high reset
    output logic [DIGIT_WIDTH-1:0]      digit_ones,   // Ones place value (0-3)
    output logic [DIGIT_WIDTH-1:0]      digit_tens,   // Tens place value (0)
    output logic [DIGIT_WIDTH-1:0]      digit_hundreds, // Hundreds place value (0-9)
    output logic [DIGIT_WIDTH-1:0]      digit_thousands // Thousands place value (0-1)
);

    // Control logic for ones digit counter
    // Counts from 0 to 1 repeatedly unless at max display value
    always_ff @(posedge div_clock or posedge reset) begin
        if(reset) begin
            digit_ones <= '0;  // Reset to zero
        end
        else begin
            if(digit_ones < MAX_ONES) begin
                digit_ones <= digit_ones + 1'b1;  // Increment if below max
            end
            else begin
                digit_ones <= digit_ones;  // Hold value at max
            end
        end
    end

    // Control logic for tens digit counter
    // Resets to 0 when ones reaches 1
    always_ff @(posedge div_clock or posedge reset) begin
        if(reset) begin
            digit_tens <= '0;  // Reset to zero
        end
        else begin
            if(digit_ones == MAX_ONES) begin
                if(digit_tens == MAX_TENS) begin
                    digit_tens <= digit_tens;  // Hold at max value
                end
                else begin
                    digit_tens <= digit_tens + 1'b1;  // Increment
                end
            end
        end
    end

    // Control logic for hundreds digit counter
    // Increments when tens and ones are at max, unless at 8
    always_ff @(posedge div_clock or posedge reset) begin
        if(reset) begin
            digit_hundreds <= '0;  // Reset to zero
        end
        else begin
            if(digit_tens == MAX_TENS && digit_ones == MAX_ONES) begin
                if(digit_hundreds == MAX_HUNDREDS) begin
                    digit_hundreds <= digit_hundreds;  // Hold at max value
                end
                else begin
                    digit_hundreds <= digit_hundreds + 1'b1;  // Increment
                end
            end
        end
    end

    // Control logic for thousands digit counter
    // Increments when all lower digits are at max, unless at 1
    always_ff @(posedge div_clock or posedge reset) begin
        if(reset) begin
            digit_thousands <= '0;  // Reset to zero
        end
        else begin
            if(digit_hundreds == MAX_HUNDREDS && digit_tens == MAX_TENS && digit_ones == MAX_ONES) begin
                if(digit_thousands == MAX_THOUSANDS) begin
                    digit_thousands <= digit_thousands;  // Hold at max value
                end
                else begin
                    digit_thousands <= digit_thousands + 1'b1;  // Increment
                end
            end
        end
    end

endmodule