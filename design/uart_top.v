`include "uart_tx.v"
`include "uart_rx.v"
module uart_wrapper(input clk,
                    input rst,
                    input ready,
                    input [7:0] data,
                    output done,
                    output [7:0] rx_data
                   );
  wire tx_done,tx;
  
  //transmitter instantiation
  uart_tx TX(.clk(clk),
             .rst(rst),
             .ready(ready),
             .data(data),
             .done(tx_done),
             .tx(tx)
              );
  
  //receiver instantiation
  uart_rx RX(.clk(clk),
             .rst(rst),
             .rx(tx),
             .done(done),
             .data(rx_data)
            );
             
  
endmodule
