///////////////////////////////////////////////////////////////////////////////
/*
                        Softcore Microprocessor
                            Command Package
               ENGN4213 Digital Systems and Microprocessors
                           CEA Technologies

 A systemverilog package module is designed to store parameters and types that
 you want to use in multiple locations. Like a C header file, it can be imported
 into multiple places as needed.
*/
///////////////////////////////////////////////////////////////////////////////


package command_package;

   // Since I don't actually care what 8 bit number any particular instruction is
   // I have left the mapping of the enumerations to numbers up to the compiler.
   // This is slightly better because it gives the compiler freedom to optimise it.
   typedef enum logic [7:0] {
      INSTR_WAIT,          // pauses the processor for a time equal to the value of the data byte * 100ms.
      INSTR_WAIT_ON_BUTTON,// pauses the processor until the push button is toggled.
      INSTR_STORE_DIRECT,  // writes the data field into the register specified by the address field (ie register[address] <= data)
      INSTR_STORE,         // writes the accumulator value into the register specified by the address field (ie register[address] <= register[0])
      INSTR_LOAD,          // writes into the accumulator. address 0 loads the data field (ie register[0] <= data), other addresses load that register (ie register[0] <= register[address])
      INSTR_ADD,           // the data field to the accumulator. Address 0 loads the data field (ie register[0] <= register[0] + data), other addresses load that register (ie register[0] <= register[0] + register[address])
      INSTR_AND,           // the data field to the accumulator. Address 0 loads the data field (ie register[0] <= register[0] & data), other addresses load that register (ie register[0] <= register[0] & register[address])
      INSTR_OR,            // the data field to the accumulator. Address 0 loads the data field (ie register[0] <= register[0] | data), other addresses load that register (ie register[0] <= register[0] | register[address])
      INSTR_XOR,           // the data field to the accumulator. Address 0 loads the data field (ie register[0] <= register[0] ^ data), other addresses load that register (ie register[0] <= register[0] ^ register[address])
      INSTR_NOT,           // the accumulator (register[0] <= ~register[0])
      INSTR_JUMP,          // Jumps to the instruction specified by the address (program_counter <= address)
      INSTR_JUMP_GT,       // Jumps to the instruction specified by the address only if the data field is greater than the accumulator
      INSTR_JUMP_EQ,       // Jumps to the instruction specified by the address only if the data field is equal to the accumulator
      INSTR_JUMP_LT,       // Jumps to the instruction specified by the address only if the data field is less than the accumulator
      INSTR_TERM           // Stops the Processor
   } InstructionType;

   // A packed struct is just a bunch of bits that you have given names to.
   // This is equivalent to logic [23:0], but it is easier to understand the
   // code if I name the address. Unpacked structs and unions are not
   // synthesisable but can be used in testbenches.
   typedef struct packed {
      InstructionType   instruction;
      logic [7:0]       address;
      logic [7:0]       data;
   } CommandType;

   // int is a 2 state variable (32 bits of 0 or 1). Integer is a 4 state
   // variable (32 bits of 0,1,x or z).
   localparam int MAX_NUM_COMMANDS     = 256;
   localparam int MAX_NUM_COMMANDS_W   = $clog2(MAX_NUM_COMMANDS);


endpackage
