module uart_rx(
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire rx_line,
    input wire baud_tick_16x,

    output reg rx_busy,
    output reg rx_done,
    output reg [7:0] data_received

);
reg [2:0] nstate, pstate;
reg [3:0] bit_count;
reg [3:0] baud_count;
reg [7:0] rx_shift_reg;

parameter [2:0] IDLE          = 3'b000,
                Enable        = 3'b001,
                Conf_rsv      = 3'b010,
                Receiving    = 3'b011,
                Receive_done  = 3'b100;

always @(*) begin: NSEQL //Non Sequential Logic
    begin:NSL //Next State Logic 
        case (pstate)
            IDLE: nstate = en ? Enable : IDLE;
            
            Enable: nstate = (!rx_line) ? Conf_rsv : Enable;  

            Conf_rsv: nstate = (baud_count == 4'd7) ? ((!rx_line) ? Receiving : Enable) : Conf_rsv;

            Receiving: nstate = (bit_count == 4'd8) ? Receive_done : Receiving;

            Receive_done: nstate = (!rx_line) ? Conf_rsv : Receive_done;

            default: nstate = IDLE;
        endcase
    end//end NSL

    begin: OL // Output logic
        case (pstate)
            IDLE: begin
                rx_busy = 1'b0;
                rx_done = 1'b0;
                data_received = 8'b0; // reset data received
                bit_count = 3'b0; // reset bit count
                baud_count = 4'b0; // reset baud count
            end 

            Enable: begin
                rx_busy = 1'b0;
                rx_done = 1'b0;
                data_received = 8'b0; // reset data received
                bit_count = 3'b0; // reset bit count
                baud_count = 4'b0; // reset baud count
            end

            Conf_rsv: begin 
                rx_busy = 1'b0;
                rx_done = 1'b0;
                //data_received = 8'b0;
                bit_count = 3'b0;
                if(baud_count >= 4'd7) begin 
                    baud_count = 4'b0;
                end
            end

            Receiving: begin 
                rx_busy = 1'b1;
                rx_done = 1'b0;
                data_received = 8'b0;
            end

            Receive_done: begin 
                rx_busy = 1'b0;
                rx_done = 1'b1;
                data_received = rx_shift_reg; // output the received data
                bit_count = 3'b0; // reset bit count
                baud_count = 4'b0; // reset baud count
            end
              
            default: begin 
                rx_busy <= 1'b0;
                rx_done <= 1'b0;
                data_received <= 8'b0; // reset data received
                bit_count <= 3'b0; // reset bit count
                baud_count <= 4'b0; // reset baud count
            end 
        endcase
    end//end OL
end //end NSEQL

always @(posedge clk, negedge rst_n) begin: SL // sequential logic
    if (!rst_n) begin
        pstate <= IDLE;
    end else begin
        if(pstate == Conf_rsv && baud_tick_16x) begin 
            baud_count <= baud_count + 1'b1;
        end
        if(pstate == Receiving && baud_tick_16x) begin 
            baud_count <= baud_count + 1'b1;
            if (baud_count == 4'd15) begin 
                baud_count <= 4'b0;
                bit_count <= bit_count + 1'b1;
                rx_shift_reg <= {rx_line, rx_shift_reg[7:1]};
            end
        end

        pstate <= nstate;
    end
end //end SL

endmodule