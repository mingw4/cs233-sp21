module keypad(valid, number, a, b, c, d, e, f, g);
   output 	valid;
   output [3:0] number;
   input 	a, b, c, d, e, f, g;

   wire w1;

   or o1(w1, a, b, c);
   or o2(valid, (w1 && d), (w1 && e), (w1 && f), (b && g));

   assign number[0] = (((a || c) && (d || f)) || (b && e));
   assign number[1] = ((d && (b || c)) || (c && e) || (a && f));
   assign number[2] = ((e && (a || b)) || (c && e) || (a && f));
   assign number[3] = (f && (b || c));


endmodule // keypad
