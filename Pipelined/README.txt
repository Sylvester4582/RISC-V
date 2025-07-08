RISC-V Implementation

How to Run:

To compile and run the simulation, execute the following command in your terminal:

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

Alternatively, if using Windows, you can execute `run.bat` which automates these steps.

---

Directory Structure:
- src/          : Core RISC-V implementation files
- Root/         : Testbench files
- results/      : Simulation output files (created during testing)

---

Test Program:
The current test program includes the following RISC-V instructions:

00000000010100000000000010010011  # ADDI x1, x0, 5
00000000100000000000000100010011  # ADDI x2, x0, 8
00000000011000000000000110010011  # ADDI x3, x0, 6
00000000100000000000010100010011  # ADDI x10, x0, 8
00000000000000000000001110010011  # ADDI x7, x0, 0
00000000001100010000001000110011  # ADD x4, x1, x3
01000000000100011000001010110011  # SUB x5, x3, x1
00000000001100001110010010110011  # OR x4, x3, x4
00000000001100001111010000110011  # AND x8, x3, x4
00000000000001010011001100000011  # LD x6, 0(x10)
00000000010001010011010000100011  # SD x4, 2(x10)
00000000000100111000001110010011  # ADDI x7, x7, 1
11111110000100111001110011100011  # BNE x7, x1, -4


---

How to Run Tests:
1. Clone the repository.
2. Run `run.bat` (Windows) or manually execute the above compilation commands in a Linux/macOS terminal.
3. The script will handle compilation and execution automatically.

---

Expected Output:
The testbench will display cycle-by-cycle execution details including:
- Current instruction and PC
- Register file contents
- Memory operations
- Branch operations
- Register write results

Additionally, detailed logs will be available for:
- Load/Store operations
- Branch decisions
- Register updates
- Memory state changes

---

Results:
Simulation results are stored in the `results/` directory:
- core_tb.vcd : Waveform dump file for viewing in GTKWave.
- cycle-by-cycle execution logs : Stored as `.log` files for debugging.

Use `cat simulation.log` to inspect the simulation output.