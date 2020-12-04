
   Sample test.e file
   ----------------------
   This file provides basic test-specific constraints for the calc1 
   testbench.

<'

extend instruction_s {
    keep cmd_in in set_of_values(opcode_t);
    keep (cmd_in.as_a(opcode_t) == SHL) => (din2 % 32) <= 15;
    keep (cmd_in.as_a(opcode_t) == SHR) => (din2 % 32) != 1;
};


extend driver_u {
    keep instructions_to_drive.size() == 300;
};

'>
