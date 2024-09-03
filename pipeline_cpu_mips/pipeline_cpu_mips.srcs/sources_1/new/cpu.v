`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  
// coding: gbk, �ڸ��´���ʱ������������...

module cpu(
        input   wire    clk,
        input   wire    rst,

        input   wire[`RegBusWidth - 1:0]    rom_data_i, // inst addr
        output  wire[`RegBusWidth - 1:0]    rom_addr_o, // 

        // link ram
        input   wire[`RegBusWidth - 1:0]    ram_data_i,
        output  wire[`RegBusWidth - 1:0]    ram_addr_o,
        output  wire[`RegBusWidth - 1:0]    ram_data_o,
        output  wire    ram_we_o,
        output  wire[3:0]   ram_sel_o,
        output  wire    ram_ce_o,
        

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

    // branch infos
    wire    id_is_in_delayslot_o;
    wire[`RegBusWidth - 1 :0] id_link_address_o;
    wire    ex_is_in_delayslot_o;
    wire[`RegBusWidth - 1 :0] ex_link_address_i;
    wire    is_in_delayslot_i;
    wire    is_in_delayslot_o;
    wire    next_inst_in_delayslot_o;
    wire    id_branch_flag_o;
    wire[`RegBusWidth - 1:0]    branch_target_address;
    
    // load store (new add)
    wire[`RegBusWidth - 1:0]    id_inst_o;
    wire[`RegBusWidth - 1:0]    ex_inst_o;
    wire[`AluOpBusWidth - 1:0]  ex_aluop_o;
    wire[`RegBusWidth - 1:0]    ex_inst_i;
    wire[`RegBusWidth - 1:0]    ex_mem_addr_o;
    wire[`RegBusWidth - 1:0]    ex_reg1_o;
    wire[`RegBusWidth - 1:0]    ex_reg2_o;
    wire[`AluOpBusWidth - 1:0]    mem_aluop_i;
    wire[`RegBusWidth - 1:0]    mem_mem_addr_i;
    wire[`RegBusWidth - 1:0]    mem_reg1_i;
    wire[`RegBusWidth - 1:0]    mem_reg2_i;

    wire J_inst;
    wire flush_b;
    wire flush_j;
    // pc_reg instancing
    pc_reg  pc_reg0(
        .clk(clk),  .rst(rst),  .pc(pc),    .ce(rom_ce_o), .stall(stall),
        .branch_flag_i(id_branch_flag_o),   .branch_target_address_i(branch_target_address)
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

        .ex_aluop_i(ex_aluop_o),
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
        .stall_from_id_o(stall_from_id),

        .is_in_delayslot_i(is_in_delayslot_i),  .next_inst_in_delayslot_o(next_inst_in_delayslot_o),
        .branch_flag_o(id_branch_flag_o),   .branch_target_address_o(branch_target_address),
        .link_addr_o(id_link_address_o),    .is_in_delayslot_o(id_is_in_delayslot_o),
        .inst_o(id_inst_o),
        .flush_b(flush_b),
        .flush_j(flush_j),
        .J_inst(J_inst)
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
        .ex_wd(ex_wd_i),    .ex_wreg(ex_wreg_i), 
        .stall(stall),

        .id_link_address(id_link_address_o),    .id_is_in_delayslot(id_is_in_delayslot_o),
        .next_inst_in_delayslot_i(next_inst_in_delayslot_o),
        .ex_link_address(ex_link_address_i),    .ex_is_in_delayslot(ex_is_in_delayslot_i),
		.is_in_delayslot_o(is_in_delayslot_i),
        .id_inst(id_inst_o)	,   .ex_inst(ex_inst_i),
        .branch_flag(id_branch_flag_o), .flush_b(flush_b),
        .flush_j(flush_j)
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
        .wdata_o(ex_wdata_o), 
        .stall_from_ex_o(stall_from_ex),
        .link_address_i(ex_link_address_i),
		.is_in_delayslot_i(ex_is_in_delayslot_i),
        .inst_i(ex_inst_i), .aluop_o(ex_aluop_o),
        .mem_addr_o(ex_mem_addr_o),
		.reg2_o(ex_reg2_o)
    );

    // ex/mem instancing
    ex_mem  ex_mem0(
        .clk(clk),  .rst(rst),

        // infos from ex
        .ex_wd(ex_wd_o),    .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        // infos to mem
        .mem_wd(mem_wd_i),  .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i), .stall(stall),
        .ex_aluop(ex_aluop_o),  .ex_mem_addr(ex_mem_addr_o),
        .ex_reg2(ex_reg2_o),    .mem_mem_addr(mem_mem_addr_i),
        .mem_aluop(mem_aluop_i),    .mem_reg2(mem_reg2_i)
    );

    // mem instancing
    mem mem0(
        .rst(rst),

        //  infos from ex/mem
        .wd_i(mem_wd_i),    .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        // infos to mem/wb
        .wd_o(mem_wd_o),    .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o),  
        .aluop_i(mem_aluop_i),
        .mem_addr_i(mem_mem_addr_i),
        .reg2_i(mem_reg2_i),
        .mem_data_i(ram_data_i),    .mem_addr_o(ram_addr_o),
        .mem_we_o(ram_we_o),    .mem_sel_o(ram_sel_o),
        .mem_data_o(ram_data_o),    .mem_ce_o(ram_ce_o)
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

