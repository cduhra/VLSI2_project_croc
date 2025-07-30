# Verilator Simulation Quickstart - Croc SoC

This guide provides instructions for setting up and running Verilator simulations for the croc SoC project. It allows you to quickly build and test software on the croc SoC using the Verilator simulator.

## Prerequisites

Before you begin, ensure you have the following tools and dependencies installed:

- **Verilator** (version 4.x or higher) - Hardware simulation framework
- **make** - Build automation tool
- **gcc** - GNU Compiler Collection for building software
- **Standard build tools** - Including basic Unix utilities
- **Repository** - The croc SoC repository should be cloned locally

Make sure Verilator is available in your PATH and is a recommended version (4.x+).

## Setup

The repository comes with the necessary configuration files for Verilator simulation:

- **`croc.flist`** - Contains the complete list of RTL source files in the project root
- **`run_helloworld.sh`** - Script in the `sw` directory for building and running simulations

No additional setup or file creation is required to get started with basic simulations.

## Running the Software & Simulation

To build the software and launch the Verilator simulation:

1. Change into the `sw` directory:
   ```bash
   cd sw
   ```

2. Run the hello world example:
   ```bash
   ./run_helloworld.sh
   ```

This script will:
- Compile the hello world software for the croc SoC
- Invoke Verilator to build the simulation binary using the existing file lists
- Run the simulation with the compiled software

## Checking Output

If the simulation runs successfully, you should see:

- **Hello World message** - Output from the simulated program
- **Simulation logs** - Verilator runtime information and debug output
- **Completion status** - Indication that the simulation finished properly

The simulation will terminate automatically when the program completes execution.

## Notes

- **File Lists**: The project includes `croc.flist` in the root directory which contains all necessary RTL source files for simulation
- **Verilator PATH**: Ensure Verilator is in your PATH and is a recommended version (4.x+). You can verify this with `verilator --version`
- **Troubleshooting**: For troubleshooting issues:
  - Check the script output and Verilator compilation messages for error details
  - Verify all prerequisite tools are properly installed and accessible
  - Ensure the existing file lists contain valid file paths relative to the project root
  - Review Verilator output for missing dependencies or syntax errors in RTL files

The repository is already configured with the necessary file lists and scripts for Verilator simulation. No additional configuration files need to be created.