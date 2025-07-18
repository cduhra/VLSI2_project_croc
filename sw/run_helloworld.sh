#!/bin/bash

exec > run_helloworld.log 2>&1

set -e  # Exit on any error
set -x  # Print each command (for debugging)

make clean

# Step 1: Build the ELF
oseda -2025.03 make bin/helloworld.elf

# Step 2: Convert ELF to HEX
oseda -2025.03 riscv64-unknown-elf-objcopy -O verilog bin/helloworld.elf bin/helloworld.hex

# Step 3: Dump ELF contents
oseda -2025.03 riscv64-unknown-elf-objdump -D -s bin/helloworld.elf > bin/helloworld.dump

# Step 4: Run Verilator
cd ../verilator

# Compile the simulation binary
oseda -2025.03 verilator --binary -j 0 \
  -Wno-fatal -Wno-style \
  --timing --autoflush --trace --trace-structs \
  -CFLAGS "-O0" \
  --top tb_croc_soc -f croc.f


# Run the simulation
oseda -2025.03 ./obj_dir/Vtb_croc_soc +binary="../sw/bin/helloworld.hex"
