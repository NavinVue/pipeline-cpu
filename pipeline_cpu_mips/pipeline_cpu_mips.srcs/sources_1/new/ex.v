`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  

module ex(
        input   rst,

        // infos from decoder inst to ex-stage
        input   wire[`AluOpBusWidth - 1 :0] aluop_i,    // alu op
        input   wire[`AluSelBusWidth - 1 :0] alusel_i,  // alu sel (sub op)
        input   wire[`RegBusWidth - 1 :0] reg1_i,   //  source number 1
        input   wire[`RegBusWidth - 1 :0] reg2_i,   //  source number 2
        input   wire[`RegAddrWidth - 1 :0] wd_i, // addr of dest reg
        input   wire    wreg_i, // write enable

        // ex results
        output  reg[`RegAddrWidth - 1 :0]   wd_o, // final dest w_reg addr
        output  reg wreg_o, // write enable
        output  reg[`RegBusWidth - 1 :0]   wdata_o // result to write 
        
        
    );
    // save logic calcu results
        reg[`RegBusWidth - 1 :0]    logicout; // result of logic compute
        reg[`RegBusWidth - 1 :0]    shiftres; // result of shift compute 
        reg[`RegBusWidth - 1 :0]    moveres;     // results of move
        reg[`RegBusWidth - 1 :0]    arithmeticres; // arithmetic result
        reg[`DoubleRegBusWidth - 1 :0] mulres; // result of mul op, 64-bit
    // vars, arithmetic operation will use
        wire    reg1_eq_reg2;   // num1 == num2 ?
        wire    reg1_lt_reg2;   // num1 < num2 ?
        wire[`RegBusWidth - 1 :0]   reg2_i_mux; // complement code of source num 2
        wire[`RegBusWidth - 1 :0]   reg1_i_not; // inverted value of source num 1
        wire[`RegBusWidth - 1 :0]   result_sum; // add result
        wire[`RegBusWidth - 1 :0]   opdata1_mult;   // multiplicand num
        wire[`RegBusWidth - 1 :0]   opdata2_mult;   // multiplier
        wire[`DoubleRegBusWidth - 1:0]  temp_mulres; // temp result of mul op

    // overflow
        wire    overflow;   // record overflow 

/*********************************************************************************
****************  prepare for arithmetic op, compute some num ********************
**********************************************************************************/
    // get complemented code of number 2, according to its aluop
    // for sub op, compare (signed num)
        assign  reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || 
            (aluop_i == `EXE_SUBU_OP) || 
            (aluop_i == `EXE_SLT_OP)) ?
            (~reg2_i)+1 : reg2_i;   

    //  (1) if add op, reg2_i_mux is the op num2, result_sum is the real result 
    //  (2) if sub op, reg2_i_mux is the complemented code of num2, result_sum is the real result
    //  (3) if compare op, use sub op to judge weathear num 1 < num 2
        assign  result_sum  = reg1_i + reg2_i_mux;

    // whether overflow, add,addi,sub
        assign overflow = ((!reg1_i[31] && !reg2_i_mux[31]) && (result_sum[31])
            || (reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
    
    // num1 <= num2?
    // A signed num
    // A.1 num1=negative, num2=positive
    // A.2 num1=positive, num2=negative
    // A.3 num1=negetive, num2=negative
    // B unsigned num, derictly compare
        assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ?
                        ((reg1_i[31] && !reg2_i[31]) ||
                        (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
                        (reg1_i[31] && reg2_i[31] && result_sum[31])):
                        (reg1_i < reg2_i);
    // reverse-bit
        assign reg1_i_not = ~reg1_i;

/***********************************************************
****************  assign for arthmeticres ******************
************************************************************/
        always @(*) begin
            if(rst == `RstEnable) begin
                arithmeticres   <= `ZeroWord;
            end else begin
                case (aluop_i)
                    `EXE_SLT_OP, `EXE_SLTU_OP:    begin
                        arithmeticres   <=  reg1_lt_reg2; // compare
                    end
                    `EXE_ADD_OP, `EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP: begin
                        arithmeticres   <=  result_sum; // add
                    end
                    `EXE_SUB_OP, `EXE_SUBU_OP: begin
                        arithmeticres   <= result_sum;  // sub
                    end
                    `EXE_CLZ_OP: begin // manually compute clz... ref: 《自己动手写cpu》
                        arithmeticres   <= reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
                    end
                    `EXE_CLO_OP: begin
                        arithmeticres   <= (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
													 reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
													 reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
													 reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
													 reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
													 reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
													 reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
													 reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
													 reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
													 reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
													 reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;

                    end
                    default: begin
                        arithmeticres   <=  `ZeroWord;
                    end
                endcase
            end
        end

