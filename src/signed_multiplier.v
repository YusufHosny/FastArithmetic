`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: signed_multiplier
// Project Name: CDD Project
// Description: 
// 
// Dependencies:
// 
// Additional Comments:
//
// 
//////////////////////////////////////////////////////////////////////////////////


module signed_multiplier
#(
   // design assumes that output length user picks is enough to contain product of inputs
   // as such no error checking or verification is done for overflows
   parameter INPUT_LENGTH = 16,
   parameter OUTPUT_LENGTH = 32
)
(   
    input wire [INPUT_LENGTH-1:0]iA, iB,
    output wire [OUTPUT_LENGTH-1:0] oRes
);
    // localparams for simplicity
    localparam N = INPUT_LENGTH/2;
    localparam SIGN_PADDING = (OUTPUT_LENGTH-INPUT_LENGTH);
    
    // declare input_length partial products of length output_length each
    // partial products are signed in 2's complement
    wire [OUTPUT_LENGTH-1:0] partial_products [N-1:0];
    
    // generate all partial products via radix-4 booth recoding
    genvar i;
    generate
        // generate +1 -1 +2 -2 operands
        wire [OUTPUT_LENGTH-1:0] adds [2:0], minuses [2:0];
        assign adds[0] = 0;
        assign minuses[0] = 0;
        assign adds[1] = iA;
        assign adds[2] = iA << 1;
        twos_complementer #(.WIDTH(OUTPUT_LENGTH)) comp1 (.iA(adds[1]), .oA(minuses[1]));
        twos_complementer #(.WIDTH(OUTPUT_LENGTH)) comp2 (.iA(adds[2]), .oA(minuses[2]));
        
        // pad multiplier with a 0 to the right
        wire [INPUT_LENGTH:0] padded_multiplier;
        assign padded_multiplier = { iB, 1'b0 };
        
        // create partial products
        for(i=1; i < INPUT_LENGTH; i = i+2)
        begin
            // extract current booth block
            wire [2:0] booth_block;
            assign booth_block = padded_multiplier[i+1:i-1];
            
            // booth encode based on table
            wire [2:0] booth_encoded; // NEG-TWO-ONE encoding table
            assign booth_encoded[2] = booth_block[2];
            assign booth_encoded[1] = ~^booth_block[1:0] & (booth_block[2] ^ booth_block[1]);
            assign booth_encoded[0] = ^booth_block[1:0];
           
            // decode booth block into partial products
            // and sign extend negative partial product
            wire [OUTPUT_LENGTH-1:0] positive_partial_product, raw_negative_partial_product, negative_partial_product;
            assign positive_partial_product = adds[booth_encoded[1:0]] << (i-1);
            assign raw_negative_partial_product = minuses[booth_encoded[1:0]] << (i-1); // without sign extension
            assign negative_partial_product = {{(SIGN_PADDING-i){1'b1}}, raw_negative_partial_product}; // sign extended
            
            // assign final partial product based on sign bit in booth encoding
            assign partial_products[(i-1)/2] = 
            (booth_encoded[2] == 0) ? positive_partial_product : negative_partial_product ;
        end
    endgenerate
    
    // compress partial products with CSA
    // wires for inputs to each CSA
    wire [OUTPUT_LENGTH-1:0] wi1 [N-2:0];
    wire [OUTPUT_LENGTH:0] wi2 [N-2:0];
    assign wi1[0] = partial_products[0];
    assign wi2[0] = {1'b0, partial_products[1] };
    generate
        for(i=0; i < N-2; i = i+1)
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
            .iA( wi1[N-2] ), 
            .iB( wi2[N-2][OUTPUT_LENGTH-1:0] ),
            .iC( 0 ),
            .oS( oRes ),
            .oC( carry_out )
          );
endmodule
