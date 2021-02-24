module decoder_test;
    reg [5:0] opcode, funct;
    reg       zero  = 0;

    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0, decoder_test);

        // remember that all your instructions from last week should still work
             opcode = `OP_OTHER0; funct = `OP0_ADD; // see if addition still works
        # 10 opcode = `OP_OTHER0; funct = `OP0_SUB; // see if subtraction still works
        // test all of the others here
        # 10 opcode = 6'b000000; funct = 6'b100100; // try and
        # 10 opcode = 6'b000000; funct = 6'b100101; // try or
        # 10 opcode = 6'b000000; funct = 6'b100111; // try nor
        # 10 opcode = 6'b000000; funct = 6'b100110; // try xor
        # 10 opcode = 6'b001000; // try addi
        # 10 opcode = 6'b001100; // try andi
        # 10 opcode = 6'b001101; // try ori
        # 10 opcode = 6'b001110; // try xori
        
        // as should all the new instructions from this week
        # 10 opcode = `OP_BEQ; zero = 0; // try a not taken beq
        # 10 opcode = `OP_BEQ; zero = 1; // try a taken beq
        // add more tests here!

        # 10 $finish;
    end

    // use gtkwave to test correctness
    wire [2:0] alu_op;
    wire [1:0] alu_src2;
    wire       writeenable, rd_src, except;
    wire [1:0] control_type;
    wire       mem_read, word_we, byte_we, byte_load, slt, lui, addm;
    mips_decode decoder(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                        mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                        opcode, funct, zero);
endmodule // decoder_test
