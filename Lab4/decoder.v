// mips_decode: a decoder for MIPS arithmetic instructions
//
// rd_src      (output) - should the destination register be rd (0) or rt (1)
// writeenable (output) - should a new value be captured by the register file
// alu_src2    (output) - should the 2nd ALU source be a register (0), zero extended immediate or sign extended immediate
// alu_op      (output) - control signal to be sent to the ALU
// except      (output) - set to 1 when the opcode/funct combination is unrecognized
// opcode      (input)  - the opcode field from the instruction
// funct       (input)  - the function field from the instruction
//

module mips_decode(rd_src, writeenable, alu_src2, alu_op, except, opcode, funct);
    output       rd_src, writeenable, except;
    output [1:0] alu_src2;
    output [2:0] alu_op;
    input  [5:0] opcode, funct;


    wire add = ((opcode == 6'b000000) & (funct == 6'b100000));
    wire sub = ((opcode == 6'b000000) & (funct == 6'b100010));
    wire and_ = ((opcode == 6'b000000) & (funct == 6'b100100));
    wire or_ = ((opcode == 6'b000000) & (funct == 6'b100101));
    wire nor_ = ((opcode == 6'b000000) & (funct == 6'b100111));
    wire xor_ = ((opcode == 6'b000000) & (funct == 6'b100110));
    wire addi = (opcode == 6'b001000);
    wire andi = (opcode == 6'b001100);
    wire ori = (opcode == 6'b001101);
    wire xori = (opcode == 6'b001110);

    assign rd_src = (addi | andi | ori | xori);
    assign writeenable = (add | sub | and_ | or_ | nor_ | xor_ | addi | andi | ori | xori);
    assign except = ~writeenable;
    assign alu_src2[0] = addi;
    assign alu_src2[1] = (andi | ori | xori);
    assign alu_op[0] = (sub | or_ | xor_ | ori | xori);
    assign alu_op[1] = (add | sub | nor_ | xor_ | addi | xori);
    assign alu_op[2] = (and_ | or_ | nor_ | xor_ | andi | ori | xori);

    
endmodule // mips_decode
