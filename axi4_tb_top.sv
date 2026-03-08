`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "axi4_package.sv"
module axi4_tb_top;
import axi4_package::*;
  // -------------------------------------------------
  // Clock & Reset
  // -------------------------------------------------
  logic ACLK;
  logic ARESETn;

  // 100 MHz clock
  initial begin
    ACLK = 1'b0;
    forever #5 ACLK = ~ACLK;
  end

  // Active-low reset
  initial begin
    ARESETn = 1'b0;
    #40;
    ARESETn = 1'b1;
  end

  // -------------------------------------------------
  // AXI4-Lite Interface Instance
  // -------------------------------------------------
  axi4_lite_if #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
  ) axi_if (
    .ACLK    (ACLK),
    .ARESETn (ARESETn)
  );

  // -------------------------------------------------
  // DUT Instance
  // -------------------------------------------------
  axi4_lite #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
  ) dut (
    .axi (axi_if)   // <-- interface modport slave used internally
  );

  // -------------------------------------------------
  // UVM Virtual Interface Configuration
  // -------------------------------------------------
  initial begin
    // Pass full interface handle (driver/monitor use modports)
    uvm_config_db#(virtual axi4_lite_if)::set(
      null,
      "uvm_test_top.env.agent*",
      "aif",
      axi_if
    );
  end

  // -------------------------------------------------
  // Start UVM
  // -------------------------------------------------
  initial begin
    run_test("axi4_test");
  end

endmodule