`timescale 1ns / 1ps

// Goode verilog coding style requires that
// module name should be exactly same as the file name
module my_mux (
               input wire X,
               input wire Y,
               input wire S,
               output wire Z
);

   assign Z = (X & S) | (Y & (~S));

endmodule
