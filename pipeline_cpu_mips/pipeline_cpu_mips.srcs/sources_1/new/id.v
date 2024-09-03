`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  

module id(
        input   wire    rst,
        input   wire[`InstAddrWidth - 1 :0] pc_i, // pc from if_id
        input   wire[`InstBusWidth - 1 :0]  inst_i, // inst from if_id
        
        // read data from regfile(regs)
        input   wire[`RegBusWidth - 1 :0]   reg1_data_i, // read reg 1
        input   wire[`RegBusWidth - 1 :0]   reg2_data_i, // read reg 2
        
        // results from ex-stage, data forward
        // data hazard
        input   wire    ex_wreg_i,
        input   wire[`RegBusWidth - 1:0]    ex_wdata_i,
        input   wire[`RegAddrWidth - 1:0]   ex_wd_i,

        // results from mem-stage, data forward
        // data hazard
        input   wire    mem_wreg_i,
        input   wire[`RegBusWidth - 1:0]    mem_wdata_i,
        input   wire[`RegAddrWidth - 1:0]   mem_wd_i,

        input   wire    is_in_delayslot_i,

        // load store
        input   wire[`AluOpBusWidth - 1:0]  ex_aluop_i,  

        output  reg next_inst_in_delayslot_o,
        output  reg branch_flag_o,
        output  reg[`RegBusWidth - 1 :0]    branch_target_address_o,
        output  reg[`RegBusWidth - 1 :0]    link_addr_o, // the address will be written into reg
        output  reg is_in_delayslot_o,

        // output to regfile (include enable sign, regaddr)
        output  reg reg1_read_o, // reg1 read enable
        output  reg reg2_read_o, // reg2 read enable
        output  reg[`RegAddrWidth - 1 :0]   reg1_addr_o, // reg1 addr
        output  reg[`RegAddrWidth - 1 :0]   reg2_addr_o, // reg2 addr
        
        // infos to  EX-stage
        output  reg[`AluOpBusWidth - 1 :0]  aluop_o, // Decoder inst stage 
        output  reg[`AluSelBusWidth - 1 :0] alusel_o, // decoder inst stage 
        output  reg[`RegBusWidth - 1 :0]    reg1_o, // decoder inst stage 
        output  reg[`RegBusWidth - 1 :0]    reg2_o, // decoder inst stage 
        output  reg[`RegAddrWidth - 1 :0]   wd_o, // addr of reg which will be written in decoder inst stage 
        output  reg wreg_o, // will reg be written in decoder inst stage
        output  wire stall_from_id_o, // stall request from id

        // inst_o, transfer inst
        output  wire[`RegBusWidth - 1 :0]   inst_o
    );
    // get func op
    wire[5:0] op = inst_i[31:26];   // inst code
    wire[4:0] op2 = inst_i[10:6];
    wire[5:0] op3 = inst_i[5:0];    // func code
    wire[4:0] op4 = inst_i[20:16];
    
    wire[`RegBusWidth - 1 :0]   pc_plus_8;    //  pc + 8
    wire[`RegBusWidth - 1 :0]   pc_plus_4;    //  pc + 4

    wire[`RegBusWidth - 1 :0]   imm_sll2_signedext; // get addr according to offset

    // save imm that ex-inst will use
    reg[`RegBusWidth - 1 :0] imm;
    
    // weather inst valid
    reg instvalid;
    
    reg stallreq_for_reg1_loadrelate;   // if reg1 has load relate
    reg stallreq_for_reg2_loadrelate;   //  if reg2 has load relate
    wire pre_inst_is_load; // if last inst is load inst?
    
    assign  stall_from_id_o = `NotStop;
    // pass inst
    assign  inst_o  = inst_i;
    assign  pre_inst_is_load = (ex_aluop_i == `EXE_LW_OP) ? 1'b1 : 1'b0;
    assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
    assign  imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
    assign  pc_plus_4 = pc_i + 4;
    assign  pc_plus_8 = pc_i + 8;

