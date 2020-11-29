
   Sample calc1_sn_env.e file
   --------------------------
   This file provides the basic structure for the calc1 
   testbench environment.

   It extends sys by the unit driver, and extends the default setup and run
   methods. It also extends the dut_error_struct.

<'

import instruction;       //  pull in instruction data structure definitions
import driver;            //  pull in driver definitions
import test_example;      //  pull in current test data
import coverage;          //  pull in coverage metric and collection events

extend sys {

   driver : driver_u is instance;

   setup() is also {

      set_check("...", ERROR_CONTINUE);   // don't quit the simulation on error

   }; 

   run() is also {

     simulator_command("probe -create -shm -all -depth all"); 

   };


}; // extend sys

// extend the error handling struct

extend dut_error_struct {
   write() is only {
      out("DUT error at time ", sys.time);
      out(message);
   }; // write() is only
}; // extend dut_error

'>

