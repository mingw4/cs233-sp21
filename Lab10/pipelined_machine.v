module pipelined_machine(clk, reset);
    input        clk, reset;

    wire [31:0]  PC;
    wire [31:2]  next_PC, PC_plus4, PC_target;
    wire [31:2]  PC_plus4_DE;
    wire [31:0]  inst;
    wire [31:0]  inst_DE;

    wire [31:0]  imm_DE = {{ 16{inst_DE[15]} }, inst_DE[15:0] };

    wire [4:0]   rs = inst_DE[25:21];
    wire [4:0]   rt = inst_DE[20:16];
    wire [4:0]   rd = inst_DE[15:11];

    wire [4:0]   wr_regnum_MW;
    wire [5:0]   opcode_DE = inst_DE[31:26];
    wire [5:0]   funct_DE = inst_DE[5:0];
    wire         flush =  PCSrc;  
    wire [4:0]   wr_regnum;
    wire [2:0]   ALUOp;

    wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst;
    wire         RegWrite_MW, MemRead_MW, MemWrite_MW, MemToReg_MW;
    wire         PCSrc, zero, ForwardA, ForwardB, stall;
    wire [31:0]  rd1_data, rd1_data_o, rd2_data, rd2_data_o, ForwardB_out, alu_out_data, alu_out_MW, load_data, wr_data, rd2_data_MW;
    
    assign stall = (MemRead_MW == 1) & ((wr_regnum_MW == rs) | (wr_regnum_MW == rt)) & (wr_regnum_MW != 0);
    
    assign ForwardA = (wr_regnum_MW == rs) & (wr_regnum_MW != 0) & RegWrite_MW;
    assign ForwardB = (wr_regnum_MW == rt) & (wr_regnum_MW != 0) & RegWrite_MW;
    
    assign PCSrc = BEQ & zero;


    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, /* enable */~stall, reset);

    assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
    adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
    adder30 target_PC_adder(PC_target, PC_plus4_DE, imm_DE[29:0]);
    mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
    
    // DO NOT comment out or rename this module.
    // or the test bench will break
    instruction_memory imem(inst, PC[31:2]);
    mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst,
                      opcode_DE, funct_DE);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum_MW, wr_data,
               RegWrite_MW, clk, reset);

    mux2v #(32) imm_mux(ForwardB_out, rd2_data_o, imm_DE, ALUSrc);
    alu32 alu(alu_out_data, zero, ALUOp, rd1_data_o, ForwardB_out);

    // Our code
    register #(32) reg_alu(alu_out_MW, alu_out_data, clk, 1'b1, reset);
    register #(32) reg_rd2(rd2_data_MW, rd2_data_o, clk,1'b1, reset);
    register #(32) reg_instr(inst_DE, inst, clk, ~stall, flush | reset);
    register #(30,30'h100000) reg_PCsrc(PC_plus4_DE[31:2], PC_plus4[31:2], clk, ~stall, flush | reset);
    register #(5) reg_wr(wr_regnum_MW, wr_regnum, clk, 1'b1, reset);

    register #(1) reg_mem_to_reg(MemToReg_MW, MemToReg, clk, 1'b1, stall | reset);
    register #(1) reg_rw(RegWrite_MW, RegWrite, clk, 1'b1, stall | reset);
    register #(1) reg_mr(MemRead_MW, MemRead, clk, 1'b1, stall | reset);
    register #(1) reg_mw(MemWrite_MW, MemWrite, clk, 1'b1, stall | reset);

    mux2v #(32) ForwardAmux(rd1_data_o, rd1_data, alu_out_MW, ForwardA);
    mux2v #(32) ForwardBmux(rd2_data_o, rd2_data, alu_out_MW, ForwardB);

    // DO NOT comment out or rename this module
    // or the test bench will break
    data_mem data_memory(load_data, alu_out_MW, rd2_data_MW, MemRead_MW, MemWrite_MW, clk, reset);

    mux2v #(32) wb_mux(wr_data, alu_out_MW, load_data, MemToReg_MW);
    mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

endmodule // pipelined_machine
