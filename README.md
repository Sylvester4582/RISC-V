# Processor-Architecture-implementation
Divided into two subparts:
1) Sequential version (basic)
2) Pipelined version

Version 1: 9/2/25; ALU implementation
## iverilog -o alu_output .\src\full_adder.v .\src\adder_64bit.v .\src\subtractor_64bit.v .\src\logical_operators.v .\src\shift_operators.v .\src\comparator.v .\src\alu.v .\src\alu_tb.v
## vvp alu_output
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Total tests: 42
Passed: 42
Failed: 0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
