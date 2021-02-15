
module arraySortCheck_control(sorted, done, load_input, load_index, select_index, go, inversion_found, end_of_array, zero_length_array, clock, reset);
	output sorted, done, load_input, load_index, select_index;
	input go, inversion_found, end_of_array, zero_length_array;
	input clock, reset;

	wire sGarbage, sStart, sProcess, sForward, sYes, sNo;

	wire sProcess_next = ~reset & (sForward | (sStart & ~go));
	wire sForward_next = ~reset & ~end_of_array & ~inversion_found & sProcess;

	wire sYes_next = ~reset & ((~inversion_found & sProcess & end_of_array) | (sYes & ~go));
	wire sNo_next = ~reset & ((inversion_found & ~end_of_array & sProcess ) | (sNo & ~go));


	wire sGarbage_next= reset | (sGarbage & ~go);
	wire sStart_next = ~reset & go & (sStart | sGarbage | sYes | sNo);

	dffe fsGarbage(sGarbage, sGarbage_next, clock, 1'b1 , 1'b0);

	dffe fsForward(sForward, sForward_next, clock, 1'b1 , 1'b0);
	dffe fsYes(sYes, sYes_next, clock, 1'b1 , 1'b0);
	dffe fsNo(sNo, sNo_next, clock, 1'b1 , 1'b0);

	dffe fsStart(sStart, sGarbage_next, clock, 1'b1 , 1'b0);
	dffe fsProcess(sProcess, sProcess_next, clock, 1'b1 , 1'b0);


	assign done = sNo | sYes;
	assign load_index = sForward | sStart;
	assign select_index = sForward;
	assign sorted = sYes;

endmodule
