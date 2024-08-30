`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: PC
// comment: ¸ù¾Ýnpc£¬Êä³öPC
// input:
// output:
// author:  

module regfile(
    input wire CLK,
    input wire RST,
    
    // write port
    input wire we, // write enable
    input wire[`RegAddrWidth - 1:0] waddr, // register addr
    input wire[`RegBusWidth - 1:0] wdata, // write data
    
    // read port 1
    input wire re1, // read enable
    input wire[`RegAddrWidth -1 :0] raddr1, // read reg 1 addr
    output reg[`RegBusWidth - 1 :0] rdata1, // read data 1
    
    // read port 2
    input wire re2,
    input wire[`RegAddrWidth -1 :0] raddr2,
    output reg[`RegBusWidth - 1 :0] rdata2
    );
/*********************************
 1. define 32 32-bits registers
**********************************/
reg[`RegBusWidth - 1 :0] regs[0:`RegNum - 1];
/*********************************
 2. write
**********************************/
    always @ (posedge CLK) begin
        if (RST == `RstDisable) begin
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end
/***********************************
   3. Read port 1
***********************************/
    always @ (*) begin
        if(RST == `RstEnable) begin
            rdata1 <= `ZeroWord;
        end else if(raddr1 == `RegNumLog2'h0) begin
            rdata1 <= `ZeroWord;
        end else if ((raddr1 == waddr) && (we == `WriteEnable)
                        && (re1 == `ReadEnable)) begin
            rdata1 <= wdata;
        end else if (re1 == `ReadEnable) begin
            rdata1 <= regs[raddr1];
        end else begin
            rdata1 <= `ZeroWord;
        end
    end

/*************************
  4. read port 2
*************************/
    always @ (*) begin
        if (RST == `RstEnable) begin
            rdata2 <= `ZeroWord;
        end else if (raddr2 == `RegNumLog2'h0) begin
            rdata2 <= `ZeroWord;
        end else if ((raddr2 == waddr) && (we == `WriteEnable)
                        && (re2 == `ReadEnable)) begin
            rdata2 <= wdata;
        end else if (re2 == `ReadEnable) begin
            rdata2 <= regs[raddr2];
        end else begin
            rdata2 <= `ZeroWord;
        end
    end
    
endmodule
