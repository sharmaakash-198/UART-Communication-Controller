module uart_tx (
    input clk,
    input reset,
    input tx_start,
    input tick,
    input [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);

    // FSM states
    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    reg [1:0] state;
    reg [7:0] data_reg;
    reg [2:0] bit_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1;
            tx_busy <= 0;
            bit_index <= 0;
        end else begin
            case (state)

                IDLE: begin
                    tx <= 1;
                    tx_busy <= 0;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        state <= START;
                        tx_busy <= 1;
                    end
                end

                START: begin
                    if (tick) begin
                        tx <= 0; // start bit
                        state <= DATA;
                        bit_index <= 0;
                    end
                end

                DATA: begin
                    if (tick) begin
                        tx <= data_reg[bit_index];
                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end
                end

                STOP: begin
                    if (tick) begin
                        tx <= 1; // stop bit
                        state <= IDLE;
                    end
                end

            endcase
        end
    end

endmodule