`include "definition.vh"
`timescale 1ns / 1ps
// module name: pc_reg 
// comment: 
// input: ����Ϊclk��rst�źţ����pc��оƬʹ���ź�
// output:  
// author: navinvue
// coding: gbk 

module pc_reg(
    input wire clk,
    input wire rst,
    output reg[`InstAddrWidth-1:0] pc,
    output reg ce
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable; // ��λ��ʱ��ָ��洢�����ã�inst mem forbidden when rst
        end else begin
            ce <= `ChipEnable; // enable chip after reset
        end
    end
    
    always @ (posedge clk) begin
        if ( ce == `ChipDisable) begin
            pc <= `ZeroWord ; // when chipdisable, pc = 0
        end else begin 
            pc <= pc + 4'h4; // pc+=4
        end
    end
    
endmodule