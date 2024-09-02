`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  

module ex(
        input   rst,

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
        reg[`RegBusWidth - 1 :0]   logicout; // result of logic compute
        reg[`RegBusWidth - 1 :0]   shiftres; // result of shift compute 
/***********************
*******   1. calcu according to alu op ��now only logic or�� *******
***********************/
// logic compute
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP: begin
                    logicout    <=  reg1_i | reg2_i; // or
                end
                `EXE_AND_OP: begin
                    logicout    <=  reg1_i & reg2_i; // and
                end
                `EXE_NOR_OP: begin
                    logicout    <=  ~(reg1_i | reg2_i); // nor
                end
                `EXE_XOR_OP:    begin
                    logicout    <=  reg1_i ^ reg2_i;
                end
                default:    begin
                    logicout <= `ZeroWord;
                end
            endcase
        end // if
    end //always

// shift compute
    always @(*) begin
        if(rst == `RstEnable) begin
            shiftres    <=  `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP:    begin   // logic left shift
                    shiftres    <=  reg2_i  <=  reg1_i[4:0]; // imm or regdata, only 4-bit
                end
                `EXE_SRL_OP:    begin   // logic right shift
                    shiftres    <=  reg2_i  >=  reg1_i[4:0];
                end
                `EXE_SRA_OP:    begin   // arithmetic right shift
                    shiftres    <=  ({32{reg2_i[31]}} << (6'd32-{1'b0,reg1_i[4:0]})) | reg2_i   >> reg1_i[4:0];
                end
                default: begin
                    shiftres    <=  `ZeroWord;
                end
            endcase
        end
        
    end

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
            `EXE_RES_SHIFT: begin
                wdata_o <=  shiftres; // choose shift res as wdata
            end
            default:    begin
                wdata_o <=  `ZeroWord;
            end
        endcase
    end

endmodule
