llomodule debouncetest_top(
input wire switchA,
input wire switchB,
input wire reset,
input wire clk,
output wire [3:0] led
);

wire spot_in, spot_out, sync_out, deb_out;

assign spot_in = sync_out | deb_out;

debouncer deb (.switchIn(switchA), .clk(clk), .debounceout(deb_out), .reset(reset));

spot spot (.spot_in(spot_in), .spot_out(spot_out), .clk(clk));

counter eventcounter(.clk(clk), .enable(spot_out), .count(led), .reset(reset));

sync synchroniser (.in(switchB), .clk(clk), .out(sync_out));


endmodule
