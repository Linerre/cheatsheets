

task automatic test09(
   output bit result
);

   //------------------------------------------------------
   //--                 Local Variables                  --
   //------------------------------------------------------
   bit      temp_result;
   bit      final_result = 1'b1;
   int      running_value;
   test_num = "Test 09";
   //------------------------------------------------------
   //--                    Test Setup                    --
   //------------------------------------------------------

   program_array[0] <=  {INSTR_LOAD,            8'h00,      8'h00}; // acc = 0;
                                                                    // do {
   program_array[1] <=  {INSTR_WAIT_ON_BUTTON,  8'h03,      8'h03}; //   wait_on_button();
   program_array[2] <=  {INSTR_ADD,             8'h03,      8'hFF}; //   add(acc, dip[7:0]);
   program_array[3] <=  {INSTR_STORE,           8'h01,      8'h33}; //   store(acc,leds[7:0]);
   program_array[4] <=  {INSTR_JUMP,            8'h01,      8'h00}; // } while(1);
   program_array[5] <=  {INSTR_TERM,            8'h00,      8'h00};
   $display("Running %s",test_num);
   $display("Testing the addition only calculator program");
   ////////////////////////////////////////////////////////////////////////////
   //                            Running the test                            //
   ////////////////////////////////////////////////////////////////////////////
   enable_in <= 1'b1;
   #(10*CLK_PERIOD);

   for(int i=0;i<5;i++)begin
      running_value = running_value + i;  // NB: running_value is a software variable, so using a blocking =
      // Add i to the result
      dip_in[7:0] <= i[7:0]; // NB: dip_in is a hardware variable, so using a non-blocking <=
      toggle_button();
      #(10*CLK_PERIOD);

      // Verify the LEDs show the answer
      temp_result = (leds_out[7:0] === running_value);
      final_result &= temp_result;

   end

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
