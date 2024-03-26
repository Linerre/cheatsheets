

task automatic test02(
   output bit result
);
   
   //------------------------------------------------------
   //--                 Local Variables                  --
   //------------------------------------------------------
   bit temp_result;
   bit final_result = 1'b1;
   test_num = "Test 02";
   
   //------------------------------------------------------
   //--                    Test Setup                    --
   //------------------------------------------------------
   
   program_array[0] <=  {INSTR_LOAD,         8'h00,      8'h20};
   program_array[1] <=  {INSTR_STORE,        8'h01,      8'h33};
   program_array[2] <=  {INSTR_TERM,         8'h00,      8'h00};
   $display("Running %s",test_num);
   $display("Test the load & store commands");
   ////////////////////////////////////////////////////////////////////////////
   //                            Running the test                            //
   ////////////////////////////////////////////////////////////////////////////
   enable_in <= 1'b1;
   #(20*CLK_PERIOD);
   
   // Did the LEDs write correctly?
   temp_result = (leds_out[7:0] === 8'h20);
   final_result &= temp_result;
   
   // Did the processor terminate?
   temp_result = (term_out === 1'b1);
   final_result &= temp_result;
   
   
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
