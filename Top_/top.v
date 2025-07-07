module top(
    input wire clk,
    input wire rst_n,
    input wire en_tx,
    input wire en_rx,

    input wire [15:0] baud_div,

    input wire start_tx,
    input wire [7:0] data_in,

    input wire rx_line,

    output wire tx_busy,
    output wire tx_done,
    output wire tx_line,

    // to send data internnaly, we need 16x out
    output wire baud_tick_16x,

    output wire rx_busy,
    output wire rx_done,
    output wire [7:0] data_received


);

wire clr,
     cnt_16x,
     cnt_1x,
     //baud_tick_16x,
     baud_tick_1x;

wire [15:0] count;

counter uut_counter (
    .clk(clk),
    .rst_n(rst_n),
    .clr(clr),
    .count(count)
);

comparator uut_comparator(
    .count(count),
    .baud_div(baud_div),
    .cnt_16x(cnt_16x),
    .cnt_1x(cnt_1x)
);

baud_gen uut_baud_gen(
    .clk(clk), 
    .rst_n(rst_n),
    .cnt_1x(cnt_1x),
    .cnt_16x(cnt_16x),

    .clr(clr),
    .baud_tick_1x(baud_tick_1x),
    .baud_tick_16x(baud_tick_16x)
);

uart_tx uut_uart_tx(
    .clk(clk), 
    .rst_n(rst_n),
    .en(en_tx),
    .start_tx(start_tx),
    .data_in(data_in),
    .baud_tick_1x(baud_tick_1x),
    .tx_busy(tx_busy),
    .tx_done(tx_done),
    .tx_line(tx_line)
);

uart_rx uut_uart_rx(
    .clk(clk),
    .rst_n(rst_n),
    .en(en_rx),
    .rx_line(rx_line),
    .baud_tick_16x(baud_tick_16x),
    .rx_busy(rx_busy),
    .rx_done(rx_done),
    .data_received(data_received)
);


endmodule