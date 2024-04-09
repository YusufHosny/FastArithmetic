`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 12:44:44 PM
// Module Name: CSaveAc_TB
// Project Name: 
// Description: 
// 
// Dependencies: 
//
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CSaveAc_TB();

  localparam CLOCK_PERIOD_NS = 100;
  
  localparam INPUT_LENGTH   = 16; 
  localparam OUTPUT_LENGTH     = 32; 
  
  reg           rClk, rRst, rStart, rStop;
  reg [INPUT_LENGTH-1:0]   rA;
  
  wire [OUTPUT_LENGTH-1:0]  wRes;
  wire          wDone, wReady;
  
  reg [OUTPUT_LENGTH-1:0]  rExpectedResult;
  
  carry_save_accumulator #( .INPUT_LENGTH(INPUT_LENGTH), .OUTPUT_LENGTH(OUTPUT_LENGTH) )
  CsaveAc
  ( .iClk(rClk), .iRst(rRst), .iAccumulate(rStart), .iTerminate(rStop), .iA(rA), .oReady(wReady), .oRes(wRes), .oDone(wDone) );

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
      rStop = 0;
      
      #(5*T);
      rRst = 0;
      #(5*T);
      
      rA = 16'h0701;
      rStart = 1;
      #T;
      rStart = 0;
      wait(wReady == 1);
      
      rA = 16'h00F1;
      rStart = 1;
      #T;
      rStart = 0;
      wait(wReady == 1);
      
      rA = 16'h10B7;
      rStart = 1;
      #T;
      rStart = 0;
      
      wait(wReady == 1);
      
      rA = 16'hA2C1;
      rStart = 1;
      #T;
      rStart = 0;
      
      
      wait(wReady == 1);
      rA = 16'h0701;
      rStart = 1;
      #T;
      rStart = 0;
      wait(wReady == 1);
      
      rA = 16'h00F1;
      rStart = 1;
      #T;
      rStart = 0;
      wait(wReady == 1);
      
      rA = 16'h10B7;
      rStart = 1;
      #T;
      rStart = 0;
      
      wait(wReady == 1);
      
      rA = 16'hA2C1;
      rStart = 1;
      #T;
      rStart = 0;

      wait(wReady == 1);
      
      rA = 16'h0701;
      rStart = 1;
      #T;
      rStart = 0;
      wait(wReady == 1);
      
      rA = 16'h00F1;
      rStart = 1;
      #T;
      rStart = 0;
      wait(wReady == 1);
      
      rA = 16'h10B7;
      rStart = 1;
      #T;
      rStart = 0;
      
      wait(wReady == 1);
      
      rA = 16'hA2C1;
      rStart = 1;
      #T;
      rStart = 0;
      
      
      wait(wReady == 1);
      
      rA = 16'h0701;
      rStart = 1;
      #T;
      rStart = 0;
      wait(wReady == 1);
      
      rA = 16'h00F1;
      rStart = 1;
      #T;
      rStart = 0;
      wait(wReady == 1);
      
      rA = 16'h10B7;
      rStart = 1;
      #T;
      rStart = 0;
      
      wait(wReady == 1);
      
      rA = 16'hA2C1;
      rStart = 1;
      #T;
      rStart = 0;
      
      
      wait(wReady == 1);
      
      rStop = 1;
      #T;
      rStop = 0;
      
      rExpectedResult = 16'h0701 + 16'h00F1 + 16'h10B7 + 16'hA2C1 + 
      16'h0701 + 16'h00F1 + 16'h10B7 + 16'hA2C1 + 
      16'h0701 + 16'h00F1 + 16'h10B7 + 16'hA2C1 + 
      16'h0701 + 16'h00F1 + 16'h10B7 + 16'hA2C1;
      // wait until wDone is asserted     
      wait(wDone == 1);
      
      // display the results in the terminal
      $display(rExpectedResult);
      $display(wRes);
      
      // compare results
      if ( rExpectedResult != wRes )
        $display("Test Failed - Incorrect Accumulation");
      else
        $display("Test Passed - Correct Accumulation");
      
      #(5*T);
        
      $stop;
    end

endmodule
