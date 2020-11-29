
   Sample test.e file
   ----------------------
   This file provides basic test-specific constraints for the calc1 
   testbench.

<'

extend instruction_s {
//   keep cmd_in in [ADD,SUB,SHL,SHR];
   keep cmd_in == ADD;
   keep din1 < 100;
   keep din2 < 10;
}; // extend instruction_s


extend driver_u {
   keep instructions_to_drive.size() == 100;
}; // extend driver_u


'>

