module counter (
    input wire clk,
    input wire rst_n,
    input wire clr,

    output reg [15:0] count
);

always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin 
        count <= 16'd0;
    end
    else begin 
        count <= clr ? 16'd0 : count + 1;
    end
    
end
    
endmodule