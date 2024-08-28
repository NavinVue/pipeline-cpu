// 定义各种指令的op部分, ref:https://elearning.ecnu.edu.cn/bbcswebdav/courses/COMS0031131014.02.2017-20182/MIPS%E6%8C%87%E4%BB%A4%E9%9B%86.pdf
// R type, op(6) rs(5) rt(5) rd(5) shamt(5) func(6)
`define ADD_OP     6b'000000
`define ADDU_OP    6b'000000
`define SUB_OP     6b'000000
`define SUBU_OP    6b'000000
`define AND_OP     6b'000000
`define OR_OP      6b'000000
`define XOR_OP     6b'000000
`define NOR_OP     6b'000000
`define SLT_OP     6b'000000
`define SLTU_OP    6b'000000
`define SLL_OP     6b'000000
`define SRL_OP     6b'000000
`define SRA_OP     6b'000000
`define SLLV_OP    6b'000000
`define SRLV_OP    6b'000000
`define SRAV_OP    6b'000000
`define JR_OP      6b'001000 // instruct format: 001000 rs 00000 00000 00000 000000
// I type, op(6) rs(5) rt(5) immediate(16)
`define ADDI_OP    6b'001000
`define ADDIU_OP   6b'001001
`define ANDI_OP    6b'001100
`define ORI_OP     6b'001101
`define XORI_OP    6b'001110
// `define LUI_OP     6b'001111 // instruct format: 001111 00000 rt imm
`define LW_OP      6b'100011
`define SW_OP      6b'101011
`define BEQ_OP     6b'000100
`define BNE_OP     6b'000101
`define SLTI_OP    6b'001010
`define SLTIU_OP   6b'001011
// J type, op(6) address(26)
`define J_OP       6b'000010
`define JAL_OP     6b'000011

//RESET
`define RESET 1'b1

// other defination (like datawidth, control signal and so on), todo 
