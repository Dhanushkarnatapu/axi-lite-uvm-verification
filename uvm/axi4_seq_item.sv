//axi4_seq_item.sv
`ifndef AXI4_SEQ_ITEM_SV
`define AXI4_SEQ_ITEM_SV
import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_seq_item extends uvm_sequence_item;
  typedef enum {AXI_READ, AXI_WRITE} axi_cmd_t; //transaction type
  rand axi_cmd_t cmd;
  randc bit[31:0] addr; //Address for AWADDR(write) or ARADDR (read)
  randc bit [31:0] wdata;
  rand bit [3:0] wstrb; //used for AXI_WRITE
  
  bit [31:0] rdata; //Read data field captured by monitor
  bit [1:0]resp; //Captured by BRESP or RRESP
  //Constraints
  constraint addr_align_c {
    addr[1:0] == 2'b00;
  }
  
  //reg_index = addr[5:2] -> 0 to 15
  constraint addr_range_c {
    addr inside {[32'h0000_0000 : 32'h0000_003C]};
  }
  
  //RTL ignores writes when WSTRB == 0
  constraint wstrb_c {
    if(cmd == AXI_WRITE)
      wstrb != 4'b0000;
  }
  //Constructor
  function new(string name = "axi4_seq_item");
    super.new(name);
  endfunction
  
  //UVM Automation
  `uvm_object_utils_begin(axi4_seq_item)
  `uvm_field_enum (axi_cmd_t, cmd, UVM_ALL_ON)
  `uvm_field_int (addr, UVM_ALL_ON)
  `uvm_field_int (wdata, UVM_ALL_ON)
  `uvm_field_int (wstrb, UVM_ALL_ON)
  `uvm_field_int (rdata, UVM_ALL_ON)
  `uvm_field_int (resp, UVM_ALL_ON)
  `uvm_object_utils_end
  
  //Convert2String(Debug Friendly)
  function string convert2string();
    return $sformatf(
      "AXI4_LITE_ITEM cmd=%s addr=0x%08X wdata=0x%08X wstrb=0x%0X rdata=0x%08X resp=%02b", (cmd == AXI_WRITE) ? "WRITE" : "READ", addr, wdata, wstrb, rdata, resp
    );//%[flags][width][base] general format structure
	/*% → start formatting
	  0 → pad with zeros
	  8 → minimum width = 8 characters
	  X → hexadecimal (uppercase)*/
	  
  endfunction
endclass
`endif
