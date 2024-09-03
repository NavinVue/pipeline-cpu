`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  

module id_ex(
            input   wire    clk,
            input   wire    rst,
            // infos from decoder inst stage
            input   wire[`AluOpBusWidth - 1 : 0]    id_aluop,
            input   wire[`AluSelBusWidth - 1 : 0]   id_alusel,
            input   wire[`RegBusWidth - 1 : 0]  id_reg1, // source number 1
            input   wire[`RegBusWidth - 1 : 0]  id_reg2, // source number 2
            input   wire[`RegAddrWidth - 1 : 0] id_wd, // dest w_reg addr
            input   wire    id_wreg,
            
            // stall sign
            input   wire[5:0]   stall,

            // branch infos
            input   wire[`RegBusWidth - 1 : 0]   id_link_address,
            input   wire    id_is_in_delayslot,
            input   wire    next_inst_in_delayslot_i,

            // inst infos
            input   wire[`RegBusWidth - 1 :0]   id_inst,    // inst from id

            output  reg[`RegBusWidth - 1 :0]   ex_inst,    // inst info to ex   

            output  reg[`RegBusWidth - 1 : 0]   ex_link_address,
            output  reg ex_is_in_delayslot,
            output  reg is_in_delayslot_o,

            // infos to ex-stage
            output  reg[`AluOpBusWidth - 1 : 0] ex_aluop,  // alu op to ex-stage
            output  reg[`AluSelBusWidth - 1 : 0]    ex_alusel,  // alu sub op to ex-stage
            output  reg[`RegBusWidth - 1 : 0]   ex_reg1, //   source number 1
            output  reg[`RegBusWidth - 1 : 0]   ex_reg2, // source number 2
            output  reg[`RegAddrWidth - 1 : 0]  ex_wd,  // ex-stage, dest w_reg addr
            output  reg ex_wreg // weathear need w_reg
    );
    
    always @ (posedge   clk) begin
        if (rst == `RstEnable) begin
            ex_aluop    <=  `EXE_NOP_OP;
            ex_alusel   <=  `EXE_RES_NOP;
            ex_reg1 <=  `ZeroWord;
            ex_reg2 <=  `ZeroWord;
            ex_wd   <=  `NOPRegAddr;
            ex_wreg <=  `WriteDisable;
        end else if(stall[2] == `Stop && stall[3] == `NotStop) begin
            ex_aluop    <=  `EXE_NOP_OP;
            ex_alusel   <=  `EXE_RES_NOP;
            ex_reg1 <=  `ZeroWord;
            ex_reg2 <=  `ZeroWord;
            ex_wd   <=  `NOPRegAddr;
            ex_wreg <=  `WriteDisable;
        end else if(stall[2] == `NotStop) begin
            ex_aluop    <=  id_aluop;
            ex_alusel   <=  id_alusel;
            ex_reg1 <=  id_reg1;
            ex_reg2 <=  id_reg2;
            ex_wd   <=  id_wd;
            ex_wreg <=  id_wreg;
            ex_link_address <=  id_link_address;
            ex_is_in_delayslot  <=  id_is_in_delayslot;
            is_in_delayslot_o   <=  next_inst_in_delayslot_i;
            ex_inst <=  id_inst;
        end
    end
    
endmodule
