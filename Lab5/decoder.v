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

    wire add_ = ((opcode == `OP_OTHER0) & (funct == `OP0_ADD));
    wire sub_ = ((opcode == `OP_OTHER0) & (funct == `OP0_SUB));
    wire and_ = ((opcode == `OP_OTHER0) & (funct == `OP0_AND));
    wire or_ = ((opcode == `OP_OTHER0) & (funct == `OP0_OR));
    wire nor_ = ((opcode == `OP_OTHER0) & (funct == `OP0_NOR));
    wire xor_ = ((opcode == `OP_OTHER0) & (funct == `OP0_XOR));
    wire addi_ = (opcode == `OP_ADDI);
    wire andi_ = (opcode == `OP_ANDI);
    wire ori_ = (opcode == `OP_ORI);
    wire xori_ = (opcode == `OP_XORI);

    wire bne_ = (opcode == `OP_BNE); //I
    wire beq_ = (opcode == `OP_BEQ); //I
    wire j_ = (opcode == `OP_J); //J
    wire jr_ = (opcode == `OP_OTHER0) & (funct == `OP0_JR); //R
    wire lui_ = (opcode == `OP_LUI); //I
    wire slt_ = (opcode == `OP_OTHER0) & (funct == `OP0_SLT); //R
    wire lw_ = (opcode == `OP_LW); //I
    wire lbu_ = (opcode == `OP_LBU); //I
    wire sw_ = (opcode == `OP_SW); //I
    wire sb_ = (opcode == `OP_SB); //I
    wire addm_ = (opcode == `OP_OTHER0) & (funct == `OP0_ADDM); //R

    // alu_op       (output) - control signal to be sent to the ALU
    assign alu_op[0] = (sub_ | or_ | xor_ | ori_ | xori_ | bne_ | beq_ | slt_);
    assign alu_op[1] = (add_ | sub_ | nor_ | xor_ | addi_ | xori_ | bne_ | beq_ | lw_ | lbu_ | sw_ | sb_ | slt_);
    assign alu_op[2] = (and_ | or_ | nor_ | xor_ | andi_ | ori_ | xori_);

    // writeenable  (output) - should a new value be captured by the register file
    assign writeenable = (add_ | sub_ | and_ | or_ | nor_ | xor_ | addi_ | andi_ | ori_ | xori_ | lw_ | lbu_ | lui_ | slt_ | addm_);
    
    // rd_src       (output) - should the destination register be rd (0) or rt (1)
    assign rd_src = (addi_ | andi_ | ori_ | xori_ | lw_ | lbu_ | lui_);

    // alu_src2     (output) - should the 2nd ALU source be a register (0) or an immediate (1)
    assign alu_src2[0] = addi_ | sw_ | sb_ | lbu_ | lw_;
    assign alu_src2[1] = (andi_ | ori_ | xori_);

    // except       (output) - set to 1 when we don't recognize an opdcode & funct combination
    assign except = ~(add_ | sub_ | and_ | or_ | nor_ | xor_ | addi_ | andi_ | ori_ | xori_ | bne_ | beq_ | j_ | jr_ | lui_ | slt_ | lw_ | lbu_ | sw_ | sb_ | addm_);

    // control_type (output) - 00 = fallthrough, 01 = branch_target, 10 = jump_target, 11 = jump_register 
    assign control_type[0] = ((!zero & bne_) | (zero & beq_) | jr_);
    assign control_type[1] = jr_ | j_;

    // mem_read     (output) - the register value written is coming from the memory
    assign mem_read = lw_ | lbu_;

    // word_we      (output) - we're writing a word's worth of data
    assign word_we = sw_;

    // byte_we      (output) - we're only writing a byte's worth of data
    assign byte_we = sb_;

    // byte_load    (output) - we're doing a byte load
    assign byte_load = lbu_;

    // slt          (output) - the instruction is an slt
    assign slt = slt_;
  
    // lui          (output) - the instruction is a lui
    assign lui = lui_;

    // addm         (output) - the instruction is an addm
    assign addm = addm_;

endmodule // mips_decode
