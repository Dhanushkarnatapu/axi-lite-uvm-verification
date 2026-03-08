// axi4_monitor.sv
`ifndef AXI4_MONITOR_SV
`define AXI4_MONITOR_SV

class axi4_monitor extends uvm_monitor;
  `uvm_component_utils(axi4_monitor)

  // Virtual interface
  virtual axi4_lite_if.MONITOR aif;

  // Analysis port
  uvm_analysis_port #(axi4_seq_item) mon_ap;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_lite_if)::get(this, "", "aif", aif))
      `uvm_fatal(get_type_name(), "Virtual interface not found for AXI4-Lite monitor")
    else
      `uvm_info(get_type_name(), "Virtual interface connected", UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      monitor_write();
      monitor_read();
    join_none
  endtask

  // ------------------------------------------------
  // WRITE MONITOR
  // ------------------------------------------------
  task monitor_write();
    axi4_seq_item tr;

    bit aw_seen, w_seen;
    bit [31:0] awaddr;
    bit [31:0] wdata;
    bit [3:0]  wstrb;

    forever begin
      aw_seen = 0;
      w_seen  = 0;

      // Capture AW & W in any order
      while (!(aw_seen && w_seen)) begin
        @(aif.mon_cb);

        if (!aw_seen && aif.mon_cb.AWVALID && aif.mon_cb.AWREADY) begin
          awaddr  = aif.mon_cb.AWADDR;
          aw_seen = 1;
        end

        if (!w_seen && aif.mon_cb.WVALID && aif.mon_cb.WREADY) begin
          wdata = aif.mon_cb.WDATA;
          wstrb = aif.mon_cb.WSTRB;
          w_seen = 1;
        end
      end

      // Wait for write response
      do @(aif.mon_cb); while (!(aif.mon_cb.BVALID && aif.mon_cb.BREADY));

      // Build transaction
      tr = axi4_seq_item::type_id::create("wr_tr", this);
      tr.cmd   = axi4_seq_item::AXI_WRITE;
      tr.addr  = awaddr;
      tr.wdata = wdata;
      tr.wstrb = wstrb;
      tr.resp  = aif.mon_cb.BRESP;

      `uvm_info(get_type_name(),
                $sformatf("MON WRITE: %s", tr.convert2string()),
                UVM_MEDIUM)

      mon_ap.write(tr);
    end
  endtask

  // ------------------------------------------------
  // READ MONITOR
  // ------------------------------------------------
  task monitor_read();
  axi4_seq_item tr;
  bit [31:0] araddr;

  forever begin
    // Wait for AR handshake
    @(posedge aif.ACLK);
    wait (aif.mon_cb.ARVALID && aif.mon_cb.ARREADY);
    araddr = aif.mon_cb.ARADDR;

    // Wait for read data valid
    @(posedge aif.ACLK);
    wait (aif.mon_cb.RVALID && aif.mon_cb.RREADY);

    // Now sample RDATA
    tr = axi4_seq_item::type_id::create("rd_tr", this);
    tr.cmd   = axi4_seq_item::AXI_READ;
    tr.addr  = araddr;
    tr.rdata = aif.mon_cb.RDATA;
    tr.resp  = aif.mon_cb.RRESP;

    `uvm_info(get_type_name(),
              $sformatf("MON READ: %s", tr.convert2string()),
              UVM_MEDIUM)

    mon_ap.write(tr);
  end
endtask
endclass
`endif
