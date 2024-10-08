`include "definition.vh"
`timescale 1ns / 1ps
// module name: 
// comment: 
// input:
// output:
// author:  navinvue

module data_ram(

	input   wire    clk,
	input   wire    ce,
	input   wire    we,
	input   wire[`DataAddrBusWidth - 1:0]   addr,
	input   wire[3:0]   sel,	// byte choose, actually not use(cause only imply lw,sw)
	input   wire[`DataBusWidth - 1:0]   data_i,
	output  reg[`DataBusWidth - 1:0]    data_o
	
);

	reg[`ByteWidth - 1:0]   data_mem0[0:`DataMemNum-1];
	reg[`ByteWidth - 1:0]   data_mem1[0:`DataMemNum-1];
	reg[`ByteWidth - 1:0]   data_mem2[0:`DataMemNum-1];
	reg[`ByteWidth - 1:0]   data_mem3[0:`DataMemNum-1];

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			//data_o <= ZeroWord;
		end else if(we == `WriteEnable) begin
			  if (sel[3] == 1'b1) begin
		      data_mem3[addr[`DataMemNumLog2+1:2]] <= data_i[31:24];
		    end
			  if (sel[2] == 1'b1) begin
		      data_mem2[addr[`DataMemNumLog2+1:2]] <= data_i[23:16];
		    end
		    if (sel[1] == 1'b1) begin
		      data_mem1[addr[`DataMemNumLog2+1:2]] <= data_i[15:8];
		    end
			  if (sel[0] == 1'b1) begin
		      data_mem0[addr[`DataMemNumLog2+1:2]] <= data_i[7:0];
		    end			   	    
		end
	end
	
	always @ (*) begin
		if (ce == `ChipDisable) begin
			data_o <= `ZeroWord;
	  end else if(we == `WriteDisable) begin
		    data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],
		               data_mem2[addr[`DataMemNumLog2+1:2]],
		               data_mem1[addr[`DataMemNumLog2+1:2]],
		               data_mem0[addr[`DataMemNumLog2+1:2]]};
		end else begin
				data_o <= `ZeroWord;
		end
	end		

endmodule
