// mips_decode: a decoder for MIPS arithmetic instructions
//
// alu_op       (output) - control signal to be sent to the ALU
// writeenable  (output) - should a new value be captured by the register file
// rd_src       (output) - should the destination register be rd (0) or rt (1)
// alu_src2     (output) - should the 2nd ALU source be a register (0) or an immediate (1)
// except       (output) - set to 1 when we don't recognize an opdcode & funct combination
// control_type (output) - 00 = fallthrough, 01 = branch_target, 10 = jump_target, 11 = jump_register 
// mem_read     (output) - the register value written is coming from the memory
// word_we      (output) - we're writing a word's worth of data
// byte_we      (output) - we're only writing a byte's worth of data
// byte_load    (output) - we're doing a byte load
// slt          (output) - the instruction is an slt
// lui          (output) - the instruction is a lui
// addm         (output) - the instruction is an addm
// opcode        (input) - the opcode field from the instruction
// funct         (input) - the function field from the instruction
// zero          (input) - from the ALU
//

module mips_decode(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   opcode, funct, zero);
    output [2:0] alu_op;
    output [1:0] alu_src2;
    output       writeenable, rd_src, except;
    output [1:0] control_type;
    output       mem_read, word_we, byte_we, byte_load, slt, lui, addm;
    input  [5:0] opcode, funct;
    input        zero;

    wire add_ = ((opcode == 6'b000000) & (funct == 6'b100000));
    wire sub_ = ((opcode == 6'b000000) & (funct == 6'b100010));
    wire and_ = ((opcode == 6'b000000) & (funct == 6'b100100));
    wire or_ = ((opcode == 6'b000000) & (funct == 6'b100101));
    wire nor_ = ((opcode == 6'b000000) & (funct == 6'b100111));
    wire xor_ = ((opcode == 6'b000000) & (funct == 6'b100110));
    wire addi_ = (opcode == 6'b001000);
    wire andi_ = (opcode == 6'b001100);
    wire ori_ = (opcode == 6'b001101);
    wire xori_ = (opcode == 6'b001110);

    wire bne_ = (opcode == 6'b000101); //I
    wire beq_ = (opcode == 6'b000100); //I
    wire j_ = (opcode == 6'b000010); //j
    wire jr_ = (opcode == 6'b000000) & (funct == 6'b001000); //R
    wire lui_ = (opcode == 6'b001111); //i
    wire slt_ = (opcode == 6'b000000) & (funct == 6'b101010); //R
    wire lw_ = (opcode == 6'b100011); //I
    wire lbu_ = (opcode == 6'b100100); //I
    wire sw_ = (opcode == 6'b101011); //I
    wire sb_ = (opcode == 101000); //I
    wire addm_ = (opcode == 6'b000000) & (funct == 6'101100); //R

    assign rd_src = (addi_ | andi_ | ori_ | xori_ | lui_ | lw_ | lbu_ | sw_ | sb_);
    assign writeenable = ~(bne_ | beq_ | j_ | jr_ | sw_ | sb_ | except);
    assign except = ~(add_ | sub_ | and_ | or_ | nor_ | xor_ | addi_ | andi_ | ori_ | xori_ | bne_ | beq_ | j_ | jr_ | lui_ | slt_ | lw_ | lbu_ | sw_ | sb_ | addm_);
    assign alu_src2 = (addi_ | andi_ | ori_ | xori_ | lui_ | lw_ | lbu_ | sw_ | sb_);
    assign alu_op[0] = (sub_ | or_ | xor_ | ori_ | xori_ | bne_ | beq_ | slt_);
    assign alu_op[1] = (add_ | sub_ | nor_ | xor_ | addi_ | xori_ | bne_ | beq_ | slt_ | lw_ | lbu_ | sw_ | sb_ | addm_);
    assign alu_op[2] = (and_ | or_ | nor_ | xor_ | andi_ | ori_ | xori_);
    assign control_type[0] = ((!zero & bne_) | (zero & beq_) | jr_);
    assign control_type[1] = jr_ | j_;
    assign mem_read = lw_ | lbu_;
    assign word_we = sw_;
    assign byte_load = lbu_;
    assign slt = slt_;
    assign lui = lui_;
    assign addm = addm_;

endmodule // mips_decode
