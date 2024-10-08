`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  navinvue

module mem_wb(
        input   wire    clk,
        input   wire    rst,

        // results from mem
        input   wire[`RegAddrWidth - 1:0]   mem_wd, // addr
        input   wire    mem_wreg,   // enable
        input   wire[`RegBusWidth - 1:0]    mem_wdata,  // data

        // stall infos
        input   wire[5:0]   stall,

        // infos to wb-stage
        output  reg[`RegAddrWidth - 1:0]    wb_wd,
        output  reg wb_wreg,
        output  reg[`RegBusWidth - 1:0] wb_wdata

    );

    always @ (posedge   clk) begin
        if(rst == `RstEnable)  begin
            wb_wd   <=  `NOPRegAddr;
            wb_wreg <=  `WriteDisable;
            wb_wdata    <=  `ZeroWord;
        end else if(stall[4] == `Stop && stall[5] == `NotStop) begin
            wb_wd   <=  `NOPRegAddr;
            wb_wreg <=  `WriteDisable;
            wb_wdata    <=  `ZeroWord;
        end else if(stall[4] == `NotStop) begin
            wb_wd   <=  mem_wd;
            wb_wreg <=  mem_wreg;
            wb_wdata    <=  mem_wdata;
        end
    end
    
endmodule

