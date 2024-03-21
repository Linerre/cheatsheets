`timescale 1ns / 1ps

module MicrowaveFSM_top(
   input wire         clk,
   input wire         enter,
   input wire         reset,
   input wire [15:0]  SW,
   output wire [15:0] LED,
   output wire [6:0]  CATHODE,
   output wire [3:0]  ANODE
) ;

   wire beat_top, stable_enter;
   reg  r1,r2,r3;   // 3 1-bit D flipflop (shift-register) to debounce btn


   // Instantiate the debouncer for enter
   clockDividerHB #(3_333_333) clkmvfsm (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .dividedClk(),
      .beat(beat_top)
   );

   // Debounce enter button
   // reg [2:0] deb;
   always@ (posedge clk)
      begin
         if (beat_top)
           begin
              r1 <= enter;
              r2 <= r1;
              r3 <= r2;
              // Or use the below with reg `deb`
              // deb[0] <= enter;  // 1st register in synchronizer
              // deb[1] <= deb[0]; // 2dn register in synchronizer
              // deb[2] <= deb[1]; // remeber prev btn state
            end
      end

   // Goes HIGH for one cycle of CLK whenever IN (r2) makes a low-to-high transition
   // SPOT aims for HIGH duration, not when to goes HIGH
   assign stable_enter = ~r3 & r2;
   // assign stable_enter = &deb;

   // Spot the debounced enter
   wire spot_enter;
   spot spt (.spot_in(stable_enter), .spot_out(spot_enter), .clk(clk));

   FSM mvfsm(.clk(clk), .enter(spot_enter), .reset(reset), .SW(SW), .LED(LED), .ssd_cathode(CATHODE));

   // Use the rightmost anode (active low)
   assign ANODE = 4'b1110;

endmodule
