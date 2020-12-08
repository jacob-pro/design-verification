<'

extend instruction_input_s {
    // Favour valid instructions over invalid ones
    keep soft cmd_in == select {
        90: set_of_values(opcode_t);
        10: others;
    };
};


extend driver_u {
    keep tests_to_drive.size() == 1;
    keep tests_to_drive[0].name == "Random mix (parallel)";
    keep tests_to_drive[0].instructions.size() == 200;
    keep tests_to_drive[0].execute_mode == PARALLEL;

    // Some more specific/directed tests to figure out the bugs
    post_generate() is also {

        // Bug 1 - Addition
        var add1: test_group_s;
        gen add1 keeping {
            .name == "ADD exclude broken bit combo (should pass)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'ADD.as_a(uint);
                ((i.din2 + 16) / 32) % 2 == 0;
                ((((i.din2 & 255 << 8) >> 8) + 16) / 32) % 2 == 0;
            };
        };
        tests_to_drive.add(add1);
        var add2: test_group_s;
        gen add2 keeping {
            .name == "ADD broken bit combo (will fail if b0111)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'ADD.as_a(uint);
                (((i.din2 + 16) / 32) % 2 != 0) || (((((i.din2 & 255 << 8) >> 8) + 16) / 32) % 2 != 0);
            };
        };
        tests_to_drive.add(add2);

        // Bug 2
        var shl_4: test_group_s;
        gen shl_4 keeping {
            .name == "SHL, shift by 1 or 2 (should pass)";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                (i.din2 % 32) >= 1;
                (i.din2 % 32) <= 2;
            };
        };
        tests_to_drive.add(shl_4);
        var shl_3: test_group_s;
        gen shl_3 keeping {
            .name == "SHL, shift by 0 (will fail if b1011)";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                (i.din2 % 32) == 0;
            };
        };
        tests_to_drive.add(shl_3);

        // Bug 5 - Subtraction always returns overflow/invalid
        var subo: test_group_s;
        gen subo keeping {
            .name == "SUB a number by a larger number (should pass)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SUB.as_a(uint);
                i.din1 <= MAX_UINT / 2;
                i.din2 > MAX_UINT / 2;
            };
        };
        tests_to_drive.add(subo);
        var subv: test_group_s;
        gen subv keeping {
            .name == "SUB a number by a smaller number (will fail)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SUB.as_a(uint);
                i.din1 >= MAX_UINT / 2;
                i.din2 < MAX_UINT / 2;
            };
        };
        tests_to_drive.add(subv);

        // Bug 6: There is a bug with SHR by 1 bit
        var shr_1: test_group_s;
        gen shr_1 keeping {
            .name == "SHR, Excluding shift by 1 bit (should pass)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHR.as_a(uint);
                (i.din2 % 32) != 1;
            };
        };
        tests_to_drive.add(shr_1);
        var shr2: test_group_s;
        gen shr2 keeping {
            .name == "SHR, Shift by 1 bit only (will fail)";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHR.as_a(uint);
                (i.din2 % 32) == 1;
            };
        };
        tests_to_drive.add(shr2);

        // Bug 7: There is a bug with SHL by anything greater than 2 bits
        var shl_1: test_group_s;
        gen shl_1 keeping {
            .name == "SHL, Shift by 2 bits or less (should pass)";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                (i.din2 % 32) <= 2;
            };
        };
        tests_to_drive.add(shl_1);
        var shl_2: test_group_s;
        gen shl_2 keeping {
            .name == "SHL, Shift by 3 bits or more (will fail)";
            .instructions.size() == 60;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                i.din2 == (index + (3 * (index / 29)) + 3);
                (i.din2 % 32) >= 3;
            };
        };
        tests_to_drive.add(shl_2);

        // Bug 8: Invalids
        var inv: test_group_s;
        gen inv keeping {
            .name == "Invalid opcodes (will fail)";
            .instructions.size() == 10;
            for each (i) in .instructions {
                i.cmd_in not in set_of_values(opcode_t);
            };
        };
        tests_to_drive.add(inv);

        // Bug 9: Priority
        var pri: test_group_s;
        gen pri keeping {
            .name == "ADD/SUB in parallel";
            .execute_mode == PARALLEL;
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'ADD.as_a(uint) || i.cmd_in == opcode_t'SUB.as_a(uint);
            };
        };
        tests_to_drive.add(pri);
        var pri2: test_group_s;
        gen pri2 keeping {
            .name == "SHL/SHR in parallel";
            .execute_mode == PARALLEL;
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint) || i.cmd_in == opcode_t'SHR.as_a(uint);
            };
        };
        tests_to_drive.add(pri2);

    }
};

'>
