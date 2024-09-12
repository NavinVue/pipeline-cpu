`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  navinvue
`define RstEnable 1'b1  //复位信号有效
`define RstDisable 1'b0 //复位信号无效

module test_bench(

);
    reg CLOCK_50;
    reg RST;
    // 10ns, clk reverse
    initial begin
        CLOCK_50    =   1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // at first, rst=true, 195ns, rst=false
    initial begin
        RST =   `RstEnable;
        #195    RST= `RstDisable;
        #4000   $stop;
    end

    // instance sopc
    min_sopc    min_sopc0(
        .clk(CLOCK_50),
        .rst(RST)
    );
    
endmodule
