//axi4_env.sv
`ifndef AXI4_ENV_SV
`define AXI4_ENV_SV

class axi4_env extends uvm_env;
`uvm_component_utils(axi4_env)
axi4_agent agent;
axi4_scoreboard scoreboard;

function new(string name = "axi4_env", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
agent = axi4_agent::type_id::create("agent", this);
scoreboard = axi4_scoreboard::type_id::create("scoreboard", this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
agent.monitor.mon_ap.connect(scoreboard.mon_ap);
endfunction
endclass
`endif
