`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: carry_save_adder
// Project Name: CDD Project
// Description: 
// 
// Dependencies:
// 
// Additional Comments:
//
// 
//////////////////////////////////////////////////////////////////////////////////


module carry_save_adder
#(
    parameter WIDTH = 8
)
(
    input wire [WIDTH-1:0] iA, iB, iC,
    output wire [WIDTH-1:0] oS,
    output wire [WIDTH:0] oC
);

    assign oS = iA ^ iB ^ iC;
    assign oC = ((iA & iB) | (iB & iC) | (iA & iC)) << 1;
    
endmodule
