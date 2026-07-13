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
  			 START = 2'b01,
  			 DATA = 2'b10,
  			 STOP = 2'b11;
  
  reg [7:0] rx_data;
  reg [2:0] bit_cnt;
  reg [3:0] sample_cnt;
  reg shift;
  
  //state register
  always@(posedge clk) begin
    if(rst)
      state<=IDLE;
    else
      state<=nxt_state;
  end
  
  //counters
  always@(posedge clk) begin
    if(rst||state==IDLE) begin
      sample_cnt<=0;
      bit_cnt<=0;
    end
    else begin
      if(sample_cnt==15 && rx_en) begin
        sample_cnt<=0;
        if(state == DATA)
          bit_cnt<=bit_cnt+1'b1;
      end
      else if((state == START || state == DATA||state==STOP) && rx_en) begin
        sample_cnt<=sample_cnt+1'b1;
      end
    end
  end
  
  //shift register
  always@(posedge clk) begin
    if(rst)
      rx_data<=0;
    else if(shift) 
      rx_data[bit_cnt]<=rx;
  end
        
  
  //transition logic
  always@(*) begin
    shift = 0;
    nxt_state = state;
    case(state)
      IDLE: begin
        if(!rx)
          nxt_state = START;
        else
          nxt_state = IDLE;
      end
      START: begin
        if(rx_en) begin
          if(sample_cnt == 7) begin
            if(rx)
              nxt_state = IDLE;
            else 
              nxt_state = START;
          end
          else if(sample_cnt != 15)
            nxt_state = START;
          else
            nxt_state = DATA;
        end
      end
      DATA: begin
        if(rx_en) begin
          if(sample_cnt == 15) begin
            shift = 1;
            if(bit_cnt == 7)
              nxt_state = STOP;
            else
              nxt_state = DATA;
          end
          else
            nxt_state = DATA;
        end
      end
      STOP: begin
        if(rx_en) begin
          if(sample_cnt==15)
            nxt_state = IDLE;
          else
            nxt_state = STOP;
        end
      end
      default:
        nxt_state = IDLE;
    endcase
  end
  
  //output logic
  always@(posedge clk) begin
    if(rst) begin
      done<=0;
      data<=0;
    end
    else
      begin
        case(state)
          IDLE: begin
            done<=0;
          end
          START: done<=0;
          STOP: begin
            if(sample_cnt==15 & rx & rx_en) begin
              done<=1;
              data<=rx_data;
            end
          end
          default: begin
            done<=0;
          end
        endcase
      end
  end
              
  
  
endmodule
