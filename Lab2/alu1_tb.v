module alu1_test;
    // exhaustively test your 1-bit ALU implementation by adapting mux4_tb.v
    reg A = 0;
    always #1 A = !A;
    reg B = 0;
    always #2 B = !B;
    reg cin = 0;
    always #4 cin = !cin;
    reg [2:0] control = 0;

    initial begin
        $dumpfile("alu1.vcd");
        $dumpvars(0, alu1_test);
        # 8 control = 1;
        # 8 control = 2;
        # 8 control = 3;
        # 8 control = 4;
        # 8 control = 5;
        # 8 control = 6;
        # 8 control = 7;
        # 8 $finish;
    end

    wire out, carryout;
    alu1 a(out, carryout, A, B, cin, control);
    initial begin
        $display("A B cin control out carryout");
        $monitor("%d %d %d %d %d %d (at time %t)", A, B, cin, control, out, carryout, $time);
    end
endmodule
