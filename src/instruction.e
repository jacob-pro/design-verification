
   instruction.e
   -------------------------
   This file provides the basic structure for the calc1 design instructions
   and also an example response checker for ADD instructions.

<'

type opcode_t : [ NOP = 0, ADD = 1, SUB = 2, SHL = 5, SHR = 6 ] (bits:4);
type response_t : [NO_RESPONSE, SUCCESS, INVALID, INTERNAL_ERROR] (bits: 2);

struct instruction_s {

   %cmd_in : uint (bits:4);
   %din1   : uint (bits:32);
   %din2   : uint (bits:32);

   !resp   : response_t;
   !dout   : uint (bits:32);

};

extend instruction_s {

    check_response() is {
        case cmd_in {
            opcode_t'NOP.as_a(uint): { check_response_matches(NO_RESPONSE) };
            opcode_t'ADD.as_a(uint): { check_add() };
            opcode_t'SUB.as_a(uint): { check_sub() };
            opcode_t'SHL.as_a(uint): { check_shl() };
            opcode_t'SHR.as_a(uint): { check_shr() };
            default: { check_response_matches(INVALID) };
        }
    };

    private check_add() is {
        var expected_resp: response_t = SUCCESS;
        var expected_dout: uint = din1 + din2;
        // Overflow case
        if (expected_dout < din1) {
            expected_resp = INVALID;
        };
        check_expected(expected_resp, expected_dout);
    };

    private check_sub() is {
        var expected_resp: response_t = SUCCESS;
        var expected_dout: uint = din1 - din2;
        // Underflow case - if op2 is larger than op1
        if (din2 > din1) {
            expected_resp = INVALID;
        };
        check_expected(expected_resp, expected_dout);
    };

    private check_shl() is {
        // Assume that the higher bits are ignored
        var shift: uint = din2 % 32;
        var expected_dout: uint = (din1 << shift);
        check_expected(SUCCESS, expected_dout);
    };

    private check_shr() is {
        var expected_dout: uint;
        // Assume that the higher bits are ignored
        var shift: uint = din2 % 32;
        // Assume that behaviour of shift right 0 always returns 0
        if shift == 0 {
            expected_dout = 0;
        } else  {
            expected_dout = (din1 >> shift);
        };
        check_expected(SUCCESS, expected_dout);
    };

    private check_expected(expected_resp: response_t, expected_dout: uint) is {
        check that resp == expected_resp && dout == expected_dout else
        dut_error(appendf("\
[R==>Invalid output.<==R]\n\
Instruction %s,   OP1 0x%X (%u),   OP2 0x%X (%u),\n\
expected %s 0x%X (%u),\n\
received %s 0x%X (%u)\n",
            cmd_in.as_a(opcode_t), din1, din1, din2, din2,
            expected_resp, expected_dout, expected_dout,
            resp, dout, dout));
    };

    private check_response_matches(expected_resp: response_t) is {
        var cmd_name: string = appendf("INV%u", cmd_in);
        if (cmd_in in set_of_values(opcode_t)) {
            cmd_name = cmd_in.as_a(opcode_t).as_a(string);
        };
        check that resp == expected_resp else
        dut_error(appendf("\
[R==>Invalid output.<==R]\n\
Instruction %s,   OP1 0x%X (%u),   OP2 0x%X (%u),\n\
expected %s received %s\n",
            cmd_name, din1, din1, din2, din2,
            expected_resp, resp));
    };

};

'>
