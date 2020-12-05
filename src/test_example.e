
   Sample test.e file
   ----------------------
   This file provides basic test-specific constraints for the calc1 
   testbench.

<'

extend instruction_s {
    keep soft cmd_in == 1;
    keep (cmd_in.as_a(opcode_t) == SHL) => (din2 % 32) <= 2;
    keep (cmd_in.as_a(opcode_t) == SHR) => (din2 % 32) != 1;
};


extend driver_u {
    keep tests_to_drive.size() == 1;
    keep tests_to_drive[0].instructions.size() == 50;


};

'>
