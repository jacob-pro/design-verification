
   Sample test.e file
   ----------------------
   This file provides basic test-specific constraints for the calc1 
   testbench.

<'

extend instruction_s {
    keep cmd_in in [ADD,SUB,SHL,SHR, NOP];
    keep (cmd_in == SHL) => (din2 % 32) <= 15;
    keep (cmd_in == SHR) => (din2 % 32) != 1;
    //keep cmd_in == 9;
};


extend driver_u {
    keep instructions_to_drive.size() == 300;
};

'>
