// Library:  calc1_sn
// Module:  Top-level wiring for use with specman testbench
// Author:  Kerstin Eder

`include "calc1_top.v"

module calc1_sn;

   wire [0:31] out_data1, 
	     out_data2, 
         out_data3, 
		 out_data4;

   wire [0:1] out_resp1, 
		 out_resp2, 
		 out_resp3, 
		 out_resp4;

   reg [0:3] req1_cmd_in, 
         req2_cmd_in, 
		 req3_cmd_in, 
		 req4_cmd_in;
   
   reg [0:31] req1_data_in,		
		 req2_data_in, 
		 req3_data_in, 
		 req4_data_in;
      
   reg [1:7] reset;

   reg  scan_in; 
   wire scan_out;

   reg [0:3] error_found; 

   reg a_clk;
   reg b_clk;
   reg c_clk;

   calc1_top calculator(out_data1, out_data2, out_data3, out_data4, out_resp1, out_resp2, out_resp3, out_resp4, scan_out, a_clk, b_clk, c_clk, error_found, req1_cmd_in, req1_data_in, req2_cmd_in, req2_data_in, req3_cmd_in, req3_data_in, req4_cmd_in, req4_data_in, reset, scan_in);

   initial 
     begin
        error_found = 4'b0000; // turns on all bugs
        scan_in = 0;
        a_clk = 0;
        b_clk = 0;
        c_clk = 0;
     end

   initial c_clk = 0;
   always #100 c_clk = ~c_clk;

endmodule // calc1_sn

