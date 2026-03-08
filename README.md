AXI4-Lite IP Repository Documentation
Project Overview

The AXI4-Lite repository contains a fully synthesizable AXI4-Lite master/slave interface module along with a UVM-based verification environment. This IP is designed to integrate into SoC designs or FPGA projects requiring a lightweight AXI interface for control and status registers.

Key Features:

Supports AXI4-Lite read and write transactions.
Burst size fixed to 1 (per AXI4-Lite spec).
Fully verified using a SystemVerilog UVM environment.
Configurable address and data width for flexible integration.
Includes a top-level testbench for functional verification.

Functional Description

The AXI4-Lite module implements the following interfaces and behaviors:
Write Channel:
AWADDR, AWVALID, AWREADY signals for address handshake.
WDATA, WSTRB, WVALID, WREADY signals for data handshake.
BVALID, BRESP for write response.

Read Channel:
ARADDR, ARVALID, ARREADY for read address handshake.
RDATA, RRESP, RVALID, RREADY for read data handshake.

Protocol Compliance:
Supports AXI4-Lite single-beat transactions.
Proper handshake sequencing enforced.

Verification
The verification environment uses UVM (Universal Verification Methodology) to fully exercise the AXI4-Lite interface.
UVM Components:
Agents: AXI master and slave agents generate transactions.
Environment (env): Instantiates agents and connects to DUT.
Test Sequences: Constrained-random and directed tests to validate protocol compliance.
Top-Level Testbench (axi4_lite_tb.sv): Integrates DUT with UVM environment.

Simulation:
Can be run with standard SystemVerilog simulators (VCS, QuestaSim, Xcelium).
Generates waveforms to observe transaction sequences and verify correctness.
