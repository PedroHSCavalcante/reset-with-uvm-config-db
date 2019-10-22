class agent_rb extends uvm_agent;
    
    typedef uvm_sequencer#(transaction_rb) sequencer;
    sequencer  sqr;
    driver_rb   drv;
    monitor_rb  mon;

    uvm_analysis_port #(transaction_rb) agt_req_port;

    `uvm_component_utils(agent_rb)

    function new(string name = "agent_rb", uvm_component parent = null);
        super.new(name, parent);
        agt_req_port  = new("agt_req_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = monitor_rb::type_id::create("mon", this);
        sqr = sequencer::type_id::create("sqr", this);
        drv = driver_rb::type_id::create("drv", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.req_port.connect(agt_req_port);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    virtual task run_phase (uvm_phase phase);

        pre_reset_task();
   
    endtask

    task pre_reset_task();
        forever begin
            uvm_config_db#(int)::wait_modified(uvm_root::get(), "*", "begin_pre_reset");
            sqr.stop_sequences();
            uvm_config_db#(int)::set(uvm_root::get(), "*", "end_pre_reset_agent_rb", 1);
        end
    endtask : pre_reset_task
endclass: agent_rb