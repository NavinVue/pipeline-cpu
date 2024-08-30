`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: 
// comment: 
// input:
// output:
// author:  
module min_sopc(
        input   wire    CLK,
        input   wire    RST
    );

    // connect 指令存储器
    wire[`InstAddrWidth - 1:0]  inst_addr;
    wire[`InstBusWidth - 1:0]   inst;
    wire    rom_ce;

    // top module instancing
    top top0(
        .CLK(CLK),  .RST(RST),
        .rom_addr_o(inst_addr), .rom_data_i(inst),
        .rom_ce_o(rom_ce)
    );

    // rom instancing
    inst_rom    inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),   .inst(inst)
    );
endmodule
