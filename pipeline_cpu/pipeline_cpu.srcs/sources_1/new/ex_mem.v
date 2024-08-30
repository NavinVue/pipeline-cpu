`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: 
// comment: 
// input:
// output:
// author:  
module ex_mem(
        input   wire    CLK,
        input   wire    RST,

        // infos from ex-stage
        input   wire[`RegAddrWidth - 1:0]  ex_wd,   // write reg addr
        input   wire    ex_wreg,    // write enavle
        input   wire[`RegBusWidth - 1:0]    ex_wdata,   // write data

        // infos to mem
        output  reg[`RegAddrWidth - 1:0]    mem_wd, // mem, write reg addr
        output  reg mem_wreg,    // mem-stage, write enable
        output  reg[`RegBusWidth - 1:0] mem_wdata   // mem, data to write 
    );
    
    always @(posedge CLK) begin
        if(RST == `RstEnable)   begin
            mem_wd  <=  `NOPRegAddr;
            mem_wreg    <=  `WriteDisable;
            mem_wdata   <=  `ZeroWord;
        end else begin
            mem_wd  <=  ex_wd;
            mem_wreg    <=  ex_wreg;
            mem_wdata   <=  ex_wdata;
        end
    end
    
endmodule
