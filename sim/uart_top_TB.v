`timescale 1ns / 1ps

module uart_top_TB ();
 
  // Define signals for module under test
  reg  rClk = 0;
  reg  rRst = 0;
  wire wRx, wTx;
  reg rTxStart;
  reg [7:0] rTxByte;
  wire [7:0] wRxByte;
  wire wTxBusy, wTxDone, wRxDone;
  integer i;
  
  // We downscale the values in the simulation
  // this will give CLKS_PER_BIT = 100 / 10 = 10
  localparam CLK_FREQ_inst  = 100;
  localparam BAUD_RATE_inst = 10;
  
  // Instantiate DUT  
  uart_top 
  #(  .CLK_FREQ(CLK_FREQ_inst), .BAUD_RATE(BAUD_RATE_inst) )
  uart_top_inst
  ( .iClk(rClk), .iRst(rRst), .iRx(wRx), .oTx(wTx) );
  
  
  
  // Instantiate TX instance
 uart_tx #(  .CLK_FREQ(CLK_FREQ_inst), .BAUD_RATE(BAUD_RATE_inst) )
  UART_TX_INST
    (.iClk(rClk),
     .iRst(rRst),
     .iTxStart(rTxStart),
     .iTxByte(rTxByte),
     .oTxSerial(wRx),
     .oTxBusy(wTxBusy),
     .oTxDone(wTxDone)
     );
     
  // Instantiate RX instance
  uart_rx #(  .CLK_FREQ(CLK_FREQ_inst), .BAUD_RATE(BAUD_RATE_inst) )
  UART_RX_INST
    (.iClk(rClk),
     .iRst(rRst),
     .iRxSerial(wTx),
     .oRxByte(wRxByte),
     .oRxDone(wRxDone)
     );
  
  // Define clock signal
  localparam CLOCK_PERIOD = 5;
  
  always
    #(CLOCK_PERIOD/2) rClk <= !rClk;
 
  // Input stimulus
  initial
    begin
    
        rRst = 1;
        #CLOCK_PERIOD
        rRst = 0;
    
       #(10*CLOCK_PERIOD);
       
       
//       // OPCODE
//       rTxByte = 8'b00; 
//       rTxStart = 1;
//       #CLOCK_PERIOD
//       rTxStart = 0;
          
//       wait(wTxDone == 1);
//       #CLOCK_PERIOD;
       
      // OPERAND 1
          
//     for(i = 0; i < 3; i = i + 1) begin // add operand width = 1024, we send NBYTES = 128 
//          rTxByte = 8'hff;
//          rTxStart = 1;
//          #CLOCK_PERIOD
//          rTxStart = 0;
          
//          wait(wTxDone == 1);
//          #CLOCK_PERIOD;
//      end
      
//          rTxByte = 8'hfF;
//          rTxStart = 1;
//          #CLOCK_PERIOD
//          rTxStart = 0;
          
//          wait(wTxDone == 1);
//          #CLOCK_PERIOD;

      
//     // OPERAND 2     
          
//     for(i = 0; i < 3; i = i + 1) begin // add operand width = 1024, we send NBYTES = 128 
//          rTxByte = 8'hff;
//          rTxStart = 1;
//          #CLOCK_PERIOD
//          rTxStart = 0;
          
//          wait(wTxDone == 1);
//          #CLOCK_PERIOD;
//      end
      
//          rTxByte = 8'h0F;
//          rTxStart = 1;
//          #CLOCK_PERIOD
//          rTxStart = 0;
          
//          wait(wTxDone == 1);
//          #CLOCK_PERIOD;
      
//      // Let it run for a while
//      #(1000*CLOCK_PERIOD); 
      
      
 /*     
      
      // OPCODE 2
       rTxByte = 8'b10; //  OPCODE
       rTxStart = 1;
       #CLOCK_PERIOD
       rTxStart = 0;
          
       wait(wTxDone == 1);
       #CLOCK_PERIOD;
       
      // OPERAND 3
          
     for(i = 0; i < 3; i = i + 1) begin // add operand width = 1024, we send NBYTES = 128 
          rTxByte = 8'h00;
          rTxStart = 1;
          #CLOCK_PERIOD
          rTxStart = 0;
          
          wait(wTxDone == 1);
          #CLOCK_PERIOD;
      end
      
          rTxByte = 8'h0F;
          rTxStart = 1;
          #CLOCK_PERIOD
          rTxStart = 0;
          
          wait(wTxDone == 1);
          #CLOCK_PERIOD;   
          
          
     // OPERAND 4
          
     for(i = 0; i < 3; i = i + 1) begin // add operand width = 1024, we send NBYTES = 128 
          rTxByte = 8'h00;
          rTxStart = 1;
          #CLOCK_PERIOD
          rTxStart = 0;
          
          wait(wTxDone == 1);
          #CLOCK_PERIOD;
      end
      
          rTxByte = 8'h0F;
          rTxStart = 1;
          #CLOCK_PERIOD
          rTxStart = 0;
          
          wait(wTxDone == 1);
          #CLOCK_PERIOD;
          
       // Let it run for a while
      #(1000*CLOCK_PERIOD); */
      
      
      // mac 3x 16 bit test
       
     for(i=0; i < 3; i=i+1) begin
          // opcode
            rTxByte = 8'b10;
            rTxStart = 1;
            #CLOCK_PERIOD
            rTxStart = 0;
              
            wait(wTxDone == 1);
            #CLOCK_PERIOD;
     
         // op 1
          rTxByte = 8'h2a;
          rTxStart = 1;
          #CLOCK_PERIOD
          rTxStart = 0;
        
          wait(wTxDone == 1);
          #CLOCK_PERIOD;
          
          rTxByte = 8'h4e;
          rTxStart = 1;
          #CLOCK_PERIOD
          rTxStart = 0;
        
          wait(wTxDone == 1);
          #CLOCK_PERIOD;
          
          // op 2
          rTxByte = 8'h11;
          rTxStart = 1;
          #CLOCK_PERIOD
          rTxStart = 0;
        
          wait(wTxDone == 1);
          #CLOCK_PERIOD;
          
          rTxByte = 8'hc6;
          rTxStart = 1;
          #CLOCK_PERIOD
          rTxStart = 0;
        
          wait(wTxDone == 1);
          #CLOCK_PERIOD;
        end
    
    
       // RET    
       rTxByte = 8'b11; 
       rTxStart = 1;
       #CLOCK_PERIOD
       rTxStart = 0;
          
       wait(wTxDone == 1);
       #CLOCK_PERIOD;
          

      $stop;
           
    end
   
endmodule