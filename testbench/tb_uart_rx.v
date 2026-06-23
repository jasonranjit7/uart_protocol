module tb_uart_rx#(parameter BAUD = 9600, FREQ = 50* 10**6,
                           OVERSAMPLE_RATE = 16)();
  reg clk,rst,rx;
  wire done;
  wire [7:0] data;
  
  uart_rx DUT(.clk(clk),
              .rst(rst),
              .rx(rx),
              .done(done),
              .data(data)
             );
  localparam RX_CYCLES = FREQ/(BAUD*OVERSAMPLE_RATE); 
  
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  
  initial begin
    rst = 1;
    rx = 1;
  end
  
  task stop;
    begin
      rx = 1'b1;
      repeat(RX_CYCLES)@(posedge clk);
    end
  endtask
  
  task start;
    begin
      rx = 1'b0;
      repeat(RX_CYCLES)@(posedge clk);
    end
  endtask
  
  task get_data;
    input rx_data;
    begin
      rx = rx_data;
      repeat(RX_CYCLES)@(posedge clk);
    end
  endtask
  
  initial begin
    $dumpfile("image.vcd");
    $dumpvars(0, tb_uart_rx.DUT);
    $monitor("state = %b, bit count = %b", DUT.state, DUT.bit_cnt);
    repeat(RX_CYCLES)@(posedge clk);
    rst = 0;
    repeat(RX_CYCLES)@(posedge clk);
    start();
    repeat(8)
      get_data($random);
    stop();
    repeat(RX_CYCLES)@(posedge clk);
    $finish();
    end
endmodule
    
    
