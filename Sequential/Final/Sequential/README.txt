RISC-V Implementation

Directory Structure:
- rtl/core/      : Core RISC-V implementation files
- tb/            : Testbench files
- results/       : Simulation output files (created during testing)

Test Program:
The current test program includes the following RISC-V instructions:
00000000010100000000000010010011  # ADDI x1, x0, 5
00000000100000000000000100010011  # ADDI x2, x0, 8
00000000011000000000000110010011  # ADDI x3, x0, 6
00000000100000000000010100010011  # ADDI x10, x0, 8
00000000000000000000001110010011  # ADDI x7, x0, 0
00000000001100010000001000110011  # ADD x4, x1, x3
01000000000100011000001010110011  # SUB x5, x3, x1
00000000000001010011001100000011  # LD x6, 0(x10)
00000000010001010011010000100011  # SD x4, 2(x10)
00000000000100111000001110010011  # ADDI x7, x7, 1
11111110000100111001110011100011  # BNE x7, x1, -4

How to Run Tests:
Clone repo and click on run.bat, it will do the work for you

Expected Output:
- The testbench will display cycle-by-cycle execution details including:
  * Current instruction and PC
  * Register file contents
  * Memory operations
  * Branch operations
  * Register write results

- Detailed logging for:
  * Load/Store operations
  * Branch decisions
  * Register updates
  * Memory state changes

Results:
- Simulation results are stored in the 'results' directory:
  * core_tb.vcd: Waveform dump file
  * cycle-by-cycle execution logs in .log