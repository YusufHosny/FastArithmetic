`timescale 1ns / 1ps

module uart_top_fast #(
    
    // values for the UART (in case we want to change them)
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200,
    parameter OPERAND_WIDTH = 1024,
    parameter   NBYTES        = OPERAND_WIDTH/8
  )  
  (
    input   wire   iClk, iRst,
    input   wire   iRx,
    output  wire   oTx
  );

  // State definition  
  localparam s_IDLE         = 4'b0000; // 0
  localparam s_WAIT_RX_OP   = 4'b0001; // 1
  localparam s_WAIT_AS_RX1  = 4'b0010; // 2
  localparam s_WAIT_AS_RX2  = 4'b0011; // 3
  localparam s_AS_START     = 4'b0100; // 4
  localparam s_AS           = 4'b0101; // 5
  localparam s_TX           = 4'b0110; // 6
  localparam s_WAIT_TX      = 4'b0111; // 7
  localparam s_DONE         = 4'b1000; // 8
  
  // first received byte is the OPCode with instruction
  reg [7:0] rOPCode;
  
  // defining the instructionss
  localparam ADD     = 8'b00;
  localparam SUB     = 8'b01;
  
  // Declare all variables needed for the finite state machine 
  // -> the FSM state
  reg [3:0]   rFSM;  
  
  // Connection to UART TX (inputs = registers, outputs = wires) 
  reg         rTxStart;
  reg [7:0]   rTxByte;
  
  wire        wTxBusy;
  wire        wTxDone;
  
  // connection to RX
  wire [7:0] wRxByte;
  wire wRxDone;
  
  // adder
  reg rAddStart;
  wire wAddDone;
  reg rSub;
  reg [OPERAND_WIDTH-1:0] rA, rB;
  wire [OPERAND_WIDTH:0] wRes;
  reg  [(NBYTES+1)*8-1:0] rRes;
  
  
  // counter to keep track of received/sent bytes
  reg [$clog2(NBYTES):0] rCnt;

  
  uart_rx #(  .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_RX_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iRxSerial(iRx),
     .oRxByte(wRxByte),
     .oRxDone(wRxDone)
     );
     
     uart_tx #(  .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_TX_INST
    (.iClk(iClk),
     .iRst(iRst),
     .iTxStart(rTxStart),
     .iTxByte(rTxByte),
     .oTxSerial(oTx),
     .oTxBusy(wTxBusy),
     .oTxDone(wTxDone)
     );
     
    // instantiate adder
    localparam RCA    =   4'b0000;
    localparam CBA    =   4'b0001;
    localparam CLA    =   4'b0010;
    localparam BCLA   =   4'b0011;
    localparam CSelA  =   4'b0100;
    localparam GFA    =   4'b0101;
    localparam IGFA   =   4'b0110;
    localparam RCACC  =   4'b0111;
    localparam CCA    =   4'b1000;
   
    mp_adder #(.OPERAND_WIDTH(OPERAND_WIDTH), .ADDER_WIDTH(256), .BLOCK_WIDTH(64), .SUB_BLOCK_WIDTH(16), .ADDER_TYPE(IGFA))
    adder_inst (
        .iClk(iClk),
        .iRst(iRst),
        .iStart(rAddStart),
        .iOpA(rA),
        .iOpB(rB),
        .iSub(rSub),
        .oRes(wRes),
        .oDone(wAddDone)
    );

     

always @(posedge iClk) // WE DON'T HAVE TO DEFINE ALL CASES FOR REGISTERS BC NOW WE'RE NOT USING A COMBINATIONAL ALWAYSAT BLOCK
  begin
  
  // reset ALL REGISTERS upon reset
  if (iRst == 1 ) 
    begin
      rFSM <= s_IDLE;
      rTxStart <= 0;
      rCnt <= 0;
      rTxByte <= 0;
      rA <= 0;
      rB <= 0;
      rAddStart <= 0;
      rRes <= 0;
      rSub <=0;
    end 

  else 
    begin
      case (rFSM)
   
        s_IDLE :
          begin
            rFSM <= s_WAIT_RX_OP;
            rSub <= 0;
            
          end
          
        s_WAIT_RX_OP: // We wait for OPCode and based on that decide the next state
        begin
        if (wRxDone)
            begin
                rOPCode <= wRxByte; // Store it for later, to decide the instruction we check wRxByte
                
                if (wRxByte <= 1 ) // ADD or SUB
                begin rFSM <= s_WAIT_AS_RX1; end
                
            end
         
        else
            begin
                rFSM <= s_WAIT_RX_OP;
                rOPCode <= rOPCode;
            end
        end
        // GET FIRST OPERAND  
        s_WAIT_AS_RX1 :
          begin
          // If we haven't transferred all bytes, we wait for wRxDone to go high so we can transfer 
          if (rCnt < NBYTES)
              begin
              
              if (wRxDone) // EVERY TIME RX DONE IS HIGH WE'RE DONE RECEIVING A BYTE AND WE CAN STORE IT iN RA
                begin
                rA <= {rA[OPERAND_WIDTH-9:0] , wRxByte};   // SHIFT REGISTER WE SHIFT TO THE RIGHT
                rFSM <= s_WAIT_AS_RX1; 
                rCnt <= rCnt + 1;
                end
            
              else // IF RXDONE IS LOW WE STAY IN THE STATE AND WAIT FOR IT TO GO HIGH
                begin
                rA <= rA;
                rFSM <= s_WAIT_AS_RX1;
                rCnt <= rCnt;
                end
              end
            
          else // IF rCnt BECOMES 8 THEN WE'VE TRANSFERRED ALL BYTES AND WE CAN GO TO THE NEXT OPERAND
            begin
            rA <= rA;
            rFSM <= s_WAIT_AS_RX2;
            rCnt <= 0;
            end
              
          end
          
        
        // GET SECOND OPERAND - EXACT SAME WORKING
        
        s_WAIT_AS_RX2 :
          begin
          // If we haven't transferred all bytes, we wait for wRxDone to go high so we can transfer the
          if (rCnt < NBYTES)
              begin
              
              if (wRxDone)
                begin
                rB <= {rB[NBYTES*8-9:0] , wRxByte};      
                rFSM <= s_WAIT_AS_RX2; 
                rCnt <= rCnt + 1;
                end
            
              else 
                begin
                rB <= rB;
                rFSM <= s_WAIT_AS_RX2;
                rCnt <= rCnt;
                end
              end
              
          else
            begin
            rB <= rB;
            rFSM <= s_AS_START;
            rCnt <= 0;
            end
              
          end
             
        s_AS_START: // Starts addition/subtraction
        begin
        
        if (rOPCode == ADD) begin
         rSub <= 0; end
         
        else begin //SUB
        rSub <= 1; // blocking assignment???? to let rSub update before rStart
        end 
        
        rAddStart <= 1; // SET ADD START TO 1 TO START ADDITION IN MP_ADDER
        rFSM <= s_AS; // GO TO ADD STATE
        
        end
        
        s_AS:
        begin
        rAddStart <= 0; // SET rAddStart TO 0
        
        if (wAddDone == 0)
        begin
        rFSM <= s_AS;
        rRes <= rRes;
        end
        
        else // wAddDone is 1
            begin
            rSub <=0;
            
            rRes <= {7'b0, wRes}; // WE TAKE THE RESULT OF THE ADDITION + CARRY AND PLACE IT IN THE RES REGISTER. THEN WE CONCATENATE
                                    // 7 0s TO THE LEFT TO FILL UP THE "CARRY BYTE"
            rFSM <= s_TX; // NOW WE WANT TO TRANSFER THE RESULT
            
            end
        end
        
        s_TX :
          begin
            // IF WE HAVEN'T SENT ALL BYTES AND TX MODULE IS NOT BUSY SENDING ALREADY
            if ( (rCnt <= NBYTES ) && (wTxBusy == 0) ) // NOW WE'RE SENDING AN EXTRA BYTE FOR THE CARRY
              begin
                rFSM <= s_WAIT_TX; // THEN WE GO TO WAIT TX TO WAIT FOR BYTE TRANSMISSION TO BE DONE
                rTxStart <= 1; // SET IT TO 1 TO START TRANSMISSION OF BYTE
                rTxByte = rRes[(NBYTES+1)*8-1:(NBYTES+1)*8-8];   // we send the uppermost byte WE NEED TO MAKE IT BLOCKING 
                                                                // SO THAT WE FIRST SET THE SENDING BYTE AND THEN SHIFT
                rRes = {rRes[NBYTES*8-1:0] , 8'b0000_0000};    // we shift from right to left. THINK OF UART ARCHITECTURE: IF YOU RECEIVE
                                                            // FROM LEFT TO RIGHT THEN YOU SEND BACK FROM RIGHT TO LEFT
                rCnt <= rCnt + 1;
              end 
            else // ONCE WE'RE DONE WITH ALL BYTES WE GO TO sDONE
              begin
                rFSM <= s_DONE;
                rTxStart <= 0; // SET START BIT TO 0
                rTxByte <= rTxByte;
                rCnt <= 0; // SET COUNTER OF TRANSFERRED BYTES TO 0
                rRes <= rRes;
              end
            end 
            
            
            s_WAIT_TX :
              begin
                if (wTxDone) begin // IF TX MODULE IS DONE WITH BYTE TRANSFER THEN WE GO BACK TO TX TO SEE IF WE NEED TO TRANSMIT ANOTHER
                  rFSM <= s_TX;
                end else begin
                  rFSM <= s_WAIT_TX;    // ELSE TX IS STILL BUSY AND WE WAIT
                  rTxStart <= 0;    // SET START BIT TO 0    
                end
              end 
              
            s_DONE : // DONE STATE, EVERYTHING IS TRANSFERRED AND WE GO BACK TO IDLE
              begin
                rFSM <= s_IDLE;
              end 

            default :
              rFSM <= s_IDLE;
             
          endcase
      end
    end       

endmodule
