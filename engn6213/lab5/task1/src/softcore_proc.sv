///////////////////////////////////////////////////////////////////////////////
/*
                        Softcore Microprocessor
                         Processor Core Module
               ENGN4213 Digital Systems and Microprocessors
                           CEA Technologies

 The simplest general purpose computing machine (a microproccessor) is a state
 machine capable of executing about 20 instructions, some memory to store the
 program and variables, and an arithmetic logic unit (ALU).
 A "softcore" processor is a processor implemented on an FPGA. A large FPGA
 project could have dozens of softcore processors in various places to do
 certain operations that are more easily done sequentially than concurrently.

 Small softcore processors can be quite small, can be written in a few hours,
 and if targetted for a specific application don't need to implement a full
 instruction set.

 This is a basic softcore processor designed to execute a fixed simple program.
 Your task is to finish it.
*/
///////////////////////////////////////////////////////////////////////////////

// default_nettype none tells the compiler to thrown an error when it finds a
// variable that hasn't been declared. Without it, the compiler will create
// new nets in certain cases when you didn't intend that to happen. This
// can cause a misspelling to go unnoticed and cause your design not to work.
`default_nettype none


// The import command loads a package that contains types & parameters that
// need to be used in multple locations. Importing the package here imports
// the variables into the global space. Imports can be done in different
// locations depending on what scope you want.
import command_package::*;

module softcore_proc #(
   //------------------------------------------------------
   //--                Module Parameters                 --
   //------------------------------------------------------
   parameter int  SIMULATION     = 0,           // The SIMULATION variable is used to reduce the wait times. A second delay may be reasonable in real life, but trying to simulate that will take hours!
   parameter int  CLK_FREQUENCY  = 100_000_000  // This is the frequency 'clk_in' is running at in Hz.
)(
   //------------------------------------------------------
   //--                   Module Ports                   --
   //------------------------------------------------------
   input  wire          clk_in,           // Putting _in & _out at the end of port names greatly aids clarity when writing verilog.
   input  wire          nrst_in,          // Active Low reset signal. The polarity of the reset really doesn't matter in an FPGA but in electronics active low is usually a little easier.

   input  wire          enable_in,        // This signal must be high for the module to run. When low, the module resets.
   output wire          term_out,         // Goes high when the program is finished.

   input  wire          push_button_in,   // Input from a push button - used for the WAIT_ON_BUTTON instruction.
   input  wire [15:0]   dip_in,           // Input from the DIP Switches - gets mapped to a register
   output wire [15:0]   leds_out,         // Output to the LEDs - gets mapped to a register

   input  CommandType   program_array_in [0:MAX_NUM_COMMANDS-1]   // The program is passed into the module so that this module can be reused to run multiple different programs. It also aids in testbench verification
);
   //------------------------------------------------------
   //--              Localparams and Types               --
   //------------------------------------------------------
   // There are multiple different ways to declare a state machine in verilog.
   // This method is probably the best for a couple of reasons.
   //    1) By using an enum, most simulators will display the textual name of the state
   //       rather than the number
   //    2) It gives the sythesiser freedom to optimise the FSM.
   // You do not need to write a FSM as 'one-hot', or grey coded when targetting
   // an FPGA device, as the synthesiser will detect and optimse the state
   // machine. What's important is that you write the FSM in a manner that the
   // synthesiser can recognise.
   typedef enum logic [3:0] {
      STATE_INIT,
      STATE_FETCH,
      STATE_WAIT,
      STATE_WAIT_ON_BUTTON,
      STATE_EXECUTE,
      STATE_INCREMENT,
      STATE_TERM
   } ProcFSMType;

   localparam int       DECISEC_TO_CYCLES = (SIMULATION==0) ? (CLK_FREQUENCY / 10) : (CLK_FREQUENCY / 10_000);  // Simulation will run 1000x faster than real life for wait commands
   localparam int       MAX_TIME          = 26;                            // Seconds
   localparam longint   MAX_TIMER_COUNT   = MAX_TIME * CLK_FREQUENCY;      // Number of cycles needed to count MAX_TIME
   localparam int       MAX_TIMER_W       = $clog2(MAX_TIMER_COUNT + 1);   // Bit width of the timer needed to represent MAX_TIMER_COUNT
   //------------------------------------------------------
   //--                    Assertions                    --
   //------------------------------------------------------
   // Assertions are useful to detect user errors with parameters. While
   // there is an assert keyword in verilog, it is not supported by all
   // compilers. 'Initial if' is the safest way to do this. (This is a 
   // regular if statement inside a regular initial block).
   // $error causes the compiler to halt & thrown an error.
   initial if(MAX_NUM_COMMANDS_W != 8) $error("The width of the command address and program counter need to be identical for the jump statements to work");
   //------------------------------------------------------
   //--                 Local Variables                  --
   //------------------------------------------------------
   // Although verilog lets you declare variables anywhere. It makes your life
   // much easier to declare them all at the top.
   genvar                           g;                // A genvar is used in a generate loop. A generate loop can only use a genvar!
   ProcFSMType                      processor_fsm;    // It's not really necessary to declare a FSM type & then the variable, I just think it's neater.
   reg   [MAX_NUM_COMMANDS_W-1:0]   program_counter;
   reg   [4:0][7:0]                 register;
   CommandType                      current_command;  // CommandType is defined in command_package.sv
   wire                             timer_done;
   reg   [MAX_TIMER_W-1:0]          timer;
   wire  [MAX_TIMER_W-1:0]          comparision_time;
   wire  [7:0]                      adder_result;
   wire  [7:0]                      and_result;
   wire  [7:0]                      or_result;
   wire  [7:0]                      xor_result;
   ////////////////////////////////////////////////////////////////////////////
   //                        Processor State Machine                         //
   ////////////////////////////////////////////////////////////////////////////
   // Writing state machines can get messy real fast. One way to clean it up
   // is to minimise the number of variables you have in an always block. This
   // always block only controls the processor_fsm registers. This block only
   // specifies how the states change. What happens at each state is specified
   // in different always blocks for those variables.
   always @(posedge clk_in)begin
      if(!nrst_in)begin
         processor_fsm <= STATE_INIT;
      end else begin
         case(processor_fsm)
            STATE_INIT : begin
               // Wait for the enable signal to be high before starting the processor
               if(enable_in)begin
                  processor_fsm <= STATE_FETCH;
               end
            end

            STATE_FETCH : begin
               // This state interprets the command the program counter is pointing to
               case(current_command.instruction)
                  INSTR_WAIT : begin
                     processor_fsm <= STATE_WAIT;
                  end
                  INSTR_WAIT_ON_BUTTON : begin
                     processor_fsm <= STATE_WAIT_ON_BUTTON;
                  end
                  INSTR_STORE_DIRECT : begin
                     processor_fsm <= STATE_EXECUTE;
                  end
                  INSTR_STORE : begin
                     processor_fsm <= STATE_EXECUTE;
                  end
                  INSTR_LOAD : begin
                     processor_fsm <= STATE_EXECUTE;
                  end
                  INSTR_ADD : begin
                     processor_fsm <= STATE_EXECUTE;
                  end
                  INSTR_AND : begin
                     processor_fsm <= STATE_EXECUTE;
                  end
                  INSTR_OR : begin
                     processor_fsm <= STATE_EXECUTE;
                  end
                  INSTR_XOR : begin
                     processor_fsm <= STATE_EXECUTE;
                  end
                  INSTR_JUMP : begin
                     processor_fsm <= STATE_INCREMENT;
                  end
                  INSTR_JUMP_GT : begin
                     processor_fsm <= STATE_INCREMENT;
                  end
                  INSTR_JUMP_EQ : begin
                     processor_fsm <= STATE_INCREMENT;
                  end
                  INSTR_JUMP_LT : begin
                     processor_fsm <= STATE_INCREMENT;
                  end
                  INSTR_TERM : begin
                     processor_fsm <= STATE_TERM;
                  end
               endcase
            end

            STATE_WAIT : begin
               // I need to wait for the timer to tell me the correct time has
               // passed
               if(timer_done)begin
                  processor_fsm <= STATE_INCREMENT;
               end
            end

            STATE_WAIT_ON_BUTTON : begin
               // Wait until the button is toggled.
               if(push_button_in)begin
                  processor_fsm <= STATE_INCREMENT;
               end
            end

            STATE_EXECUTE : begin
               // If all my operations take only one clock cycle, I can
               // transition to increment immediately.
               // If an operation takes more that one clock cycle, I will need
               // to use the timer to give enough time for the instruction to
               // complete.
               processor_fsm <= STATE_INCREMENT;
            end

            STATE_INCREMENT : begin
               // This state instructs the program counter to increment
               processor_fsm <= STATE_FETCH;
            end

            STATE_TERM : begin
               // If the enable control goes low, reset the processor
               if(!enable_in)begin
                  processor_fsm <= STATE_INIT;
               end
            end

            default : begin
               // This should never occur
               processor_fsm <= STATE_TERM;
            end
         endcase
      end
   end
   //------------------------------------------------------
   //--                 Current Command                  --
   //------------------------------------------------------
   assign current_command = program_array_in[program_counter];

   //------------------------------------------------------
   //--                 Program Counter                  --
   //------------------------------------------------------
   // The program counter is the register in a CPU that keeps track of which
   // instruction the processor is up to. Here is always increments in order
   // unless a jump command is issued.
   always @(posedge clk_in)begin
      if(!nrst_in)begin
         program_counter <= {MAX_NUM_COMMANDS_W{1'b0}};
      end else begin
         // The Program Counter only increments in STATE_INCREMENT
         if(processor_fsm == STATE_INCREMENT)begin

            // If it is not a jump command, increment the program counter
            program_counter <= program_counter + 1'b1;

            //!! TODO: Task 1.2
            //!! You will need to modify this block to implement the jump
            //!! command. A jump instruction moves the program counter to
            //!! a location of your choosing.
            //!! Test08 will pass when you have done this correctly

            //!! TODO: Task 2.1
            //!! Implement the remaining jump commands here as well.
            //!! These are tested in tests 10 through 15.

         end
      end
   end
   //------------------------------------------------------
   //--                 term_out signal                  --
   //------------------------------------------------------
   assign term_out = (processor_fsm == STATE_TERM);
   ////////////////////////////////////////////////////////////////////////////
   //                               Registers                                //
   ////////////////////////////////////////////////////////////////////////////
   //------------------------------------------------------
   //--               Accumulator Register               --
   //------------------------------------------------------
   always @(posedge clk_in)begin
      // Don't use resets if you don't need them! Resets are high fanout
      // signals that are difficult for the fitter to route.
      // Generally speaking you only need to reset control signals, not the
      // data path.
      if(processor_fsm == STATE_EXECUTE)begin
         if(current_command.instruction == INSTR_LOAD)begin
            if(current_command.address == 8'h00)begin
               register[0] <= current_command.data;

            end else begin
               register[0] <= register[current_command.address];

            end
         end else if(current_command.instruction == INSTR_ADD)begin
            register[0] <= adder_result;

         end else if(current_command.instruction == INSTR_AND)begin
            register[0] <= and_result;

         end else if(current_command.instruction == INSTR_OR)begin
            register[0] <= or_result;

         end else if(current_command.instruction == INSTR_XOR)begin
            register[0] <= xor_result;

         end
      end
   end
   //------------------------------------------------------
   //--                 Output Registers                 --
   //------------------------------------------------------
   // Registers 1 & 2, which are read & write registers connected
   // to the LEDs are exactly the same, so I can use a generate loop
   // to save code.
   // Note that register 0 cannot be written to in this block, because
   // it is already used in the block above.
   generate
      for(g=1;g<3;g++)begin

         always @(posedge clk_in)begin
            if(processor_fsm == STATE_EXECUTE)begin
               if(g==current_command.address)begin
                  if(current_command.instruction == INSTR_STORE)begin
                     register[g] <= register[0];
                  end
                  if(current_command.instruction == INSTR_STORE_DIRECT)begin
                     register[g] <= current_command.data;
                  end
               end
            end
         end

      end
   endgenerate
   //------------------------------------------------------
   //--     Connecting Registers to Physical Objects     --
   //------------------------------------------------------
   assign leds_out[7:0]    = register[1];
   assign leds_out[15:8]   = register[2];
   assign register[3]      = dip_in[7:0];
   assign register[4]      = dip_in[15:8];
   ////////////////////////////////////////////////////////////////////////////
   //                                 Timer                                  //
   ////////////////////////////////////////////////////////////////////////////
   // This always block synthesese to MAX_TIMER_W D flip flops with an enable
   // driven from (processor_fsm == STATE_WAIT) and an adder
   always @(posedge clk_in)begin
      if(processor_fsm == STATE_WAIT)begin
         timer <= timer + 1'b1;
      end else begin
         timer <= {MAX_TIMER_W{1'b0}};
      end
   end

   assign comparision_time = current_command.data * DECISEC_TO_CYCLES; // current_command.data is in units of 100ms. This line converts that into cycles.
   assign timer_done = (timer >= comparision_time);
   ////////////////////////////////////////////////////////////////////////////
   //                         Arithmetic Logic Unit                          //
   ////////////////////////////////////////////////////////////////////////////
   // The ALU in a CPU is the area of logic dedicated to doing arithemetic.
   // Classically it was a big deal, but in verilog it's almost trivial!
   // In this example I've only done the basic operations. But as an extension
   // it would be cool to add multiplication and division. Multiplication is
   // not that hard as there are hard multipliers in FPGAs that can do it within
   // a clock cycle. Division in logic is not easy, and requires a dedicate circuit
   // and multiple clock cycles. Modern ALUs will also do floating point arithemetic

   //!! TODO: Task 1.1
   //!! Write the commands below needed to implement the ADD, AND, & OR commands
   //!! Tests 3, 4, and 5 will pass when you have implemented them correctly.
   //!! XOR has been done for you as an example.
   //!! Recall that the ternary operator '?' can be used to reduce conditional statements ( condition ? exprIfTrue : exprIfFalse )
   //!! Gotchas: Beware of the difference between bitwise and logical operators in verilog.
   //!! assign adder_result  = ...
   //!! assign and_result    = ...
   //!! assign or_result     = ...
   assign xor_result    = register[0] ^ ((current_command.address==8'h00) ? current_command.data : register[current_command.address]);

endmodule
