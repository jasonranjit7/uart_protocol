module tb_uart_top();
  reg clk, rst, ready;
  reg [7:0] data;
  wire done;
  wire [7:0] rx_data;
  
  uart_wrapper DUT (
    .clk(clk),
    .rst(rst),
    .ready(ready),
    .data(data),
    .done(done),
    .rx_data(rx_data)
  );
  
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  task run;
    input [7:0] d;
    begin
      @(posedge clk);
      data  = d;
      ready = 1;         // Assert ready
      @(posedge clk);
      ready = 0;         // De-assert ready
    end
  endtask
  
  initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0, tb_uart_top);
    
    rst   = 1;
    ready = 0;
    data  = 0;
    
    repeat(10) @(posedge clk);
    rst = 0;
    repeat(10) @(posedge clk);
    
    $display("[TB] Sending Data: %b", 8'b10010010);
    run(8'b10010010);
    
    $monitor("Time = %0t | Input Data = %b | RX Output = %b | Done = %b", $time, data, rx_data, done);
    
    @(posedge done);
    repeat(10) @(posedge clk);
    
    $display("[TB] Simulation Finished. Received Data Match: %b (Expected: %b)", rx_data, 8'b10010010);
    $finish();
  end
endmodule
