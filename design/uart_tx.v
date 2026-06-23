`include "baud_rate_gen.v"
module uart_tx(input clk,
               input rst,
               input ready,
               input [7:0] data,
               output reg done,
               output reg tx
              );
  wire tx_en;
  reg [3:0] bit_cnt;
  reg [7:0] data_frame;
  
  baud_rate_gen baud(.clk(clk),
                .rst(rst),
                .tx_en(tx_en),
                .rx_en()
               );
  
  reg [1:0] state, nxt_state;
  
  localparam IDLE = 2'd0,
  			 START = 2'b01,
  			 DATA = 2'b10,
  			 STOP = 2'b11;
  
  //bit counter
  always@(posedge clk) begin
    if(rst | state == IDLE)
      bit_cnt <= 0;
    else if(state == DATA && tx_en)
      bit_cnt <= bit_cnt + 1'b1;
  end
  
  //shift reg
  always@(posedge clk) begin
    if(rst | state == IDLE)
      data_frame <= data;
    else if(state == DATA && bit_cnt!=4'd8 && tx_en)
      data_frame <= {1'b1,data_frame[7:1]};
  end
      
  
  //state register
  always@(posedge clk) begin
    if(rst)
      state <= IDLE;
    else
      state <= nxt_state;
  end
  
  //transition logic
  always@(*) begin
    nxt_state = state;
    tx = 1'b1;
    done = 0;
    case(state)
      IDLE: begin
        if(ready)
          nxt_state = START;
        else
          nxt_state = IDLE;
      end
      START: begin
        if(tx_en) begin
          nxt_state = DATA;
        end
        else nxt_state = START;
      end
      DATA: begin
        if(tx_en) begin
          if(bit_cnt == 4'd8) begin
            nxt_state = STOP;
          end
          else begin
            nxt_state = DATA;
          end
        end
        else nxt_state = DATA;
      end
      STOP: begin
        if(tx_en)
          nxt_state = IDLE;
      end
    endcase
  end
  
  //output logic
  always@(posedge clk) begin
    if(rst)
        tx <= 1;
    else if(state == START)
        tx <= 0;
    else if(state == DATA && tx_en) begin
      tx <= data_frame[0];
      if(bit_cnt == 4'd8)
        done <= 1'b1;
    end     
    else if(state == STOP && tx_en) begin
      tx <= 1;
      done <= 1;
    end
    else if(state == IDLE)
      done <= 0;
  end
      
            
        
        
  
endmodule
  
  
  

