`include "definition.vh"
`timescale 1ns / 1ps
// module name: pc_reg 
// comment: 
// input: 
// output:  
// author: navinvue
// coding: gbk 

module pc_reg(
    input wire clk,
    input wire rst,
    input wire[5:0] stall, // stop sign from ctrl module
    output reg[`InstAddrWidth-1:0] pc,
    output reg ce
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable; // disable chip
        end else begin
            ce <= `ChipEnable; // enable chip after reset
        end
    end
    
    always @ (posedge clk) begin
        if ( ce == `ChipDisable) begin
            pc <= `ZeroWord ; // when chipdisable, pc = 0
        end else if (stall[0] == `NotStop) begin
            pc <= pc + 4'h4;
        end
    end
    
endmodule