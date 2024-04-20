`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: KU Leuven Group T Campus 
// Engineer: Yusuf Hussein
// 
// Create Date: 03/29/2024
// Module Name: carry_save_accumulator
// Project Name: CDD Project
// Description: 
// 
// Dependencies: full_adder, mp_adder
// 
// Additional Comments:
//
// 
//////////////////////////////////////////////////////////////////////////////////

module carry_save_accumulator
#(
   parameter INPUT_LENGTH = 16,
   parameter OUTPUT_LENGTH = 32
)
(   
    input wire iClk, iRst,
    input wire [INPUT_LENGTH-1:0]iA,
    input wire iAccumulate, iTerminate, // iStart: add iA to current sum, iStop: Process carries and return sum
    output wire [OUTPUT_LENGTH-1:0] oRes,
    output wire oReady, oDone
); 
    // declarations
    reg rReady, rStartProcess;
    wire wProcessed;
    
    reg [OUTPUT_LENGTH-1:0] rRes; // result and overflow bit
    wire [OUTPUT_LENGTH-1:0] woResAdd;
    
    // Register for number to be added
    reg [INPUT_LENGTH-1:0] rA;
    
    // Redundant bit representation of each digit for accumulator
    reg [1:0] accumulator [OUTPUT_LENGTH-1:0]; 
    wire [1:0] accumulatorNext [OUTPUT_LENGTH-1:0];
    
    // maybe set up to infer bram if necessary?
    // Define registers for accumulator
    integer n;
    always @(posedge iClk)
    begin
        for(n=0; n < OUTPUT_LENGTH; n = n+1)
        begin
            if(iRst) accumulator[n] <= 0;
            else accumulator[n] <= accumulatorNext[n];
        end
    end
    
    
    // generate logic blocks
    genvar i;
    generate
        // carry save logic:
        // for each accumulator digit (which is 2 bits since it can be 0, 1, 2, or 3)
        // we add the current input bit, the accumulator's sum, and the last carry from the digit to the right
        
        // base case
        full_adder FA1
            (.iA(rA[0]), .iB(accumulator[0][0]), .iCarry(0),.oCarry(accumulatorNext[0][1]), .oSum(accumulatorNext[0][0]));
       
       // adder blocks below input length
        for(i=1; i < INPUT_LENGTH; i = i+1)
        begin
            full_adder FA
                (.iA(rA[i]), .iB(accumulator[i][0]), .iCarry(accumulator[i-1][1]),.oCarry(accumulatorNext[i][1]), .oSum(accumulatorNext[i][0]));
        end
        
        // remaining adder blocks
        for(i=INPUT_LENGTH; i < OUTPUT_LENGTH; i = i+1)
        begin
             full_adder FA
                (.iA(0), .iB(accumulator[i][0]), .iCarry(accumulator[i-1][1]),.oCarry(accumulatorNext[i][1]), .oSum(accumulatorNext[i][0]));
        end
        
        // output processing adder

        // first generate the 2 operands to be added
        wire [OUTPUT_LENGTH-1:0] wOperandA; // sum bits of accumulator
        wire [OUTPUT_LENGTH:0] wOperandB; // carry bits of accumulator, 1 bit shifted to the left
        assign wOperandB[0] = 0; // since we bit shift first bit is always 0
        
        for(i=0; i < OUTPUT_LENGTH; i = i+1)
        begin
            assign wOperandA[i] = accumulator[i][0];
            assign wOperandB[i+1] = accumulator[i][1];
        end
        
        // underlying adder can be changed
        // define adder types
        localparam RCA =   4'b0000;
        localparam CBA =   4'b0001;
        localparam CLA =   4'b0010;
        localparam BCLA =  4'b0011;
        localparam CSelA = 4'b0100;
        localparam GFA =   4'b0101;
        localparam IGFA =  4'b0110;
        localparam RCACC = 4'b0111;
        localparam CCA   =  4'b1000;
    
        mp_adder #(.OPERAND_WIDTH(OUTPUT_LENGTH), .ADDER_WIDTH(8), .ADDER_TYPE(CLA))
        adder_inst (
            .iClk(iClk),
            .iRst(iRst),
            .iStart( rStartProcess ),
            .iOpA( wOperandA ),
            .iOpB( wOperandB[OUTPUT_LENGTH-1:0] ),
            .oRes( woResAdd ),
            .oDone( wProcessed )
        );
          
    endgenerate
    
    
    // FSM
    // State definitions
    localparam s_IDLE         = 3'b000; // 0
    localparam s_ACCUMULATE     = 3'b001; // 1
    localparam s_PROCESS     = 3'b010; // 2
    localparam s_DONE          = 3'b011; // 3
    
    reg [2:0] rFSM;
    
    always @(posedge iClk)
    begin
        if(iRst)
        begin
            rA <= 0;
            rReady <= 0;
            rFSM <= s_IDLE;
            rStartProcess <= 0;
            rRes <= 0;
        end
        
        else begin
        case(rFSM)
            s_IDLE:
                begin
                    rRes <= rRes;
                    if(iAccumulate) begin
                        rStartProcess <= 0;
                        rReady <= 1;
                        rA <= iA;
                        rFSM <= s_IDLE;
                    end
                    else if(iTerminate) begin
                        rStartProcess <= 1;
                        rFSM <= s_PROCESS;
                        rReady <= 0;
                        rA <= 0;
                    end
                    else begin
                        rStartProcess <= 0;
                        rFSM <= s_IDLE;
                        rReady <= 1;
                        rA <= 0;
                    end
                end
           
           s_PROCESS:
                begin
                    rStartProcess <= 0;
                    rReady <= 0;
                    rA <= 0;
                    if (wProcessed) begin
                        rFSM <= s_DONE;
                        rRes <= woResAdd;
                    end else begin
                        rFSM <= s_PROCESS;
                        rRes <= rRes;
                    end
                end
               
            s_DONE:
                begin
                    rRes <= rRes;
                    rStartProcess <= 0;
                    rReady <= 1;
                    rA <= 0;
                    rFSM <= s_IDLE;
                end
                
            default:
                begin
                    rRes <= rRes;
                    rStartProcess <= 0;
                    rReady <= 0;
                    rA <= 0;
                    rFSM <= s_IDLE;
                end
               
        endcase
        end
    end
    
    // output logic
    assign oRes = rRes;
    assign oReady = rReady;
    assign oDone = (rFSM == s_DONE);
  
    
endmodule
