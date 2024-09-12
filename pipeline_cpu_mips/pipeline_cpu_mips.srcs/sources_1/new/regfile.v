`include "definition.vh"
`timescale 1ns / 1ps
// module name: pc_reg 
// comment: 
// input: 输入为clk，rst信号，输出pc，芯片使能信??
// output:  
// author: navinvue
// coding: gbk  

module regfile(
    input wire clk,
    input wire rst,
    
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
integer i;
    always @(posedge clk or posedge rst) begin
        if (rst==`RstEnable) begin
            for (i = 0; i < `RegNum; i = i + 1) begin
                regs[i] <= {`RegBusWidth{1'b0}}; // init regs
            end
        end else begin
        
        end
    end
/*********************************
 2. write
**********************************/
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end
/***********************************
   3. Read port 1
***********************************/
    always @ (*) begin
        if(rst == `RstEnable) begin
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
        if (rst == `RstEnable) begin
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
