module spot (
input wire clk,
input wire spot_in,
output wire spot_out);
reg D;
// you write the module code!
    always @(posedge clk) begin
        D<=spot_in;
    end
    assign spot_out = spot_in &(~D);
endmodule