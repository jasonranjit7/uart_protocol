`timescale 1ns/1ps
module tb_uart_tx();
  reg [7:0] data;
  reg clk,rst,ready;
  wire tx,done;
  
  uart_tx DUT(.clk(clk),
              .rst(rst),
              .data(data),
              .ready(ready),
              .tx(tx),
              .done(done)
                      );
  
  initial
  	forever #10 clk = ~clk;
  
  initial begin
    clk = 0;
    rst = 1;
    ready = 0;
    data = 7'd0;
  end
  
  task run;
    input [7:0] tx_data;
    begin
      data = tx_data;
      @(negedge clk);
      ready = 1;
      @(posedge clk);
      #1 ready = 0;
      $monitor("tx = %b", tx);
      
      //$monitor("bit count = %d, tx = %b, state = %b", DUT.bit_count, tx, DUT.state);
      wait(done);
    end
  endtask
  
  initial begin
    $dumpfile("image.vcd");
    $dumpvars(0,tb_uart_tx.DUT);
        
    repeat(2)@(posedge clk);
    rst = 0;
    run(6'b110011);
    $finish();
  end
endmodule
