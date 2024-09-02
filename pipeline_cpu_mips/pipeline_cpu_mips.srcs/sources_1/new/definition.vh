/*************************************************
******************** Macro Definitions ***********
**************************************************/

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

`define EXE_NOP 6'b000000
`define SSNOP 32'b00000000000000000000000001000000

`define EXE_SPECIAL_INST 6'b000000
`define EXE_REGIMM_INST 6'b000001
`define EXE_SPECIAL2_INST 6'b011100 


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

`define EXE_NOP_OP    8'b00000000

//  ALuSel, sub op kind
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010

`define EXE_RES_NOP 3'b000


// regs
`define RegAddrWidth 5 // 32个寄存器, 5位地址
`define RegBusWidth 32 // Reg bus width, 32-bit
`define RegNum  32 // 32个Register
`define RegNumLog2 5 // log_2(32)=5,log_2(RegNum)
`define NOPRegAddr 5'b00000
