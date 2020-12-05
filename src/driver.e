
   Sample driver.e file
   --------------------
   This file provides the basic structure for the calc1 testbench 
   driver. 

   The driver interacts directly with the DUV by driving test data into
   the DUV and collecting the response from the DUV. It also invokes the
   instruction specific response checker. 

<'

struct test_group_s {
   name: string;
   instructions : list of instruction_s;
};

unit driver_u {

   clk_p : inout simple_port of bit is instance; // can be driven or read by sn
   keep clk_p.hdl_path() == "~/calc1_sn/c_clk";

   reset_p : out simple_port of uint(bits:7) is instance; // driven by sn
   keep reset_p.hdl_path() == "~/calc1_sn/reset";

   req1_cmd_in_p : out simple_port of uint(bits:4) is instance; // driven by sn
   keep req1_cmd_in_p.hdl_path() == "~/calc1_sn/req1_cmd_in";

   req1_data_in_p : out simple_port of uint(bits:32) is instance; // driven by sn
   keep req1_data_in_p.hdl_path() == "~/calc1_sn/req1_data_in";

   out_resp1_p : in simple_port of uint(bits:2) is instance; // read by sn
   keep out_resp1_p.hdl_path() == "~/calc1_sn/out_resp1";

   out_data1_p : in simple_port of uint(bits:32) is instance; // read by sn
   keep out_data1_p.hdl_path() == "~/calc1_sn/out_data1";
  

   tests_to_drive : list of test_group_s;


   event clk is fall(clk_p$)@sim;
   event resp is change(out_resp1_p$)@sim;


   drive_reset() @clk is {
      var i : int;

      for { i=0; i<=8; i+=1 } do {

         reset_p$ = 1111111;
         wait cycle;

      }; // for

      reset_p$ = 0000000;

   }; // drive_reset


   drive_instruction(ins : instruction_s, i : int) @clk is {

      // display generated command and data
      //outf("Command %s = %s\n", i, ins.cmd_in);
      //out("Op1     = ", ins.din1);
      //out("Op2     = ", ins.din2);
      //out();

      // drive data into calculator port 1
      req1_cmd_in_p$  = pack(NULL, ins.cmd_in);
      req1_data_in_p$ = pack(NULL, ins.din1);
         
      wait cycle;

      req1_cmd_in_p$  = 0000;  
      req1_data_in_p$ = pack(NULL, ins.din2);

   }; // drive_instruction


   collect_response(ins : instruction_s) @clk is {

        // Need to add timeout
        if (ins.cmd_in == opcode_t'NOP.as_a(uint)) {
            wait cycle;
        } else {
            while (out_resp1_p$ == 0) {
               wait cycle;
            };
        };


        ins.resp = out_resp1_p$.as_a(response_t);
        ins.dout = out_data1_p$;

   };


    drive() @clk is {

        for each (group) in tests_to_drive do {
            drive_reset();

            var passed: uint = 0;
            for each (ins) in group.instructions do {
                drive_instruction(ins, index);
                collect_response(ins);
                if (ins.check_response()) { passed = passed + 1; };
                wait cycle;
            };
            outf("\nPassed %u/%u instructions in group %u \"%s\"\n\n", passed, group.instructions.size(), index + 1, group.name);

        };

        wait [10] * cycle;
        stop_run();

    };


   run() is also {
      start drive();        // spawn
   }; // run

}; // unit driver_u


'>

