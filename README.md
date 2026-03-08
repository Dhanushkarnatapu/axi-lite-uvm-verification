# AXI4-Lite with UVM Verification

## Overview
This project implements an **AXI4-Lite interface** in SystemVerilog and verifies the design using a **UVM (Universal Verification Methodology) based verification environment**.

The AXI4-Lite IP provides a lightweight, single-beat transaction interface suitable for **control and status registers** in SoC or FPGA designs.

## Design Features
- AXI4-Lite read and write channels
- Single-beat transaction support (burst size = 1)
- Parameterizable address and data width
- Proper handshake and response signaling (`VALID` / `READY`, `RESP`)
- Synthesizable RTL implementation

## Verification Environment
The design is verified using a **UVM testbench architecture** including:

- UVM agents for AXI master and slave interfaces
- Drivers and monitors for stimulus and observation
- Sequencers and sequences for transaction generation
- Scoreboard for functional checking
- Top-level testbench integrating DUT with the UVM environment

## Repository Structure
rtl/ -> RTL implementation of AXI4-Lite
uvm/ -> UVM verification components including agents, env, tests, and top-level TB


## Tools Used
- SystemVerilog
- UVM
- ModelSim / QuestaSim / VCS / Xcelium simulation

## Learning Outcomes
- AXI4-Lite protocol understanding and implementation
- DUT integration with UVM environment
- Testbench architecture and functional verification
- Scoreboard and transaction-based verification methodology
