// ****�������ָ���op����, ref:https://elearning.ecnu.edu.cn/bbcswebdav/courses/COMS0031131014.02.2017-20182/MIPS%E6%8C%87%E4%BB%A4%E9%9B%86.pdf*********
// R type, op(6) rs(5) rt(5) rd(5) shamt(5) func(6)
`define ADD_OP     6'b000000
`define ADDU_OP    6'b000000
`define SUB_OP     6'b000000
`define SUBU_OP    6'b000000
`define AND_OP     6'b000000
`define OR_OP      6'b000000
`define XOR_OP     6'b000000
`define NOR_OP     6'b000000
`define SLT_OP     6'b000000
`define SLTU_OP    6'b000000
`define SLL_OP     6'b000000
`define SRL_OP     6'b000000
`define SRA_OP     6'b000000
`define SLLV_OP    6'b000000
`define SRLV_OP    6'b000000
`define SRAV_OP    6'b000000
`define JR_OP      6'b001000 // instruct format: 001000 rs 00000 00000 00000 000000
// I type, op(6) rs(5) rt(5) immediate(16)
`define ADDI_OP    6'b001000
`define ADDIU_OP   6'b001001
`define ANDI_OP    6'b001100
`define ORI_OP     6'b001101
`define XORI_OP    6'b001110
// `define LUI_OP     6'b001111 // instruct format: 001111 00000 rt imm
`define LW_OP      6'b100011
`define SW_OP      6'b101011
`define BEQ_OP     6'b000100
`define BNE_OP     6'b000101
`define SLTI_OP    6'b001010
`define SLTIU_OP   6'b001011
// J type, op(6) address(26)
`define J_OP       6'b000010
`define JAL_OP     6'b000011

//*********global definition ****************
`define RstEnable 1'b1  //��λ�ź���Ч
`define RstDisable 1'b0 //��λ�ź���Ч
`define WriteEnable 1'b1 //ʹ��д
`define WriteDisable 1'b0 //��ֹд
`define ReadEnable  1'b1   //ʹ�ܶ�
`define ReadDisable 1'b0    //��ֹ��
`define True_v  1'b1    //�߼����桱
`define False_v 1'b0    //�߼����١�
`define InstValid 1'b0 // ָ����Ч
`define InstInvalid 1'b1 //ָ����Ч
`define ChipEnable 1'b1 // оƬʹ��
`define ChipDisable 1'b0 // оƬ��ֹ




`define AddrWidth 32  //��ַ��λ���������ƣ�
`define InstWidth 32   //MIPSָ��λ���������ƣ�
`define ZeroWord         32'h00000000 //32λ����ֵ0

//`define PCWidth 32  
//`define 
`define AluOpBusWidth 8 // ����׶ε����aluop_o�Ŀ��
`define AluSelBusWidth 3    //����׶ε����alusel_o�Ŀ��    


/*******  define about specific inst *************/
`define EXE_ORI 6'b001101 // inst code of inst ori
`define EXE_NOP 6'b000000 //

// AluOp
`define EXE_OR_OP   8'b00100101
`define EXE_NOP_OP  8'b00000000

// AluSel
`define EXE_RES_LOGIC   3'b001

`define EXE_RES_NOP 3'b000

/**************** define about inst store ROM  ********************/
`define InstAddrWidth 32 // ָ���ַλ���������ƣ�
`define InstBusWidth 32 // ָ�����߿�� 32 bit
`define InstMemNum  131071 // ROM size 128KB
`define InstMemNumLog2  17 // log2(InstMemNum)

/****************** defone about regs ***************/
`define RegAddrWidth 5 // 32���Ĵ���, 5λ��ַ
`define RegBusWidth 32 // Reg bus width, 32-bit
`define RegNum  32 // 32��Register
`define RegNumLog2 5 // log_2(32)=5,log_2(RegNum)
`define NOPRegAddr 5'b00000
//`define 
// other defination (like datawidth, control signal and so on), todo 
