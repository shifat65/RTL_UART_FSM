`timescale  1ns/1ps

module tb_rx;
//clock and reset
reg clk = 0;
reg rst_n;

//counter
wire clr;
wire [15:0] count;

//comparator
reg [15:0] baud_div = 16'd32;
wire cnt_16x;
wire cnt_1x;

//baud gen
wire baud_tick_16x;
wire baud_tick_1x;

//uart_rx
reg en;
reg rx_line;
wire rx_busy;
wire rx_done;
wire [7:0] data_received;

counter uut_counter (
    .clk(clk),
    .rst_n(rst_n),
    .clr(clr),
    .count(count)
);

comparator uut_comparator (
    .baud_div(baud_div),
    .count(count),
    .cnt_16x(cnt_16x),
    .cnt_1x(cnt_1x)
);

baud_gen uut_baud_gen (
    .clk(clk),
    .rst_n(rst_n),
    .cnt_1x(cnt_1x),
    .cnt_16x(cnt_16x),
    .clr(clr),
    .baud_tick_1x(baud_tick_1x),
    .baud_tick_16x(baud_tick_16x)
);

uart_rx uut_uart_rx (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .rx_line(rx_line),
    .baud_tick_16x(baud_tick_16x),
    .rx_busy(rx_busy),
    .rx_done(rx_done),
    .data_received(data_received)
);

always #5 clk = ~clk; // 100 MHz clock

// task to send a byte to the Uart receiver
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
    $dumpfile("tb_rx.vcd");
    $dumpvars(0, tb_rx);

    rst_n = 1'b0;
    en = 1'b0;
    rx_line = 1'b1; // idle state of RX line
    @(posedge clk);

    rst_n <= 1'b1; // release reset
    repeat(2)@(posedge clk);
    en <= 1'b1; // enable UART receiver
    repeat(10)@(posedge clk);

    send_byte(8'hAA);
    repeat(170)@(posedge clk); // wait for some time

    send_byte(8'hAB);
    repeat(170)@(posedge clk);

    $finish; // end simulation

end

endmodule