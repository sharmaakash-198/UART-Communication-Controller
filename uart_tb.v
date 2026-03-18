`timescale 1ns/1ps

module uart_tb;

    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;
    wire tick;

    wire rx;
    assign rx = tx;

    wire [7:0] rx_data;
    wire rx_done;

    baud_gen bg (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    // Instantiate UART TX
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tick(tick),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    //Instantiate UART rx
    uart_rx rx_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(tick),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'b10101100;

        // Reset pulse
        #10 reset = 0;

        // Start transmission
        #10 tx_start = 1;
        #10 tx_start = 0;

        // Wait for the receiver to finish and check the received byte.
        @(posedge rx_done);
        #1;
        if (rx_data == tx_data)
            $display("PASS: rx_data = %b, tx_data = %b", rx_data, tx_data);
        else
            $display("FAIL: rx_data = %b, tx_data = %b", rx_data, tx_data);

        // Small delay so the result is visible before ending simulation.
        #20;

        $finish;
    end

    // Dump waveform
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, uart_tb);
    end

endmodule
