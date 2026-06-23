module uart_rx(input clk,
               input rst,
               input rx,
               output reg done,
               output reg [7:0] data
              );
  
  wire rx_en;
  
  baud_rate_gen baud(.clk(clk),
                .rst(rst),
                .tx_en(),
                .rx_en(rx_en)
               );
  
  reg [1:0] state, nxt_state;
  localparam IDLE = 2'b00,
  			 DATA = 2'b01,
  			 STOP = 2'b10;
  
  reg [7:0] tx_data;
  reg [2:0] bit_cnt;
  
  //data register
  always@(posedge clk) begin
    if(rst) begin
      tx_data <= 0;
      done <= 0;
    end
    else if(rx_en && state == DATA)
      tx_data[bit_cnt] <= rx;
    else if(rx_en && state == STOP) begin
      if(rx) begin
        data <= tx_data;
        done <= 1'b1;
      end
      else done<= 0;
    end
    else
      done <= 0;
  end
  
  //bit counter
  always@(posedge clk) begin
    if(rst | state == IDLE)
      bit_cnt <= 0;
    else if(state == DATA && rx_en)
      bit_cnt <= bit_cnt + 1'b1;
  end
  
  //state register
  always@(posedge clk) begin
    if(rst)
      state <= IDLE;
    else
      state <= nxt_state;
  end
  
  //state transition
  always@(*) begin
    nxt_state = state;
    if(rx_en)
      case(state)
        IDLE: begin
          if(!rx)
            nxt_state = DATA;
          else
            nxt_state = IDLE;
        end
        DATA: begin
          if(bit_cnt != 3'd7)
            nxt_state = DATA;
          else
            nxt_state = STOP;
        end
        STOP: begin
          nxt_state = IDLE;
        end
        default: nxt_state = IDLE;
      endcase
  end
  
endmodule
          
