// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

module full_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;  
    wire [31:0] PC;  
    //alu add_PC+4
    wire [31:0] add4 = 4;
    wire [31:0]PC_4, PC_branch, branchOffset, PC_next;
    wire [2:0]add = 3'b010; 
    alu32 PCadd4(PC_4, , , , PC, add4, add);
    
    // alu add_branchOffset
    
    alu32 PCaddB(PC_branch, , , , PC_4, branchOffset, add);

    // decoder outputs
    wire [2:0] alu_op;
    wire [1:0] alu_src2;
    wire enable = 1;
    wire writeenable, rd_src, except;
    wire [1:0] control_type;
    wire zero, overflow, negative;
    wire [31:0]jumpTo;
    wire mem_read, word_we, byte_we, byte_load, slt, lui, addm;
    mips_decode decode1(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   inst[31:26], inst[5:0], zero);

    //controler mux 
    wire [31:0]w_1, w_2;
    wire [31:0]wdata;
    wire [31:0]A_data, B_data;
    wire [31:0]Sext, lui_in, Zext;
    assign jumpTo[31:28] = PC_4[31:28];//pc_4 or pc?
    assign jumpTo[27:2] = inst[25:0];
    assign jumpTo[1:0] = 0;
    mux4v #(32)control(PC_next, PC_4, PC_branch, jumpTo, A_data, control_type);
   
    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(32) PC_reg(PC, PC_next, clock, enable, reset);

    // DO NOT comment out or rename this module
    // or the test bench will break
    
    instruction_memory im(inst, PC[31:2]);
    
    //mux decision-rt/rd
    wire [4:0]wnum;
    mux2v #(5) rdrt(wnum, inst[15:11], inst[20:16], rd_src);
    
    //mux decision for B input in alu out
    
    zero_extender z1(Zext, inst[15:0]);//zero extender
    sign_extender s1(Sext, inst[15:0]);//sign extender
    assign lui_in[31:16] = inst[15:0];
    assign lui_in[15:0] = 0; 
    assign branchOffset[31:2] = Sext[29:0];
    assign branchOffset[1:0] = 0;
    
    mux3v #(32) getW_1(w_1, B_data, Sext, Zext, alu_src2);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (A_data, B_data,
                inst[25:21], inst[20:16], wnum, wdata, 
                writeenable, clock, reset);

    alu32 getW_2(w_2, overflow, zero, negative, A_data, w_1, alu_op);

    wire [31:0]negative_32, w_3;
    assign negative_32[0] = negative;
    assign negative_32[31:1] = 0;
    mux2v #(32) getW_3(w_3, w_2, negative_32, slt);
    wire [31:0]data_out;
    data_mem memo(data_out, w_2, B_data, word_we, byte_we, clock, reset);
    wire[31:0] byte_;
    assign byte_[31:8] = 0;
    mux4v #(8) getbyte(byte_[7:0], data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24], w_2[1:0]);
    wire[31:0] w_4;
    mux2v #(32) byte_mux(w_4, data_out, byte_, byte_load);
    wire[31:0] w_5;
    mux2v #(32) mem_mux(w_5, w_3, w_4, mem_read);
    mux2v #(32) lui_mux(wdata, w_4, lui_in, lui);

    

    /* add other modules */

endmodule // full_machine

module sign_extender(out, in);
    input [15:0] in;
    output [31:0] out;

    assign out = {{16{in[15]}}, in[15:0]};

endmodule

module zero_extender(out, in);
    input [15:0] in;
    output [31:0] out;
    assign out = {{16{1'b0}}, in[15:0]};
        
endmodule

