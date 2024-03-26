///////////////////////////////////////////////////////////////////////////////
/*
                        Softcore Microprocessor
                    Program & Instantiation Module
               ENGN4213 Digital Systems and Microprocessors
                           CEA Technologies

 The purpose of this module is to define the program the processor will run.
 By moving the program out here it makes it much easier to change without
 messing with the softcore module.
*/
///////////////////////////////////////////////////////////////////////////////
`default_nettype none

import command_package::*;

module program_module #(
   //------------------------------------------------------
   //--                Module Parameters                 --
   //------------------------------------------------------
   parameter int  CLK_FREQUENCY = 100_000_000      // This is the frequency clk_in is running at in Hz.

)(
   //------------------------------------------------------
   //--                   Module Ports                   --
   //------------------------------------------------------
   input  wire          clk_in,
   input  wire          nrst_in,

   input  wire          push_button_in,
   input  wire          enable_in,
   output wire          term_out,

   input  wire [15:0]   dip_in,
   output wire [15:0]   leds_out


);
   //------------------------------------------------------
   //--              Localparams and Types               --
   //------------------------------------------------------

   //------------------------------------------------------
   //--                 Local Variables                  --
   //------------------------------------------------------
   // This is where the program for the processor is defined.
   // Initially I tried to use a localparam for this, but sythesisers often
   // don't let you do things that you really should be able to do in
   // systemverilog. Therefore I accepted this initialised variable method
   // as the least bad option.

   CommandType program_array [0:MAX_NUM_COMMANDS-1];


   //------------------------------------------------------
   //--                     Program                      --
   //------------------------------------------------------
   initial begin
      // Bounce
                         // Instruction    Address     Data
      program_array[0]  <= {INSTR_STORE_DIRECT, 8'h01,      8'h01};     // Write 0x01 to the LEDs
      program_array[1]  <= {INSTR_WAIT,         8'h00,      8'd10};     // 10*100ms = 1 second pause.
      program_array[2]  <= {INSTR_STORE_DIRECT, 8'h01,      8'h02};     // Write 0x02 to the LEDs
      program_array[3]  <= {INSTR_WAIT,         8'h00,      8'd10};     // 10*100ms = 1 second pause.
      program_array[4]  <= {INSTR_STORE_DIRECT, 8'h01,      8'h04};
      program_array[5]  <= {INSTR_WAIT,         8'h00,      8'd10};
      program_array[6]  <= {INSTR_STORE_DIRECT, 8'h01,      8'h08};
      program_array[7]  <= {INSTR_WAIT,         8'h00,      8'd10};
      program_array[8]  <= {INSTR_STORE_DIRECT, 8'h01,      8'h10};
      program_array[9]  <= {INSTR_WAIT,         8'h00,      8'd10};
      program_array[10] <= {INSTR_STORE_DIRECT, 8'h01,      8'h20};
      program_array[11] <= {INSTR_WAIT,         8'h00,      8'd10};
      program_array[12] <= {INSTR_TERM,         8'h00,      8'h00};

      //!! TODO: Task 1.4
      //!! Replace the instructions in this inital block with the addition only
      //!! calculator program in the comments below.

      // Addition only Calculator - Test 09
      // In part 1 you will implementing the instructions necessary to run this program
      // When you are ready, copy the instructions below into the initial block above to
      // change the program.

      // program_array[0] <=  {INSTR_LOAD,            8'h00,      8'h00}; //  acc = 0;
      //                                                                  //  do {
      // program_array[1] <=  {INSTR_WAIT_ON_BUTTON,  8'h03,      8'h03}; //     wait_on_button();
      // program_array[2] <=  {INSTR_ADD,             8'h03,      8'hFF}; //     add(acc, dip[7:0]);
      // program_array[3] <=  {INSTR_STORE,           8'h01,      8'h33}; //     store(acc,leds[7:0]);
      // program_array[4] <=  {INSTR_JUMP,            8'h01,      8'h00}; //  } while(1);
      // program_array[5] <=  {INSTR_TERM,            8'h00,      8'h00};
   end


   ////////////////////////////////////////////////////////////////////////////
   //                             Processor Core                             //
   ////////////////////////////////////////////////////////////////////////////
   softcore_proc #(
      .CLK_FREQUENCY    (CLK_FREQUENCY)   // This is the frequency 'clk_in' is running at in Hz.
   ) softcore_proc_inst (
      .clk_in           (clk_in),
      .nrst_in          (nrst_in),

      .push_button_in   (push_button_in),
      .enable_in        (enable_in),
      .term_out         (term_out),

      .dip_in           (dip_in),
      .leds_out         (leds_out),

      .program_array_in (program_array)
   );
endmodule
