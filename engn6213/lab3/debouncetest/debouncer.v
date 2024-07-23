module debouncer (
    input wire switchIn,
    input wire clk,
    input wire reset,
    output wire debounceout);
    wire beat;
    
    // 3_333_333
    clockDividerHB #(.THRESHOLD(3_333_333)) div (.clk(clk),
                                                .enable(1'b1),
                                                .reset(reset), 
                                                .dividedClk(),
                                                .beat(beat));

    reg[2:0] pipeline;
    always @(posedge clk) begin
        // beat?
        if (beat) begin
            pipeline[0] <= switchIn;
            pipeline[1] <= pipeline[0];
            pipeline[2] <= pipeline[1];
        end    
    end
    
    assign debounceout = &pipeline;
endmodule
