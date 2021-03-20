`define STATUS_REGISTER 5'd12
`define CAUSE_REGISTER  5'd13
`define EPC_REGISTER    5'd14

module cp0(rd_data, EPC, TakenInterrupt,
           wr_data, regnum, next_pc,
           MTC0, ERET, TimerInterrupt, clock, reset);
    output [31:0] rd_data;
    output [29:0] EPC;
    output        TakenInterrupt;
    input  [31:0] wr_data;
    input   [4:0] regnum;
    input  [29:0] next_pc;
    input         MTC0, ERET, TimerInterrupt, clock, reset;


    // your Verilog for coprocessor 0 goes here
    wire [31:0] MTC0_decoded, cause_register, user_status, status_register;
    wire exception_level;
    wire [29:0] EPC_Q, EPC_D;


	assign status_register[31:16] = 0;
    assign status_register[7:2] = 0;
    assign cause_register[31:16] = 0;
    assign cause_register[14:0] = 0;

	assign status_register[15] =  user_status[15];
	assign status_register[14] =  user_status[14];
	assign status_register[13] =  user_status[13];
	assign status_register[12] =  user_status[12];
	assign status_register[11] =  user_status[11];
	assign status_register[10] =  user_status[10];
	assign status_register[9] =  user_status[9];
	assign status_register[8] =  user_status[8];
	assign status_register[1] = exception_level;
	assign status_register[0] = user_status[0];

	
	assign cause_register[15] = TimerInterrupt;
	
	assign EPC = EPC_Q;
    mux32v #(32) rd(rd_data, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, status_register, cause_register, {EPC_Q[29:0], 2'b0}, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, regnum);
    decoder32 MTC0_decoder(MTC0_decoded, regnum, MTC0);
    dffe Exception_level(exception_level, 1'b1, clock, TakenInterrupt, reset | ERET);
    assign TakenInterrupt = ((cause_register[15] && status_register[15]) && (!status_register[1] && status_register[0]));
    register #(30) epc(EPC_Q, EPC_D, clock, TakenInterrupt || MTC0_decoded[14], reset);
    mux2v #(30) next_pc_or_write_data(EPC_D, wr_data[31:2], next_pc, TakenInterrupt);
    register register_user_status(user_status, wr_data, clock, (MTC0_decoded[12] && (regnum == `STATUS_REGISTER)), reset);





endmodule
