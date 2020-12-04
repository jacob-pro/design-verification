
   instruction.e
   -------------------------
   This file provides the basic structure for the calc1 design instructions
   and also an example response checker for ADD instructions.

<'

type opcode_t : [ NOP, ADD, SUB, INV, INV1, SHL, SHR ] (bits:4);
type response_t : [NO_RESPONSE, SUCCESS, INVALID, INTERNAL_ERROR] (bits: 2);

struct instruction_s {

   %cmd_in : opcode_t;
   %din1   : uint (bits:32);
   %din2   : uint (bits:32);

   !resp   : response_t;
   !dout   : uint (bits:32);

   check_response() is empty;

}; // struct instruction_s


extend instruction_s {

    private check_expected(expected_resp: response_t, expected_dout: uint) is {
        check that resp == expected_resp && dout == expected_dout else
        dut_error(appendf("\
[R==>Invalid output.<==R]\n\
Instruction %s,   OP1 0x%X (%u),   OP2 0x%X (%u),\n\
expected %s 0x%X (%u),\n\
received %s 0x%X (%u)\n",
            cmd_in, din1, din1, din2, din2,
            expected_resp, expected_dout, expected_dout,
            resp, dout, dout));
    };

    when ADD'cmd_in instruction_s {

        check_response() is only {
            var expected_resp: response_t = SUCCESS;
            var expected_dout: uint = din1 + din2;
            // Overflow case
            if (expected_dout < din1) {
                expected_resp = INVALID;
            };
            check_expected(expected_resp, expected_dout);
        };

    };

    when SUB'cmd_in instruction_s {

        check_response() is only {
            var expected_resp: response_t = SUCCESS;
            var expected_dout: uint = din1 - din2;
            // Underflow case - if op2 is larger than op1
            if (din2 > din1) {
                expected_resp = INVALID;
            };
            check_expected(expected_resp, expected_dout);
        };

    };

    when SHL'cmd_in instruction_s {

        check_response() is only {
            // Assume that the higher bits are ignored
            var shift: uint = din2 % 32;
            var expected_dout: uint = (din1 << shift);
            check_expected(SUCCESS, expected_dout);
        };

    };

    when SHR'cmd_in instruction_s {

        check_response() is only {
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

    };

};

'>
