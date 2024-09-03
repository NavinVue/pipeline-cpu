/*************************************************
******************** Macro Definitions ***********
**************************************************/
// coding: gbk

// addr, inst
`define InstAddrWidth 32 // 指令地址位数（二进制）
`define InstBusWidth 32 // 指令总线宽度 32 bit
`define InstMemNum  131071 // ROM size 128KB
`define InstMemNumLog2  17 // log2(InstMemNum)

// all kinds of enable and disable
`define RstEnable   1'b1    // rst sign is able
`define RstDisable  1'b0    // rst sign is disable
`define WriteEnable 1'b1    // write is able
`define WriteDisable    1'b0    // write is disable
`define ReadEnable  1'b1    // read is able
`define ReadDisable 1'b0    // read is disable
`define InstValid   1'b1    // inst is valid
`define InstInvalid 1'b0    // inst is invalid
`define ChipEnable  1'b1    // chip is able
`define ChipDisable 1'b0    // chip is forbidden
`define Stop    1'b1    // stop sign
`define NotStop 1'b0    // not stop sign
`define Branch  1'b1    // is branch
`define NotBranch   1'b0    // is not branch  
`define InDelaySlot 1'b1    // in delay slot 
`define NotInDelaySlot  1'b0    // not in delay slot

// num
`define ZeroWord    32'h00000000    // 32-bit zero

// aluop and subop width
`define AluOpBusWidth   8   // op kind, such as or
`define AluSelBusWidth  3   // sub op kind such as logic

// inst code
`define EXE_AND  6'b100100  // special+exe_and
`define EXE_OR   6'b100101  // special+exe_or
`define EXE_XOR 6'b100110   // special+exe_xor
`define EXE_NOR 6'b100111   // special+exe_nor
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111

`define EXE_SLL  6'b000000
`define EXE_SLLV  6'b000100
`define EXE_SRL  6'b000010
`define EXE_SRLV  6'b000110
`define EXE_SRA  6'b000011
`define EXE_SRAV  6'b000111
`define EXE_SYNC  6'b001111
`define EXE_PREF  6'b110011

// arithmetic operation
`define EXE_SLT  6'b101010
`define EXE_SLTU  6'b101011
`define EXE_SLTI  6'b001010
`define EXE_SLTIU  6'b001011   
`define EXE_ADD  6'b100000
`define EXE_ADDU  6'b100001
`define EXE_SUB  6'b100010
`define EXE_SUBU  6'b100011
`define EXE_ADDI  6'b001000
`define EXE_ADDIU  6'b001001
`define EXE_CLZ  6'b100000
`define EXE_CLO  6'b100001

// mov
`define EXE_MOVZ    6'b001010
`define EXE_MOVN    6'b001011

`define EXE_NOP 6'b000000
`define SSNOP 32'b00000000000000000000000001000000

`define EXE_SPECIAL_INST 6'b000000
`define EXE_REGIMM_INST 6'b000001
`define EXE_SPECIAL2_INST 6'b011100 

`define EXE_MUL  6'b000010

`define EXE_J  6'b000010
`define EXE_JAL  6'b000011
`define EXE_JALR  6'b001001
`define EXE_JR  6'b001000
`define EXE_BEQ  6'b000100
`define EXE_BGEZ  5'b00001
`define EXE_BGEZAL  5'b10001
`define EXE_BGTZ  6'b000111
`define EXE_BLEZ  6'b000110
`define EXE_BLTZ  5'b00000
`define EXE_BLTZAL  5'b10000
`define EXE_BNE  6'b000101

// lw and sw
`define EXE_SW  6'b101011
`define EXE_LW  6'b100011


//  AluOp, op kind
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   

`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111

// arithmetic
`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP  8'b01011000   
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110
`define EXE_CLZ_OP  8'b10110000
`define EXE_CLO_OP  8'b10110001

`define EXE_MUL_OP  8'b10101001

`define EXE_NOP_OP    8'b00000000

// mov 
`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011

// j and b
`define EXE_J_OP  8'b01001111
`define EXE_JAL_OP  8'b01010000
`define EXE_JALR_OP  8'b00001001
`define EXE_JR_OP  8'b00001000
`define EXE_BEQ_OP  8'b01010001
`define EXE_BGEZ_OP  8'b01000001
`define EXE_BGEZAL_OP  8'b01001011
`define EXE_BGTZ_OP  8'b01010100
`define EXE_BLEZ_OP  8'b01010011
`define EXE_BLTZ_OP  8'b01000000
`define EXE_BLTZAL_OP  8'b01001010
`define EXE_BNE_OP  8'b01010010

// lw, sw
`define EXE_SW_OP  8'b11101011
`define EXE_LW_OP  8'b11100011

//  ALuSel, sub op kind
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_MOVE 3'b011
`define EXE_RES_ARITHMETIC 3'b100	
`define EXE_RES_NOP 3'b000
`define EXE_RES_MUL 3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE 3'b111	


// regs
`define RegAddrWidth 5 // 32个寄存器, 5位地址
`define RegBusWidth 32 // Reg bus width, 32-bit
`define DoubleRegBusWidth   64  // double regbuswidth, specially for mul op
`define RegNum  32 // 32个Register
`define RegNumLog2 5 // log_2(32)=5,log_2(RegNum)
`define NOPRegAddr 5'b00000

// data_ram
`define DataAddrBusWidth 32
`define DataBusWidth 32
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 8