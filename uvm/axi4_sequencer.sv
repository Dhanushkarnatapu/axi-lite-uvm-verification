//axi4_sequencer.sv
`ifndef AXI4_SEQUENCER_SV
`define AXI4_SEQUENCER_SV

class axi4_sequencer extends uvm_sequencer #(axi4_seq_item);
  `uvm_component_utils(axi4_sequencer)
  function new(string name = "axi4_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build Phase: AXI4 Sequencer created successfully", UVM_LOW)
  endfunction 
endclass
`endif
