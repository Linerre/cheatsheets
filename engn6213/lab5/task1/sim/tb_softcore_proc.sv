///////////////////////////////////////////////////////////////////////////////
/*
                        Softcore Microprocessor
                          Automated Testbench
               ENGN4213 Digital Systems and Microprocessors
                           CEA Technologies

 This module is the top level testbench. By far the best way to test your code
 works is with an automated testbench. You can tailor the tests to look for
 edge cases and stress test your module, and you don't need to search through the
 waveform view to figure out if it works. I have written a pretty basic testbench
 here, just checking that each instruction works the way I intended.

 NOTE WELL: Verilog & VHDL have synthesizable code, and simulation code. In the
 former you are in hardware land, and you are describing circuits. In the latter
 you are in software land, and are writing a program. This testbench is in
 software land, and I am doing things that cannot be done in an FPGA. The most
 confusing thing for beginners is getting your head around what is software and
 what is hardware description. Especially since they are written in the same
 language. A testbench will contain some hardware bits, and some software bits
 interchanged at the same time.

*/
///////////////////////////////////////////////////////////////////////////////
`default_nettype none   // Verilog is a little too weakly typed. This directive tells the compiler not to invent nets that you haven't declared.

import command_package::*;

module tb_softcore_proc();
   // These statements say that my testbench tick is 1ns, which is fine since I'm using a 10ns clk period, a nice integer multiple of 1.
   timeunit 1ns;
   timeprecision 1ns;
   //------------------------------------------------------
   //--              Localparams and Types               --
   //------------------------------------------------------
   localparam CLK_PERIOD = 10ns;
   localparam int N_TESTS = 17;
   //------------------------------------------------------
   //--                 Local Variables                  --
   //------------------------------------------------------
   logic                clk_in;
   logic                nrst_in;
   logic                enable_in;
   logic                term_out;
   logic                push_button_in;
   logic [15:0]         dip_in;
   logic [15:0]         leds_out;
   CommandType          program_array [0:MAX_NUM_COMMANDS-1];
   logic [N_TESTS:1]    test_result;
   string               test_num;
   ////////////////////////////////////////////////////////////////////////////
   //                                 Tests                                  //
   ////////////////////////////////////////////////////////////////////////////
   // An initial block runs at simulation startup once. You can have as many
   // initial blocks as you want, they run as separate concurrent threads.
   initial begin
      cleanup();
      run();
   end

   // A task is a function that knows about time. An automatic task has it's
   // own memory space and won't stop on variables in other threads.
   task automatic run();
      bit   passed = 1'b1;
      bit   result;

      // Running the tests
      test01(test_result[1]);  passed &= test_result[1];
      test02(test_result[2]);  passed &= test_result[2];
      test03(test_result[3]);  passed &= test_result[3];
      test04(test_result[4]);  passed &= test_result[4];
      test05(test_result[5]);  passed &= test_result[5];
      test06(test_result[6]);  passed &= test_result[6];
      test07(test_result[7]);  passed &= test_result[7];
      test08(test_result[8]);  passed &= test_result[8];
      test09(test_result[9]);  passed &= test_result[9];
      test10(test_result[10]); passed &= test_result[10];
      test11(test_result[11]); passed &= test_result[11];
      test12(test_result[12]); passed &= test_result[12];
      test13(test_result[13]); passed &= test_result[13];
      test14(test_result[14]); passed &= test_result[14];
      test15(test_result[15]); passed &= test_result[15];
      test16(test_result[16]); passed &= test_result[16];
      test17(test_result[17]); passed &= test_result[17];

      #(20*CLK_PERIOD);

      // Displaying the results
      $display("------------------------------------------------------");
      for(int i=1;i<=N_TESTS;i++)begin
         if(test_result[i]===1'b1)begin   // === 1'b1 means it must equal 1'b1, it can't be x or z
            $display("Test %1d: PASSED!",i);
         end else begin
            $display("Test %1d: FAILED!",i);
         end
      end
      $display("------------------------------------------------------");
      if(passed)
         $display("Result: PASSED!");
      else
         $display("Result: FAILED!");
      $display("------------------------------------------------------");

      $stop();
   endtask
   // `include just inserts the other file into this one. I put the tests into
   // different files so this testbench file doesn't get so big its unreadable.
   `include "test01.sv" // Test the wait & store direct command
   `include "test02.sv" // Test the load & store command
   `include "test03.sv" // Test the add command
   `include "test04.sv" // Test the and command
   `include "test05.sv" // Test the OR command
   `include "test06.sv" // Test the XOR command
   `include "test07.sv" // Test the NOT command
   `include "test08.sv" // Test the JUMP command
   `include "test09.sv" // Testing the addition only calculator program
   `include "test10.sv" // Test the JUMP_GT command
   `include "test11.sv" // Test the JUMP_GT command
   `include "test12.sv" // Test the JUMP_EQ command
   `include "test13.sv" // Test the JUMP_EQ command
   `include "test14.sv" // Test the JUMP_LT command
   `include "test15.sv" // Test the JUMP_LT command
   `include "test16.sv" // Test the WAIT_ON_BUTTON command
   `include "test17.sv" // Testing the full calculator program

   ////////////////////////////////////////////////////////////////////////////
   //                              Helper Tasks                              //
   ////////////////////////////////////////////////////////////////////////////
   // This task just resets everything so that my testbench is in the same
   // state between the different tests.
   task automatic cleanup();
      @(posedge clk_in);   // Wait until a clock edge to ensure this block runs synchronous to the clock
      push_button_in <= 1'b0;
      enable_in <= 1'b0;
      nrst_in <= 1'b0;     // Assert the reset
      program_array <= '{MAX_NUM_COMMANDS{24'dx}}; // Initialised the program array to x
      @(posedge clk_in);   // The above two commands are non-blocking, and therefore occur at this clock edge

      #(10*CLK_PERIOD);    // This waits 100ns, but doesn't guarantee the wait ends on a clock edge
      nrst_in <= 1'b1;     // Assert the reset
      @(posedge clk_in);
   endtask

   task automatic toggle_button();
      @(posedge clk_in);
      push_button_in <= 1'b1;
      @(posedge clk_in);
      push_button_in <= 1'b0;
      @(posedge clk_in);
   endtask
   ////////////////////////////////////////////////////////////////////////////
   //                               Test Logic                               //
   ////////////////////////////////////////////////////////////////////////////
   //------------------------------------------------------
   //--               Generating the Clock               --
   //------------------------------------------------------
   initial begin
      clk_in <= 1'b0;
      forever begin
         #(CLK_PERIOD/2);
         clk_in <= !clk_in;
      end
   end
   ////////////////////////////////////////////////////////////////////////////
   //                            Unit Under Test                             //
   ////////////////////////////////////////////////////////////////////////////
   softcore_proc #(
      .SIMULATION       (1),
      .CLK_FREQUENCY    (100_000_000)   // This is the frequency 'clk_in' is running at in Hz.
   ) uut (
      .clk_in           (clk_in),
      .nrst_in          (nrst_in),

      .enable_in        (enable_in),
      .term_out         (term_out),

      .push_button_in   (push_button_in),
      .dip_in           (dip_in),
      .leds_out         (leds_out),

      .program_array_in (program_array)
   );
endmodule
