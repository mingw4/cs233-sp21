module machine(clk, reset);
   input        clk, reset;

   wire [31:0]  PC;
   wire [31:2]  next_PC, PC_plus4, PC_target;
   wire [31:0]  inst;

   wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
   wire [4:0]   rs = inst[25:21];
   wire [4:0]   rt = inst[20:16];
   wire [4:0]   rd = inst[15:11];

   wire [4:0]   wr_regnum;
   wire [2:0]   ALUOp;

   wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET;
   wire         PCSrc, zero, negative;
   wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

   //Your extra wires go here
   wire [31:0]  MemToReg_out, c0rd_data;
   wire         new_MemRead, new_MemWrite, TimerInterrupt, TimerAddress, TakenInterrupt;
   wire [29:0]  EPC;
   wire [31:2]  ERET_out, Taken_Interupt_out;
   wire [31:0]  t_data, t_address, cycle, c0_wr_data, c0_rd_data, NotIO;


   register #(30, 30'h100000) PC_reg(PC[31:2], Taken_Interupt_out, clk, /* enable */1'b1, reset);
   assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
   adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
   adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
   mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
   assign PCSrc = BEQ & zero;

   instruction_memory imem (inst, PC[31:2]);

   mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET,
                      inst);

   regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum, wr_data,
               RegWrite, clk, reset);

   mux2v #(32) imm_mux(B_data, rd2_data, imm, ALUSrc);
   alu32 alu(alu_out_data, zero, negative, ALUOp, rd1_data, B_data);

   data_mem data_memory(load_data, alu_out_data, rd2_data, new_MemRead, new_MemWrite, clk, reset);

   mux2v #(32) wb_mux(MemToReg_out, alu_out_data, load_data, MemToReg);
   mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);
   
   //Connect your new modules below

   mux2v #(30) eret_mux(ERET_out, next_PC[31:2], EPC, ERET);
   mux2v #(30) taken_interupt_mux(Taken_Interupt_out, ERET_out, 30'b100000000000000000000001100000, TakenInterrupt);
   
   assign t_address = alu_out_data;
   assign t_data = rd2_data;
   assign c0_wr_data = rd2_data;
   assign cycle = load_data;
   assign NotIO = TimerAddress;
   assign new_MemRead = MemRead & ~TimerAddress;
   assign new_MemWrite = MemWrite & ~TimerAddress;

   mux2v mfc0_mux(wr_data, MemToReg_out, c0rd_data, MFC0);
   cp0 CP_0(c0rd_data, EPC, TakenInterrupt, c0_wr_data, rd, next_PC, MTC0, ERET, TimerInterrupt, clk, reset);
   timer timer_(TimerInterrupt, load_data, TimerAddress, t_data, t_address,  MemRead, MemWrite, clk, reset);

endmodule // machine