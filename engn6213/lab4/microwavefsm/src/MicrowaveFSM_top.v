`timescale 1ns / 1ps

module MicrowaveFSM_top(
   input wire         clk,
   input wire         enter,
   input wire         reset,
   input wire [15:0]  SW,
   output wire [15:0] LED,
   output reg [6:0]   CATHODE,
   output reg [3:0]   ANODE
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
   always@ (posedge clk)
      begin
         if (beat_top)
            begin
               r1 <= enter;       // 1st register in synchronizer
               r2 <= r1;          // 2dn register in synchronizer
               r3 <= r2;          // remeber prev btn state
            end
      end

   // Goes HIGH for one cycle of CLK whenever IN (r2) makes a low-to-high transition
   // SPOT aims for HIGH duration, not when to goes HIGH
   assign stable_enter = ~r3 & r2;


   // Debounce other swithches?
   // reg [15:0] deb_sw;
   // debouncer deb_sw0(.btn_in(SW[0]),.clk(clk),.reset(reset),.deb_out(deb_sw[0]));
   // debouncer deb_sw1(.btn_in(SW[1]),.clk(clk),.reset(reset),.deb_out(deb_sw[1]));
   // debouncer deb_sw2(.btn_in(SW[2]),.clk(clk),.reset(reset),.deb_out(deb_sw[2]));
   // debouncer deb_sw3(.btn_in(SW[3]),.clk(clk),.reset(reset),.deb_out(deb_sw[3]));
   // debouncer deb_sw4(.btn_in(SW[4]),.clk(clk),.reset(reset),.deb_out(deb_sw[4]));
   // debouncer deb_sw5(.btn_in(SW[5]),.clk(clk),.reset(reset),.deb_out(deb_sw[5]));
   // debouncer deb_sw6(.btn_in(SW[6]),.clk(clk),.reset(reset),.deb_out(deb_sw[6]));
   // debouncer deb_sw7(.btn_in(SW[7]),.clk(clk),.reset(reset),.deb_out(deb_sw[7]));
   // debouncer deb_sw8(.btn_in(SW[8]),.clk(clk),.reset(reset),.deb_out(deb_sw[8]));
   // debouncer deb_sw9(.btn_in(SW[9]),.clk(clk),.reset(reset),.deb_out(deb_sw[9]));
   // debouncer deb_sw10(.btn_in(SW[10]),.clk(clk),.reset(reset),.deb_out(deb_sw[10]));
   // debouncer deb_sw11(.btn_in(SW[11]),.clk(clk),.reset(reset),.deb_out(deb_sw[11]));
   // debouncer deb_sw12(.btn_in(SW[12]),.clk(clk),.reset(reset),.deb_out(deb_sw[12]));
   // debouncer deb_sw13(.btn_in(SW[13]),.clk(clk),.reset(reset),.deb_out(deb_sw[13]));
   // debouncer deb_sw14(.btn_in(SW[14]),.clk(clk),.reset(reset),.deb_out(deb_sw[14]));
   // debouncer deb_sw15(.btn_in(SW[15]),.clk(clk),.reset(reset),.deb_out(deb_sw[15]));


   FSM mvfsm(.clk(clk), .enter(stable_enter), .reset(reset), .SW(SW), .LED(LED));

endmodule
