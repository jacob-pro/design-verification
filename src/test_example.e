
   Sample test.e file
   ----------------------
   This file provides basic test-specific constraints for the calc1 
   testbench.

<'

extend instruction_s {
    // Favour valid instructions over invalid ones
    keep soft cmd_in == select {
        90: set_of_values(opcode_t);
        10: others;
    };
};


extend driver_u {
    keep tests_to_drive.size() == 1;
    keep tests_to_drive[0].name == "Random mix";
    keep tests_to_drive[0].instructions.size() == 200;
};

'>
