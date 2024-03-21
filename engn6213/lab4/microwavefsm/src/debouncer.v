module debouncer(input wire btn_in, input wire clk, input wire reset, output wire deb_out);
    wire beat;

    // 3_333_333 is approximately 0.3s
    // if a switch remains ON for about 0.2s, then the btn/sw is considered ON
    // Instantiate the heartbeat
    clockDividerHB #(3_333_333) btn (
        .clk(clk),
        .enable(1'b1),             // always enable
        .reset(reset),
        .dividedClk(),
        .beat(beat)
    );

    reg  r1,r2;
    always @(posedge clk)
        begin
            if (beat)
                begin
                    r1 <= btn_in;
                    r2 <= r1;
                end
        end

    assign deb_out = r2;
endmodule
