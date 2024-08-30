`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: 
// comment: 
// input:
// output:
// author:  

module pc_reg(
    input wire CLK,
    input wire RST,
    output reg[`InstAddrWidth-1:0] pc,
    output reg ce
    );
    
    always @ (posedge CLK) begin
        if (RST == `RstEnable) begin
            ce <= `ChipDisable; // 复位的时候指令存储器禁用，inst mem forbidden when rst
        end else begin
            ce <= `ChipEnable; // enable chip after reset
        end
    end
    
    always @ (posedge CLK) begin
        if ( ce == `ChipDisable) begin
            pc <= `ZeroWord ; // when chipdisable, pc = 0
        end else begin 
            pc <= pc + 4'h4; // pc+=4
        end
    end
    
endmodule
