`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 11:46:17 AM
// Design Name: 
// Module Name: Multiply_Accumulator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Multiply_Accumulator
#(
   parameter INPUT_LENGTH = 16,
   parameter OUTPUT_LENGTH = 32
)
(   
    input wire iClk, iRst,
    input wire [INPUT_LENGTH-1:0]iA, iB,
    input wire iMAC, iRET, // iStart: add product of iA, iB to current sum, iStop: Process carries and return sum
    output wire [OUTPUT_LENGTH-1:0] oRes,
    output wire oReady, oDone
); 

    // declare fast multiplier
    wire [OUTPUT_LENGTH-1:0] wProduct;
    signed_multiplier 
    #(.INPUT_LENGTH(INPUT_LENGTH), .OUTPUT_LENGTH(OUTPUT_LENGTH))
    M ( .iA(iA), .iB(iB), .oRes(wProduct) );
    
    // feed output into accumulator
    carry_save_accumulator #( .INPUT_LENGTH(OUTPUT_LENGTH), .OUTPUT_LENGTH(OUTPUT_LENGTH) )
    CsaveAc
    ( .iClk(iClk), .iRst(iRst), .iAccumulate(iMAC), .iTerminate(iRET), .iA(wProduct), 
    .oReady(oReady), .oRes(oRes), .oDone(oDone) );
    

endmodule
