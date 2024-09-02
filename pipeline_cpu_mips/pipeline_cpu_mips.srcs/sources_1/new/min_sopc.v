`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  
module min_sopc(
        input   wire    clk,
        input   wire    rst
    );

    // connect 指令存储�?
    wire[`InstAddrWidth - 1:0]  inst_addr;
    wire[`InstBusWidth - 1:0]   inst;
    wire    rom_ce;

    // top module instancing
    cpu cpu0(
        .clk(clk),  .rst(rst),
        .rom_addr_o(inst_addr), .rom_data_i(inst),
        .rom_ce_o(rom_ce)
    );

    // rom instancing
    inst_rom    inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),   .inst(inst)
    );
endmodule
