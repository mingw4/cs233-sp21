/**
 * @file
 * Contains an implementation of the countOnes function.
 */

unsigned countOnes(unsigned input) {
	// TODO: write your code here
	input = ((input & 0xAAAAAAAA) >> 1) + (input & 0x55555555);
	input = ((input & 0xCCCCCCCC) >> 2) + (input & 0x33333333);
	input = ((input & 0xF0F0F0F0) >> 4) + (input & 0xF0F0F0F);
	input = ((input & 0x00FF00FF) >> 8) + (input & 0xFF00FF00);
	input = ((input & 0x0000FFFF) >> 16) + (input & 0xFFFF0000);
	



	

	return input;
}