/*******************
    1. decode inst
********************/
    always @ (*) begin
        
        if (rst == `RstEnable) begin
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
            wd_o    <= `NOPRegAddr;
            wreg_o <=  `WriteDisable;
            instvalid <= `InstValid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            imm <=32'h0;
            link_addr_o <=  `ZeroWord;
            branch_target_address_o <=  `ZeroWord;
            branch_flag_o   <=  `NotBranch;
            next_inst_in_delayslot_o    <=  `NotInDelaySlot;
        end else begin
            aluop_o <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o    <=  inst_i[15:11];
            wreg_o  <= `WriteDisable;
            instvalid   <=  `InstInvalid;
            reg1_read_o <=  1'b0;
            reg2_read_o <=  1'b0;
            reg1_addr_o <= inst_i[25:21];   // default ref2_addr_o (addr)
            reg2_addr_o <= inst_i[20:16];   // default reg2_addr_o (addr)
            imm <= `ZeroWord;
            link_addr_o <=  `ZeroWord;
            branch_target_address_o <=  `ZeroWord;
            branch_flag_o   <=  `NotBranch;
            next_inst_in_delayslot_o    <=  `NotInDelaySlot;
            case (op)
                `EXE_SPECIAL_INST: begin // inst code is special, ref: ���Լ�����дCPU�� screen-shot https://navinvue.oss-cn-beijing.aliyuncs.com/202409021322157.png
                    case (op2)
                        5'b00000:   begin
                            case(op3)
                                `EXE_OR:   begin // inst or
                                    wreg_o  <= `WriteEnable;
                                    aluop_o <=  `EXE_OR_OP;
                                    alusel_o    <=  `EXE_RES_LOGIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_AND:   begin   // inst and
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_AND_OP;
                                    alusel_o    <=  `EXE_RES_LOGIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_XOR:   begin   // inst xor
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_XOR_OP;
                                    alusel_o    <=  `EXE_RES_LOGIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_NOR:   begin   // inst nor
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_NOR_OP;
                                    alusel_o    <=  `EXE_RES_LOGIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_SLLV:  begin   // inst sllv
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_SLL_OP;
                                    alusel_o    <=  `EXE_RES_SHIFT;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_SRLV:  begin   // inst srlv
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_SRL_OP;
                                    alusel_o    <=  `EXE_RES_SHIFT;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_SRAV:  begin   // inst srav(arithmetic shift)
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_SRA_OP;
                                    alusel_o    <=  `EXE_RES_SHIFT;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_SYNC:  begin   // inst sync
                                    wreg_o  <=  `WriteDisable;
                                    aluop_o <=  `EXE_NOP_OP;
                                    alusel_o    <=  `EXE_RES_NOP;
                                    reg1_read_o <=  1'b0;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_MOVN:  begin   // movn
                                    aluop_o <=  `EXE_MOVN_OP;
                                    alusel_o    <=  `EXE_RES_MOVE;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                    if (reg2_o  != `ZeroWord) begin
                                        wreg_o  <=  `WriteEnable;
                                    end else begin
                                        wreg_o  <=  `WriteDisable;
                                    end
                                end
                                `EXE_MOVZ:  begin   // movz
                                    aluop_o <=  `EXE_MOVZ_OP;
                                    alusel_o    <=  `EXE_RES_MOVE;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    if(reg2_o == `ZeroWord) begin
                                        wreg_o  <=  `WriteEnable;
                                    end  else begin
                                        wreg_o  <=  `WriteDisable;
                                    end
                                end
                                `EXE_SLT: begin
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_SLT_OP;
                                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_SLTU:  begin
                                    wreg_o  <= `WriteEnable;
                                    aluop_o <=  `EXE_SLTU_OP;
                                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_ADD:   begin
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_ADD_OP;
                                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_ADDU:  begin
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_ADDU_OP;
                                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_SUB:   begin
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_SUB_OP;
                                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_SUBU:  begin
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_SUBU_OP;
                                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b1;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_JR:    begin
                                    wreg_o  <=  `WriteDisable;
                                    aluop_o <=  `EXE_JR_OP;
                                    alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b0;
                                    link_addr_o <=  `ZeroWord;
                                    branch_target_address_o <=  reg1_o;
                                    branch_flag_o   <=  `Branch;
                                    next_inst_in_delayslot_o    <=  `InDelaySlot;
                                    instvalid   <=  `InstValid;
                                end
                                `EXE_JALR:  begin
                                    wreg_o  <=  `WriteEnable;
                                    aluop_o <=  `EXE_JALR_OP;
                                    alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                                    reg1_read_o <=  1'b1;
                                    reg2_read_o <=  1'b0;
                                    wd_o    <=  inst_i[15:11];
                                    link_addr_o <=  pc_plus_8;
                                    branch_target_address_o <=  reg1_o;
                                    branch_flag_o   <=  `Branch;
                                    next_inst_in_delayslot_o    <=  `InDelaySlot;
                                    instvalid   <=  `InstValid;
                                end
                                default:    begin
                                end
                            endcase
                        end
                    default: begin
                        end
                    endcase
                end
                `EXE_ORI:   begin   // ori inst
                    wreg_o  <=  `WriteEnable;
                    // op is 'or'
                    aluop_o <=  `EXE_OR_OP;
                    // sub op is logic
                    alusel_o    <=  `EXE_RES_LOGIC;
                    // need read reg port 1
                    reg1_read_o <=  1'b1;
                    // don't need reg port 2
                    reg2_read_o <=  1'b0;
                    // imm
                    imm <= {16'h0, inst_i[15:0]};
                    
                    // write reg addr
                    wd_o    <=  inst_i[20:16];
                    
                    // valid inst
                    instvalid   <=  `InstValid;
                end
                `EXE_ANDI: begin    // andi inst
                    wreg_o  <= `WriteEnable;
                    aluop_o <=  `EXE_AND_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm <=  {16'h0, inst_i[15:0]};
                    wd_o    <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_XORI:  begin   // xori inst
                    wreg_o  <=  `WriteEnable;
                    aluop_o <=  `EXE_XOR_OP;
                    alusel_o    <=  `EXE_RES_LOGIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm <=  {16'h0, inst_i[15:0]};
                    wd_o    <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_LUI:   begin   // lui inst, {imm,16'h0}
                        wreg_o  <=  `WriteEnable;
                        // reg1_o  <=  `WriteEnable;
                        aluop_o <=  `EXE_OR_OP;
                        alusel_o    <=  `EXE_RES_LOGIC;
                        reg1_read_o <=  1'b1;   //  reg is $0
                        reg2_read_o <=  1'b0;
                        imm <=  {inst_i[15:0], 16'h0};
                        wd_o    <=  inst_i[20:16];
                        instvalid   <=  `InstValid;
                    // if(inst_i[25:21]==5'b00000) begin
                    //     reg1_o  <=  `WriteEnable;
                    //     aluop_o <=  `EXE_OR_OP;
                    //     alusel_o    <=  `EXE_RES_LOGIC;
                    //     reg1_read_o <=  1'b1;   //  reg is $0
                    //     reg2_read_o <=  1'b0;
                    //     imm <=  {inst_i[15:0], 16'h0};
                    //     wd_o    <=  inst_i[20:16];
                    //     instvalid   <=  `InstValid;
                    // end else begin
                    //     // not valid func
                    // end
                end
                `EXE_ADDI:  begin   // addi
                    wreg_o  <=  `WriteEnable;
                    aluop_o <=  `EXE_ADDI_OP;
                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm <= {{16{inst_i[15]}}, inst_i[15:0]}; // sign extend
                    wd_o    <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_ADDIU: begin
                    wreg_o  <=  `WriteEnable;
                    aluop_o <=  `EXE_ADDIU_OP;
                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                    wd_o    <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_J: begin
                    wreg_o  <=  `WriteDisable;
                    aluop_o <=  `EXE_J_OP;
                    alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                    reg1_read_o <=  1'b0;
                    reg2_read_o <=  1'b0;
                    link_addr_o <=  `ZeroWord;
                    branch_flag_o   <=  `Branch;
                    next_inst_in_delayslot_o    <=  `InDelaySlot;
                    instvalid   <=  `InstValid;
                    branch_target_address_o <=  {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                end
                `EXE_JAL:begin
                    wreg_o  <=  `WriteEnable;
                    aluop_o <=  `EXE_JAL_OP;
                    alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                    reg1_read_o <=  1'b0;
                    reg2_read_o <=  1'b0;
                    wd_o    <=  5'b11111;   // $31 reg
                    link_addr_o <=  pc_plus_4; // fix bug
                    branch_flag_o   <=  `Branch;
                    next_inst_in_delayslot_o    <=  `InDelaySlot;
                    instvalid   <=  `InstValid;
                    branch_target_address_o <=  {pc_plus_4[31:28], inst_i[25:0],2'b00};
                end
                `EXE_BEQ:   begin
                    wreg_o  <=  `WriteDisable;
                    aluop_o <=  `EXE_BEQ_OP;
                    alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b1;
                    instvalid   <=  `InstValid;
                    if(reg1_o == reg2_o) begin
                        branch_target_address_o <=  pc_plus_4+imm_sll2_signedext;
                        branch_flag_o   <=  `Branch;
                        next_inst_in_delayslot_o    <=  `InDelaySlot;
                    end
                end
                `EXE_BGTZ:  begin
                    wreg_o  <=  `WriteDisable;
                    aluop_o <=  `EXE_BGTZ_OP;
                    alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    instvalid   <=  `InstValid;
                    if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord)) begin
                        branch_target_address_o <=  pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o   <=  `Branch;
                        next_inst_in_delayslot_o    <=  `InDelaySlot;
                    end
                end
                `EXE_BLEZ:  begin
                    wreg_o  <=  `WriteDisable;
                    aluop_o <=  `EXE_BLEZ_OP;
                    alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0 ;
                    instvalid   <=  `InstValid;
                    if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord))   begin
                        branch_target_address_o <=  pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o   <=  `Branch;
                        next_inst_in_delayslot_o    <=  `InDelaySlot;
                    end 
                end
                `EXE_BNE:   begin
                    wreg_o  <=  `WriteDisable;
                    aluop_o <=  `EXE_BLEZ_OP;
                    alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b1;
                    instvalid   <=  `InstValid;
                    if(reg1_o   !=  reg2_o) begin
                        branch_target_address_o <=  pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o   <=  `Branch;
                        next_inst_in_delayslot_o    <=  `InDelaySlot;
                    end
                end
                `EXE_LW:    begin
                    wreg_o  <=  `WriteEnable;
                    aluop_o <=  `EXE_LW_OP;
                    alusel_o    <=  `EXE_RES_LOAD_STORE;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    wd_o    <=  inst_i[20:16];
                    instvalid   <=  `InstValid;
                end
                `EXE_SW:    begin
                    wreg_o  <=  `WriteDisable;
                    aluop_o <=  `EXE_SW_OP;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b1;
                    instvalid   <=  `InstValid;
                    alusel_o    <=  `EXE_RES_LOAD_STORE;
                end
                `EXE_SLTI:  begin
                    wreg_o  <=  `WriteEnable;
                    aluop_o <=  `EXE_SLT_OP;
                    alusel_o    <=  `EXE_RES_ARITHMETIC;
                    reg1_read_o <=  1'b1;
                    reg2_read_o <=  1'b0;
                    imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                    wd_o <= inst_i[20:16];
                    instvalid <= `InstValid;
                end
                `EXE_SLTIU: begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `EXE_SLTU_OP;
                    alusel_o <= `EXE_RES_ARITHMETIC; 
                    reg1_read_o <= 1'b1;	
                    reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                    wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
                end
                `EXE_SPECIAL2_INST: begin
                    case (op3)
                        `EXE_CLZ: begin
                            wreg_o  <=  `WriteEnable;
                            aluop_o <=   `EXE_CLZ_OP;
                            alusel_o    <=  `EXE_RES_ARITHMETIC;
                            reg1_read_o <=  1'b1;
                            reg2_read_o <=  1'b0;
                            instvalid   <=  `InstValid;
                        end
                        `EXE_CLO: begin
                            wreg_o  <=  `WriteEnable;
                            aluop_o <=  `EXE_CLO_OP;
                            alusel_o    <=  `EXE_RES_ARITHMETIC;
                            reg1_read_o <=  1'b1;
                            reg2_read_o <=  1'b0;
                            instvalid   <= `InstValid;

                        end
                        `EXE_MUL:   begin
                            wreg_o  <=  `WriteEnable;
                            aluop_o <=  `EXE_MUL_OP;
                            alusel_o    <=  `EXE_RES_MUL;
                            reg1_read_o <=  1'b1;
                            reg2_read_o <=  1'b1;
                            instvalid   <=  `InstValid;
                        end

                    endcase
                end
                `EXE_REGIMM_INST:   begin       
                    case(op4)
                        `EXE_BGEZ:  begin
                            wreg_o  <=  `WriteDisable;
                            aluop_o <=  `EXE_BGEZ_OP;
                            alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                            reg1_read_o <=  1'b1;
                            reg2_read_o <=  1'b0;
                            instvalid   <=  `InstValid;
                            if(reg1_o[31]   ==  1'b0)   begin
                                branch_target_address_o <=  pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o   <=  `Branch;
                                next_inst_in_delayslot_o    <=  `InDelaySlot;
                            end
                        end
                        `EXE_BGEZAL:    begin
                            wreg_o  <=  `WriteEnable;
                            aluop_o <=  `EXE_BGEZAL_OP;
                            alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                            reg1_read_o <=  1'b1;
                            reg2_read_o <=  1'b0;
                            link_addr_o <=  pc_plus_8;
                            wd_o    <=  5'b11111; // $31 reg
                            instvalid   <=  `InstValid;
                            if(reg1_o[31] == 1'b0)  begin
                                branch_target_address_o <=  pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o   <=  `Branch;
                                next_inst_in_delayslot_o    <=  `InDelaySlot;
                            end
                        end
                        `EXE_BLTZ:  begin
                            wreg_o  <=  `WriteDisable;
                            aluop_o <=  `EXE_BGEZAL_OP;
                            alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                            reg1_read_o <=  1'b1;
                            reg2_read_o <=  1'b0;
                            instvalid   <=  `InstValid;
                            if(reg1_o[31] == 1'b1)  begin
                                branch_target_address_o <=  pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o   <=  `Branch;
                                next_inst_in_delayslot_o    <=  `InDelaySlot;
                            end
                        end
                        `EXE_BLTZAL:    begin
                            wreg_o  <=  `WriteEnable;
                            aluop_o <=  `EXE_BGEZAL_OP;
                            alusel_o    <=  `EXE_RES_JUMP_BRANCH;
                            reg1_read_o <=  1'b1;
                            reg2_read_o <=  1'b0;
                            link_addr_o <=  pc_plus_8;
                            wd_o    <=  5'b11111;
                            instvalid   <=  `InstValid;
                            if(reg1_o[31] == 1'b1)  begin
                                branch_target_address_o <=  pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o   <=  `Branch;
                                next_inst_in_delayslot_o    <=  `InDelaySlot;
                            end
                        end
                        default:    begin
                            
                        end
                    endcase
                end
                default:begin
                end
            endcase // case op
        
        if(inst_i[31:21] == 11'b00000000000) begin
            if(op3 == `EXE_SLL) begin   //  sll
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_SLL_OP;
                alusel_o    <=  `EXE_RES_SHIFT;
                reg1_read_o <=  1'b0;
                reg2_read_o <=  1'b1;
                imm[4:0]    <=  inst_i[10:6]; // sa
                wd_o    <=  inst_i[15:11];
                instvalid   <=  `InstValid;
            end else if (op3 == `EXE_SRL)   begin   // srl
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_SRL_OP;
                alusel_o    <=  `EXE_RES_SHIFT;
                reg1_read_o <=  1'b0;
                reg2_read_o <=  1'b1;
                imm[4:0]    <=  inst_i[10:6];
                wd_o    <=  inst_i[15:11];
                instvalid   <=  `InstValid;
            end else if(op3 == `EXE_SRA) begin  // sra
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_SRA_OP;
                alusel_o    <=  `EXE_RES_SHIFT;
                reg1_read_o <=  1'b0;
                reg2_read_o <=  1'b1;
                imm[4:0]    <=  inst_i[10:6];
                wd_o    <=  inst_i[15:11];
                instvalid   <=  `InstValid;
            end 
        end
    end // if
end // always
    
/************************
******   2.  get source number 1     ********
***********************/
// 1. the reg that port 1 will read is the reg ex-stage will write
// make: reg1_o=ex_wdata_i
// 2. the reg that port 1 will read is the reg mem-stage will write,
// make: reg1_o=ex_wdata_i

    always @ (*) begin
        stallreq_for_reg1_loadrelate    <=  `NotStop;
        if(rst == `RstEnable) begin
            reg1_o  <= `ZeroWord;
        end else if((pre_inst_is_load == 1'b1) && (ex_wd_i == reg1_addr_o) && (reg1_read_o == 1'b1))    begin
            stallreq_for_reg1_loadrelate    <=  `Stop;
        end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o  <= ex_wdata_i;
        end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
            reg1_o  <= mem_wdata_i;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o  <= reg1_data_i; // get data form regs port 1
        end else if (reg1_read_o == 1'b0) begin
            reg1_o  <= imm;
        end else begin
            reg1_o  <= `ZeroWord;
        end
    end
    
/**************************
****** 3. get source number 2 *************
****************************/
// same as source number 1
// case 1: ex
// case 2: mem
    always @ (*) begin
        stallreq_for_reg2_loadrelate    <=  `NotStop;
        if (rst == `RstEnable) begin
            reg2_o  <= `ZeroWord;
        end else if((pre_inst_is_load == 1'b1) && (ex_wd_i == reg2_addr_o) && (reg2_read_o == 1'b1))    begin
            stallreq_for_reg2_loadrelate    <=  `Stop;
        end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
            reg2_o  <= ex_wdata_i;
        end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
            reg2_o  <= mem_wdata_i;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o  <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o  <= imm;
        end else begin
            reg2_o  <=  `ZeroWord;
        end
    end

    //output  is in delayslot o
    always @(*) begin
        if(rst == `RstEnable)   begin
            is_in_delayslot_o   <=  `NotInDelaySlot;
        end else begin
            is_in_delayslot_o   <=  is_in_delayslot_i;    
        end
    end
endmodule
