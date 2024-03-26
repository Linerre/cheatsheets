///////////////////////////////////////////////////////////////////////////////
/*
                        Softcore Microprocessor
                               Top Module
               ENGN4213 Digital Systems and Microprocessors
                           CEA Technologies

 This is the top module of the Vivado or Quartus project designed to map IO
 pins through to the softcore processor. It also does all the synchronisation
 needed for those IO pins.
*/
///////////////////////////////////////////////////////////////////////////////

`default_nettype none

module top(
   // Top level pin names should match the schematic. It makes it much easier to trace signals through when you have a problem!
   input  wire          CLK100MHZ,
   input  wire          BTNC,

   input  wire          BTND,
   output wire [15:0]   LED,
   input  wire [15:0]   SW

);

   //------------------------------------------------------
   //--              Localparams and Types               --
   //------------------------------------------------------
   localparam int CLK_FREQ       = 100_000_000;
   localparam int DEBOUNCE_TIME  = CLK_FREQ / 10;           // This is the number of cycles in 100ms.
   localparam int DEBOUNCE_W     = $clog2(DEBOUNCE_TIME);   // This will actually count 2^24 = 167ms
   //------------------------------------------------------
   //--                 Local Variables                  --
   //------------------------------------------------------
   reg  [15:0]             dip_buf;
   reg  [15:0]             dip;
   reg                     btnc_buf;
   reg                     btnc_sync;
   reg                     button_buf;
   reg                     button_sync;
   reg  [DEBOUNCE_W-1:0]   debounce_cntr;
   wire                    button_debounced;
   reg                     button_debounced_buf;
   wire                    button_posedge;
   reg  [1:0]              nrst_sync;
   wire                    nrst;
   wire [15:0]             leds;
   wire                    term;

   ////////////////////////////////////////////////////////////////////////////
   //                          Input Sychronisation                          //
   ////////////////////////////////////////////////////////////////////////////
   // All asynchronous inputs into an FPGA need to be synchronised in some manner
   // the easist way is to double flop them - this eliminates any metastability.
   always @(posedge CLK100MHZ)begin
      dip_buf     <= SW;
      dip         <= dip_buf;
   end
   always @(posedge CLK100MHZ)begin
      btnc_buf    <= BTNC;
      btnc_sync   <= btnc_buf;
   end
   always @(posedge CLK100MHZ)begin
      button_buf  <= BTND;
      button_sync <= button_buf;
   end

   always @(posedge CLK100MHZ)begin
      if(button_sync)begin
         debounce_cntr <= {DEBOUNCE_W{1'b1}};
      end else if(|debounce_cntr)begin
         debounce_cntr <= debounce_cntr - 1;
      end
   end

   assign button_debounced = |debounce_cntr;

   always @(posedge CLK100MHZ)begin
      button_debounced_buf <= button_debounced;
   end
   assign button_posedge = !button_debounced_buf && button_debounced;

   // This is an asynchronous assert, synchronous deassert reset sychroniser.
   // It is the theoretical best way to synchronise a reset, and works well
   // on the smaller devices. Larger devices no longer have async reset on the
   // DFFs, and therefore can't do this type of reset as perfectly.
   always @(posedge CLK100MHZ, posedge btnc_sync)begin
      if(btnc_sync)begin
         nrst_sync <= 2'b00;
      end else begin
         nrst_sync[0] <= 1'b1;
         nrst_sync[1] <= nrst_sync[0];
      end
   end
   assign nrst = nrst_sync;
   ////////////////////////////////////////////////////////////////////////////
   //                             Processor Core                             //
   ////////////////////////////////////////////////////////////////////////////
   program_module #(
      .CLK_FREQUENCY    (CLK_FREQ)   // This is the frequency clk_in is running at in Hz.
   ) program_inst (
      .clk_in           (CLK100MHZ),
      .nrst_in          (nrst),

      .push_button_in   (button_posedge),
      .enable_in        (dip[15]),
      .term_out         (term),

      .dip_in           ({1'b0,dip[14:0]}),
      .leds_out         (leds)
   );

   assign LED[14:0]  = leds[14:0];
   assign LED[15]    = term;
endmodule
