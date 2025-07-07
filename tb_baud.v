`timescale 1ns/1ps

module tb_baud;

    reg clk;
    reg rst_n;
    wire cnt_1x;
    wire cnt_16x;
    reg [15:0] baud_div; // Example divisor for 9600 baud at 100MHz

    wire [15:0] count;
    wire clr;
    wire baud_tick_1x;
    wire baud_tick_16x;

    // Instantiate the module under test
    baud_gen uut_baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .cnt_1x(cnt_1x),
        .cnt_16x(cnt_16x),
        .clr(clr),
        .baud_tick_1x(baud_tick_1x),
        .baud_tick_16x(baud_tick_16x)
    );
    counter uut_counter(
        .clk(clk),
        .rst_n(rst_n),
        .clr(clr),
        .count(count)
    );

    comparator uut_comparator(
        .count(count),
        .baud_div(baud_div), // Example baud rate divisor for 9600 baud at 100MHz
        .cnt_1x(cnt_1x),
        .cnt_16x(cnt_16x)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_baud.vcd");
        $dumpvars(0, tb_baud);
        // Initialize inputs
        rst_n = 0;
        baud_div = 16'd32; // Set baud divisor for 9600 baud at 100MHz
        @(negedge clk);
        rst_n = 1; // Release reset
        repeat(500) @(posedge clk); // Wait for a few clock cycles
        $finish;
    end


endmodule
