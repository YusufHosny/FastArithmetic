`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: partial_full_adder
// Project Name: CDD Project
// Description: 
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module partial_full_adder(
    input wire iA, iB, iC,
    output wire oS, oP, oG
    );
    
    
    assign oS = (iA ^ iB) ^ (iC);
    assign oP = iA | iB;
    assign oG = iA & iB;
    
endmodule
