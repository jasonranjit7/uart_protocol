module baud_rate_gen#(parameter BAUD = 9600, FREQ = 50* 10**6,
                           OVERSAMPLE_RATE = 16)
  						 (input clk,
                          input rst,
                          output tx_en,
                          output rx_en
                         );
  
  localparam tx_cycles = FREQ/BAUD;
  localparam rx_cycles = tx_cycles/OVERSAMPLE_RATE; //oversampling
  
  reg [$clog2(tx_cycles)-1:0] tx_count; 
  reg [$clog2(rx_cycles)-1:0] rx_count;
  
  //tx counter
  always@(posedge clk) begin
    if(rst)
      tx_count <= 0;
    else if(tx_count != tx_cycles-1)
      tx_count <= tx_count + 1'b1;
    else 
      tx_count <= 0;
  end
  
  assign tx_en = (tx_count == 0);
  
  //rx counter
  always@(posedge clk) begin
    if(rst)
      rx_count <= 0;
    else if(rx_count != rx_cycles-1)
      rx_count <= rx_count + 1'b1;
    else 
      rx_count <= 0;
  end
  
  assign rx_en = (rx_count == 0);
      
  
endmodule
  
  
