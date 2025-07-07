`timescale 1ns/1ps

module tb_tx;
//clk rst
reg clk=0;
reg rst_n=0;
//baud gen
wire cnt_1x;
wire cnt_16x;
wire clr;
wire baud_tick_1x;
wire baud_tick_16x;
//counter
wire [15:0] count;
//comparator
reg [15:0] baud_div = 16'd32;

//uart_tx
reg start_tx=0;
reg [7:0] data_in;
wire tx_busy;
wire tx_done;
wire tx_line;
reg en = 0;


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
        .baud_div(baud_div),
        .cnt_1x(cnt_1x),
        .cnt_16x(cnt_16x)
    );

uart_tx uut_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .start_tx(start_tx),
        .data_in(data_in),
        .baud_tick_1x(baud_tick_1x),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx_line(tx_line)
    );

// Clock generation: 10ns period (100MHz)
always #5 clk = ~clk;

initial begin
    $dumpfile("tb_tx.vcd");
    $dumpvars(0, tb_tx);

    // Initialize inputs
    rst_n = 0;
    en = 0;
    data_in=8'hA5;
    @(negedge clk);

    rst_n = 1; 
    repeat(2) @(posedge clk); 

    en = 1; // Enable the UART transmitter
    repeat(2) @(posedge clk);

    start_tx = 1; // Start transmission
    repeat(2) @(posedge clk);
   
    start_tx = 0; // Clear start signal   
    repeat(364)@(negedge clk); 

    data_in <= 8'hAA; // Change data to be sent
    start_tx <= 1; // Start transmission again
    repeat(2) @(posedge clk);
    
    start_tx = 0; // Clear start signal
    repeat(364)@(negedge clk);

    $finish;
end

endmodule