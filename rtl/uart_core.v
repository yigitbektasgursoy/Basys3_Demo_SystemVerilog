module uart_core(
    input clk_i,
    input rst_i,

    output reg [7:0] rx_data_o,
    output reg rx_done_o,
    output reg tx_done_o,

    input[15:0] cbp_i,
    input[1:0] stop_bits_i,
    input[7:0] tx_data_i,
    input[2:0] cfg_i,

    input rx,
    output reg tx
);
    reg[7:0] rx_data_o_nxt;
    reg[7:0] rx_data_tmp, rx_data_tmp_nxt;
    reg rx_done_o_prv, tx_done_o_prv;
    reg[2:0] rx_cntr, rx_cntr_nxt;
    reg[2:0] tx_cntr, tx_cntr_nxt;

    reg[1:0] rx_state, rx_state_nxt;
    reg[1:0] tx_state, tx_state_nxt;
    localparam STATE_IDLE  = 0;
    localparam STATE_START = 1;
    localparam STATE_DATA  = 2;
    localparam STATE_STOP  = 3;

    reg[15:0] rx_clk_cntr, rx_clk_cntr_nxt;
    reg[15:0] tx_clk_cntr, tx_clk_cntr_nxt;
    reg rx_state_en, rx_state_en_nxt;
    reg tx_state_en, tx_state_en_nxt;
    always @(posedge clk_i) begin
        rx_state    <= rx_state_nxt;
        tx_state    <= tx_state_nxt;
        rx_state_en <= rx_state_en_nxt;
        tx_state_en <= tx_state_en_nxt;
        rx_clk_cntr <= rx_clk_cntr_nxt;
        tx_clk_cntr <= tx_clk_cntr_nxt;

        rx_cntr   <= rx_cntr_nxt;
        tx_cntr   <= tx_cntr_nxt;
        rx_data_o <= rx_data_o_nxt;
        rx_data_tmp <= rx_data_tmp_nxt;
        rx_done_o_prv <= rx_done_o;
        tx_done_o_prv <= tx_done_o;
    end
    always @* begin
        rx_state_en_nxt = rst_i;
        tx_state_en_nxt = rst_i;
        rx_clk_cntr_nxt = rx_clk_cntr + 1;
        tx_clk_cntr_nxt = tx_clk_cntr + 1;

        if(tx_state == STATE_STOP) begin
            tx_clk_cntr_nxt = {tx_clk_cntr[15:1] + 1, cbp_i[0]};
        end

        if(rx_clk_cntr == cbp_i) begin
            rx_clk_cntr_nxt = 0;
            rx_state_en_nxt = 1;
        end
        if(tx_clk_cntr == cbp_i) begin
            tx_clk_cntr_nxt = 0;
            tx_state_en_nxt = 1;
        end

        if(rx_state == STATE_IDLE) begin
            rx_clk_cntr_nxt = {1'b0, cbp_i[15:1]};
        end
        
        if(tx_state == STATE_IDLE) begin
            tx_clk_cntr_nxt = 0;
        end
    end

    // Receiver
    always @* begin
        rx_data_o_nxt = rx_data_o;
        rx_done_o = rx_done_o_prv;
        rx_cntr_nxt = rx_cntr + 1;
        rx_data_tmp_nxt = rx_data_tmp;
        case(rx_state)
            STATE_IDLE: begin
                rx_state_nxt = rx ? rx_state : STATE_START;
            end
            STATE_START: begin
                rx_cntr_nxt = 0;
                rx_state_nxt = STATE_DATA;
            end
            STATE_DATA: begin
                rx_data_tmp_nxt[rx_cntr] = rx;
                rx_state_nxt = rx_state;
                if(&rx_cntr) begin
                    rx_state_nxt = STATE_STOP;
                    rx_done_o = 1'b1;
                    rx_data_o_nxt = rx_data_tmp_nxt;
                end
            end
            STATE_STOP: begin
                rx_state_nxt = STATE_IDLE;
            end
        endcase

        if((rx_state != STATE_IDLE) && (!rx_state_en)) begin
            rx_done_o = cfg_i[1];
            rx_cntr_nxt   = rx_cntr;
            rx_state_nxt  = rx_state;
            rx_data_o_nxt = rx_data_o;
            rx_data_tmp_nxt = rx_data_tmp;
        end

        if(rst_i) begin
            rx_state_nxt = STATE_IDLE;
            rx_done_o = 1'b0;
        end
    end
    
    // Transmitter
    always @* begin
        tx_done_o = tx_done_o_prv;
        tx_cntr_nxt = tx_cntr + 1;
        case(tx_state)
            STATE_IDLE: begin
                tx = 1;
                tx_state_nxt = ((~tx_done_o_prv) & cfg_i[0]) ? STATE_START : tx_state;
            end
            STATE_START: begin
                tx = 0;
                tx_cntr_nxt = 0;
                tx_state_nxt = STATE_DATA;
            end
            STATE_DATA: begin
                tx = tx_data_i[tx_cntr];
                tx_state_nxt = tx_state;
                if(&tx_cntr) begin
                    tx_state_nxt = STATE_STOP;
                    tx_done_o = 1'b1;
                end
            end
            STATE_STOP: begin
                tx = 1;
                tx_state_nxt = tx_state;
                case(tx_cntr)
                    3'b001: if(stop_bits_i == 2'b00) tx_state_nxt = STATE_IDLE;
                    3'b010: if(stop_bits_i == 2'b01) tx_state_nxt = STATE_IDLE;
                    3'b011: tx_state_nxt = STATE_IDLE;
                endcase
            end
        endcase
        
        if((tx_state != STATE_IDLE) && (!tx_state_en)) begin
            tx_cntr_nxt   = tx_cntr;
            tx_state_nxt  = tx_state;
            tx_done_o = cfg_i[2];
        end
        
        if(rst_i) begin
            tx_state_nxt = STATE_IDLE;
            tx_done_o = 1'b0;
        end
    end

endmodule