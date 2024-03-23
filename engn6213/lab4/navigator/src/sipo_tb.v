module sipo_tb;

   // wire supports continuous assignment while reg does NOT
   wire [15:0] led;
   wire [11:0] uinput;          // Do not initialize this wire
   reg [3:0]   btn = 4'b0;
   reg [1:0]   ubtn;
   reg         clk = 0;
   always #5 clk = ~clk;

   reg btn_e = 0;
   reg btn_w = 0;
   reg btn_s = 0;
   reg btn_n = 0;
   reg reset = 0;

   initial begin
      #5 btn_e = 1; btn = {btn_e,btn_w,btn_s,btn_n};
      #10 btn_w = 1; btn_e = 0; btn = {btn_e,btn_w,btn_s,btn_n};
      #10 reset = 1;
      #10 reset = 0;
      #10 btn_s = 1; btn_w = 0; btn = {btn_e,btn_w,btn_s,btn_n};
      #10 btn_n = 1; btn_s = 0; btn = {btn_e,btn_w,btn_s,btn_n};
      #10 btn_e = 1; btn_n = 0; btn = {btn_e,btn_w,btn_s,btn_n};
      #10 btn_e = 1; btn = {btn_e,btn_w,btn_s,btn_n};
      #5 $finish;
   end

   always @ (posedge clk)
     begin
      case (btn)
         4'b1000: begin
            ubtn = 2'b00;
         end
         4'b0100: begin
            ubtn = 2'b01;
         end
         4'b0010: begin
            ubtn = 2'b10;
         end
         4'b0001: begin
            ubtn = 2'b11;
         end
         default: begin
            ubtn = 2'bxx;
         end
      endcase // case (btn)
   end // always @(btn)

   sipo test(.clk(clk),
             .reset(reset),
             .btn_in(ubtn),
             .user_steps(uinput)
             );

   initial
     begin
        $monitor("At time %0t, clk = %b, btn = %b, utbn = %b, usr_steps = %b",
                 $time,
                 clk,
                 btn,
                 ubtn,
                 uinput);
     end
   endmodule
