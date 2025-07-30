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

## Creating croc.f

Before running the simulation, you need to create a file list for Verilator:

1. In the project root directory, create a file named `croc.f`
2. Add the following line to `croc.f`:
   ```
   rtl/cve2/cve2_mac_controller.sv
   ```
3. Further RTL files can be added one per line if needed for your specific design requirements

**Note:** The `croc.f` file tells Verilator which RTL source files to include in the simulation build. The example above includes the CVE2 MAC controller module as a starting point.

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
- Invoke Verilator to build the simulation binary using the `croc.f` file list from the project root
- Run the simulation with the compiled software

## Checking Output

If the simulation runs successfully, you should see:

- **Hello World message** - Output from the simulated program
- **Simulation logs** - Verilator runtime information and debug output
- **Completion status** - Indication that the simulation finished properly

The simulation will terminate automatically when the program completes execution.

## Notes

- **croc.f Updates**: The `croc.f` file must be updated if RTL changes are made, including when source files are added, removed, or renamed
- **Verilator PATH**: Ensure Verilator is in your PATH and is a recommended version (4.x+). You can verify this with `verilator --version`
- **Troubleshooting**: For troubleshooting issues:
  - Check the script output and Verilator compilation messages for error details
  - Verify all prerequisite tools are properly installed and accessible
  - Ensure the `croc.f` file contains valid file paths relative to the project root
  - Review Verilator output for missing dependencies or syntax errors in RTL files

For more comprehensive simulation with the full SoC, you may need to add additional RTL files to `croc.f` based on your specific requirements.