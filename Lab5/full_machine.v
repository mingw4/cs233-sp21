// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

module full_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire wr_enable;
    wire rd_src;
    wire overflow;
    wire zero;
    wire negative;
    wire mem_read;
    wire word_we;
    wire byte_we;
    wire byte_load;
    wire lui;
    wire slt;
    wire addm;
    
    wire [31:0] inst;  
    wire [31:0] PC;  
    wire [2:0] alu_op;
    wire [31:0] zero_;
    wire [31:0] one_;
    wire [31:0] two_;
    wire [1:0] control_type;
    wire [1:0] alu_src2;
    wire [4:0] W_addr;
    wire [31:0] W_data, B, rtData, sign_extended, zero_extended, rsData,  out, data_out, PCnext;
    wire [7:0] byte_out;
	wire [31:0] byte_load_one, slt_one, lui_zero, lui_one, branchoffset, mem_read_one, mem_read_zero, addr, addm_out, lui_out;
    assign branchoffset[31:2] = sign_extended[29:0]; 
	assign branchoffset[1:0] = 0;
    wire enable = 1'b1;


    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(32) PC_reg(PC, PCnext, clock, enable, reset);

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory im(inst, PC[31:2]);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (rsData, rtData, inst[25:21], inst[20:16], W_addr, W_data, wr_enable, clock, reset);

    /* add other modules */

    //The upper left mux4
    mux4v upper_left_4(PCnext, zero_, one_, two_, rsData, control_type);      
    alu32 a1(zero_, , , , PC, 32'h4, `ALU_ADD);                         //Port0
    alu32 a2(one_, , , , zero_, branchoffset, `ALU_ADD);                //Port1
    assign two_[31:28] = PC[31:28];                                     //Port2
    assign two_[27:2] = inst[25:0];
    assign two_[1:0] = 2'b0;

    //rd_src mux that select rd or rt (leftmost mux2)
    mux2v #(5) leftmost_2(W_addr, inst[15:11], inst[20:16], rd_src);

    //sign extender and zero extender
    sign_extender s0(sign_extended, inst[15:0]);
    zero_extender z1(zero_extended, inst[15:0]);

    //alu_src2 controller
    mux3v alu_src2_(B, rtData, sign_extended, zero_extended, alu_src2);

    //From A and B to out
    alu32 a0(out, overflow, zero, negative, rsData, B, alu_op);

    //addm controller
    mux2v addm_(addr, out, rsData, addm);	
	alu32 a3(addm_out, , , , data_out, rtData, `ALU_ADD);

    //Data_Memory
	data_mem dm(data_out, addr, rtData, word_we, byte_we, clock, reset);

    //the most rightsided mux4
	mux4v #(8) rightmost_4(byte_out, data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24], out[1:0]);

    //extend the bytes and the most rightsided mux2
    assign byte_load_one[31:8] = 0;
	assign byte_load_one[7:0] = byte_out[7:0];
	mux2v rightmost_2(mem_read_one, data_out, byte_load_one, byte_load);

    //fix slt
    assign slt_one[31:1] = 0;
	assign slt_one[0] = negative ^ overflow;

    //slt controller
	mux2v slt_(mem_read_zero, out, slt_one, slt);

    //mem_read_
	mux2v mem_read_(lui_zero, mem_read_zero, mem_read_one, mem_read);

    //lui controller
    assign lui_one[31:16] = inst[15:0];
	assign lui_one[15:0] = 0;
	mux2v lui_(lui_out, lui_zero, lui_one, lui);

	mux2v lui_addm_out(W_data, lui_out, addm_out, addm);

    //decoder
    mips_decode d0(alu_op, wr_enable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   inst[31:26], inst[5:0], zero);

endmodule // full_machine

module sign_extender (out, inst);
    output [31:0] out;
    input [15:0] inst;
    assign out[31:16] = {16{inst[15]}};
    assign out[15:0] = inst[15:0];
endmodule

module zero_extender(out, in);
    input [15:0] in;
    output [31:0] out;
    assign out = {{16{1'b0}}, in[15:0]};
        
endmodule