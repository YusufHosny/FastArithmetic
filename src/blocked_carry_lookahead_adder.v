`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: blocked_carry_lookahead_adder
// Project Name: CDD Project
// Description: 
// 
// Dependencies: carry_lookahead_adder
// 
// Additional Comments:
//
// 
//////////////////////////////////////////////////////////////////////////////////


module blocked_carry_lookahead_adder
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

    wire [WIDTH/BLOCK_WIDTH:0] wCs;
    assign wCs[0] = iC;
    
    genvar i;
    generate
        for(i=0; i < WIDTH/BLOCK_WIDTH; i = i+1)
        begin
            carry_lookahead_adder #( .WIDTH(BLOCK_WIDTH) ) 
            CLA   (
                .iA( iA[i*BLOCK_WIDTH +: BLOCK_WIDTH] ), 
                .iB( iB[i*BLOCK_WIDTH +: BLOCK_WIDTH] ),
                .iC(wCs[i]),
                .oS(oS[i*BLOCK_WIDTH +: BLOCK_WIDTH]),
                .oC(wCs[i+1])
              );
        
        
        end
    endgenerate

    assign oC = wCs[WIDTH/BLOCK_WIDTH];
    
endmodule
