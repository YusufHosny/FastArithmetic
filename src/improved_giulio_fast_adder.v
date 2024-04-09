`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: improved_giulio_fast_adder
// Project Name: CDD Project
// Description: 
// 
// Dependencies: carry_lookahead_adder
// 
// Additional Comments: a CSelA with BCLAs instead of RCAs as building blocks
//
// 
//////////////////////////////////////////////////////////////////////////////////



module improved_giulio_fast_adder
#(
    parameter WIDTH = 32,
    parameter BLOCK_WIDTH = 8,
    parameter SUB_BLOCK_WIDTH = 4
)

(
    input wire iC,
    input wire [WIDTH-1:0] iA, iB,
    output wire [WIDTH-1:0] oS,
    output wire oC
);
    
    // wire for all carries, first carry assignment
    wire [WIDTH/BLOCK_WIDTH:0] wCs;
    assign wCs[0] = iC;
    
    genvar i;
    generate
        
        // generate CSelA blocks
        for(i=0; i < WIDTH/BLOCK_WIDTH; i = i+1)
        begin
            // output sum and carry wires for carry = 0 and carry = 1
            wire [BLOCK_WIDTH-1:0] wS0, wS1;
            wire wC0, wC1;
        
            // generate 2 CLAs with carry 0 and 1
            blocked_carry_lookahead_adder #( .WIDTH(BLOCK_WIDTH), .BLOCK_WIDTH(SUB_BLOCK_WIDTH) ) 
            BCLA_0   (
                .iA( iA[i*BLOCK_WIDTH +: BLOCK_WIDTH] ), 
                .iB( iB[i*BLOCK_WIDTH +: BLOCK_WIDTH] ),
                .iC( 1'b0 ),
                .oS(wS0),
                .oC(wC0)
              );
             
            blocked_carry_lookahead_adder #( .WIDTH(BLOCK_WIDTH), .BLOCK_WIDTH(SUB_BLOCK_WIDTH) ) 
            BCLA_1   (
                .iA( iA[i*BLOCK_WIDTH +: BLOCK_WIDTH] ), 
                .iB( iB[i*BLOCK_WIDTH +: BLOCK_WIDTH] ),
                .iC( 1'b1 ),
                .oS(wS1),
                .oC(wC1)
              );
              
              // mux carry and sum
              assign wCs[i+1] = (wCs[i] == 1) ? wC1 : wC0;
              assign oS[i*BLOCK_WIDTH +: BLOCK_WIDTH] = (wCs[i] == 1) ? wS1 : wS0;
            
        end
       
    endgenerate
    
    
    // assign output as last carry
    assign oC = wCs[WIDTH/BLOCK_WIDTH];

endmodule
