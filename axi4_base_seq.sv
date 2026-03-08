//axi4_base_seq.sv
`ifndef AXI4_BASE_SEQ_SV
`define AXI4_BASE_SEQ_SV

class axi4_base_seq extends uvm_sequence #(axi4_seq_item);
  int unsigned txn_id;
  `uvm_object_utils(axi4_base_seq)
  
  function new(string name = "axi4_base_seq");
    super.new(name);
  endfunction
  
  virtual task body();
  `uvm_info(get_type_name(),
            "Starting AXI4-Lite Base Sequence",
            UVM_MEDIUM)

    repeat (300) begin
    axi4_seq_item seq_item;
    seq_item = axi4_seq_item::type_id::create(
                 $sformatf("seq_item_%0d", txn_id));
    start_item(seq_item);
    if (!seq_item.randomize())
      `uvm_error(get_type_name(), "Randomization failed");
    finish_item(seq_item);
    log_txn(seq_item, txn_id);
    txn_id++;
  end
  `uvm_info(get_type_name(),
            "Completed AXI4-Lite Base Sequence",
            UVM_LOW)
endtask
  virtual protected task log_txn(axi4_seq_item item, int txn_id);
  `uvm_info(
    get_type_name(),
    $sformatf("TXN[%0d] %s", txn_id, item.convert2string()),
    UVM_MEDIUM
  )
endtask
endclass
//WRITE ONLY SEQUENCE
class axi4_write_only_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_write_only_seq)
  function new(string name = "axi_write_only_seq");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_info(get_type_name(), "Starting Write only sequence", UVM_LOW)
    repeat(20) begin
      axi4_seq_item seq_item;
      seq_item = axi4_seq_item::type_id::create(
        $sformatf("seq_item_%0d", txn_id));
      start_item(seq_item);
      assert(seq_item.randomize() with {
        cmd == AXI_WRITE;
      });
      finish_item(seq_item);
      log_txn(seq_item, txn_id);
      txn_id++;
    end
    `uvm_info(get_type_name(), "Completed Write only sequence", UVM_LOW)
  endtask
endclass
//READ ONLY SEQUENCE
class axi4_read_only_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_read_only_seq)
  function new(string name = "axi4_read_only_seq");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_info(get_type_name(), "Starting Read only sequence", UVM_LOW)
    repeat(20) begin
      axi4_seq_item seq_item;
      seq_item = axi4_seq_item::type_id::create(
        $sformatf("seq_item_%0d", txn_id));
      start_item(seq_item);
      assert(seq_item.randomize() with {
        cmd == AXI_READ;
      });
      finish_item(seq_item);
      log_txn(seq_item, txn_id);
      txn_id++;
    end
    `uvm_info(get_type_name(), "Completed Read only sequence", UVM_LOW)
  endtask
endclass
//BACK TO BACK WR SEQUENCE
class axi4_back_to_back_rw_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_back_to_back_rw_seq)
  function new(string name = "axi4_back_to_back_rw_seq");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_info(get_type_name(), "Starting Back to Back RW Sequence", UVM_LOW)
    repeat(10) begin
      axi4_seq_item wr, rd;
      bit[31:0]addr;
      addr = $urandom_range(0, 15) << 2;
      //Write
      wr = axi4_seq_item::type_id::create($sformatf("wr_item_%0d", txn_id));
      start_item(wr);
      assert(wr.randomize() with {
        cmd == AXI_WRITE;
        addr == local::addr;
      });
      finish_item(wr);
      log_txn(wr, txn_id);
      //Read
      rd = axi4_seq_item::type_id::create($sformatf("rd_item_%0d", txn_id));
      start_item(rd);
      assert(rd.randomize() with {
        cmd == AXI_READ;
        addr == local::addr;
      });
      finish_item(rd);
      log_txn(rd, txn_id);
      txn_id++;
    end
    `uvm_info(get_type_name(), "Completed Back to Back RW Sequence", UVM_LOW)
  endtask
endclass
//PARTIAL WRITE SEQUENCE
class axi4_partial_write_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_partial_write_seq)
  function new(string name = "axi4_partial_write_seq");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_info(get_type_name(), "Starting AXI4 Partial Write Sequence", UVM_LOW)
    repeat(20) begin
      axi4_seq_item seq_item;
      seq_item = axi4_seq_item::type_id::create($sformatf("seq_item_%0d", txn_id));
      start_item(seq_item);
      assert(seq_item.randomize() with {
        cmd == AXI_WRITE;
        wstrb inside {4'b0001, 4'b0011, 4'b0101, 4'b1110};
      });
      finish_item(seq_item);
      log_txn(seq_item, txn_id);
      txn_id++;
    end
    `uvm_info(get_type_name(), "Completed AXI4 Partial Write Sequence", UVM_LOW)
  endtask
endclass
//ILLEGAL ADDRESS SEQUENCE 
class axi4_illegal_addr_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_illegal_addr_seq)
  function new(string name = "axi4_illegal_addr_seq");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_info(get_type_name(), "Starting Illegal address sequence", UVM_LOW)
    repeat(10) begin
      axi4_seq_item seq_item;
      seq_item = axi4_seq_item::type_id::create($sformatf("seq_item_%0d", txn_id));
      start_item(seq_item);
      seq_item.addr_range_c.constraint_mode(0);//Disable randomize to see the outer address range
      assert(seq_item.randomize() with {
        addr inside {[32'h0000_0040 : 32'h0000_00FF]};
      });
      finish_item(seq_item);
      log_txn(seq_item, txn_id);
      txn_id++;
    end
    `uvm_info(get_type_name(), "Completed Illegal address sequence", UVM_LOW)
  endtask
endclass
//SAME ADDRESS STRESS SEQUENCE
class axi4_same_addr_stress_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_same_addr_stress_seq)
  function new(string name = "axi4_same_addr_stress_seq");
    super.new(name);
  endfunction
  virtual task body();
    bit [31:0]hot_addr;
    hot_addr = 32'h0000_0008;
    `uvm_info(get_type_name(), "Starting same address stress sequence", UVM_LOW)
    repeat(30) begin
      axi4_seq_item seq_item;
      seq_item = axi4_seq_item::type_id::create($sformatf("seq_item_%0d", txn_id));
      start_item(seq_item);
      assert(seq_item.randomize() with {
        addr == local::hot_addr;
      });
      finish_item(seq_item);
      log_txn(seq_item, txn_id);
      txn_id++;
    end
    `uvm_info(get_type_name(), "Completed same address stress sequence", UVM_LOW)
  endtask
endclass
//RANDOM MIX SEQUENCE 
class axi4_random_mix_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_random_mix_seq)
  function new(string name = "axi4_random_mix_seq");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_info(get_type_name(),
              "Starting RANDOM MIX REGRESSION sequence",
              UVM_LOW)
    repeat (500) begin
      axi4_seq_item seq_item;
      seq_item = axi4_seq_item::type_id::create($sformatf("seq_item_%0d", txn_id));
      start_item(seq_item);
      assert(seq_item.randomize() with {
        cmd dist {AXI_WRITE := 60, AXI_READ := 40};
      });
      finish_item(seq_item);
      log_txn(seq_item, txn_id);
      txn_id++;
    end
  endtask
endclass
`endif