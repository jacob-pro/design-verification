# Bug Report

Bugs 1 through 4 apply to those controlled by the `error_found` bit flags in `calc1_sn.v`.
They can be demonstrated using specific test cases described in `tests.e`

## 1: Addition

Addition produces the wrong result when the second operand matches these conditions:
For both the least or second least significant bytes of the (4 byte integer):
It will break if one of (not both) the 5th or 6th LSBs are set.

## 5: Subtraction Response Code

The subtraction (`SUB`) operation always returns an overflow error (response 3) even when the input 
should not have overflown (the output data is still correct).

## 6: Shift Right by One

The shift right (`SHR`) operation fails to shift by one bit (or more specifically when 
`din2 mod 32 == 1`). Instead the un-shifted operand1 is returned.\
Shifting by greater than 1 bit works fine.

## 7: Shift Left by Three or More

The shift left (`SHL`) operation fails when shifting by three or more bits.\
Where `A` is `din2 mod 32`, and A >= 3. Then the results have an offset of 2^(A-3).\
E.g. shifting left by 10, the result is 128 larger than expected.\
(Shifting by 0, 1 or 2 bits still works as expected)

## 8: Invalid operations

An invalid operation responds with success (1) instead of invalid command (2) 
as defined in the specification.

## 9: Priority Logic
