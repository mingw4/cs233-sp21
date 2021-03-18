module timer(TimerInterrupt, cycle, TimerAddress,
             data, address, MemRead, MemWrite, clock, reset);
    output        TimerInterrupt;
    output [31:0] cycle;
    output        TimerAddress;
    input  [31:0] data, address;
    input         MemRead, MemWrite, clock, reset;

    // complete the timer circuit here

    // HINT: make your interrupt cycle register reset to 32'hffffffff
    //       (using the reset_value parameter)
    //       to prevent an interrupt being raised the very first cycle
    wire [31:0] Cycle_counter_Q, Cycle_counter_D, Interrupt_cycle_Q;
    wire        TimerRead, TimerWrite, Acknowledge, enableInterruptLine, resetInterrupt_line, left_qual, middle_equal, right_equal;

    assign left_qual = (Cycle_counter_Q == Interrupt_cycle_Q);
    assign middle_equal = (address == 32'hffff001c);
    assign right_equal = (address == 32'hffff006c);

    register Cycle_counter(Cycle_counter_Q, Cycle_counter_D, clock, 1'b1, reset);
    register #(32, 32'hffffffff) Interrupt_cycle(Interrupt_cycle_Q, data, clock, TimerWrite, reset);
    register #(1) Interrupt_line(TimerInterrupt, 1'b1, clock, left_qual, resetInterrupt_line);

    and upper_and(Acknowledge, right_equal, MemWrite);
    and middle_and(TimerRead, middle_equal, MemRead);
    and lower_end(TimerWrite, middle_equal, MemWrite);

    or lower_or(TimerAddress, middle_equal, right_equal);
    or upper_or(resetInterrupt_line, Acknowledge, reset);

    tristate triangle_thing(cycle, Cycle_counter_Q, TimerRead);

    alu32 the_only_alu(Cycle_counter_D, , , `ALU_ADD, Cycle_counter_Q, 32'b1);
    
endmodule
