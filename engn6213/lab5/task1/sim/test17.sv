

task automatic test17(
   output bit result
);

   //------------------------------------------------------
   //--                 Local Variables                  --
   //------------------------------------------------------
   bit      temp_result;
   bit      final_result = 1'b1;
   string   test_num = "Test 17";
   int      running_value;
   //------------------------------------------------------
   //--                    Test Setup                    --
   //------------------------------------------------------

   //!! TODO Task Section 7.3
   //!! You need to write a program here that implements the following pseudo code.
   //!! You have all the instructions needed to do this now.
   //!! Some lines are filled for you. Follow the comments to write the rest of the program
   //!! Note: Make sure you remember to set the index of the program array properly.

   //!! acc = 0;
   //!! do {
   //!!    wait_on_button();
   //!!    if(dip[15:8] == 0)
   //!!       add(acc, dip[7:0]);
   //!!    else if(dip[15:8] == 8'd1)
   //!!       and(acc, dip[7:0]);}
   //!!    else if(dip[15:8] == 8'd2)
   //!!       or(acc, dip[7:0]);
   //!!    else if(dip[15:8] == 8'd3)
   //!!       xor(acc, dip[7:0]);
   //!!    else if(dip[15:8] == 8'd4)
   //!!       not(acc);
   //!!    else if(dip[15:8] == 8'd5)
   //!!       subtract(acc, dip[7:0]);
   //!!    else
   //!!       term;
   //!! } while(1);



   // Initialise acc
   program_array[0] <=  {INSTR_LOAD,            8'h00,      8'h00};
   // Wait for user input
   program_array[1] <=  {INSTR_WAIT_ON_BUTTON,  8'h03,      8'h03};
   // Put the current accumulator into reg 1
   program_array[2] <=  {INSTR_STORE,           8'h01,      8'h03};
   // Load reg4
   program_array[3] <=  {INSTR_LOAD,            8'h04,      8'h03};
   // Evaluate if - Jump EQ
   program_array[4] <=  {INSTR_JUMP_EQ,         8'd11,      8'h00};
   program_array[5] <=  {INSTR_JUMP_EQ,         8'd15,      8'h01};
   program_array[6] <=  {INSTR_JUMP_EQ,         8'd19,      8'h02};
   // Write the conditional jump to the Xor section
   program_array[7] <=  {INSTR_JUMP_EQ,         8'd23,      8'h03};
   // Write the conditional jump to the Not section
   program_array[8] <=  {INSTR_JUMP_EQ,         8'd27,      8'h04};
   // Write the conditional jump to the Subtract section
   program_array[9] <=  {INSTR_JUMP_EQ,         8'd31,      8'h05};

   // Jump to the end of the program
   program_array[10]<=  {INSTR_JUMP,            8'd37,      8'h05};

   // Add section
      // Lcad reg1 back into acc
   program_array[11]<=  {INSTR_LOAD,            8'h01,      8'h03};
      // Do the operation
   program_array[12]<=  {INSTR_ADD,             8'h03,      8'hFF};
      // Store to LEDs
   program_array[13]<=  {INSTR_STORE,           8'h01,      8'h33};
      // Loop back to start
   program_array[14]<=  {INSTR_JUMP,            8'h01,      8'h00};

   // And section
      // Lcad reg1 back into acc
   program_array[15]<=  {INSTR_LOAD,            8'h01,      8'h03};
      // Do the operation
   program_array[16]<=  {INSTR_AND,             8'h03,      8'hFF};
      // Store to LEDs
   program_array[17]<=  {INSTR_STORE,           8'h01,      8'h33};
      // Loop back to start
   program_array[18]<=  {INSTR_JUMP,            8'h01,      8'h00};

   // Or section
      // You need to fill in this section
   program_array[19]<=  {INSTR_LOAD,            8'd01,      8'h03};
   program_array[20]<=  {INSTR_OR,              8'd03,      8'h03};
   program_array[21]<=  {INSTR_STORE,           8'h01,      8'h33};
   program_array[22]<=  {INSTR_JUMP,            8'h01,      8'h00};
   // Xor section
      // You need to fill in this section
   program_array[23]<=  {INSTR_LOAD,            8'd01,      8'h03};
   program_array[24]<=  {INSTR_XOR,             8'd03,      8'h03};
   program_array[25]<=  {INSTR_STORE,           8'h01,      8'h33};
   program_array[26]<=  {INSTR_JUMP,            8'h01,      8'h00};

   // Not section
      // You need to fill in this section
   program_array[27]<=  {INSTR_LOAD,            8'd01,      8'h03};
   program_array[28]<=  {INSTR_NOT,             8'd00,      8'h03};
   program_array[29]<=  {INSTR_STORE,           8'h01,      8'h33};
   program_array[30]<=  {INSTR_JUMP,            8'h01,      8'h00};

   // subtract section
      // You need to fill in this section
	  // Consider 2's complement for subtraction
   program_array[31]<=  {INSTR_LOAD,            8'd03,      8'h03};
   program_array[32]<=  {INSTR_NOT,            8'd03,      8'h03};
   program_array[33]<=  {INSTR_ADD,             8'd00,      8'h01};
   program_array[34]<=  {INSTR_ADD,             8'd01,      8'h01};
   program_array[35]<=  {INSTR_STORE,           8'h01,      8'h33};
   program_array[36]<=  {INSTR_JUMP,            8'h01,      8'h00};

   // Terminate Section, the end of the program. The index may be extended to fit extra instructions if needed.
   program_array[37]<=  {INSTR_TERM,            8'h00,      8'h00};
   $display("Running %s",test_num);
   $display("Testing the full calculator program");
   ////////////////////////////////////////////////////////////////////////////
   //                            Running the test                            //
   ////////////////////////////////////////////////////////////////////////////
   // The test is:
   // 0 + 5 = 5
   // 5 + 2 = 7
   // 7 & E = 6
   // 6 | 3 = 7
   // 7 ^ 3 = 4
   // 4 - 1 = 3
   // ~3 = FC

   enable_in <= 1'b1;
   #(10*CLK_PERIOD);

   // 0 + 5 = 5
   dip_in[15:8]   <= 8'd0;
   dip_in[7:0]    <= 8'd5;
   toggle_button();
   #(60*CLK_PERIOD);

   // Verify the LEDs show the answer
   temp_result = (leds_out[7:0] === 8'd5);
   final_result &= temp_result;


   // 5 + 2 = 7
   dip_in[15:8]   <= 8'd0;
   dip_in[7:0]    <= 8'd2;
   toggle_button();
   #(60*CLK_PERIOD);

   // Verify the LEDs show the answer
   temp_result = (leds_out[7:0] === 8'd7);
   final_result &= temp_result;

   // 7 & E = 6
   dip_in[15:8]   <= 8'd1;
   dip_in[7:0]    <= 8'h0E;
   toggle_button();
   #(60*CLK_PERIOD);

   // Verify the LEDs show the answer
   temp_result = (leds_out[7:0] === 8'd6);
   final_result &= temp_result;

   // 6 | 3 = 7
   dip_in[15:8]   <= 8'd2;
   dip_in[7:0]    <= 8'd3;
   toggle_button();
   #(60*CLK_PERIOD);

   // Verify the LEDs show the answer
   temp_result = (leds_out[7:0] === 8'd7);
   final_result &= temp_result;

   // 7 ^ 3 = 4
   dip_in[15:8]   <= 8'd3;
   dip_in[7:0]    <= 8'd3;
   toggle_button();
   #(60*CLK_PERIOD);

   // Verify the LEDs show the answer
   temp_result = (leds_out[7:0] === 8'd4);
   final_result &= temp_result;

   // 4 - 1 = 3
   dip_in[15:8]   <= 8'd5;
   dip_in[7:0]    <= 8'd1;
   toggle_button();
   #(60*CLK_PERIOD);

   // Verify the LEDs show the answer
   temp_result = (leds_out[7:0] === 8'd3);
   final_result &= temp_result;

   // ~3 = FC
   dip_in[15:8]   <= 8'd4;
   dip_in[7:0]    <= 8'd1;
   toggle_button();
   #(60*CLK_PERIOD);

   // Verify the LEDs show the answer
   temp_result = (leds_out[7:0] === 8'hFC);
   final_result &= temp_result;

   #(40*CLK_PERIOD);



   //------------------------------------------------------
   //--                     Cleanup                      --
   //------------------------------------------------------
   if(!final_result)begin
      $error("%s FAILED!",test_num);
   end else begin
      $info("%s PASSED!",test_num);
   end
   result = final_result;
   cleanup();
endtask
