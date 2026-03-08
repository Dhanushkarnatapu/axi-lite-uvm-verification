// axi4_driver.sv
`ifndef AXI4_DRIVER_SV
`define AXI4_DRIVER_SV

class axi4_driver extends uvm_driver #(axi4_seq_item);
  `uvm_component_utils(axi4_driver)

  // ---------------------------
  // Use the full interface here
  // ---------------------------
  virtual axi4_lite_if aif;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_lite_if)::get(this, "", "aif", aif))
      `uvm_fatal(get_type_name(), "Virtual interface not found")
  endfunction

  // ------------------------------------------------
  // RUN PHASE
  // ------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    axi4_seq_item tr;

    wait_for_reset();
    reset_signals();

    forever begin
      seq_item_port.get_next_item(tr);

      if (tr.cmd == axi4_seq_item::AXI_WRITE)
        drive_write(tr);
      else
        drive_read(tr);

      seq_item_port.item_done();
    end
  endtask

  // ------------------------------------------------
  // RESET
  // ------------------------------------------------
  task wait_for_reset();
    wait (aif.ARESETn == 0);
    wait (aif.ARESETn == 1);
    @(posedge aif.ACLK);
  endtask

  task reset_signals();
    aif.drv_cb.AWVALID <= 0;
    aif.drv_cb.WVALID  <= 0;
    aif.drv_cb.BREADY  <= 0;
    aif.drv_cb.ARVALID <= 0;
    aif.drv_cb.RREADY  <= 0;
  endtask

  // ------------------------------------------------
  // WRITE TRANSACTION
  // ------------------------------------------------
  task drive_write(axi4_seq_item tr);
    bit aw_done, w_done;

    aw_done = 0;
    w_done  = 0;

    // Drive address + data
    @(posedge aif.ACLK);
    aif.drv_cb.AWADDR  <= tr.addr;
    aif.drv_cb.AWVALID <= 1;
    aif.drv_cb.WDATA   <= tr.wdata;
    aif.drv_cb.WSTRB   <= tr.wstrb;
    aif.drv_cb.WVALID  <= 1;

    // Wait for handshakes (read directly from interface)
    while (!(aw_done && w_done)) begin
      @(posedge aif.ACLK);

      if (!aw_done && aif.AWREADY) begin
        aif.drv_cb.AWVALID <= 0;
        aw_done = 1;
      end

      if (!w_done && aif.WREADY) begin
        aif.drv_cb.WVALID <= 0;
        w_done = 1;
      end
    end

    // Write response
    aif.drv_cb.BREADY <= 1;
    do @(posedge aif.ACLK); while (!aif.BVALID);

    tr.resp = aif.BRESP;
    aif.drv_cb.BREADY <= 0;
  endtask

  // ------------------------------------------------
  // READ TRANSACTION
  // ------------------------------------------------
  task drive_read(axi4_seq_item tr);

    // Address phase
    @(posedge aif.ACLK);
    aif.drv_cb.ARADDR  <= tr.addr;
    aif.drv_cb.ARVALID <= 1;

    do @(posedge aif.ACLK); while (!aif.ARREADY);
    aif.drv_cb.ARVALID <= 0;

    // Data phase
    aif.drv_cb.RREADY <= 1;
    do @(posedge aif.ACLK); while (!aif.RVALID);

    tr.rdata = aif.RDATA;
    tr.resp  = aif.RRESP;
    aif.drv_cb.RREADY <= 0;
  endtask

endclass
`endif