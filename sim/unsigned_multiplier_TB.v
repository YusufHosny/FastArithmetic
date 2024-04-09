`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 12:44:44 PM
// Module Name: unsigned_multiplier_TB
// Project Name: 
// Description: 
// 
// Dependencies: 
//
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module unsigned_multiplier_TB();

  localparam CLOCK_PERIOD_NS = 100;
  
  localparam INPUT_LENGTH   = 16; 
  localparam OUTPUT_LENGTH     = 32; 
  
  reg           rClk, rRst, rStart;
  reg [INPUT_LENGTH-1:0]   rA, rB;
  
  wire [OUTPUT_LENGTH-1:0]  wRes;
  wire          wDone, wReady;
  
  reg [OUTPUT_LENGTH-1:0]  rExpectedResult;
  
  unsigned_multiplier
    #( .INPUT_LENGTH(INPUT_LENGTH), .OUTPUT_LENGTH(OUTPUT_LENGTH))
    mult_inst
    (   .iClk(rClk), .iRst(rRst),
        .iA(rA), .iB(rB),
        .iStart(rStart),
        .oRes(wRes),
        .oReady(wReady), .oDone(wDone)
    ); 

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
      
      #(5*T);
      rRst = 0;
      #(5*T);
      
      
      rStart = 1;
      rA <= 16'h0701;
      rB <= 16'h2F0A;
      #T;
      rStart = 0;
      #T;
      
      rExpectedResult = 16'h0701 * 16'h2F0A;
      // wait until wDone is asserted     
      wait(wDone == 1);
      
      // display the results in the terminal
      $display(rExpectedResult);
      $display(wRes);
      
      // compare results
      if ( rExpectedResult != wRes )
        $display("Test Failed - Incorrect Multiplication");
      else
        $display("Test Passed - Correct Multiplication");
      
      #(5*T);
        
      $stop;
    end

endmodule
