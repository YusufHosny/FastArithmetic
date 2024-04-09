`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: carry_bypass_adder
// Project Name: CDD Project
// Description: 
// 
// Dependencies: carry_bypass_block
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module carry_bypass_adder
#(
    parameter WIDTH = 16,
    parameter BLOCK_WIDTH = 4
)

(
    input wire iC,
    input wire [WIDTH-1:0] iA, iB,
    output wire [WIDTH-1:0] oS,
    output wire oC
);
    
    // bus for carries
    wire [WIDTH:0] wCs;
    assign wCs[0] = iC;
 

    // generate all blocks and connect them
    genvar i;
    generate 
        for (i=0; i < (WIDTH/BLOCK_WIDTH); i = i+1)
        begin        
            carry_bypass_block #( .WIDTH(BLOCK_WIDTH) ) CBB
                (.iA(iA[((i+1)*BLOCK_WIDTH)-1:((i)*BLOCK_WIDTH)]), .iB(iB[((i+1)*BLOCK_WIDTH)-1:((i)*BLOCK_WIDTH)]),
                 .iC(wCs[i]), .oS(oS[((i+1)*BLOCK_WIDTH)-1:((i)*BLOCK_WIDTH)]), .oC(wCs[i+1]));
                
        end
    endgenerate
    
    assign oC = wCs[WIDTH/BLOCK_WIDTH];


endmodule
