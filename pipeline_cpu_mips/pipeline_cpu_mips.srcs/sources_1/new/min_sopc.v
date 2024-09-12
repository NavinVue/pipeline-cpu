`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  navinvue
module min_sopc(
        input   wire    clk,
        input   wire    rst
    );

    // connect data????rom
    wire[`InstAddrWidth - 1:0]  inst_addr;
    wire[`InstBusWidth - 1:0]   inst;
    wire    rom_ce;
    // data ram
    wire mem_we_i;
    wire[`RegBusWidth - 1:0]   mem_addr_i;
    wire[`RegBusWidth - 1:0]   mem_data_i;
    wire[`RegBusWidth - 1:0]   mem_data_o;
    wire[3:0]   mem_sel_i;  
    wire    mem_ce_i;  

    // top module instancing
    cpu cpu0(
        .clk(clk),  .rst(rst),
        .rom_addr_o(inst_addr), .rom_data_i(inst),
        .rom_ce_o(rom_ce),

        //ram
        .ram_we_o(mem_we_i),
		.ram_addr_o(mem_addr_i),
		.ram_sel_o(mem_sel_i),
		.ram_data_o(mem_data_i),
		.ram_data_i(mem_data_o),
		.ram_ce_o(mem_ce_i)	
    );

    // // rom instancing
    // inst_rom    inst_rom0(
    //     .ce(rom_ce),
    //     .addr(inst_addr),   .inst(inst)
    // );
 inst_rom_ip inst_rom0 (
   .a(inst_addr[11:2]),      // input wire [9 : 0] a
   .spo(inst)  // output wire [31 : 0] spo
 );  
//    // ram
    //  data_ram data_ram0(
	//  	.clk(clk),
	//  	.we(mem_we_i),
	//  	.addr(mem_addr_i),
	//  	.sel(mem_sel_i),
	//  	.data_i(mem_data_i),
	//  	.data_o(mem_data_o),
	//  	.ce(mem_ce_i)		
	//  );
   data_ram_ip data_ram0 (
   .a(mem_addr_i[11:2]),      // input wire [9 : 0] a
   .d(mem_data_i),      // input wire [31 : 0] d
   .clk(clk),  // input wire clk
   .we(mem_we_i),    // input wire we
   .spo(mem_data_o)  // output wire [31 : 0] spo
 );
endmodule
