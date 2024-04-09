`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: unsigned_multiplier
// Project Name: CDD Project
// Description: 
// 
// Dependencies: carry_save_accumulator
// 
// Additional Comments:
//
// 
//////////////////////////////////////////////////////////////////////////////////


module unsigned_multiplier
#(
   parameter INPUT_LENGTH = 16,
   parameter OUTPUT_LENGTH = 32
)
(   
    input wire iClk, iRst,
    input wire [INPUT_LENGTH-1:0]iA, iB,
    input wire iStart,
    output wire [OUTPUT_LENGTH-1:0] oRes,
    output wire oReady, oDone
); 
    // declarations
    reg [INPUT_LENGTH-1:0] rA, rB;
    reg [OUTPUT_LENGTH-1:0] rOperand; 
    reg rAcc, rTerminateAcc; // accumulator control registers
    wire wReadyAcc;
    reg rReady;

    carry_save_accumulator #( .INPUT_LENGTH(OUTPUT_LENGTH), .OUTPUT_LENGTH(OUTPUT_LENGTH) )
    CsaveAc
    ( .iClk(iClk), .iRst(iRst), .iAccumulate(rAcc), .iTerminate(rTerminateAcc), .iA(rOperand), 
    .oReady(wReadyAcc), .oRes(oRes), .oDone(oDone) );
    
    
     // FSM
    // State definitions
    localparam s_IDLE         = 3'b000; // 0
    localparam s_START_MULTIPLY  = 3'b001; // 1
    localparam s_MULTIPLY     = 3'b010; // 2
    localparam s_WAIT_MULTIPLY     = 3'b011; // 3
    
    
    reg [$clog2(INPUT_LENGTH):0] rCnt;
    
    reg [2:0] rFSM;
    
    always @(posedge iClk)
    begin
        if(iRst)
        begin
            rA <= 0;
            rB <= 0;
            rOperand <= 0;
            rCnt <= 0;
            rAcc <= 0;
            rTerminateAcc <=0;
            rReady <= 0;
            rFSM <= s_IDLE;
        end
        
        else begin
        case(rFSM)
            s_IDLE:
                begin
                    rAcc <= 0;
                    rCnt <= 0;
                    rOperand <= 0;
                    rTerminateAcc <=0;
                    if(iStart) begin
                        rFSM <= s_START_MULTIPLY;
                        rA <= rA;
                        rB <= rB;
                        rReady <= 0;
                    end
                    else begin
                        rFSM <= s_IDLE;
                        rA <= 0;
                        rB <= 0;
                        rReady <= 1;
                    end
                end
                
            s_START_MULTIPLY:
                begin
                    rFSM <= s_MULTIPLY;
                    rA <= iA;
                    rB <= iB;
                    rReady <= 0;
                    rAcc <= 0;
                    rCnt <= 0;
                    rOperand <= 0;
                    rTerminateAcc <=0;
                end
                
            s_MULTIPLY:
                begin
                    rReady <= 0;
                    rA <= rA;
                    rB <= rB;
                    if(wReadyAcc & !rAcc) begin
                        if(rCnt < INPUT_LENGTH) begin
                            rAcc <= 1;
                            rTerminateAcc <= 0;
                            rOperand <= (rB[rCnt] == 1) ? (rA << rCnt) : 0;
                            rCnt <= rCnt + 1;
                            rFSM <= s_MULTIPLY;
                        end else begin
                            rAcc <= 0;
                            rTerminateAcc <= 1;
                            rOperand <= 0;
                            rFSM <= s_WAIT_MULTIPLY;
                        end
                    end else begin
                        rAcc <= 0;
                        rTerminateAcc <= 0;
                        rOperand <= rOperand;
                        rFSM <= s_MULTIPLY;
                    end
                end
           
           s_WAIT_MULTIPLY:
                begin
                    rAcc <= 0;
                    rTerminateAcc <=0;
                    rA <= rA;
                    rB <= rB;
                    rCnt <= 0;
                    if(oDone) begin
                        rReady <= 1;
                        rFSM <= s_IDLE;
                    end else begin
                        rReady <= 0;
                        rFSM <= s_WAIT_MULTIPLY;
                    end
                end

                
            default:
                begin
                    rAcc <= 0;
                    rTerminateAcc <=0;
                    rReady <= 0;
                    rA <= 0;
                    rB <= 0;
                    rFSM <= s_IDLE;
                end
               
        endcase
        end
    end
    
    // output logic
    assign oReady = rReady;
    
endmodule
