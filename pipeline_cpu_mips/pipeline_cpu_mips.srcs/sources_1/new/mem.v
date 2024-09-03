`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  

module mem (
    input   wire    rst,
    
    // infos from ex
    input   wire[`RegAddrWidth - 1:0] wd_i, // reg addr
    input   wire    wreg_i, // write enable
    input   wire[`RegBusWidth - 1:0]    wdata_i,    // write data
    
    // load store
    input   wire[`AluOpBusWidth - 1 :0] aluop_i,
    input   wire[`RegBusWidth - 1 :0]   mem_addr_i,
    input   wire[`RegBusWidth - 1 :0]   reg2_i,

    // infos from ram
    input   wire[`RegBusWidth - 1 :0]   mem_data_i,

    output  reg[`RegBusWidth - 1 :0]    mem_addr_o,
    output  wire    mem_we_o,
    output  reg[3 :0]    mem_sel_o,
    output  reg[`RegBusWidth - 1 :0]    mem_data_o,
    output  reg mem_ce_o,

    // end infos about load store

    // results of mem
    output reg[`RegAddrWidth - 1:0] wd_o,
    output  reg wreg_o,
    output  reg[`RegBusWidth - 1:0] wdata_o
);
    wire[`RegBusWidth - 1:0]    zero32;
    reg mem_we;
    assign  mem_we_o    = mem_we;
    assign  zero32  =   `ZeroWord;

    always @ (*) begin
        if(rst == `RstEnable) begin
            wd_o    <=  `NOPRegAddr;
            wreg_o  <=  `WriteDisable;
            wdata_o <=  `ZeroWord;
            mem_addr_o  <=  `ZeroWord;
            mem_we  <=  `WriteDisable;
            mem_sel_o   <=  4'b0000;
            mem_data_o  <=  `ZeroWord;
            mem_ce_o    <=  `ChipDisable;
        end else begin
            wd_o    <=  wd_i;
            wreg_o  <=  wreg_i;
            wdata_o <=  wdata_i;
            mem_we  <=  `WriteDisable;
            mem_addr_o  <=  `ZeroWord;
            mem_sel_o   <=  4'b1111;
            mem_ce_o    <=  `ChipDisable;
            case(aluop_i)
                `EXE_LW_OP: begin
                    mem_addr_o  <=  mem_addr_i;
                    mem_we  <=  `WriteDisable;
                    wdata_o <=  mem_data_i;
                    mem_sel_o   <=  4'b1111;
                    mem_ce_o    <=  `ChipEnable;
                end
                `EXE_SW_OP: begin
                    mem_addr_o  <=  mem_addr_i;
                    mem_we  <=  `WriteEnable;
                    mem_data_o  <=  reg2_i;
                    mem_sel_o   <=  4'b1111;
                    mem_ce_o    <=  `ChipEnable;
                end
                default:    begin
                    
                end
            endcase
        end
    end
endmodule
