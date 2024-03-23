// Serial-in-parallel-out shift registers
module sipo(input wire         clk,
            input wire         reset,
            input wire  [1:0]  btn_in,
            output wire [11:0] user_steps
);

   reg [11:0] Q ;
   always @ (posedge clk)
   begin
      if (reset) Q <= 12'd0;
      else Q <= {btn_in, Q[11:2]};
   end

   assign user_steps = Q;
endmodule
