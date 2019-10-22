class simple_test extends uvm_test;
  env env_h;
  sequence_in seq;
  sequence_rb seq_rb;
  bit reset;
  int count_tr_reset;

  `uvm_component_utils(simple_test)

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    count_tr_reset = 2000;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = env::type_id::create("env_h", this);
    seq = sequence_in::type_id::create("seq", this);
    seq_rb = sequence_rb::type_id::create("seq_rb", this);
  endfunction

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);
        env_h.mst.mon.count_tr_reset = count_tr_reset;
        forever begin
            fork
              seq_rb.start(env_h.mst_rb.sqr);
              begin 
                  if (reset) begin 
                      repeat(3000) seq.start(env_h.mst.sqr);
                      phase.drop_objection(this);
                  end

                  if (!reset) begin 
                      repeat(count_tr_reset) seq.start(env_h.mst.sqr);
                      reset = 1;
                  end
              end

              begin
                  @(negedge env_h.mst_rb.drv.vif.rst);
                  uvm_config_db#(int)::set(uvm_root::get(), "*", "begin_pre_reset", 1);
                  uvm_config_db#(int)::wait_modified(uvm_root::get(), "*", "end_pre_reset_agent_rb");
                  uvm_config_db#(int)::set(uvm_root::get(), "*", "begin_reset", 1);
                fork
                  uvm_config_db#(int)::wait_modified(uvm_root::get(), "*", "end_reset_driver_rb");
                  uvm_config_db#(int)::wait_modified(uvm_root::get(), "*", "end_reset_driver");
                  uvm_config_db#(int)::wait_modified(uvm_root::get(), "*", "end_reset_refmod");
                join
                  uvm_config_db#(int)::set(uvm_root::get(), "*", "begin_main", 1);
              end
            join
        end
    endtask
endclass
