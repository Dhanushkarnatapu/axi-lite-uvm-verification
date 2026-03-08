//axi4_test.sv
`ifndef AXI4_TEST_SV
`define AXI4_TEST_SV

class axi4_test extends uvm_test;
`uvm_component_utils(axi4_test)
axi4_env env;

function new(string name, uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
env = axi4_env::type_id::create("env", this);
endfunction

task run_phase(uvm_phase phase);

axi4_base_seq              base_seq;
axi4_write_only_seq        write_only_seq;
axi4_read_only_seq         read_only_seq;
axi4_back_to_back_rw_seq   back_to_back_rw_seq;
axi4_partial_write_seq     partial_write_seq;
axi4_illegal_addr_seq      illegal_addr_seq;
axi4_same_addr_stress_seq  same_addr_stress_seq;
axi4_random_mix_seq        random_mix_seq;

phase.raise_objection(this);

base_seq = axi4_base_seq::type_id::create("base_seq");
write_only_seq = axi4_write_only_seq::type_id::create("write_only_seq");
read_only_seq = axi4_read_only_seq::type_id::create("read_only_seq");
back_to_back_rw_seq = axi4_back_to_back_rw_seq::type_id::create("back_to_back_rw_seq");
partial_write_seq = axi4_partial_write_seq::type_id::create("partial_write_seq");
illegal_addr_seq = axi4_illegal_addr_seq::type_id::create("illegal_addr_seq");
same_addr_stress_seq = axi4_same_addr_stress_seq::type_id::create("same_addr_stress_seq");
random_mix_seq = axi4_random_mix_seq::type_id::create("random_mix_seq");

base_seq.start(env.agent.sequencer);
write_only_seq.start(env.agent.sequencer);
read_only_seq.start(env.agent.sequencer);
back_to_back_rw_seq.start(env.agent.sequencer);
partial_write_seq.start(env.agent.sequencer);
illegal_addr_seq.start(env.agent.sequencer);
same_addr_stress_seq.start(env.agent.sequencer);
random_mix_seq.start(env.agent.sequencer);

phase.drop_objection(this);
endtask

function void end_of_elaboration_phase(uvm_phase phase);
uvm_top.print_topology();
endfunction

function void final_phase(uvm_phase phase);
axi4_scoreboard sb;
if($cast(sb, env.scoreboard))
sb.display_coverage();
endfunction
endclass
`endif
