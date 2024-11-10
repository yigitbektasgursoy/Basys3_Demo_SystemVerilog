module UART(
    input clk_i,
    input rst_i,
    
    input write_i,
    input [3:0] data_be_i,
    input [4:0] addr_i,
    input [31:0] wdata_i,
    output [31:0] rdata_o,

	input rx,
	output tx
);

    wire[15:0] cbp;
    wire[1:0]  stop_bits;
    wire[7:0]  tx_data;
    wire[2:0]  cfg;
    
    wire[7:0]  rx_data;
    wire   rx_done;
    wire   tx_done;
    
    uart_mem uart_mem(
        clk_i,
        rst_i,
        
        write_i,
        data_be_i,
        {27'b0, addr_i},
        wdata_i,
        rdata_o,
        
        rx_data,
        rx_done,
        tx_done,

        cbp,
        stop_bits,
        tx_data,
        cfg
    );

    uart_core uart_core(
        clk_i,
        rst_i,

        rx_data,
        rx_done,
        tx_done,

        cbp,
        stop_bits,
        tx_data,
        cfg,

        rx,
        tx
    );

endmodule