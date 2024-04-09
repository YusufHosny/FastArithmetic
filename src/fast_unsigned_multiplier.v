`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: fast_unsigned_multiplier
// Project Name: CDD Project
// Description: 
// 
// Dependencies:
// 
// Additional Comments:
//
// 
//////////////////////////////////////////////////////////////////////////////////


module fast_unsigned_multiplier
#(
   parameter INPUT_LENGTH = 16,
   parameter OUTPUT_LENGTH = 32
)
(   
    input wire [INPUT_LENGTH-1:0]iA, iB,
    output wire [OUTPUT_LENGTH-1:0] oRes
);
    
    // declare input_length partial products of length output_length each
    wire [OUTPUT_LENGTH-1:0] partial_products [INPUT_LENGTH-1:0];
    
    // generate all partial products
    genvar i;
    generate
        for(i=0; i < INPUT_LENGTH; i = i+1)
        begin
            assign partial_products[i] = (iB[i] == 1) ? iA << i : 0;
        end
    endgenerate
    
    // compress partial products with CSA
    // wires for inputs to each CSA
    wire [OUTPUT_LENGTH-1:0] wi1 [INPUT_LENGTH-2:0];
    wire [OUTPUT_LENGTH:0] wi2 [INPUT_LENGTH-2:0];
    assign wi1[0] = partial_products[0];
    assign wi2[0] = {1'b0, partial_products[1] };
    generate
        for(i=0; i < INPUT_LENGTH-2; i = i+1)
        begin
            carry_save_adder #(.WIDTH(OUTPUT_LENGTH)) 
            CSA (
                .iA(wi1[i]), .iB(wi2[i][OUTPUT_LENGTH-1:0]), .iC(partial_products[i+2]), .oS(wi1[i+1]), .oC(wi2[i+1])
            );
        end
    endgenerate
    
    // resolve last sum with CLA or IGFA
    wire carry_out;
    carry_lookahead_adder #( .WIDTH(OUTPUT_LENGTH) ) 
        adder_inst   (
            .iA( wi1[INPUT_LENGTH-2] ), 
            .iB( wi2[INPUT_LENGTH-2][OUTPUT_LENGTH-1:0] ),
            .iC( 0 ),
            .oS( oRes ),
            .oC( carry_out )
          );
endmodule
