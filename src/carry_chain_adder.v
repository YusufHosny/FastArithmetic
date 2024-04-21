`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: carry_chain_adder
// Project Name: CDD Project
// Description: 
// 
// Dependencies: rca_carry_chain
// 
// Additional Comments: Vivado RTL Add but in CSelA blocks to decrease logic delay
//
// 
//////////////////////////////////////////////////////////////////////////////////



module carry_chain_adder
#(
    parameter WIDTH = 32,
    parameter BLOCK_WIDTH = 8
)

(
    input wire iC,
    input wire [WIDTH-1:0] iA, iB,
    output wire [WIDTH-1:0] oS,
    output wire oC
);
    
    // wire for all carries, first carry assignment
    wire [WIDTH/BLOCK_WIDTH-1:0] wCs;
   
    rca_carry_chain #( .WIDTH(BLOCK_WIDTH) ) 
                rca   (
                    .iA( iA[0 +: BLOCK_WIDTH] ), 
                    .iB( iB[0 +: BLOCK_WIDTH] ),
                    .iC( iC ),
                    .oS( oS[0 +: BLOCK_WIDTH] ),
                    .oC( wCs[0] )
                  );
    
    genvar i, i0, i1;
    generate
        
        // generate CSelA blocks
        for(i=1; i < WIDTH/BLOCK_WIDTH; i = i+1)
        begin
            // output sum and carry wires for carry = 0 and carry = 1
            wire [BLOCK_WIDTH-1:0] wS0, wS1;
            wire wC0, wC1;
        
            rca_carry_chain #( .WIDTH(BLOCK_WIDTH) ) 
                rca0   (
                    .iA( iA[i*BLOCK_WIDTH +: BLOCK_WIDTH] ), 
                    .iB( iB[i*BLOCK_WIDTH +: BLOCK_WIDTH] ),
                    .iC( 1'b0 ),
                    .oS(wS0),
                    .oC(wC0)
                  );
                  
            rca_carry_chain #( .WIDTH(BLOCK_WIDTH) ) 
                rca1   (
                    .iA( iA[i*BLOCK_WIDTH +: BLOCK_WIDTH] ), 
                    .iB( iB[i*BLOCK_WIDTH +: BLOCK_WIDTH] ),
                    .iC( 1'b1 ),
                    .oS(wS1),
                    .oC(wC1)
                  );
                          
            
              
            // mux carry and sum
            assign wCs[i] = (wCs[i-1] == 1) ? wC1 : wC0;
            assign oS[i*BLOCK_WIDTH +: BLOCK_WIDTH] = (wCs[i-1] == 1) ? wS1 : wS0;
            
        end
       
    endgenerate
    
    
    // assign output as last carry
    assign oC = wCs[WIDTH/BLOCK_WIDTH-1];

endmodule

