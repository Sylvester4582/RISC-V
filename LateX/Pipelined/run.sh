#!/bin/bash

# Compile Verilog files
iverilog -o processor.vvp main_tb.v \
    src/main.v \
    src/control_unit.v \
    src/immediate_generator.v \
    src/register_file.v \
    src/branch_unit.v \
    src/program_counter.v \
    src/instruction_memory.v \
    src/data_memory.v \
    src/full_adder.v \
    src/adder_64bit.v \
    src/alu.v \
    src/comparator.v \
    src/logical_operators.v \
    src/shift_operators.v \
    src/subtractor_64bit.v

# Run simulation and log output
vvp processor.vvp > simulation.log 2>&1

# Display the log contents
cat simulation.log