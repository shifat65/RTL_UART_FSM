module baud_gen (
    input wire clk, 
    input wire rst_n,
    input wire cnt_1x,
    input wire cnt_16x,

    output reg clr,
    output reg baud_tick_1x,
    output reg baud_tick_16x

);

reg [1:0] nstate, pstate;

parameter [1:0]     IDLE         = 2'b00,
                    running      = 2'b01,
                    tick_16x     = 2'b10,
                    tick_1x      = 2'b11;

always @(*) begin: NSEQL // Non Sequential Logic
    begin: NSL // Next state Logic
        case(pstate) 
            IDLE    : nstate = (rst_n ? running : IDLE);
        
            running : nstate = (cnt_1x  ? tick_1x  : (cnt_16x ? tick_16x : running));
            
            tick_16x: nstate = running;

            tick_1x : nstate = running;

            default : nstate = IDLE;
            
        endcase

    end

    begin: OL // Output Logic  
        case(pstate) 
            IDLE    : begin 
                        clr = 1'b1;
                        baud_tick_16x = 1'b0;
                        baud_tick_1x = 1'b0;
            end
            running : begin 
                        clr = 1'b0;
                        baud_tick_16x = 1'b0;
                        baud_tick_1x = 1'b0;
            end
            tick_16x: begin 
                        clr = cnt_1x ? 1'b1 : 1'b0;
                        baud_tick_16x = 1'b1;
                        baud_tick_1x  = cnt_1x ? 1'b1 : 1'b0;
            end
            tick_1x : begin 
                        clr = 1'b1;
                        baud_tick_16x = 1'b1;
                        baud_tick_1x  = 1'b1;
            end
            default : begin 

            end
        endcase
    end

end

always @(posedge clk, negedge rst_n) begin : SEQL // sequential Logic
    if(~rst_n) begin 
        pstate <= IDLE;
    end
    else begin 
        pstate <= nstate;
    end
end

endmodule