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

    // Some more specific/directed tests to figure out the bugs
    post_generate() is also {

        // There is a bug with SHR by 1 bit
        var shr_1: test_group_s;
        gen shr_1 keeping {
            .name == "SHR, Excluding shift by 1";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHR.as_a(uint);
                (i.din2 % 32) != 1;
            };
        };
        tests_to_drive.add(shr_1);
        var shr2: test_group_s;
        gen shr2 keeping {
            .name == "SHR, Shift by 1 only";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHR.as_a(uint);
                (i.din2 % 32) == 1;
            };
        };
        tests_to_drive.add(shr2);

        // There is a bug with SHL by anything other than 2 bits
        var shl_1: test_group_s;
        gen shl_1 keeping {
            .name == "SHL, Shift by 2 or less";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                (i.din2 % 32) <= 2;
            };
        };
        tests_to_drive.add(shl_1);
        var shl_2: test_group_s;
        gen shl_2 keeping {
            .name == "SHL, Shift by 3 or more";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                (i.din2 % 32) >= 3;
            };
        };
        tests_to_drive.add(shl_2);

    }
};

'>
