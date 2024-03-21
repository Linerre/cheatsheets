module FSM (
  input wire        clk,
  input wire        enter,
  input wire        reset,
  input wire [15:0] SW,
  output reg [15:0] LED,
  output wire [6:0] ssd_cathode // ssd for indicating current state
  // output reg [3:0]  ssd_anode
) ;

   // States encoding
   parameter        IDLE = 2'd0;
   parameter        COOK = 2'd1;
   parameter        SET_TIMER = 2'd2;
   parameter        ALARM = 2'd3;

   reg [1:0]        state, nextState;
   wire             beat;
   reg [15:0]       ledcount;
   reg [15:0]       ledtoggle = 16'd0;
   reg [6:0]        cathode;

   // Create 1Hz beat, using the default THRESHOLD
   clockDividerHB clkfsm (
     .clk(clk),
     .reset(reset),
     .enable(1'b1),
     .beat(beat),
     .dividedClk()
   );

   // State memory - sequential
   always@ (posedge clk) begin
      if (reset)  state <= IDLE;
      else state <= nextState;
   end

   // Next state logic - combinational
   always@ (*) begin
      case (state)
        IDLE: begin
           if (enter) nextState = SET_TIMER;
           else nextState = IDLE;
        end
        SET_TIMER: begin
           if (enter) nextState = COOK;
           else nextState = SET_TIMER;
        end
        COOK: begin
           // counter overflow
           // `&` is reduction:
           // for each bit of ~LED, compute 1 AND (~LED)[i] and get a result
           // use the result to compute result = result AND (~LED)[i+1];
           // and so on until there is only bit left, that is, the result
           // When counter overflows, LED is 16'b0, thus ~LED is 16'b1(16)
           if (&(~LED)) nextState = ALARM;
           else nextState = COOK;
        end
        ALARM: begin
           if (enter) nextState = IDLE;
           else nextState = ALARM;
        end
        default: nextState = IDLE;
      endcase // case (state)
   end

   // Counter - sequential
   always@ (posedge clk)
     begin
        if (state == SET_TIMER) ledcount <= SW;
        else if (beat) ledcount <= ledcount >> 1;
        // In sequential logic, ok to leave out the else branch
     end

   // Toggle - sequential
   always@ (posedge clk)
     begin
        if (beat) ledtoggle <= 16'b1111_1111_1111_1111;
        else ledtoggle <= ~ledtoggle;
     end

   // Output logic - combinational
   always@ (*)
     begin
        case (state)
          IDLE : begin
             cathode = 7'b0000001; // display number 0
             LED = 16'd0;
          end
          SET_TIMER: begin
             cathode = 7'b1001111; // display number 1
             LED = SW;
          end
          COOK : begin
             cathode = 7'b0010010; // display number 2
             LED = ledcount;
          end
          ALARM : begin
             cathode = 7'b0000110; // display number 3
             LED = ledtoggle;
          end

          default: begin
             cathode = 7'b0000001; // display number 0
             LED = 16'b1111_1111_1111_1111;
          end

        endcase // case (state)
     end

   assign ssd_cathode = cathode;

endmodule // FSM
