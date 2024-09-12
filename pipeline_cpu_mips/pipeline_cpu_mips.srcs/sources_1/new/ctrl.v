`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  navinvue
// encoding: utf-8
module ctrl(
        input   wire    rst,
        input   wire    stall_from_id,  //  stall request from id-stage
        input   wire    stall_from_ex,  //  stall request from ex-stage  
        output  reg[5:0]    stall // stall sign
    );
    // 0 stands for not stall, 1 stands for stall
    always @(*) begin
        if(rst == `RstEnable) begin
            stall <=    6'b000000; 
        end else if (stall_from_id == `Stop) begin
            stall <=    6'b000111; 
        end else if (stall_from_ex == `Stop) begin
            stall <=    6'b001111;
        end else    begin
            stall   <=  6'b000000;
        end
    end
endmodule
