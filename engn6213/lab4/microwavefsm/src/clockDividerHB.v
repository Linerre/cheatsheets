module clockDividerHB
#(parameter integer THRESHOLD = 50_000_000)
    (input wire  clk,
     input wire  reset,
     input wire  enable,
     output wire beat,
     output reg  dividedClk);


    reg [31:0] counter;

    // Clock goes at the default speed: 1 cycle every 10ns
    // Counter starts with 0 and when counts to 49, 50 clock cycles passed.
    // In this case, we need 1Hz clock cycles, that is the THRESHOLD
    // The clock goes HIGH for 0.5s and then goes LOW for 0.5s
    // In general, THRESHOLD = needed_number_of_cycles
    // How many numbers of cycles we need so that that take 0.5s in total?
    // needed_cycles_num = 0.5s / 10ns = 50_000_000
    always @ (posedge clk)
        begin
            if (reset == 1'b1 || counter >= THRESHOLD-1)
                counter <= 1'b0;
            else if (enable == 1'b1)
                counter <= counter + 1'b1;
        end

    // dividedClk is the desired clock we want to use
    // counter reaches THRESHOLD-1 every 0.5s, so dividedClk becomes 1 every 0.5s
    always @ (posedge clk)
        begin
            if (reset == 1'b1)
                dividedClk <= 1'b0;
            else if (counter >= THRESHOLD - 1)
                dividedClk <= ~dividedClk;
            // sequential logic, no else statement is fine here
        end

    // Though an output, this beat rarely connects to any board port
    // Instead, it remains internal to a logic design
    assign beat = (counter == THRESHOLD-1) & (dividedClk);

endmodule
