`timescale 1ns / 1ps
`include "instruction_define.vh"
// module name: 
// comment: 
// input:
// output:
// author:  


module id(
        input wire RST,
        input wire[`InstAddrWidth - 1 :0] pc_i, // pc from if_id
        input wire[`InstBusWidth - 1 :0] inst_i, // inst from if_id
        
        // read data from regfile(regs)
        input wire[`RegBusWidth - 1 :0] reg1_data_i, // read reg 1
        input wire[`RegBusWidth - 1 :0] reg2_data_i, // read reg 2
        
        // output to regfile (include enable sign, regaddr)
        output reg  reg1_read_o, // reg1 read enable
        output reg  reg2_read_o, // reg2 read enable
        output reg[`RegAddrWidth - 1 :0] reg1_addr_o, // reg1 addr
        output reg[`RegAddrWidth - 1 :0] reg2_addr_o, // reg2 addr
        
        // infos to  EX-stage
        output reg[`AluOpBusWidth - 1 :0]   aluop_o, // Decoder inst stage 要进行的运算的类型
        output reg[`AluSelBusWidth - 1 :0]  alusel_o, // decoder inst stage 要进行的运算的子类型
        output reg[`RegBusWidth - 1 :0] reg1_o, // decoder inst stage 要进行的运算的源操作数1
        output reg[`RegBusWidth - 1 :0] reg2_o, // decoder inst stage 要进行的运算的源操作数2
        output reg[`RegAddrWidth - 1 :0] wd_o, // addr of reg which will be written in decoder inst stage 
        output reg  wreg_o // will reg be written in decoder inst stage
    );
    // get func op
    wire[5:0] op = inst_i[31:26];
    wire[4:0] op2 = inst_i[10:6];
    wire[5:0] op3 = inst_i[5:0];
    wire[4:0] op4 = inst_i[20:16];
    
    // save imm that ex-inst will use
    reg[`RegBusWidth - 1 :0] imm;
    
    // weather inst valid
    reg instvalid;
    
/*******************
    1. decode inst
********************/
    always @ (*) begin
        if (RST == `RstEnable) begin
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
        end else begin
            aluop_o <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o    <=  inst_i[15:11];
            wreg_o  <= `WriteDisable;
            instvalid   <=  `InstInvalid;
            reg1_read_o <=  1'b0;
            reg2_read_o <=  1'b0;
            reg1_addr_o <= inst_i[25:21];   // 默认通过regfile读端口1读取的寄存器地址
            reg2_addr_o <= inst_i[20:16];   // 默认通过regfile读端口2读取的寄存器地址
            imm <= `ZeroWord;
            
            case (op)
                `EXE_ORI:   begin   // 根据op判断是否为ori
                wreg_o  <=  `WriteEnable;
                
                // sub alu is 'or'
                alusel_o    <=  `EXE_RES_LOGIC;
                
                // need read reg port 1
                reg1_read_o <=  1'b1;
                
                // don't need reg port 2
                reg2_read_o <= 1'b0;
                
                // imm
                imm <= {16'h0, inst_i[15:0]};
                
                // write reg addr
                wd_o    <=  inst_i[20:16];
                
                // valid inst
                instvalid   <=  `InstValid;
            end
            default:begin
            end
        endcase // case op
    end // if
end // always
    
/************************
******   2.  get source number 1     ********
***********************/
    always @ (*) begin
        if(RST == `RstEnable) begin
            reg1_o  <= `ZeroWord;
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
    always @ (*) begin
        if (RST == `RstEnable) begin
            reg2_o  <= `ZeroWord;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o  <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o  <= imm;
        end else begin
            reg2_o  <=  `ZeroWord;
        end
    end

endmodule
