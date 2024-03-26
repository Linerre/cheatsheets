

task automatic test01(
   output bit result
);
   
   //------------------------------------------------------
   //--                 Local Variables                  --
   //------------------------------------------------------
   bit temp_result;
   bit final_result = 1'b1;
   test_num = "Test 01";
   
   //------------------------------------------------------
   //--                    Test Setup                    --
   //------------------------------------------------------
   
   program_array[0] <= {INSTR_STORE_DIRECT,  8'h01,      8'h20};
   program_array[1] <= {INSTR_STORE_DIRECT,  8'h02,      8'h33};
   program_array[2] <= {INSTR_WAIT,          8'h01,      8'h02};  // This should wait for 200us
   program_array[3] <= {INSTR_STORE_DIRECT,  8'h01,      8'hAA};
   program_array[4] <= {INSTR_TERM,          8'h00,      8'h00};
   $display("Running %s",test_num);
   $display("Test the wait & store direct command");
   ////////////////////////////////////////////////////////////////////////////
   //                            Running the test                            //
   ////////////////////////////////////////////////////////////////////////////
   enable_in <= 1'b1;
   #(20*CLK_PERIOD);
   
   // Did the LEDs write correctly?
   temp_result = (leds_out[7:0] === 8'h20);
   final_result &= temp_result;
   temp_result = (leds_out[15:8] === 8'h33);
   final_result &= temp_result;
   
   // Did the processor terminate?
   temp_result = (term_out === 1'b0);  // It should not have terminated yet
   final_result &= temp_result;
   
   // Wait 150 us - check that it is still waiting
   #(150us);
   temp_result = (leds_out[7:0] === 8'h20);
   final_result &= temp_result;
   temp_result = (term_out === 1'b0);  // It should not have terminated yet
   final_result &= temp_result;
   
   // Wait 50us more - it should have finished.
   #(50us);
   temp_result = (leds_out[7:0] === 8'hAA);
   final_result &= temp_result;
   temp_result = (term_out === 1'b1);  // It should not have terminated yet
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
