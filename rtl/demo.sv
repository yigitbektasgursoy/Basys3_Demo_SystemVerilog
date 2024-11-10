`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2024 04:17:26 PM
// Design Name: 
// Module Name: demo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top-level module that implements a 4-digit counter displayed on
//              7-segment displays. The counter increments at a divided clock rate
//              and displays values from 0000 to 1999.
// 
// Dependencies: 
//   - clock_div: Clock divider module to generate slower clock
//   - digits: Counter logic for each digit position
//   - LED: 7-segment display controller
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Parameterized top-level module for counter display system
typedef enum logic [2:0] {
    IDLE,
    SET_CPB,
    SET_STOP,
    SET_TDR,
    SET_CFG,
    WAIT,
    DONE
} state_t;



module demo #(
    parameter DISPLAY_WIDTH = 4,           // Number of display digits
    parameter SEGMENT_WIDTH = 7,           // Number of segments per digit
    parameter DIGIT_WIDTH = 4,             // Bits per digit counter
    parameter DATA_WIDTH = 8,
    parameter IMAGE_SIZE = 5558,
    parameter UART_BAUD_RATE = 57600,
    parameter CLK_FREQ = 100_000_000
)(
    input  logic                    clk_100MHz,      // Main system clock from Basys 3 (100MHz)
    input  logic                    reset,           // System reset (active high) - connected to btnC
    output logic [0:SEGMENT_WIDTH-1] seg,            // 7-segment display segment pattern (active low)
    output logic                    tx,             // UART transmit signal (connected to USB-RS232)
    output logic [DISPLAY_WIDTH-1:0] an              // Display digit enable signals (active low)
);
    
    // Internal signals for digit values
    logic [DIGIT_WIDTH-1:0] digit_ones;      // Counter for ones place (0-9)
    logic [DIGIT_WIDTH-1:0] digit_tens;      // Counter for tens place (0-9)
    logic [DIGIT_WIDTH-1:0] digit_hundreds;  // Counter for hundreds place (0-9)
    logic [DIGIT_WIDTH-1:0] digit_thousands; // Counter for thousands place (0-1)
    
    // Divided clock signal for counter update rate
    logic divided_clock;
    
    logic [DATA_WIDTH-1:0] image_data [IMAGE_SIZE-1:0];
    initial begin
        $readmemh("image.hex", image_data);
    end
    // Clock divider instantiation - generates slower clock for counter updates
    clock_divider clock_divider(
        .input_clock(clk_100MHz),
        .reset_n(reset),
        .output_clock(divided_clock)
    );
    
    // Digit counter instantiation - manages counter logic for all digits
    digit_counter digit_counter(
        .div_clock(divided_clock),
        .reset(reset),
        .digit_ones(digit_ones),
        .digit_tens(digit_tens),
        .digit_hundreds(digit_hundreds),
        .digit_thousands(digit_thousands)
    );
    
    // Display controller instantiation - handles 7-segment display multiplexing
    display_controller display_controller(
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .ones(digit_ones),
        .tens(digit_tens),
        .hundreds(digit_hundreds),
        .thousands(digit_thousands),
        .seg(seg),
        .an(an)
    );


    logic [$clog2(IMAGE_SIZE)-1:0] image_index, image_index_next;
    logic write_i, write_i_next;
    logic [4:0] addr_i, addr_i_next;
    logic [31:0] wdata_i, wdata_i_next;
    logic [31:0] rdata_o;
    UART uart(
        clk_100MHz,
        reset,
    
        write_i,
        4'hf,
        addr_i,
        wdata_i,
        rdata_o,
    
        1'b1,
        tx
    );
    
    state_t state, next_state;

    always_ff @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            write_i <= 1'b0;
            addr_i <= 5'd0;
            wdata_i <= 32'd0;
            image_index <= 0;
        end else begin
            state <= next_state;
            write_i <= write_i_next;
            addr_i <= addr_i_next;
            wdata_i <= wdata_i_next;
            image_index <= image_index_next;
        end
    end

    always_comb begin
        next_state = state;
        write_i_next = 1'b0;
        addr_i_next = addr_i;
        wdata_i_next = wdata_i;
        image_index_next = image_index;
        case (state)
            IDLE: next_state = SET_CPB;
            SET_CPB: begin
                next_state = SET_STOP;
                write_i_next = 1'b1;
                addr_i_next = 5'd0;
                wdata_i_next = (CLK_FREQ / UART_BAUD_RATE) - 1;
            end
            SET_STOP: begin
                next_state = SET_TDR;
                write_i_next = 1'b1;
                addr_i_next = 5'd4;
                wdata_i_next = 32'd2;
            end
            SET_TDR: begin
                next_state = SET_CFG;
                write_i_next = 1'b1;
                addr_i_next = 5'd12;
                wdata_i_next = {24'b0, image_data[image_index]};
                image_index_next = image_index + 1;
            end
            SET_CFG: begin
                next_state = WAIT;
                write_i_next = 1'b1;
                addr_i_next = 5'd16;
                wdata_i_next = 32'd1;
            end
            WAIT:begin
                next_state = WAIT;
                if(rdata_o == 32'd5) begin
                    write_i_next = 1'b1;
                    wdata_i_next = 32'd0;
                    next_state = SET_TDR;
                    if(image_index == IMAGE_SIZE - 1) begin
                        next_state = DONE;
                    end
                end
            end
            DONE: next_state = state;
        endcase
    end

endmodule
