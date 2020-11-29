
   Sample coverage.e file
   ----------------------
   This file provides a basic example of coverage collection for the calc1 
   testbench.

<'

extend instruction_s {

   event instruction_complete;

   cover instruction_complete is {
      item cmd_in;
      item resp;
      cross cmd_in, resp;
   }

}; // extend instruction_s

extend driver_u {

   collect_response(ins : instruction_s) @clk is also {

      emit ins.instruction_complete;

   };

}; // extend driver_u

'>

