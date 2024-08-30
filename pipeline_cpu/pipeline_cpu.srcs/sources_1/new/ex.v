`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: 
// comment: 
// input:
// output:
// author:  

module ex(
        input   RST,

        // infos from decoder inst to ex-stage
        input   wire[`AluOpBusWidth - 1 :0] aluop_i,    // alu op
        input   wire[`AluSelBusWidth - 1 :0] alusel_i,  // alu sel (sub op)
        input   wire[`RegBusWidth - 1 :0] reg1_i,   //  source number 1
        input   wire[`RegBusWidth - 1 :0] reg2_i,   //  source number 2
        input   wire[`RegAddrWidth - 1 :0] wd_i, // addr of dest reg
        input   wire    wreg_i, // write enable

        // ex results
        output  reg[`RegAddrWidth - 1 :0]   wd_o, // final dest w_reg addr
        output  reg wreg_o, // write enable
        output  reg[`RegBusWidth - 1 :0]   wdata_o // result to write 
        
        
    );
    // save logic calcu results
        reg[`RegBusWidth - 1 :0]   logicout;

/***********************
*******   1. calcu according to alu op £¨now only logic or£© *******
***********************/

    always @ (*) begin
        if (RST == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP:begin
                    logicout <= reg1_i | reg2_i;
                end
                default:    begin
                    logicout <= `ZeroWord;
                end
            endcase
        end // if
    end //always

/************************
**** 2. according to alusel_i, choose result (here only logicout) ****
*************************/

    always @ (*) begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case ( alusel_i )
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout; // results to wdata_o
            end
            default:    begin
                wdata_o <=  `ZeroWord;
            end
        endcase
    end

endmodule