/******************************************************
******************   mul op   *************************
*******************************************************/
    // multiplicand, signed mul, if negative get complemented code
    assign opdata1_mult = ((aluop_i == `EXE_MUL_OP) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
    // multiplier
    assign opdata2_mult = ((aluop_i == `EXE_MUL_OP) && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;
    // temp result of mul
    assign temp_mulres = opdata1_mult * opdata2_mult;
    // modify mul res(signed should judge weather negative plus positive)
    always @(*) begin
        if(rst == `RstEnable) begin
            mulres <= {`ZeroWord, `ZeroWord};
        end else if ((aluop_i == `EXE_MUL_OP)) begin
            if (reg1_i[31] ^ reg2_i[31] == 1'b1) begin // positive plus negative
                mulres <= ~temp_mulres + 1;
            end else begin
                mulres <= temp_mulres;
            end
        end else begin
            mulres <= temp_mulres;
        end
    end

/***********************
*******   1. calcu according to alu op*******
***********************/
// logic compute
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP: begin
                    logicout    <=  reg1_i | reg2_i; // or
                end
                `EXE_AND_OP: begin
                    logicout    <=  reg1_i & reg2_i; // and
                end
                `EXE_NOR_OP: begin
                    logicout    <=  ~(reg1_i | reg2_i); // nor
                end
                `EXE_XOR_OP:    begin
                    logicout    <=  reg1_i ^ reg2_i;
                end
                default:    begin
                    logicout <= `ZeroWord;
                end
            endcase
        end // if
    end //always

// shift compute
    always @(*) begin
        if(rst == `RstEnable) begin
            shiftres    <=  `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP:    begin   // logic left shift
                    shiftres    <=  reg2_i  <=  reg1_i[4:0]; // imm or regdata, only 4-bit
                end
                `EXE_SRL_OP:    begin   // logic right shift
                    shiftres    <=  reg2_i  >=  reg1_i[4:0];
                end
                `EXE_SRA_OP:    begin   // arithmetic right shift
                    shiftres    <=  ({32{reg2_i[31]}} << (6'd32-{1'b0,reg1_i[4:0]})) | reg2_i   >> reg1_i[4:0];
                end
                default: begin
                    shiftres    <=  `ZeroWord;
                end
            endcase
        end
        
    end

// move compute
    always @(*) begin
        if(rst == `RstEnable) begin
            moveres <=  `ZeroWord;
        end else begin
            moveres <=  `ZeroWord;
            case (aluop_i)
                `EXE_MOVZ_OP:   begin
                    moveres <=  reg1_i;
                end
                `EXE_MOVN_OP:   begin
                    moveres <=  reg1_i;
                end
                default:    begin
                end
            endcase
        end
    end

/************************
**** 2. according to alusel_i, choose result (here only logicout) ****
*************************/

    always @ (*) begin
        wd_o <= wd_i;
        // wreg_o <= wreg_i;
        if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (overflow == 1'b1)) begin
            wreg_o <= `WriteDisable;
        end else begin
            wreg_o <= wreg_i;
        end
        case ( alusel_i )
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout; // results to wdata_o
            end
            `EXE_RES_SHIFT: begin
                wdata_o <=  shiftres; // choose shift res as wdata
            end
            `EXE_RES_MOVE:  begin
                wdata_o <=  moveres;
            end
            `EXE_RES_ARITHMETIC: begin
                wdata_o <= arithmeticres;
            end
            `EXE_RES_MUL: begin
                wdata_o <=  mulres[31:0]; // mul, only save the low 32-bit   
            end
            default:    begin
                wdata_o <=  `ZeroWord;
            end
        endcase
    end

endmodule
