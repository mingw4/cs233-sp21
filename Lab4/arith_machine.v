// arith_machine: execute a series of arithmetic instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock  (input)  - the clock signal
// reset  (input)  - set to 1 to set all registers to zero, set to 0 for normal execution.

module arith_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;  
    wire [31:0] PC;  

    // DO NOT comment out or rename this module
    // or the test bench will break
 //control
    wire enable = 1'b1;
    wire [31:0] add4 = 4;
    wire [31:0]PC_next;
    wire [2:0]add = 3'b010;

    wire overflow_, zero_, negative_; // useless
    register #(32) PC_reg(PC, PC_next, clock, enable, reset);

    alu32 PC_4(PC_next, overflow_, zero_, negative_, PC, add4, add);
    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory im(inst, PC[31:2]);

    //decode
    wire rd_src, writeenable;
    wire [1:0] alu_src2;
    wire [2:0] alu_op;
    mips_decode decode1(rd_src, writeenable, alu_src2, alu_op, except, inst[31:26], inst[5:0]);

    //first mux decision
    wire [4:0]wnum;
    mux2v #(5) rdrt(wnum, inst[15:11], inst[20:16], rd_src);
    
    //second mux decision
    wire [31:0]wtemp;
    wire [31:0]wdata;
    wire [31:0]A_data, B_data;
    wire [31:0]Sext, Zext;
    sign_extender s1(Sext, inst[15:0]);//sign extender
    zero_extender z1(Zext, inst[15:0]);//zero extender
    mux3v #(32) getW_1(wtemp, B_data, Sext, Zext, alu_src2);

    //final ALU
    wire overflow, zero, negative;
    alu32 getW_2(wdata, overflow, zero, negative, A_data, wtemp, alu_op);
    

    // DO NOT comment out or rename this module
    // or the test bench will break
    // inst[25:21] = rs_num
    // inst[20:16] = rt_num
    regfile rf (A_data, B_data,
                inst[25:21], inst[20:16], wnum, wdata, 
                writeenable, clock, reset); 
    
    /* add other modules */
   
endmodule // arith_machine

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
