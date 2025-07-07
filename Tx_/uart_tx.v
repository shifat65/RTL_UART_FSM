module uart_tx (
    input wire clk, 
    input wire rst_n,
    input wire en,
    input wire start_tx,
    input wire [7:0] data_in,
    input wire baud_tick_1x,

    output reg tx_busy,
    output reg tx_done,
    output reg tx_line
);

reg [2:0] nstate, pstate;
reg [9:0] tx_shift_reg;
reg [3:0] bit_count;

parameter [2:0]     IDLE         = 3'b000,
                    Enable       = 3'b001,
                    Make_pkt     = 3'b010,
                    sending      = 3'b011,
                    send_done    = 3'b100;

always @(*) begin: NSEQL // Non Sequential Logic
    begin: NSL // Next state Logic
        case(pstate) 
            IDLE    : nstate = en ? Enable : IDLE;

            Enable  : nstate = start_tx ? Make_pkt : Enable;

            Make_pkt: nstate = (baud_tick_1x)? sending : Make_pkt;

            sending : nstate = (bit_count >= 4'd10) ? send_done : sending;

            send_done: nstate = start_tx ? Make_pkt : send_done;

            default : nstate = IDLE;

        endcase

    end

    begin: OL // Output Logic  
        case(pstate) 
            IDLE    : 
                begin 
                    tx_busy <= 1'b0;
                    tx_done <= 1'b0;
                    tx_line <= 1'b1; // idle state of UART line is high
                    bit_count <= 4'b0; // reset bit count             
                end

            Enable  : 
                begin 
                    tx_busy <= 1'b0;
                    tx_done <= 1'b0;
                    tx_line <= 1'b1; // idle state of UART line is high     
                    bit_count <= 4'b0; // reset bit count         
                end

            Make_pkt:
                begin 
                    tx_busy <= 1'b1;
                    tx_done <= 1'b0;
                    tx_line <= 1'b1; // start bit is low
                    tx_shift_reg <= {1'b1, data_in, 1'b0}; // add stop bit and start bit
                    bit_count <= 4'b0; // reset bit count
                end

            sending : 
                begin 
                    tx_busy <= 1'b1;
                    tx_done <= 1'b0;
                    if(bit_count >= 4'd10)begin 
                        tx_line <= 1'b1;;
                    end else begin 
                        tx_line <= tx_shift_reg[0];
                    end
                    
                end

            send_done: 
                begin 
                    tx_busy <= 1'b0;
                    tx_done <= 1'b1;
                    tx_line <= 1'b1; // stop bit is high
                    bit_count <= 4'b0; // reset bit count
                end

            default : 
                begin 
                    tx_busy <= 1'bx;
                    tx_done <= 1'bx;
                    tx_line <= 1'bx; // idle state of UART line is high
                end
        endcase
    end

end

always @(posedge clk, negedge rst_n) begin : SEQL // sequential Logic
    if(~rst_n) begin 
        pstate <= IDLE;
        bit_count <= 4'b0;
        tx_shift_reg <= 10'b0;
    end
    else begin
        if(pstate == sending && baud_tick_1x) begin
            tx_shift_reg <= tx_shift_reg >>1; // shift right
            bit_count <= bit_count + 1'b1; // increment bit count
        end
        pstate <= nstate;
        
    end
end

endmodule