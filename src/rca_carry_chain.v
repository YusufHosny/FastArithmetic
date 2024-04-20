`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: rca_carry_chain
// Project Name: CDD Project
// Description: 
// 
// Dependencies: 
// 
// Additional Comments: Vivado inferred RTL Add
//
// 
//////////////////////////////////////////////////////////////////////////////////


module rca_carry_chain
#(
    parameter WIDTH = 32
)

(
    input wire iC,
    input wire [WIDTH-1:0] iA, iB,
    output wire [WIDTH-1:0] oS,
    output wire oC
);
    
    wire [WIDTH:0] oRes;
    
    assign oRes = iC + iA + iB;
    
    assign oS = oRes[WIDTH-1:0];
    assign oC = oRes[WIDTH];


endmodule
