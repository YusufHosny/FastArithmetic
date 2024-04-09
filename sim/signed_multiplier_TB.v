`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 12:44:44 PM
// Module Name: signed_multplier_TB
// Project Name: 
// Description: 
// 
// Dependencies: 
//
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module signed_multiplier_TB();

  localparam CLOCK_PERIOD_NS = 100;
  
  localparam INPUT_LENGTH   = 8; 
  localparam OUTPUT_LENGTH     = 16; 
  
  reg signed [INPUT_LENGTH-1:0]   rA, rB;
  
  wire [OUTPUT_LENGTH-1:0]  wRes;
  
  reg signed [OUTPUT_LENGTH-1:0]  rExpectedResult;
  
  signed_multiplier
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

      rA <= 8'sd120;
      rB <= -8'sd100;
      #T;
      
      rExpectedResult = (rA * rB);
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
