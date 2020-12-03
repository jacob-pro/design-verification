
   Sample instruction.e file
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

   check_response(ins : instruction_s) is empty;

}; // struct instruction_s


extend instruction_s {

    when ADD'cmd_in instruction_s {

        check_response(ins : instruction_s) is only {

            var expected_resp: response_t = SUCCESS;
            var expected_dout: uint = ins.din1 + ins.din2;

            // Overflow case
            if (expected_dout < ins.din1) {
                expected_resp = INVALID;
            };

            check that ins.resp == expected_resp && ins.dout == expected_dout else
            dut_error(appendf("[R==>Invalid add output.<==R]\n\t Instruction %s 0x%X 0x%X,\n\t expected %s 0x%X,\n\t received %s 0x%X \n",
                          ins.cmd_in, ins.din1, ins.din2, expected_resp.as_a(string), expected_dout, ins.resp.as_a(string), ins.dout));
        };
    };

};


'>
