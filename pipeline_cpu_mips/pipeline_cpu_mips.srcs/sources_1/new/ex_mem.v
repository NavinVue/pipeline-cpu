`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  

module ex_mem(
        input   wire    clk,
        input   wire    rst,

        // infos from ex-stage
        input   wire[`RegAddrWidth - 1:0]  ex_wd,   // write reg addr
        input   wire    ex_wreg,    // write enavle
        input   wire[`RegBusWidth - 1:0]    ex_wdata,   // write data

        // stall infos
        input   wire[5:0]   stall,

        // new infos , load-store
        input   wire[`AluOpBusWidth - 1 :0] ex_aluop,
        input   wire[`RegBusWidth   - 1 :0] ex_mem_addr,    //addr
        input   wire[`RegBusWidth   - 1 :0] ex_reg2,    // data
        output  reg[`RegBusWidth - 1 :0]    mem_aluop,
        output  reg[`RegBusWidth - 1 :0]    mem_mem_addr,
        output  reg[`RegBusWidth - 1 :0]    mem_reg2,
        // end new infos, load-store

        // infos to mem
        output  reg[`RegAddrWidth - 1:0]    mem_wd, // mem, write reg addr
        output  reg mem_wreg,    // mem-stage, write enable
        output  reg[`RegBusWidth - 1:0] mem_wdata   // mem, data to write 
    );
    
    always @(posedge clk) begin
        if(rst == `RstEnable)   begin
            mem_wd  <=  `NOPRegAddr;
            mem_wreg    <=  `WriteDisable;
            mem_wdata   <=  `ZeroWord;
            mem_aluop   <=  `EXE_NOP_OP;
            mem_mem_addr    <=  `ZeroWord;
            mem_reg2    <=  `ZeroWord;
        end else if (stall[3] == `Stop && stall[4] == `NotStop) begin
            mem_wd  <=  `NOPRegAddr;
            mem_wreg    <=  `WriteDisable;
            mem_wdata   <=  `ZeroWord;
            mem_aluop   <=  `EXE_NOP_OP;
            mem_mem_addr    <=  `ZeroWord;
            mem_reg2    <=  `ZeroWord;
        end else if (stall[3] == `NotStop) begin
            mem_wd  <=  ex_wd;
            mem_wreg    <=  ex_wreg;
            mem_wdata   <=  ex_wdata;
            mem_aluop   <=  ex_aluop;
            mem_mem_addr    <=  ex_mem_addr;
            mem_reg2    <=  ex_reg2;
        end else begin
            
        end
    end
    
endmodule
