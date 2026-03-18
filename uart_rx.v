module uart_rx (
    input clk,
    input reset,
    input rx,
    input tick,
    output reg [7:0] rx_data,
    output reg rx_done
);

    parameter IDLE = 3'b000;
    parameter START = 3'b001;
    parameter DATA = 3'b010;
    parameter STOP = 3'b011;
    parameter DONE = 3'b100;

    reg [2:0] state;
    reg [2:0] bit_index;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
            rx_data <= 0;
            rx_done <= 0;
            bit_index <= 0;
        end else begin 
            case (state)

                IDLE: begin
                    rx_done <= 0;
                    if(rx == 0)  //start bit detected
                        state <= START;
                end

                START: begin
                    if (tick) begin
                        if (rx == 0) begin   // confirm start bit
                            state <= DATA;
                            bit_index <= 0;
                        end else begin
                            state <= IDLE;   // false start
                        end
                    end
                end

                DATA: begin
                    if (tick) begin
                        rx_data[bit_index] <= rx;
                        if(bit_index == 7)
                            state <= STOP;
                        else 
                            bit_index <= bit_index + 1;
                    end
                end

                STOP: begin
                    if (tick) begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    rx_done <= 1;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule

