
module arraySortCheck_control(sorted, done, load_input, load_index, select_index, go, inversion_found, end_of_array, zero_length_array, clock, reset);
	output sorted, done, load_input, load_index, select_index;
	input go, inversion_found, end_of_array, zero_length_array;
	input clock, reset;

	wire garbage, doNothing, check, notSort, sort;
	//wire garbage_next, doNothing_next, check_next, notSort_next, sort_next;
	wire garbage_next = reset | garbage & ~go;
	wire doNothing_next = ~reset & go & (doNothing | garbage | notSort | sort);//? wait for campuswire response
	wire check_next = ~reset & ((check & ~inversion_found & ~end_of_array & ~zero_length_array) | (doNothing & ~go));
	wire notSort_next = ~reset & ((check & inversion_found & ~end_of_array & ~zero_length_array) | (notSort & ~go));
	wire sort_next = ~reset & ((check & ~inversion_found & (end_of_array | zero_length_array)) | (sort & ~go));

	dffe toGarbage(garbage, garbage_next, clock, 1'b1, 1'b0);
	dffe t0DoNothing(doNothing, doNothing_next, clock, 1'b1, 1'b0);
	dffe toCheck(check, check_next, clock, 1'b1, 1'b0);
	dffe toNotSort(notSort, notSort_next, clock, 1'b1, 1'b0);
	dffe toSort(sort, sort_next, clock, 1'b1, 1'b0);

	assign sorted = sort;
	assign done = (notSort | sort);
	assign load_input = doNothing;
	assign load_index = (doNothing | check);
	assign select_index = (doNothing | check);



	 
endmodule