`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: 
// comment: 
// input:
// output:
// author:  

module mem (
    input   wire    RST,
    
    // infos from ex
    input   wire[`RegAddrWidth - 1:0] wd_i, // reg addr
    input   wire    wreg_i, // write enable
    input   wire[`RegBusWidth - 1:0]    wdata_i,    // write data

    // results of mem
    output reg[`RegAddrWidth - 1:0] wd_o,
    output  reg wreg_o,
    output  reg[`RegBusWidth - 1:0] wdata_o
);
    
    always @ (*) begin
        if(RST == `RstEnable) begin
            wd_o    <=  `NOPRegAddr;
            wreg_o  <=  `WriteDisable;
            wdata_o <=  `ZeroWord;
        end else begin
            wd_o    <=  wd_i;
            wreg_o  <=  wreg_i;
            wdata_o <=  wdata_i;
        end
    end
endmodule