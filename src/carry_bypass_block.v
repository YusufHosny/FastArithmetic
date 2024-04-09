`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: carry_bypass_block
// Project Name: CDD Project
// Description: 
// 
// Dependencies: partial_full_adder
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module carry_bypass_block
#( parameter WIDTH = 4 )

(
    input wire iC,
    input wire [WIDTH-1:0] iA, iB,
    output wire [WIDTH-1:0] oS,
    output wire oC
    
);

    // buses for the and chain, carries, propagates, and generates
    wire [WIDTH:0] wCs;
    wire [WIDTH-1:0] wPs, wGs;
    wire chain;
    
    // first carry in
    assign wCs[0] = iC;
    
    // collapse all wPs into single value (P0 & P1 & P2 .... PN)
    assign chain = &wPs & iC;


    // generate all PFAs and connect them
    genvar i;
    generate 
        for (i=0; i < WIDTH; i = i+1)
        begin        
            partial_full_adder PFA
                (.iA(iA[i]), .iB(iB[i]), .iC(wCs[i]), .oS(oS[i]), .oP(wPs[i]), .oG(wGs[i]));
                
            assign wCs[i+1] = (wPs[i] & wCs[i]) | (wGs[i]);
        end
    endgenerate
    
    // final XOR
    assign oC = wCs[WIDTH] | chain;
 


endmodule
