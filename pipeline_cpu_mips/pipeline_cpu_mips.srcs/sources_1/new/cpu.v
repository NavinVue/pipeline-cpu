`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  
// coding: gbk, 在更新代码时，出现了乱码...

module cpu(
        input   wire    clk,
        input   wire    rst,

        input   wire[`RegBusWidth - 1:0]    rom_data_i, // inst addr
        output  wire[`RegBusWidth - 1:0]    rom_addr_o, // 
        output  wire    rom_ce_o
    );
    // vars, connect if/id and id
    wire[`InstAddrWidth - 1:0]  pc;
    wire[`InstAddrWidth - 1:0]  id_pc_i;
    wire[`InstBusWidth - 1:0]   id_inst_i;

    // vars, connect id and id/ex
    wire[`AluOpBusWidth - 1:0]  id_aluop_o;
    wire[`AluSelBusWidth - 1:0] id_alusel_o;
    wire[`RegBusWidth - 1:0]    id_reg1_o;
    wire[`RegBusWidth - 1:0]    id_reg2_o;
    wire    id_wreg_o;
    wire[`RegAddrWidth - 1:0]   id_wd_o;

    // vars, connect id/ex and ex
    wire[`AluOpBusWidth - 1:0]  ex_aluop_i;
    wire[`AluSelBusWidth - 1:0] ex_alusel_i;
    wire[`RegBusWidth - 1:0]    ex_reg1_i;
    wire[`RegBusWidth - 1:0]    ex_reg2_i;
    wire    ex_wreg_i;
    wire[`RegAddrWidth - 1:0]   ex_wd_i;

    // vars, ex and ex/mem
    wire    ex_wreg_o;
    wire[`RegAddrWidth - 1:0]   ex_wd_o;
    wire[`RegBusWidth - 1:0]    ex_wdata_o;

    // vars, ex/mem and mem
    wire    mem_wreg_i;
    wire[`RegAddrWidth - 1:0]   mem_wd_i;
    wire[`RegBusWidth - 1:0]    mem_wdata_i;

    // vars, mem and mem/wb
    wire    mem_wreg_o;
    wire[`RegAddrWidth - 1:0]   mem_wd_o;
    wire[`RegBusWidth - 1:0]    mem_wdata_o;

    // vars, mem/wb and wb
    wire    wb_wreg_i;
    wire[`RegAddrWidth - 1:0]   wb_wd_i;
    wire[`RegBusWidth - 1:0]    wb_wdata_i;

    // vars, id and regfile
    wire    reg1_read;
    wire    reg2_read;
    wire[`RegBusWidth - 1:0]    reg1_data;
    wire[`RegBusWidth - 1:0]    reg2_data;
    wire[`RegAddrWidth - 1:0]   reg1_addr;
    wire[`RegAddrWidth - 1:0]   reg2_addr;

    // stall sign
    wire[5:0]   stall;
    wire    stall_from_id;
    wire    stall_from_ex;

    // pc_reg instancing
    pc_reg  pc_reg0(
        .clk(clk),  .rst(rst),  .pc(pc),    .ce(rom_ce_o), .stall(stall)
    );

    assign  rom_addr_o  = pc;   // 

    // if/id instancing
    if_id   id_id0(
        .clk(clk),  .rst(rst),  .if_pc(pc),
        .if_inst(rom_data_i),   .id_pc(id_pc_i),
        .id_inst(id_inst_i), .stall(stall)
    );

    // id instancing
    id id0(
        .rst(rst),  .pc_i(id_pc_i), .inst_i(id_inst_i),

        // from regfile
        .reg1_data_i(reg1_data),    .reg2_data_i(reg2_data),

        // infos from ex-stage
        .ex_wreg_i(ex_wreg_o),  .ex_wd_i(ex_wd_o),
        .ex_wdata_i(ex_wdata_o),

        // infos from mem-stage
        .mem_wreg_i(mem_wreg_o), .mem_wd_i(mem_wd_o),
        .mem_wdata_i(mem_wdata_o),

        //  infos to regfile
        .reg1_read_o(reg1_read),    .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),    .reg2_addr_o(reg2_addr),

        // infos to id/ex
        .aluop_o(id_aluop_o),   .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o), .reg2_o(id_reg2_o), // data (source number which will be used later)
        .wd_o(id_wd_o), .wreg_o(id_wreg_o),
        .stall_from_id_o(stall_from_id)
    );

    // Regfile instancing
    regfile regfile1(   // why here names "1" not "2" like others?
        .clk(clk),  .rst(rst),
        .we(wb_wreg_i), .waddr(wb_wd_i),
        .wdata(wb_wdata_i), .re1(reg1_read),
        .raddr1(reg1_addr), .rdata1(reg1_data),
        .re2(reg2_read),    .raddr2(reg2_addr),
        .rdata2(reg2_data)
    );

    // id/ex instancing
    id_ex   id_ex0(
        .clk(clk),  .rst(rst),

        //  infos from id module
        .id_aluop(id_aluop_o),  .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),    .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),    .id_wreg(id_wreg_o),

        // infos to ex module
        .ex_aluop(ex_aluop_i),  .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),    .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),    .ex_wreg(ex_wreg_i), .stall(stall)
    );

    // ex instancing
    ex ex0(
        .rst(rst),

        // infos from id/ex
        .aluop_i(ex_aluop_i),   .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),

        // infos to ex/mem
        .wd_o(ex_wd_o), .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o), .stall_from_ex_o(stall_from_ex)
    );

    // ex/mem instancing
    ex_mem  ex_mem0(
        .clk(clk),  .rst(rst),

        // infos from ex
        .ex_wd(ex_wd_o),    .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        // infos to mem
        .mem_wd(mem_wd_i),  .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i), .stall(stall)
    );

    // mem instancing
    mem mem0(
        .rst(rst),

        //  infos from ex/mem
        .wd_i(mem_wd_i),    .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        // infos to mem/wb
        .wd_o(mem_wd_o),    .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o)
    );

    // mem/wb instacing
    mem_wb  mem_wb0(
        .clk(clk),  .rst(rst),
        // infos from mem
        .mem_wd(mem_wd_o),  .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),

        // infos to wb
        .wb_wd(wb_wd_i),    .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i), .stall(stall)    
    );

    ctrl ctrl0(
        .rst(rst),
        .stall_from_id(stall_from_id),
        .stall_from_ex(stall_from_ex),
        .stall(stall)
    );

endmodule

