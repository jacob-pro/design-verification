// Library:  calc1
// Module:  Top-level wiring 
// Author:  Kerstin Eder

`include "calc1_top.v"

module calc1 (out_data1, out_data2, out_data3, out_data4, out_resp1, out_resp2, out_resp3, out_resp4, c_clk, req1_cmd_in, req1_data_in, req2_cmd_in, req2_data_in, req3_cmd_in, req3_data_in, req4_cmd_in, req4_data_in, reset);

   output [0:31] out_data1, 
		 out_data2, 
		 out_data3, 
		 out_data4;

   output [0:1]  out_resp1, 
		 out_resp2, 
		 out_resp3, 
		 out_resp4;

   input 	 c_clk;

   input [0:3] 	 req1_cmd_in, 
		 req2_cmd_in, 
		 req3_cmd_in, 
		 req4_cmd_in;
   
   input [0:31]  req1_data_in,		
		 req2_data_in, 
		 req3_data_in, 
		 req4_data_in;
      
   input [1:7] 	 reset;

   reg 	         scan_in; 
   wire          scan_out;

   reg [0:3]     error_found; 

   reg 	         a_clk;
   reg 	         b_clk;

   wire [0:31] ontime_port2;
   reg [0:31]  delayed_port2;

always @(negedge c_clk) begin
	if (reset == 1) begin
		delayed_port2 <= 0;
	end
	else begin
		delayed_port2 <= ontime_port2;
	end
end

assign out_data2 = delayed_port2;

   calc1_top calculator(out_data1, ontime_port2, out_data3, out_data4, out_resp1, out_resp2, out_resp3, out_resp4, scan_out, a_clk, b_clk, c_clk, error_found, req1_cmd_in, req1_data_in, req2_cmd_in, req2_data_in, req3_cmd_in, req3_data_in, req4_cmd_in, req4_data_in, reset, scan_in);
// KIE - place to change port connections  
   initial 
     begin
	error_found = 4'b0000; // turns on all bugs
//  error_found = 4'b0000; // KIE local bugs can be modified here
    scan_in = 0;
	a_clk = 0;
	b_clk = 0;
     end

endmodule // calc1


