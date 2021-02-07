//implement your 32-bit ALU

/*
`define ALU_ADD    3'h2
`define ALU_SUB    3'h3
`define ALU_AND    3'h4
`define ALU_OR     3'h5
`define ALU_NOR    3'h6
`define ALU_XOR    3'h7
*/
module alu32(out, overflow, zero, negative, A, B, control);
    output [31:0] out;
    output        overflow, zero, negative;
    input  [31:0] A, B;
    input   [2:0] control;

    wire   [31:0] cout;

    alu1 alu10(out[0], cout[0], A[0],B[0], control[0], control);
    alu1 alu11(out[1],cout[1], A[1], B[1], cout[0], control); 
    alu1 alu12(out[2],cout[2], A[2], B[2], cout[1], control);
    alu1 alu13(out[3],cout[3], A[3], B[3], cout[2], control);
    alu1 alu14(out[4],cout[4], A[4], B[4], cout[3], control);
    alu1 alu15(out[5],cout[5], A[5], B[5], cout[4], control);
    alu1 alu16(out[6],cout[6], A[6], B[6], cout[5], control);
    alu1 alu17(out[7],cout[7], A[7], B[7], cout[6], control);
    alu1 alu18(out[8],cout[8], A[8], B[8], cout[7], control);
    alu1 alu19(out[9],cout[9], A[9], B[9], cout[8], control);
    alu1 alu110(out[10],cout[10], A[10], B[10], cout[9], control);
    alu1 alu111(out[11],cout[11], A[11], B[11], cout[10], control);
    alu1 alu112(out[12],cout[12], A[12], B[12], cout[11], control);
    alu1 alu113(out[13],cout[13], A[13], B[13], cout[12], control);
    alu1 alu114(out[14],cout[14], A[14], B[14], cout[13], control);
    alu1 alu115(out[15],cout[15], A[15], B[15], cout[14], control);
    alu1 alu116(out[16],cout[16], A[16], B[16], cout[15], control);
    alu1 alu117(out[17],cout[17], A[17], B[17], cout[16], control);
    alu1 alu118(out[18],cout[18], A[18], B[18], cout[17], control);
    alu1 alu119(out[19],cout[19], A[19], B[19], cout[18], control);
    alu1 alu120(out[20],cout[20], A[20], B[20], cout[19], control);
    alu1 alu121(out[21],cout[21], A[21], B[21], cout[20], control);
    alu1 alu122(out[22],cout[22], A[22], B[22], cout[21], control);
    alu1 alu123(out[23],cout[23], A[23], B[23], cout[22], control);
    alu1 alu124(out[24],cout[24], A[24], B[24], cout[23], control);
    alu1 alu125(out[25],cout[25], A[25], B[25], cout[24], control);
    alu1 alu126(out[26],cout[26], A[26], B[26], cout[25], control);
    alu1 alu127(out[27],cout[27], A[27], B[27], cout[26], control);
    alu1 alu128(out[28],cout[28], A[28], B[28], cout[27], control);
    alu1 alu129(out[29],cout[29], A[29], B[29], cout[28], control);
    alu1 alu130(out[30],cout[30], A[30], B[30], cout[29], control);
    alu1 alu131(out[31],cout[31], A[31], B[31], cout[30], control);

    xor xor1(overflow, cout[30], cout[31]);
    assign zero = (out[31:0] == 32'b0);
    assign negative = out[31];

endmodule // alu32
