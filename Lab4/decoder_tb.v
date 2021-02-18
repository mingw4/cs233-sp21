module decoder_test;
    reg [5:0] opcode, funct;

    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0, decoder_test);

             opcode = `OP_OTHER0; funct = `OP0_ADD; // try addition
        # 10 opcode = `OP_OTHER0; funct = `OP0_SUB; // try subtraction
        // add more tests here!
        # 10 opcode = 6'b000000; funct = 6'b100100; // try and
        # 10 opcode = 6'b000000; funct = 6'b100101; // try or
        # 10 opcode = 6'b000000; funct = 6'b100111; // try nor
        # 10 opcode = 6'b000000; funct = 6'b100110; // try xor
        # 10 opcode = 6'b001000; // try addi
        # 10 opcode = 6'b001100; // try andi
        # 10 opcode = 6'b001101; // try ori
        # 10 opcode = 6'b001110; // try xori

        # 10 $finish;
    end

    // use gtkwave to test correctness
    wire [2:0] alu_op;
    wire [1:0] alu_src2; 
    wire       rd_src, writeenable, except;
    mips_decode decoder(rd_src, writeenable, alu_src2, alu_op, except,
                        opcode, funct);
endmodule // decoder_test
