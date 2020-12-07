
   driver.e
   --------------------
   The driver interacts directly with the DUV by driving test data into
   the DUV and collecting the response from the DUV. It also invokes the
   instruction specific response checker. 

<'

type execute_t : [ PORT1 = 0, PORT2 = 1, PORT3 = 2, PORT4 = 3, PARALLEL ];

struct test_group_s {
    name: string;
    instructions : list of instruction_input_s;
    execute_mode: execute_t;
    keep soft execute_mode == PARALLEL;
};

unit port_u {
    req_cmd_in_p : out simple_port of uint(bits:4) is instance;
    req_data_in_p : out simple_port of uint(bits:32) is instance;
    out_resp_p : in simple_port of uint(bits:2) is instance;
    out_data_p : in simple_port of uint(bits:32) is instance;
    id: uint;

    no_response(): bool is {
        return out_resp_p$ == response_t'NO_RESPONSE.as_a(uint);
    };
};

struct pending_task_s {
    !ins: instruction_input_s;
    !port: port_u;
    !clock: uint;

    send_cmd() is {
        // Need to send cmd and data1 on first cycle
        port.req_cmd_in_p$ = pack(NULL, ins.cmd_in);
        port.req_data_in_p$ = pack(NULL, ins.din1);
    };

    tick(): instruction_output_s is {
        clock += 1;
        if (clock == 1) {
            // Send data2 on the next cycle
            port.req_cmd_in_p$  = 0000;
            port.req_data_in_p$ = pack(NULL, ins.din2);
        } else if (!port.no_response() || ins.is_nop()){
            return new instruction_output_s with {
                .resp = port.out_resp_p$.as_a(response_t);
                .dout = port.out_data_p$;
                .port_number = port.id;
                .input = ins;
                .ticks = clock;
            };
        };
        return NULL;
    };
};

unit driver_u {

    clk_p : inout simple_port of bit is instance; // can be driven or read by sn
    keep clk_p.hdl_path() == "~/calc1_sn/c_clk";

    reset_p : out simple_port of uint(bits:7) is instance; // driven by sn
    keep reset_p.hdl_path() == "~/calc1_sn/reset";

    ports: list of port_u is instance;
    keep ports.size() == 4;

    keep ports[0].id == 1;
    keep ports[0].req_cmd_in_p.hdl_path() == "~/calc1_sn/req1_cmd_in";
    keep ports[0].req_data_in_p.hdl_path() == "~/calc1_sn/req1_data_in";
    keep ports[0].out_resp_p.hdl_path() == "~/calc1_sn/out_resp1";
    keep ports[0].out_data_p.hdl_path() == "~/calc1_sn/out_data1";

    keep ports[1].id == 2;
    keep ports[1].req_cmd_in_p.hdl_path() == "~/calc1_sn/req2_cmd_in";
    keep ports[1].req_data_in_p.hdl_path() == "~/calc1_sn/req2_data_in";
    keep ports[1].out_resp_p.hdl_path() == "~/calc1_sn/out_resp2";
    keep ports[1].out_data_p.hdl_path() == "~/calc1_sn/out_data2";

    keep ports[2].id == 3;
    keep ports[2].req_cmd_in_p.hdl_path() == "~/calc1_sn/req3_cmd_in";
    keep ports[2].req_data_in_p.hdl_path() == "~/calc1_sn/req3_data_in";
    keep ports[2].out_resp_p.hdl_path() == "~/calc1_sn/out_resp3";
    keep ports[2].out_data_p.hdl_path() == "~/calc1_sn/out_data3";

    keep ports[3].id == 4;
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

    drive_parallel(instructions: list of instruction_input_s): uint @clk is {
        var pending: list of pending_task_s;
        var passed: uint = 0;

        // Start a task on each port
        for each port_u (port) in ports {
            if (instructions.size() > 0) {
                pending.add(new pending_task_s with {
                    .ins = instructions.pop0();
                    .port = port;
                    .clock = 0;
                    .send_cmd();
                });
            };
        };
        wait cycle;

        // Drive each task to completion.
        while (pending.size() > 0) {
            var new_list: list of pending_task_s;
            for each pending_task_s (task) in pending {
                var res: instruction_output_s = task.tick();
                if (res != NULL) {
                    if (res.check_response()) { passed = passed + 1; };
                    // Replace with a new task on the same port
                    if (instructions.size() > 0) {
                        new_list.add(new pending_task_s with {
                            .ins = instructions.pop0();
                            .port = task.port;
                            .clock = 0;
                            .send_cmd();
                        });
                    };
                } else {
                    new_list.add(task);
                }
            };
            pending = new_list;
            wait cycle;
            assert pending.size() <= ports.size();
        };

        assert instructions.size() == 0;
        return passed;
    };

    drive_on_single_port(instructions: list of instruction_input_s, port: port_u): uint @clk is {
        var passed: uint = 0;
        for each (ins) in instructions do {

            port.req_cmd_in_p$ = pack(NULL, ins.cmd_in);
            port.req_data_in_p$ = pack(NULL, ins.din1);
            wait cycle;
            port.req_cmd_in_p$  = 0000;
            port.req_data_in_p$ = pack(NULL, ins.din2);

            var ticks: uint = 1;
            while (port.no_response() && !ins.is_nop()) {
                wait cycle;
                ticks += 1;
            };

            var res: instruction_output_s = new instruction_output_s with {
                .resp = port.out_resp_p$.as_a(response_t);
                .dout = port.out_data_p$;
                .port_number = port.id;
                .input = ins;
                .ticks = ticks;
            };

            if (res.check_response()) { passed = passed + 1; };

            wait cycle;
        };
        return passed;
    };

    drive() @clk is {

        for each (group) in tests_to_drive do {
            drive_reset();
            var passed: uint;
            if (group.execute_mode == PARALLEL) {
                passed = drive_parallel(group.instructions);
            } else {
                passed = drive_on_single_port(group.instructions, ports[group.execute_mode.as_a(uint)]);
            };
            outf("\nPassed %u/%u instructions in group %u \"%s\"\n\n", passed, group.instructions.size(), index + 1, group.name);
        };

        wait [10] * cycle;
        stop_run();
    };

    run() is also {
        start drive();  // spawn
    };

};

'>
