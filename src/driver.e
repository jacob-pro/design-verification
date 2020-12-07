
   driver.e
   --------------------
   The driver interacts directly with the DUV by driving test data into
   the DUV and collecting the response from the DUV. It also invokes the
   instruction specific response checker. 

<'

type execute_t : [ ANY_PORT, PORT1, PORT2, PORT3, PORT4 ];

struct test_group_s {
    name: string;
    instructions : list of instruction_s;
    execute_on: execute_t;
};

unit port_u {
    req_cmd_in_p : out simple_port of uint(bits:4) is instance;
    req_data_in_p : out simple_port of uint(bits:32) is instance;
    out_resp_p : in simple_port of uint(bits:2) is instance;
    out_data_p : in simple_port of uint(bits:32) is instance;

    last_cmd: uint(bits:4);
    keep last_cmd == opcode_t'NOP.as_a(uint);

    is_busy(): bool is {
        if (out_resp_p$ == response_t'NO_RESPONSE.as_a(uint) && last_cmd != opcode_t'NOP.as_a(uint)) {
            return TRUE;
        };
        return FALSE;
    };

    set_req_cmd_in(value: uint(bits:4)) is {
        last_cmd = value;
        req_cmd_in_p$ = value;
    };
};

unit driver_u {

    clk_p : inout simple_port of bit is instance; // can be driven or read by sn
    keep clk_p.hdl_path() == "~/calc1_sn/c_clk";

    reset_p : out simple_port of uint(bits:7) is instance; // driven by sn
    keep reset_p.hdl_path() == "~/calc1_sn/reset";

    ports: list of port_u is instance;
    keep ports.size() == 4;

    keep ports[0].req_cmd_in_p.hdl_path() == "~/calc1_sn/req1_cmd_in";
    keep ports[0].req_data_in_p.hdl_path() == "~/calc1_sn/req1_data_in";
    keep ports[0].out_resp_p.hdl_path() == "~/calc1_sn/out_resp1";
    keep ports[0].out_data_p.hdl_path() == "~/calc1_sn/out_data1";

    keep ports[1].req_cmd_in_p.hdl_path() == "~/calc1_sn/req2_cmd_in";
    keep ports[1].req_data_in_p.hdl_path() == "~/calc1_sn/req2_data_in";
    keep ports[1].out_resp_p.hdl_path() == "~/calc1_sn/out_resp2";
    keep ports[1].out_data_p.hdl_path() == "~/calc1_sn/out_data2";

    keep ports[2].req_cmd_in_p.hdl_path() == "~/calc1_sn/req3_cmd_in";
    keep ports[2].req_data_in_p.hdl_path() == "~/calc1_sn/req3_data_in";
    keep ports[2].out_resp_p.hdl_path() == "~/calc1_sn/out_resp3";
    keep ports[2].out_data_p.hdl_path() == "~/calc1_sn/out_data3";

    keep ports[3].req_cmd_in_p.hdl_path() == "~/calc1_sn/req4_cmd_in";
    keep ports[3].req_data_in_p.hdl_path() == "~/calc1_sn/req4_data_in";
    keep ports[3].out_resp_p.hdl_path() == "~/calc1_sn/out_resp4";
    keep ports[3].out_data_p.hdl_path() == "~/calc1_sn/out_data4";

    event clk is fall(clk_p$)@sim;

    tests_to_drive : list of test_group_s;

    check_reset() is {
        for each port_u (port) in ports {
            check that port.out_resp_p$ == 0 && port.out_data_p$ == 0 else
                dut_errorf("Reset failed for port %u", index + 1);
        };
    };

    drive_reset() @clk is {
        for i from 0 to 8 do {
            reset_p$ = 1111111;
            wait cycle;
        };
        reset_p$ = 0000000;
        check_reset();
    };

    drive_parallel(instructions: list of instruction_s): uint @clk is {
        var stack: list of instruction_s = instructions.reverse();
        var passed: uint = 0;

        while (stack.size() > 0) {
            for each port_u (port) in ports {
                if (!port.is_busy()) {
                    var ins: instruction_s = stack.pop();
                    port.set_req_cmd_in(pack(NULL, ins.cmd_in));
                }

            };
            wait cycle;
        };
        return passed;
    };

    drive_on_single_port(instructions: list of instruction_s, port: uint): uint @clk is {
        var passed: uint = 0;
        for each (ins) in instructions do {

            ports[port].set_req_cmd_in(pack(NULL, ins.cmd_in));
            ports[port].req_data_in_p$ = pack(NULL, ins.din1);
            wait cycle;
            ports[port].req_cmd_in_p$  = 0000;
            ports[port].req_data_in_p$ = pack(NULL, ins.din2);

            while (ports[port].is_busy()) {
                wait cycle;
            };

            ins.resp = ports[port].out_resp_p$.as_a(response_t);
            ins.dout = ports[port].out_data_p$;

            if (ins.check_response()) { passed = passed + 1; };

            wait cycle;
        };
        return passed;
    };

    drive() @clk is {

        for each (group) in tests_to_drive do {
            drive_reset();
            var passed: uint = drive_on_single_port(group.instructions, 0);
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

