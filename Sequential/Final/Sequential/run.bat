@echo off
REM Clean up previous simulation files
del /Q *.vvp *.vcd *.log

echo.
echo Test file contents:
type testcase.txt
echo.

REM Compile Verilog files
iverilog -o processor.vvp ^
    tb/core_tb.v ^
    rtl/core/core.v ^
    rtl/core/control_unit.v ^
    rtl/core/immediate_generator.v ^
    rtl/core/register_file.v ^
    rtl/core/branch_unit.v ^
    rtl/core/program_counter.v ^
    rtl/memory/instruction_memory.v ^
    rtl/memory/data_memory.v ^
    rtl/alu/full_adder.v ^
    rtl/alu/adder_64bit.v ^
    rtl/alu/alu.v ^
    rtl/alu/comparator.v ^
    rtl/alu/logical_operators.v ^
    rtl/alu/shift_operators.v ^
    rtl/alu/subtractor_64bit.v

REM Run simulation if compilation succeeded
if %ERRORLEVEL% EQU 0 (
    vvp processor.vvp > simulation.log 2>&1
    type simulation.log
) else (
    echo Compilation failed!
)

pause