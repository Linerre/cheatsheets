`timescale 1ns / 1ps // timestep duration and time precision
module TB_my_mux;

   // Inputs to Unit Under Test (UUT)
   reg X;
   reg Y;
   reg S;

   // Output to UUT
   wire Z;

   // Instantiate the design to be tested - ensure module name match!
   my_mux UUT (
               .X(X),
               .S(S),
               .Y(Y),
               .Z(Z)
               );

   // Duration of simulation. Here set at 300 timesteps
   initial begin: stopat
      #300;
      $finish;
   end

   // Signal changes: #xx means enact change after xx timesteps
   initial begin
      X = 1'b0;
      Y = 1'b1;
      S = 1'b1;

      #30X = 1'b1;
      #30S = 1'b0;
      #30Y = 1'b0;

      #30X = 1'b0;
      #30Y = 1'b1;
      #30S = 1'b1;

      #30X = 1'b1;
      #30Y = 1'b0;
      #30S = 1'b0;
   end // initial begin

endmodule
