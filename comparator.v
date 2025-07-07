module comparator (
    input wire [15:0] count,
    input wire [15:0] baud_div,

    output wire cnt_16x,
    output wire cnt_1x
);
    wire[15:0] step_16x = baud_div >> 4;
    //reg [3:0] baud_count;
    assign cnt_1x = (count == baud_div-1) ? 1'b1 : 1'b0;
    assign cnt_16x = ((step_16x !=0) && ((count % step_16x)==0))? 1'b1 : 1'b0;

endmodule