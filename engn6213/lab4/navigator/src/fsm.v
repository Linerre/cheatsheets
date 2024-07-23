module fsm(
   input wire        clk,
   input wire        reset,
   input wire        btn_e,
   input wire        btn_w,
   input wire        btn_s,
   input wire        btn_n,
   output reg [15:0] LED,
   output wire [11:0] user_steps
   // output wire [3:0] ANODE,
   // output wire [6:0] CATHODE
/*AUTOARG*/);

   // States encoding
   parameter  S1=3'b001,S2=3'b010,S3=3'b011,S4=3'b100,S5=3'b101,S6=3'b110;
   parameter  IDLE=3'b000, READY=3'b111;
   parameter  E=2'b00,W=2'b01,S=2'b10,N=2'b11;
   parameter  correct_steps = {E,S,E,N,N,W};

   reg [1:0]  user_input;
   wire [3:0] btn;

   // 4'b1000 (bE), 4'b0100(bW), 4'b0010(bS), 4'b0001(bN)
   assign btn = {btn_e, btn_w, btn_s, btn_n};

   // Store user input SIPO shift register
   always @ (btn)
     begin
      case (btn)
         4'b1000: begin
            user_input = E;
         end
         4'b0100: begin
            user_input = W;
         end
         4'b0010: begin
            user_input = S;
         end
         4'b0001: begin
            user_input = N;
         end
         default: begin
            user_input = 2'bxx;
         end
      endcase // case (btn)
   end


   sipo inputs(.clk(clk), .reset(reset), .btn_in(user_input), .user_steps(user_steps));

   // State registers for state
   reg [2:0] state, next_state;

   // State FF for state
   always @ ( posedge clk) begin
      if (reset) state <= IDLE; else
         state <= next_state;
   end

   // Next State Logic for state
   always @ ( /*AUTOSENSE*/btn or reset or state) begin
      case (state)
         IDLE: begin
            if (reset) next_state = IDLE;
            else if (btn) next_state = S1;
            else next_state = state;
         end
         S1: begin
            if (reset) next_state = IDLE;
            else if (btn) next_state = S2;
            else next_state = state;
         end
         S2: begin
            if (reset) next_state = IDLE;
            else if (btn) next_state = S2;
            else next_state = S2;
         end
         S3: begin
            if (reset) next_state = IDLE;
            else if (btn) next_state = S4;
            else next_state = S3;
         end
         S4: begin
            if (reset) next_state = IDLE;
            else if (btn) next_state = S5;
            else next_state = S4;
         end
         S5: begin
            if (reset) next_state = IDLE;
            else if (btn) next_state = S6;
            else next_state = S5;
         end
         S6: begin
            if (reset) next_state = IDLE;
            else if (btn) next_state = READY;
            else next_state = S6;
         end
         READY: begin
            if (reset) next_state = IDLE;
            else next_state = READY;
         end
      endcase // case (state)
   end // always @ (*)


   // Output logic
   always @ (/*AS*/state) begin
      case (state)
   IDLE: begin
      LED = 16'd0;

   end
   S1: begin
      LED = 16'd1;
   end
   S2: begin
      LED = 16'd2;
   end
   S3: begin
      LED = 16'd3;
   end
   S4: begin
      LED = 16'd4;

   end
   S5: begin
      LED = 16'd5;

   end
   S6: begin
      LED = 16'd6;

   end
   READY: begin
      LED = 16'b1010_1010_1010_1010;
   end
      endcase // case (state)
   end


endmodule
