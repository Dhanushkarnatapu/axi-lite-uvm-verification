// fifo_package.sv
`ifndef AXI4_PACKAGE_SV
`define AXI4_PACKAGE_SV

package axi4_package;

  // Include UVM library
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "axi4_seq_item.sv"
  `include "axi4_base_seq.sv"

  `include "axi4_driver.sv"
  `include "axi4_monitor.sv"
  `include "axi4_sequencer.sv"
  `include "axi4_agent.sv"
  `include "axi4_scoreboard.sv"
  `include "axi4_env.sv"
  `include "axi4_test.sv"

endpackage : axi4_package
`endif
