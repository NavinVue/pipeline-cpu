`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  

module if_id(
        input wire clk,
        input wire rst,
        // signal from inst fetch stage
        input wire[`InstAddrWidth - 1:0] if_pc, // in pc
        input wire[31:0] if_inst, // in inst
        
        // signal to decoder inst stage
        output reg[`InstAddrWidth - 1:0] id_pc, // out pc
        output reg[31:0] id_inst // out inst
        
    );
    always @ (posedge clk) begin
        if (rst==`RstEnable) begin
            id_pc <= `ZeroWord; // reset, pc,inst=32'b00...0
            id_inst <= `ZeroWord;
        end else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule