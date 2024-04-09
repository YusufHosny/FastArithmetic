`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: carry_lookahead_adder
// Project Name: CDD Project
// Description: 
// 
// Dependencies: partial_full_adder
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module carry_lookahead_adder
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
    
    // first carry in
    assign wCs[0] = iC;


    // generate all PFAs and connect them
    genvar i, j;
    generate 
        for (i=0; i < WIDTH; i = i+1)
        begin        
            partial_full_adder PFA
                (.iA(iA[i]), .iB(iB[i]), .iC(wCs[i]), .oS(oS[i]), .oP(wPs[i]), .oG(wGs[i]));    
         
            // wire that contains all the Generates that have propagated from the past bits
            wire [i:0] wPropagatedGs;           
            
            // first G is always the current G
            assign wPropagatedGs[0] = wGs[i];
            
            // another genvar j that will increment from 1 up until the index of the current bit
            for(j=1; j <= i; j = j+1)
            begin
                // get the j-th propagated G as the G that was j bits before and-ed with all the Ps between that G and the current bit  
                assign wPropagatedGs[j] = wGs[i-j] & &wPs[i:i-j+1];
            end
            
            // assign next carry as all previous P's and-ed together with Cin or all the propagated G's or-ed together
            assign wCs[i+1] = (&wPs[i:0] & iC) | (|wPropagatedGs);

        end
    endgenerate
    
    // assign Cout as final carry
    assign oC = wCs[WIDTH];
 


endmodule
