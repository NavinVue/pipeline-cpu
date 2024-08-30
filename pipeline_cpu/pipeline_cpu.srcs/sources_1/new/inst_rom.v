`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: 
// comment: 
// input:
// output:
// author:  

module inst_rom(
        input   wire    ce, // enable sign
        input   wire[`InstAddrWidth - 1:0]  addr,
        output  reg[`InstBusWidth - 1:0]    inst
    );

    // define an array, size InstMemNum, width InstBusWidth
    reg[`InstBusWidth - 1:0] inst_mem[0:`InstMemNum - 1];

    // initial
    initial $readmemh   ("inst_rom.mem", inst_mem);

    always @(*) begin
        if (ce == `ChipDisable) begin
            inst    <=  `ZeroWord;
        end else begin
            inst    <=  inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end

endmodule
