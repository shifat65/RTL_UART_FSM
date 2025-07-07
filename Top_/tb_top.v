`timescale 1ns/1ps

module tb_top;

    reg clk=0;
    reg rst_n;
    reg en_tx;
    reg en_rx;

    reg [15:0] baud_div;

    reg start_tx;
    reg [7:0] data_in;

    reg rx_line;

    wire tx_busy;
    wire tx_done;
    wire tx_line;

    wire rx_busy;
    wire rx_done;
    wire [7:0] data_received;

    wire baud_tick_16x;

top uut_top(
    .clk(clk),
    .rst_n(rst_n),
    .en_tx(en_tx),
    .en_rx(en_rx),

    .baud_div(baud_div),

    .start_tx(start_tx),
    .data_in(data_in),

    .rx_line(rx_line),

    .tx_busy(tx_busy),
    .tx_done(tx_done),
    .tx_line(tx_line),
    .rx_busy(rx_busy),

    .rx_done(rx_done),
    .data_received(data_received),
    .baud_tick_16x(baud_tick_16x)
);

always #5 clk = ~clk;

task send_byte(input [7:0] byte);
    integer i;
    begin 
        //Start bit
        rx_line = 1'b0;
        repeat(16)@(posedge baud_tick_16x);

        //Sending data
        for( i =0; i<8; i++)begin 
            rx_line = byte[i];
            repeat(16)@(posedge baud_tick_16x);
        end

        //sending stop bit

        rx_line =  1'b1;
        repeat(16)@(posedge baud_tick_16x);
    end
endtask

initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0,tb_top);

    rst_n <= 1'b0;
    en_tx <= 0 ;
    en_rx <= 0;
    baud_div <= 16'd32;
    start_tx <= 0;
    data_in <= 0;
    rx_line <= 1;
    @(negedge clk);

    rst_n <= 1'b1;
    repeat(3)@(negedge clk);

    en_tx <= 1'b1;
    @(negedge clk);

    //sending data AA
    data_in <= 8'hAA;
    start_tx <= 1'b1;
    repeat(1)@(negedge clk);
    start_tx <= 1'b0;
    repeat(364)@(negedge clk);

    //sending data 
    data_in <= 8'b11001100;
    start_tx =1;
    @(negedge clk);
    start_tx =0;
    repeat(364)@(negedge clk);


    en_rx = 1;
    repeat(2)@(negedge clk);

    //receiveing data AB
    send_byte(8'hAB);
    repeat(170)@(posedge clk);
    
    //receiving data BD
    send_byte(8'hBD);
    repeat(170)@(posedge clk);

    //sending and receing same time
    data_in <= 8'b10101010;
    start_tx <=1;
    send_byte(8'hA9);
    @(negedge clk);
    start_tx =0;
    repeat(364)@(negedge clk);


    $finish;

end



endmodule
