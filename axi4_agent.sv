//axi4_agent.sv
`ifndef AXI4_AGENT_SV
`define AXI4_AGENT_SV

class axi4_agent extends uvm_agent;
`uvm_component_utils(axi4_agent)
axi4_sequencer sequencer;
axi4_driver driver;
axi4_monitor monitor;

//virtual interface
virtual axi4_lite_if aif;
//constructor
function new(string name = "axi4_agent", uvm_component parent);
super.new(name, parent);
endfunction;

//Build phase
function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(get_is_active == UVM_ACTIVE) begin
sequencer = axi4_sequencer::type_id::create("sequencer", this);
driver = axi4_driver::type_id::create("driver", this);
if(!uvm_config_db #(virtual axi4_lite_if)::get(this, "", "aif", aif))
`uvm_fatal(get_type_name(), "Virtual interface is not set for AXI4 Agent");

end
monitor = axi4_monitor::type_id::create("monitor", this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
if(get_is_active == UVM_ACTIVE)begin
driver.seq_item_port.connect(sequencer.seq_item_export);
end
endfunction
endclass
`endif