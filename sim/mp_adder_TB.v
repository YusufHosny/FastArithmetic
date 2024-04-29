`timescale 1ns / 1ps

module mp_adder_TB();

  localparam CLOCK_PERIOD_NS = 100;
  
  localparam OPERAND_WIDTH   = 128; 
  localparam ADDER_WIDTH     = 32; 
  
  reg           rClk, rRst, rStart, rSub;
  reg [OPERAND_WIDTH-1:0]   rA, rB;
  
  wire [OPERAND_WIDTH:0]  wRes;
  wire          wDone;
  
  reg [OPERAND_WIDTH:0]  rExpectedResult;
  
  // define adder types
    localparam RCA =   4'b0000;
    localparam CBA =   4'b0001;
    localparam CLA =   4'b0010;
    localparam BCLA =  4'b0011;
    localparam CSelA = 4'b0100;
    localparam GFA =   4'b0101;
    localparam IGFA =  4'b0110;
    localparam RCACC = 4'b0111;
    localparam CCA   =  4'b1000;
  
  mp_adder #( .OPERAND_WIDTH(OPERAND_WIDTH), .ADDER_WIDTH(ADDER_WIDTH), .BLOCK_WIDTH(8), .SUB_BLOCK_WIDTH(4), .ADDER_TYPE(CLA) )
  mp_adder_INST
  ( .iClk(rClk), .iRst(rRst), .iStart(rStart), .iSub(rSub), .iOpA(rA), .iOpB(rB), .oRes(wRes), .oDone(wDone) );

  // definition of clock period
  localparam  T = 20;  
  
  // generation of clock signal
  always 
  begin
    rClk = 1;
    #(T/2);
    rClk = 0;
    #(T/2);
  end

  initial
    begin
      rRst = 1;
      rStart = 0;
      rA = 0;
      rB = 0;
      rSub = 0;
      
      #(5*T);
      rRst = 0;
      #(5*T);
      
      rSub = 1;
      rStart = 1;
      rA <= 128'd10000000000000000000000000000;
      rB <= 128'd5000000000000000000000000000;
      #T;
      rExpectedResult = rA - rB;
      rStart = 0;
            
      // wait until wDone is asserted     
      @(posedge wDone);
      
      // display the results in the terminal
      $display(rExpectedResult);
      $display(wRes);
      
      // compare results
      // if using the test vector, answer should be: 0x1_02020202_02020202_02020202_09090908
      if ( rExpectedResult != wRes )
        $display("Test Failed - Incorrect Addition");
      else
        $display("Test Passed - Correct Addition");
      
      #(5*T);
        
      $stop;
    end

endmodule
