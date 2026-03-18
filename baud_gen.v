module baud_gen #(
    parameter CLK_FREQ = 50000000,   // 50 MHz
    parameter BAUD_RATE = 9600
)(
    input clk,
    input reset,
    output reg tick
);

    localparam DIVISOR = 10;   // TEMP FOR SIMULATION
    reg [15:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            tick <= 0;
        end else begin
            if (counter == DIVISOR - 1) begin
                counter <= 0;
                tick <= 1;  // pulse
            end else begin
                counter <= counter + 1;
                tick <= 0;
            end
        end
    end

endmodule