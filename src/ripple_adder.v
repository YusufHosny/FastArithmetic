`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2022 09:20:44 AM
// Design Name: 
// Module Name: ripple_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ripple_adder #
(parameter N = 3)

(
    input wire [N-1:0] iA, iB,
    input wire iC,
    output wire [N-1:0] oS,
    output wire oC
    
    );
    wire [N:0] wC;
    assign wC[0] = iC;
    
    genvar i;
    
    generate 
        for (i=0; i < N; i = i+1)
        begin
            full_adder FAs
                (.iA(iA[i]), .iB(iB[i]), .iCarry(wC[i]),.oCarry(wC[i+1]), .oSum(oS[i]));
        end 
    endgenerate
     
    assign oC = wC[N];

endmodule
