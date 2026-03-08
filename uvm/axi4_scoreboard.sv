// axi4_lite_scoreboard.sv
`ifndef AXI4_LITE_SCOREBOARD_SV
`define AXI4_LITE_SCOREBOARD_SV

class axi4_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi4_scoreboard)

  // -----------------------------
  // Analysis port to receive transactions from monitor
  // -----------------------------
  uvm_analysis_imp #(axi4_seq_item, axi4_scoreboard) mon_ap;

  // Functional storage to track writes
  bit [31:0] expected_mem [0:15];

  // Transaction for coverage
  axi4_seq_item cov_pkt;

  // -----------------------------
  // COVERAGE
  // -----------------------------
  covergroup axi4_coverage;
    option.per_instance = 1;

    ADDR_C: coverpoint cov_pkt.addr {
      bins addr_bins[] = {0, 4, 8, 12, 16, 20, 24, 28, 32, 36};
  }
    CMD_C:  coverpoint cov_pkt.cmd;
    WDATA_C: coverpoint cov_pkt.wdata;
    RDATA_C: coverpoint cov_pkt.rdata
  iff (cov_pkt.cmd == axi4_seq_item::AXI_READ) {
  option.auto_bin_max = 16;
}
    RESP_C: coverpoint cov_pkt.resp {
  bins okay    = {2'b00};
  bins slverr  = {2'b10};
  illegal_bins unsupported = {2'b01, 2'b11};
}

    //WR_X_WDATA: cross CMD_C, WDATA_C;
    //RD_X_RDATA: cross ADDR_C, RDATA_C;
  endgroup

  // -----------------------------
  // Constructor
  // -----------------------------
  function new(string name = "axi4_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
    cov_pkt = axi4_seq_item::type_id::create("cov_pkt");
    axi4_coverage = new();
  endfunction

  // -----------------------------
  // Analysis port write callback
  // -----------------------------
  function void write(axi4_seq_item t);
    int idx;
    idx = t.addr[5:2]; // 16 registers

if (idx > 15) begin
  `uvm_warning("SCOREBOARD",
    $sformatf("Ignoring illegal address access: 0x%0h", t.addr))
  return;
end

  // -----------------------------
  // Functional checking
  // -----------------------------
  if (t.cmd == axi4_seq_item::AXI_WRITE) begin
    for (int b = 0; b < 4; b++) begin
      if (t.wstrb[b])
        expected_mem[idx][8*b +: 8] = t.wdata[8*b +: 8];
    end
    `uvm_info("SCOREBOARD", $sformatf("WRITE: Addr=0x%0h Data=0x%0h Resp=%0b", t.addr, t.wdata, t.resp), UVM_LOW)
  end else if (t.cmd == axi4_seq_item::AXI_READ) begin
    if (t.rdata !== expected_mem[idx]) begin
      `uvm_error("SCOREBOARD", $sformatf("READ MISMATCH: Addr=0x%0h Expected=0x%0h Got=0x%0h Resp=%0b", t.addr, expected_mem[idx], t.rdata, t.resp))
    end else begin
      `uvm_info("SCOREBOARD", $sformatf("READ MATCH: Addr=0x%0h Data=0x%0h Resp=%0b", t.addr, t.rdata, t.resp), UVM_LOW)
    end
  end

  // -----------------------------
  // Coverage sampling using persistent object
  // -----------------------------
  cov_pkt.copy(t);
  axi4_coverage.sample();
endfunction

  // -----------------------------
  // Display coverage report
  // -----------------------------
  function void display_coverage();
    $display("-----------------------------------------------------------");
    $display("AXI4-Lite Coverage Report");
    $display("Overall covergroup coverage: %0f%%", axi4_coverage.get_coverage());
    $display("ADDR_C coverage: %0f%%", axi4_coverage.ADDR_C.get_coverage());
    $display("CMD_C coverage:  %0f%%", axi4_coverage.CMD_C.get_coverage());
    $display("WDATA_C coverage: %0f%%", axi4_coverage.WDATA_C.get_coverage());
    $display("RDATA_C coverage: %0f%%", axi4_coverage.RDATA_C.get_coverage());
    $display("RESP_C coverage:  %0f%%", axi4_coverage.RESP_C.get_coverage());
    $display("-----------------------------------------------------------");
  endfunction

endclass

`endif
