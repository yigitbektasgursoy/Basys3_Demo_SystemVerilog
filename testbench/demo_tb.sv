`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2024 04:31:33 PM
// Design Name: 
// Module Name: demo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module demo_tb();

    logic  clk_100MHz;       // from Basys 3
    logic  reset;            // btnC
    logic  [0:6] seg;       // 7 segment display segment pattern
    logic  [3:0] an;         // 7 segment display anodes,
    logic tx;

    integer CLK_PERIOD = 10;
    
    initial begin
        clk_100MHz = 0;
        forever begin
            #(CLK_PERIOD) clk_100MHz = ~clk_100MHz;
        end
    end
    
    
    demo DUT (clk_100MHz, reset, seg, tx, an);
    
    initial begin
     reset = 1;
     #(50_000);
     reset = 0;
    end
    

endmodule
