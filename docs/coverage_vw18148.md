---
geometry: margin=2cm
output: pdf_document
author: Jacob Halsey
title: Coverage Report
---

## Code Coverage

The testbench has 89% coverage of the calc1 code:

![](./code_coverage.png)

## Functional Coverage

The functional coverage is defined in `coverage.e` as follows:

The cross of the `cmd_in` (opcode), operand1 and operand2 (the high and low bytes of each), and the port number that was used to execute the instruction.
By using ranges and buckets for the first and last bytes of the operands it ensures that a large range of numbers are covered, but also that there is variation of the less significant bits as well.

Results show 99% coverage:

![](./functional_coverage.png)
