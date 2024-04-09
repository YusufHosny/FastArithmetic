`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 12:19:47 AM
// Design Name: 
// Module Name: twos_complementer
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


module twos_complementer
#(
    parameter WIDTH = 8
)
(
    input wire [WIDTH-1:0] iA,
    output wire [WIDTH-1:0] oA
);
    
    // can be changed to an RTL implementation later on
    assign oA = ~iA + 1;
    
endmodule
