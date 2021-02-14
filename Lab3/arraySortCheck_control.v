
module arraySortCheck_control(sorted, done, load_input, load_index, select_index, go, inversion_found, end_of_array, zero_length_array, clock, reset);
	output sorted, done, load_input, load_index, select_index;
	input go, inversion_found, end_of_array, zero_length_array;
	input clock, reset;

	wire sGarbage, sStart, s1, s2, s3, s4, sSortedDone, sunSortedDone, s0SortedDone, s0unSortedDone;

	wire sGarbage_next = reset | (sGarbage & ~go) | (sStart & zero_length_array);
	wire sStart_next = (sGarbage & go) & ~reset;
	
	wire s1_next = ~reset & sStart & ~zero_length_array & ~end_of_array & ~inversion_found;
	wire s2_next = ~reset & s1 & ~zero_length_array & ~end_of_array & ~inversion_found;
	wire s3_next = ~reset & s2 & ~zero_length_array & ~end_of_array & ~inversion_found;
	wire s4_next = ~reset & s3 & ~zero_length_array & ~end_of_array & ~inversion_found;

	wire s0SortedDone_next = ~reset & sStart & ~zero_length_array & end_of_array & ~inversion_found;
	wire s0unSortedDone_next = ~reset & sStart & ~zero_length_array & end_of_array & inversion_found;
	wire sSortedDone_next = ~reset & (s1 | s2 | s3 | s4) & ~zero_length_array & end_of_array & ~inversion_found;
	wire sunSortedDone_next = ~reset & (s1 | s2 | s3 | s4) & ~zero_length_array & end_of_array & inversion_found;

	dffe fsGarbage(sGarbage, sGarbage_next, clock, 1'b1, 1'b0);
	dffe fsStart(sStart, sStart_next, clock, 1'b1, 1'b0);

	dffe fs1(s1, s1_next, clock, 1'b1, 1'b0);
	dffe fs2(s2, s2_next, clock, 1'b1, 1'b0);
	dffe fs3(s3, s3_next, clock, 1'b1, 1'b0);
	dffe fs4(s4, s4_next, clock, 1'b1, 1'b0);

	dffe fs0SortedDone(s0unSortedDone, s0unSortedDone_next, clock, 1'b1, 1'b0);
	dffe fs0unSortedDone(s0unSortedDone, s0unSortedDone_next, clock, 1'b1, 1'b0);
	dffe fsSortedDone(sSortedDone, sSortedDone_next, clock, 1'b1, 1'b0);
	dffe fsunSortedDone(sunSortedDone, sunSortedDone_next, clock, 1'b1, 1'b0);

	assign sorted = sGarbage | sSortedDone | s0SortedDone;
	asisgn done = sGarbage | s0SortedDone | s0unSortedDone | sSortedDone | sunSortedDone;
	assign load_input = sStart;
	assign load_index = ~sGarbage;
	sssign select_index = s1 | s2 | s3 | s4 | sSortedDone | sunSortedDone;



endmodule
