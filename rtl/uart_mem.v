module uart_mem(
    input clk_i,
    input rst_i,

    input write_bus,
    input[3:0] be_bus,
    input[31:0] addr_bus,
    input[31:0] data_i_bus,
    output reg[31:0] data_o_bus,
    
    input[7:0]   rx_data_i,
    input    rx_done_i,
    input    tx_done_i,

    output[15:0] cbp_o,
    output[1:0]  stop_bits_o,
    output[7:0]  tx_data_o,
    output[2:0]  cfg_o
);
    parameter SIZE=5;
    parameter[SIZE-1:0] ALLOW_WRITE=5'b11011;

    reg[31:0] mem[0:SIZE-1], mem_nxt[0:SIZE-1];
    reg[(SIZE-1):0] mem_wren_bus;
    
    integer j;
    initial begin
        for(j=0; j<SIZE; j=j+1) begin
            if(~ALLOW_WRITE[j]) mem[j] = 0;
        end
    end

    assign cbp_o       = mem[0][15:0];
    assign stop_bits_o = mem[1][1:0];
    assign tx_data_o   = mem[3][7:0];
    assign cfg_o       = mem[4][2:0];

    genvar i;
    generate
        for(i=0;i<SIZE;i=i+1) begin
            always @(posedge clk_i) mem[i] <= rst_i ? 0 : mem_nxt[i];
        end
        for(i=0;i<2;i=i+1) begin
            always @* begin
                mem_nxt[i] = mem[i];
                if(mem_wren_bus[i]) begin
                    mem_nxt[i][ 0+:8] = be_bus[0] ? data_i_bus[ 0+:8] : mem[i][ 0+:8];
                    mem_nxt[i][ 8+:8] = be_bus[1] ? data_i_bus[ 8+:8] : mem[i][ 8+:8];
                    mem_nxt[i][16+:8] = be_bus[2] ? data_i_bus[16+:8] : mem[i][16+:8];
                    mem_nxt[i][24+:8] = be_bus[3] ? data_i_bus[24+:8] : mem[i][24+:8];
                end
            end
        end
        always @* begin
            mem_nxt[2] = {24'h0, rx_data_i};
            
            mem_nxt[3] = mem[3];
            if(mem_wren_bus[3]) begin
                mem_nxt[3][ 0+:8] = be_bus[0] ? data_i_bus[ 0+:8] : mem[3][ 0+:8];
                mem_nxt[3][ 8+:8] = be_bus[1] ? data_i_bus[ 8+:8] : mem[3][ 8+:8];
                mem_nxt[3][16+:8] = be_bus[2] ? data_i_bus[16+:8] : mem[3][16+:8];
                mem_nxt[3][24+:8] = be_bus[3] ? data_i_bus[24+:8] : mem[3][24+:8];
            end
            
            mem_nxt[4] = {mem[4][31:3], tx_done_i, rx_done_i, mem[4][0]};
            if(mem_wren_bus[4]) begin
                mem_nxt[4][ 0+:8] = be_bus[0] ? data_i_bus[ 0+:8] : mem[4][ 0+:8];
                mem_nxt[4][ 8+:8] = be_bus[1] ? data_i_bus[ 8+:8] : mem[4][ 8+:8];
                mem_nxt[4][16+:8] = be_bus[2] ? data_i_bus[16+:8] : mem[4][16+:8];
                mem_nxt[4][24+:8] = be_bus[3] ? data_i_bus[24+:8] : mem[4][24+:8];
            end
        end

    endgenerate

    always @* begin
        mem_wren_bus = 0;
        mem_wren_bus[addr_bus[31:2]] = write_bus & ALLOW_WRITE[addr_bus[31:2]];
        data_o_bus = mem[addr_bus[31:2]];
    end
endmodule