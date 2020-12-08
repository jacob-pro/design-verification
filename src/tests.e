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

        // Bug 1: Addition
        var bug1a: test_group_s;
        gen bug1a keeping {
            .name == "ADD exclude broken bit combo (should pass if b0111)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'ADD.as_a(uint);
                ((i.din2 + 16) / 32) % 2 == 0;
                ((((i.din2 & 255 << 8) >> 8) + 16) / 32) % 2 == 0;
            };
        };
        tests_to_drive.add(bug1a);
        var bug1b: test_group_s;
        gen bug1b keeping {
            .name == "ADD broken bit combo (will fail if b0111)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'ADD.as_a(uint);
                (((i.din2 + 16) / 32) % 2 != 0) || (((((i.din2 & 255 << 8) >> 8) + 16) / 32) % 2 != 0);
            };
        };
        tests_to_drive.add(bug1b);

        // Bug 2: SHL By One
        var bug2a: test_group_s;
        gen bug2a keeping {
            .name == "SHL, shift by 1 or 2 (should pass if b1011)";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                (i.din2 % 32) >= 1;
                (i.din2 % 32) <= 2;
            };
        };
        tests_to_drive.add(bug2a);
        var bug2b: test_group_s;
        gen bug2b keeping {
            .name == "SHL, shift by 0 (will fail if b1011)";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                (i.din2 % 32) == 0;
            };
        };
        tests_to_drive.add(bug2b);

        // Bug 3: Addition overflow
        var bug3a: test_group_s;
        gen bug3a keeping {
            .name == "ADD numbers which won't overflow (should pass if b1101)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'ADD.as_a(uint);
                (i.din1 + i.din2) <= MAX_UINT;  // The generator seems to do addition differently
            };
        };
        tests_to_drive.add(bug3a);
        var bug3b: test_group_s;
        gen bug3b keeping {
            .name == "ADD numbers which will overflow (will fail if b1101)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'ADD.as_a(uint);
                (i.din1 + i.din2) > MAX_UINT;  // The generator seems to do addition differently
            };
        };
        tests_to_drive.add(bug3b);

        // Bug 5: Subtraction always returns overflow/invalid
        var bug5a: test_group_s;
        gen bug5a keeping {
            .name == "SUB a number by a larger number (should pass if bugs disabled)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SUB.as_a(uint);
                i.din1 <= MAX_UINT / 2;
                i.din2 > MAX_UINT / 2;
            };
        };
        tests_to_drive.add(bug5a);
        var bug5b: test_group_s;
        gen bug5b keeping {
            .name == "SUB a number by a smaller number (will fail if bugs disabled)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SUB.as_a(uint);
                i.din1 >= MAX_UINT / 2;
                i.din2 < MAX_UINT / 2;
            };
        };
        tests_to_drive.add(bug5b);

        // Bug 6: There is a bug with SHR by 1 bit
        var bug6a: test_group_s;
        gen bug6a keeping {
            .name == "SHR, Excluding shift by 1 bit (should pass if bugs disabled)";
            .instructions.size() == 100;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHR.as_a(uint);
                (i.din2 % 32) != 1;
            };
        };
        tests_to_drive.add(bug6a);
        var bug6b: test_group_s;
        gen bug6b keeping {
            .name == "SHR, Shift by 1 bit only (will fail if bugs disabled)";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHR.as_a(uint);
                (i.din2 % 32) == 1;
            };
        };
        tests_to_drive.add(bug6b);

        // Bug 7: There is a bug with SHL by anything greater than 2 bits
        var bug7a: test_group_s;
        gen bug7a keeping {
            .name == "SHL, Shift by 2 bits or less (should pass if bugs disabled)";
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                (i.din2 % 32) <= 2;
            };
        };
        tests_to_drive.add(bug7a);
        var bug7b: test_group_s;
        gen bug7b keeping {
            .name == "SHL, Shift by 3 bits or more (will fail if bugs disabled)";
            .instructions.size() == 60;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint);
                i.din2 == (index + (3 * (index / 29)) + 3);
                (i.din2 % 32) >= 3;
            };
        };
        tests_to_drive.add(bug7b);

        // Bug 8: Invalids
        var bug8: test_group_s;
        gen bug8 keeping {
            .name == "Invalid opcodes (will fail)";
            .instructions.size() == 10;
            for each (i) in .instructions {
                i.cmd_in not in set_of_values(opcode_t);
            };
        };
        tests_to_drive.add(bug8);

        // Bug 9: Priority
        var bug9a: test_group_s;
        gen bug9a keeping {
            .name == "ADD/SUB in parallel (pass count irrelevant, check for queue errors)";
            .execute_mode == PARALLEL;
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'ADD.as_a(uint) || i.cmd_in == opcode_t'SUB.as_a(uint);
            };
        };
        tests_to_drive.add(bug9a);
        var bug9b: test_group_s;
        gen bug9b keeping {
            .name == "SHL/SHR in parallel (pass count irrelevant, check for queue errors)";
            .execute_mode == PARALLEL;
            .instructions.size() == 20;
            for each (i) in .instructions {
                i.cmd_in == opcode_t'SHL.as_a(uint) || i.cmd_in == opcode_t'SHR.as_a(uint);
            };
        };
        tests_to_drive.add(bug9b);

    }
};

'>
