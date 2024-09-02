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
        end else if (stall[3] == `Stop && stall[4] == `NotStop) begin
            mem_wd  <=  `NOPRegAddr;
            mem_wreg    <=  `WriteDisable;
            mem_wdata   <=  `ZeroWord;
        end else if (stall[3] == `NotStop) begin
            mem_wd  <=  ex_wd;
            mem_wreg    <=  ex_wreg;
            mem_wdata   <=  ex_wdata;
        end
    end
    
endmodule
