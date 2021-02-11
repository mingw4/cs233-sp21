//implement a test bench for your 32-bit ALU
module alu32_test;
    reg [31:0] A = 0, B = 0;
    reg [2:0] control = 0;

    initial begin
        $dumpfile("alu32.vcd");
        $dumpvars(0, alu32_test);

             A = 8; B = 4; control = `ALU_ADD; // try adding 8 and 4
        # 10 A = 2; B = 5; control = `ALU_SUB; // try subtracting 5 from 2
        // add more test cases here!
        # 10 A = 14; B = -14; control = `ALU_SUB;
        # 10 A = 1010; B = 1111; control = `ALU_AND;
        # 10 A = 32'b10101010; B = 32'b1111000; control = `ALU_OR;
        # 10 A = 32'h662e385; B = 32'h37c33ed1; control = 3'h1;
        # 10 $finish;
    end

    wire [31:0] out;
    wire overflow, zero, negative;
    alu32 a(out, overflow, zero, negative, A, B, control);  
    initial begin
        $display("out, overflow, zero, negative, A, B, control");
        $monitor("%d %d %d %d %d %d %d (at time %t)", out, overflow, zero, negative, A, B, control, $time);
    end
endmodule // alu32_test
