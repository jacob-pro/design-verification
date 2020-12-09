
   coverage.e file
   ----------------------
   This file defines functional coverage metrics for calc1

<'

extend instruction_output_s {

    event instruction_executed;

    cover instruction_executed is {
        item cmd_in: uint (bits:4) = input.cmd_in;
        item din1_high: uint (bits:32) = input.din1 using ranges = {range([0..MAX_UINT], "", 0xFFFFFF, 1)};
        item din2_high: uint (bits:32) = input.din2 using ranges = {range([0..MAX_UINT], "", 0xFFFFFF, 1)};
        item din1_low: uint (bits:8) = input.din1 & 0xFF using ranges = {range([0..255], "", 4, 1)};
        item din2_low: uint (bits:8) = input.din2 & 0xFF using ranges = {range([0..255], "", 4, 1)};
        item port_number;
        cross cmd_in, din1_high, din2_high, din1_low, din2_low, port_number;
    };

    check_response(): bool is also {
        emit instruction_executed;
    };

};

'>

