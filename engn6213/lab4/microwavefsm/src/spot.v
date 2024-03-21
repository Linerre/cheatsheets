// Single pulse on transition or level-to-pulse
// When a btn/sw (asynchronous) is pressed/turned on, really ON, the spot creates
// a HIGH value for one cycle (one clock period wide)
module spot (
input wire clk,
input wire spot_in,
output wire spot_out);
reg D;
// you write the module code!
    always @(posedge clk) begin
        D <= spot_in;
    end
    assign spot_out = spot_in &(~D);
endmodule
