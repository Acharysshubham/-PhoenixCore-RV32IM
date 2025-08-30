
# PhoenixCore RV32IM: An AXI-Compliant, 5-Stage Pipelined RISC-V Processor

## Overview

This project documents the design, implementation, and verification of a complete 5-stage pipelined RISC-V processor, named **PhoenixCore**. The core is designed to be a reusable, SoC-ready IP, featuring a standard AXI4-Lite interface for communication with memory and peripherals. The project started as a simple single-cycle processor and was methodically evolved to include advanced, industry-standard features like hazard management, multi-cycle execution units, and exception handling hooks.

The primary goal was to create a robust and feature-rich soft-core processor that demonstrates a comprehensive understanding of modern computer architecture and digital design principles.

---

## 🏛️ Final Architecture & Key Features

* **5-Stage Pipelined Architecture:** The core uses a classic 5-stage (IF, ID, EX, MEM, WB) pipeline to maximize instruction throughput.
* **Complete Hazard Management:**
    * **Data Forwarding:** A forwarding unit resolves data hazards without stalling the pipeline.
    * **Stalling:** A hazard detection unit stalls the pipeline for one cycle on true load-use dependencies.
    * **Flushing:** Control hazards from taken branches and exceptions are handled by flushing the pipeline.
* **SoC-Ready AXI4-Lite Interface:** The processor is wrapped as an IP with a standard AXI4-Lite slave interface, allowing it to be easily integrated into a larger System-on-Chip design in Vivado.
* **RV32IM Instruction Set:**
    * Implements the full base integer instruction set (RV32I).
    * Includes the **M-extension** via an integrated, multi-cycle multiplication unit.
* **Exception Handling:** The hardware foundation for exception handling is built in, including a Control and Status Register (CSR) file (`mepc`, `mcause`) and logic to detect and trap on illegal instructions.
* **Advanced Verification:** The core was verified using a self-checking SystemVerilog testbench that acts as an AXI master to load the program, run the CPU, and automatically check the results against a reference model.



---

## 🚀 How to Run

1.  **Setup:**
    * Create a new project in Xilinx Vivado.
    * Add all the SystemVerilog files from the `/src` directory to the project's "Design Sources".
    * Add the `advanced_tb.sv` file to the project's "Simulation Sources".
    * Ensure the memory files from `/data` (`instructions.mem`, `data_mem.mem`) are in a location accessible by the simulator (e.g., the `sim_1/behav/xsim` directory).
2.  **Simulation:**
    * Set `advanced_tb` as the top module for simulation.
    * Run the behavioral simulation. The testbench will automatically load the program, run the CPU, and print `PASS` or `FAIL` messages to the Tcl console.
3.  **Synthesis & Implementation:**
    * Set `phoenix_core_top` as the top module for synthesis.
    * Synthesize, implement, and generate a bitstream for a target Zynq FPGA.

---
