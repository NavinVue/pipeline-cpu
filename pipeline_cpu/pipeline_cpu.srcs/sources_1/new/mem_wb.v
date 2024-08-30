`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: 
// comment: 
// input:
// output:
// author:  

module mem_wb(
        input   wire    CLK,
        input   wire    RST,

        // results from mem
        input   wire[`RegAddrWidth - 1:0]   mem_wd, // addr
        input   wire    mem_wreg,   // enable
        input   wire[`RegBusWidth - 1:0]    mem_wdata,  // data

        // infos to wb-stage
        output  reg[`RegAddrWidth - 1:0]    wb_wd,
        output  reg wb_wreg,
        output  reg[`RegBusWidth - 1:0] wb_wdata

    );

    always @ (posedge   CLK) begin
        if(RST == `NOPRegAddr)  begin
            wb_wd   <=  `NOPRegAddr;
            wb_wreg <=  `WriteDisable;
            wb_wdata    <=  `ZeroWord;
        end else begin
            wb_wd   <=  mem_wd;
            wb_wreg <=  mem_wreg;
            wb_wdata    <=  mem_wdata;
        end
    end
    
endmodule
