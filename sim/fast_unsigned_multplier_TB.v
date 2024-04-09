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


module fast_unsigned_multplier_TB();

  localparam CLOCK_PERIOD_NS = 100;
  
  localparam INPUT_LENGTH   = 16; 
  localparam OUTPUT_LENGTH     = 32; 
  
  reg [INPUT_LENGTH-1:0]   rA, rB;
  
  wire [OUTPUT_LENGTH-1:0]  wRes;
  
  reg [OUTPUT_LENGTH-1:0]  rExpectedResult;
  
  fast_unsigned_multiplier
    #( .INPUT_LENGTH(INPUT_LENGTH), .OUTPUT_LENGTH(OUTPUT_LENGTH))
    mult_inst
    (
        .iA(rA), .iB(rB),
        .oRes(wRes)
    ); 

  // definition of clock period
  localparam  T = 20;  
  
  initial
    begin

      rA <= 16'h0701;
      rB <= 16'h2F0A;
      #T;
      
      rExpectedResult = 16'h0701 * 16'h2F0A;
      #T
      
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
