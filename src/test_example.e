
   Sample test.e file
   ----------------------
   This file provides basic test-specific constraints for the calc1 
   testbench.

<'

extend instruction_s {
   //keep cmd_in in [ADD,SUB,SHL,SHR];
   keep cmd_in in [ADD];
   keep din1 <= MAX_UINT;
   keep din1 <= MAX_UINT;
};


extend driver_u {
   keep instructions_to_drive.size() == 100;
};


'>

