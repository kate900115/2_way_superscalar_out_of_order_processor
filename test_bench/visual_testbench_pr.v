
//`include "sys_defs.vh"
`timescale 1ns/100ps

extern void initcurses(int,int,int,int,int,int,int,int,int,int);
extern void flushpipe();
extern void waitforresponse();
extern void initmem();
extern int get_instr_at_pc(int);
extern int not_valid_pc(int);

module testbench;

	//variables used in the testbench
    	logic         clock;                    // System clock
    	logic         reset;                    // System reset
		logic [31:0]  clock_count;
		logic [31:0]  instr_count;
    	int           wb_fileno;
	
    	logic [3:0]   mem2proc_response;        // Tag from memory about current request
    	logic [63:0]  mem2proc_data;            // Data coming back from memory
    	logic [3:0]   mem2proc_tag;              // Tag from memory about current reply

    	BUS_COMMAND   proc2mem_command;    // command sent to memory
    	logic [63:0]  proc2mem_addr;      // Address sent to memory
  	 	logic [63:0]  proc2mem_data;      // Data sent to memory

    	logic [3:0]   pipeline_completed_insts;
    	logic [3:0]   pipeline_error_status;

    	// testing hooks (these must be exported so we can test
    	// the synthesized version) data is tested by looking at
    	// the final values in memory

    	//output
    	// Outputs from IF-Stage 
    	//Output from rob
    	logic							ROB_commit1_valid;
    	logic [63:0]					PRF_writeback_value1;
    	logic [63:0]					ROB_commit1_pc;
    	logic [$clog2(`ARF_SIZE)-1:0]	ROB_commit1_arn_dest;
    	logic							ROB_commit1_wr_en;
    	logic							ROB_commit2_valid;
    	logic [63:0]					PRF_writeback_value2;
    	logic [63:0]					ROB_commit2_pc;
   		logic [$clog2(`ARF_SIZE)-1:0]	ROB_commit2_arn_dest;
    	logic							ROB_commit2_wr_en;
    	
    	//pc output
		logic [31:0]	PC_inst1;
		logic [31:0]	PC_inst2;
		logic			PC_inst1_valid;
		logic			PC_inst2_valid;
		logic [63:0]	PC_proc2Imem_addr;
		logic			PC_thread1_is_available;
		
		//decoder
		logic [63:0]	ID_inst1_opa;
		logic [63:0]	ID_inst1_opb;
		logic			ID_inst1_opa_valid;
		logic			ID_inst1_opb_valid;
		logic [63:0]	ID_inst2_opa;
		logic [63:0]	ID_inst2_opb;
		logic			ID_inst2_opa_valid;
		logic			ID_inst2_opb_valid;
		logic [4:0]		ID_dest_ARF_idx1;
		logic [4:0]		ID_dest_ARF_idx2;
		ALU_FUNC		ID_alu_func1;
		ALU_FUNC		ID_alu_func2;
		FU_SELECT		ID_fu_select1;
		FU_SELECT		ID_fu_select2;
		logic [5:0]		ID_op_type1;
		logic [5:0]		ID_op_type2;
		logic			ID_inst1_is_cond_branch;
		logic			ID_inst2_is_cond_branch;
		logic			ID_inst1_is_uncond_branch;
		logic			ID_inst2_is_uncond_branch;
		logic			ID_inst1_is_valid;
		logic			ID_inst2_is_valid;
		logic			ID_inst1_is_halt;
		logic			ID_inst2_is_halt;
		logic			ID_inst1_is_illegal;
		logic			ID_inst2_is_illegal;

		//rat output
		logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_opa_idx1;
		logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_opb_idx1;
		logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_opa_idx2;
		logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_opb_idx2;

		logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_opa_idx1;	
		logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_opb_idx1;
		logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_opa_idx2;
		logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_opb_idx2;

		logic	RAT1_PRF_allocate_req1;
		logic	RAT1_PRF_allocate_req2;
		logic	RAT2_PRF_allocate_req1;
		logic	RAT2_PRF_allocate_req2;

		logic	[`PRF_SIZE-1:0]		RAT1_PRF_free_list;
		logic	[`PRF_SIZE-1:0]		RAT2_PRF_free_list;
		logic				rat1_prf_free_valid;
		logic				rat2_prf_free_valid;


		//prf output
		logic	PRF_RAT1_rename_valid1;
		logic	PRF_RAT1_rename_valid2;
		logic	PRF_RAT2_rename_valid1;
		logic	PRF_RAT2_rename_valid2;
	
		logic [$clog2(`PRF_SIZE)-1:0]	PRF_RAT1_rename_idx1;
		logic [$clog2(`PRF_SIZE)-1:0]	PRF_RAT1_rename_idx2;
		logic [$clog2(`PRF_SIZE)-1:0]	PRF_RAT2_rename_idx1;
		logic [$clog2(`PRF_SIZE)-1:0]	PRF_RAT2_rename_idx2;

		logic [63:0]	PRF_RS_inst1_opa;
		logic [63:0]	PRF_RS_inst1_opb;
		logic [63:0]	PRF_RS_inst2_opa;
		logic [63:0]	PRF_RS_inst2_opb;
		logic			PRF_RS_inst1_opa_valid;
		logic			PRF_RS_inst1_opb_valid;
		logic			PRF_RS_inst2_opa_valid;
		logic			PRF_RS_inst2_opb_valid;

		logic			PRF_is_full;

		//rrat output
		logic [`ARF_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]		RRAT_RAT_mispredict_up_idx1;
		logic [`ARF_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]		RRAT_RAT_mispredict_up_idx2;
		logic							RRAT1_PRF_free_valid1;
		logic [$clog2(`PRF_SIZE)-1:0]	RRAT1_PRF_free_idx1;
		logic 							RRAT1_PRF_free_valid2;
		logic [$clog2(`PRF_SIZE)-1:0]	RRAT1_PRF_free_idx2;
		logic							RRAT2_PRF_free_valid1;
		logic [$clog2(`PRF_SIZE)-1:0]	RRAT2_PRF_free_idx1;
		logic 							RRAT2_PRF_free_valid2;
		logic [$clog2(`PRF_SIZE)-1:0]	RRAT2_PRF_free_idx2;
		logic [`PRF_SIZE-1:0]			RRAT1_PRF_free_enable_list;
		logic [`PRF_SIZE-1:0]			RRAT2_PRF_free_enable_list;

		//rob output
		logic ROB_t1_is_full;
		logic ROB_t2_is_full;
		logic [$clog2(`ROB_SIZE):0]		ROB_inst1_rob_idx;
		logic							ROB_commit1_if_rename_out;
		logic							ROB_commit1_mispredict;
		logic [$clog2(`ROB_SIZE):0]		ROB_inst2_rob_idx;
		logic							ROB_commit2_if_rename_out;
		logic							ROB_commit2_mispredict;
		logic							cdb1_branch_taken;
		logic							cdb2_branch_taken;
		logic [63:0]					ROB_commit1_target_pc;
		logic [63:0]					ROB_commit2_target_pc;
		logic [$clog2(`PRF_SIZE)-1:0]	ROB_commit1_prn_dest;
		logic [$clog2(`PRF_SIZE)-1:0]	ROB_commit2_prn_dest;
		logic 							ROB_commit1_is_thread1;
		logic 							ROB_commit1_is_branch;
		logic 							ROB_commit2_is_thread1;
		logic							ROB_commit2_is_branch;
		logic							ROB_commit1_is_halt;
		logic							ROB_commit1_is_illegal;
		logic							ROB_commit2_is_halt;
		logic							ROB_commit2_is_illegal;

		//rs output
		logic [5:0][63:0]		RS_EX_opa;
		logic [5:0][63:0]		RS_EX_opb;
		logic [5:0][$clog2(`PRF_SIZE)-1:0]	RS_EX_dest_tag;
		logic [5:0][$clog2(`ROB_SIZE):0]	RS_EX_rob_idx;
		logic [5:0][5:0]			RS_EX_op_type;
		logic [5:0]					RS_EX_out_valid;
		ALU_FUNC [5:0]				RS_EX_alu_func;
		logic						RS_full;

		//ex output
		logic [5:0]							EX_RS_fu_is_available;
		logic [5:0][$clog2(`PRF_SIZE)-1:0]	EX_CDB_dest_tag;
		logic [5:0][63:0]					EX_CDB_fu_result_out;
		logic [5:0]							EX_CDB_fu_result_is_valid;
		logic [5:0][$clog2(`ROB_SIZE):0]	EX_CDB_rob_idx;
		logic [1:0]							EX_CDB_mispredict_sig;
		//ex success send to cdb
		logic					adder1_send_in_success;
		logic					adder2_send_in_success;
		logic					mult1_send_in_success;
		logic					mult2_send_in_success;
		logic					memory1_send_in_success;
		logic					memory2_send_in_success;

		//cdb output
		logic							cdb1_valid;
		logic [63:0]					cdb1_value;
		logic [$clog2(`PRF_SIZE)-1:0]	cdb1_tag;
		logic [$clog2(`ROB_SIZE):0]		cdb1_rob_idx;
		logic							cdb2_valid;
		logic [63:0]					cdb2_value;
		logic [$clog2(`PRF_SIZE)-1:0]	cdb2_tag;
		logic [$clog2(`ROB_SIZE):0]		cdb2_rob_idx;

		logic [63:0]	thread1_target_pc;
		logic [63:0]	thread2_target_pc;
    	

		processor processor_0(
			//input
    		.clock(clock),                    					// System clock
    		.reset(reset),                    					// System reset
    		.mem2proc_response(mem2proc_response),        		// Tag from memory about current request
    		.mem2proc_data(mem2proc_data),            			// Data coming back from memory
    		.mem2proc_tag(mem2proc_tag),              			// Tag from memory about current reply

			//output
    		.proc2mem_command(proc2mem_command),    			// command sent to memory
    		.proc2mem_addr(proc2mem_addr),      				// Address sent to memory
    		.proc2mem_data(proc2mem_data),      				// Data sent to memory

    		.pipeline_completed_insts(pipeline_completed_insts),
    
    		.pipeline_error_status(pipeline_error_status),
    		//.pipeline_commit_wr_idx(pipeline_commit_wr_idx),
    		//.pipeline_commit_wr_data(pipeline_commit_wr_data),
    		//.pipeline_commit_wr_en(pipeline_commit_wr_en),
    		//.pipeline_commit_NPC(pipeline_commit_NPC),


    		// testing hooks (these must be exported so we can test
    		// the synthesized version) data is tested by looking at
    		// the final values in memory

    		//output
    		//Output from rob
    		.ROB_commit1_valid(ROB_commit1_valid),
    		.ROB_commit1_arn_dest(ROB_commit1_arn_dest),
    		.ROB_commit1_wr_en(ROB_commit1_wr_en),
    		.PRF_writeback_value1(PRF_writeback_value1),
    		.ROB_commit2_valid(ROB_commit2_valid),
    		.ROB_commit2_arn_dest(ROB_commit2_arn_dest),
    		.ROB_commit2_wr_en(ROB_commit2_wr_en),
    		.PRF_writeback_value2(PRF_writeback_value2),
    		
    		.PC_proc2Imem_addr(PC_proc2Imem_addr),
			.PC_proc2Imem_addr_previous(PC_proc2Imem_addr_previous),
			.PC_inst1(PC_inst1),
			.PC_inst2(PC_inst2),
			.PC_inst1_valid(PC_inst1_valid),
			.PC_inst2_valid(PC_inst2_valid),
    
    		// Outputs from RS
			.fu_next_inst_pc_out(fu_next_inst_pc_out),
			.RS_EX_op_type(RS_EX_op_type),
			.RS_EX_alu_func(RS_EX_alu_func),
	
			// Outputs from EX-stage
			.fu_inst_pc_out(fu_inst_pc_out),	
			.EX_alu_func_out(EX_alu_func_out),
    		.EX_rs_op_type_out(EX_rs_op_type_out),
    		.EX_RS_fu_is_available(EX_RS_fu_is_available),
    		.EX_CDB_fu_result_is_valid(EX_CDB_fu_result_is_valid),
	
			// Outputs from ROB
			.ROB_commit1_pc(ROB_commit1_pc),
			.ROB_commit2_pc(ROB_commit2_pc),
			.ROB_commit1_inst_out(ROB_commit1_inst_out),
			.ROB_commit2_inst_out(ROB_commit2_inst_out)
	);

	// Instantiate the Data Memory
	mem memory(
			// Inputs
			.clock             (clock),
			.proc2mem_command  (proc2mem_command),
			.proc2mem_addr     (proc2mem_addr),
			.proc2mem_data     (proc2mem_data),

			 // Outputs
			.mem2proc_response (mem2proc_response),
			.mem2proc_data     (mem2proc_data),
			.mem2proc_tag      (mem2proc_tag)
		   );

	// Generate System Clock
	always
	begin
		#(`VERILOG_CLOCK_PERIOD/2.0);
		clock = ~clock;
	end

	// Task to display # of elapsed clock edges


  always @(negedge clock)
  begin
    if(!reset)
    begin
      `SD;
      `SD;

      // deal with any halting conditions
      if(pipeline_error_status!=NO_ERROR)
      begin
        #100
        $display("\nDONE\n");
        waitforresponse();
        flushpipe();
        $finish;
      end

    end
  end 

  // Count the number of posedges and number of instructions completed
  // till simulation ends
	
	// Count the number of posedges and number of instructions completed
	// till simulation ends
	always @(posedge clock or posedge reset)
	begin
		if(reset)
		begin
			clock_count <= `SD 0;
			instr_count <= `SD 0;
		end
		else
		begin
			clock_count <= `SD (clock_count + 1);
			instr_count <= `SD (instr_count + pipeline_completed_insts);
		end
	end  

  initial
  begin
    clock = 0;
    reset = 0;

    // Call to initialize visual debugger
    // *Note that after this, all stdout output goes to visual debugger*
    // each argument is number of registers/signals for the group
    // (IF, RS, ID, ROB, EX, EX/MEM, MEM, RAT, WB, Misc)
    // p: PC 6  g: ID 13  
    initcurses(6,13,26,24,9,48,10,42,10,2);

    // Pulse the reset signal
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);

    // Read program contents into memory array
    $readmemh("program.mem", memory.unified_memory);

    @(posedge clock);
    @(posedge clock);
    `SD;
    // This reset is at an odd time to avoid the pos & neg clock edges
    reset = 1'b0;
  end
  
  
  always @(clock) begin
    #2;

    // Dump clock and time onto stdout
    $display("c%h%7.0d",clock,clock_count);
    $display("t%8.0f",$time);
    $display("z%h",reset);

    // dump PRF contents
    $write("a");
    $write("%h", processor_0.prf1.prf2[0].value);
    $write("%h", processor_0.prf1.prf2[1].value);
    $write("%h", processor_0.prf1.prf2[2].value);
    $write("%h", processor_0.prf1.prf2[3].value);
    $write("%h", processor_0.prf1.prf2[4].value);
    $write("%h", processor_0.prf1.prf2[5].value);
    $write("%h", processor_0.prf1.prf2[6].value);
    $write("%h", processor_0.prf1.prf2[7].value);
    $write("%h", processor_0.prf1.prf2[8].value);
    $write("%h", processor_0.prf1.prf2[9].value);
    $write("%h", processor_0.prf1.prf2[10].value);
    $write("%h", processor_0.prf1.prf2[11].value);
    $write("%h", processor_0.prf1.prf2[12].value);
    $write("%h", processor_0.prf1.prf2[13].value);
    $write("%h", processor_0.prf1.prf2[14].value);
    $write("%h", processor_0.prf1.prf2[15].value);
    $write("%h", processor_0.prf1.prf2[16].value);
    $write("%h", processor_0.prf1.prf2[17].value);
    $write("%h", processor_0.prf1.prf2[18].value);
    $write("%h", processor_0.prf1.prf2[19].value);
    $write("%h", processor_0.prf1.prf2[20].value);
    $write("%h", processor_0.prf1.prf2[21].value);
    $write("%h", processor_0.prf1.prf2[22].value);
    $write("%h", processor_0.prf1.prf2[23].value);
    $write("%h", processor_0.prf1.prf2[24].value);
    $write("%h", processor_0.prf1.prf2[25].value);
    $write("%h", processor_0.prf1.prf2[26].value);
    $write("%h", processor_0.prf1.prf2[27].value);
    $write("%h", processor_0.prf1.prf2[28].value);
    $write("%h", processor_0.prf1.prf2[29].value);
    $write("%h", processor_0.prf1.prf2[30].value);
    $write("%h", processor_0.prf1.prf2[31].value);
    $write("%h", processor_0.prf1.prf2[32].value);
    $write("%h", processor_0.prf1.prf2[33].value);
    $write("%h", processor_0.prf1.prf2[34].value);
    $write("%h", processor_0.prf1.prf2[35].value);
    $write("%h", processor_0.prf1.prf2[36].value);
    $write("%h", processor_0.prf1.prf2[37].value);
    $write("%h", processor_0.prf1.prf2[38].value);
    $write("%h", processor_0.prf1.prf2[39].value);
    $write("%h", processor_0.prf1.prf2[40].value);
    $write("%h", processor_0.prf1.prf2[41].value);
    $write("%h", processor_0.prf1.prf2[42].value);
    $write("%h", processor_0.prf1.prf2[43].value);
    $write("%h", processor_0.prf1.prf2[44].value);
    $write("%h", processor_0.prf1.prf2[45].value);
    $write("%h", processor_0.prf1.prf2[46].value);
    $write("%h", processor_0.prf1.prf2[47].value);
    $display("");

    // dump IR information so we can see which instruction
    // is in each stage
 /*   $write("p");
    $write("%h%h%h%h%h%h%h%h%h%h ",
            processor_0.if_IR_out, processor_0.if_valid_inst_out,
            processor_0.if_id_IR,  processor_0.if_id_valid_inst,
            processor_0.id_ex_IR,  processor_0.id_ex_valid_inst,
            processor_0.ex_mem_IR, processor_0.ex_mem_valid_inst,
            processor_0.mem_wb_IR, processor_0.mem_wb_valid_inst);
    $display("");*/
    
    // Dump interesting register/signal contents onto stdout
    // format is "<reg group prefix><name> <width in hex chars>:<data>"
    // Current register groups (and prefixes) are:
    // p: PC 6  g: ID 26  r: RAT 16  f: PRF  17  e:RRAT 10  i:ROB  22 s:RS 5 x:EX 9  d:CDB 10 w: WB 10 v: misc. reg 2
    // g: IF/ID   h: ID/EX  i: EX/MEM  j: MEM/WB

    // PC signals (6) - prefix 'f'
    $display("fPC1 16:%h",          			processor_0.PC_proc2Imem_addr);
    $display("fPC2 16:%h",          			processor_0.PC_proc2Imem_addr+4);
    $display("fPC_inst1_valid 1:%h",    		processor_0.PC_inst1_valid);
    $display("fPC_inst2_valid 1:%h",         	processor_0.PC_inst2_valid);
    $display("fPC_proc2Imem_addr 16:%h",       	processor_0.PC_proc2Imem_addr);
    $display("fPC_thread1_is_available 1:%h",   processor_0.PC_thread1_is_available);

    // ID signals (26) - prefix 'd'
    $display("dID_inst1_opa 16:%h",        		processor_0.ID_inst1_opa);
    $display("dID_inst1_opb 16:%h",        		processor_0.ID_inst1_opb);
    $display("dID_inst1_opa_valid 1:%h",   		processor_0.ID_inst1_opa_valid);
    $display("dID_inst1_opb_valid 1:%h",   		processor_0.ID_inst1_opb_valid);
    $display("dID_dest_ARF_idx1 5:%d",			processor_0.ID_dest_ARF_idx1);
    $display("dID_alu_func1 16:%h",     		processor_0.ID_alu_func1);
    $display("dID_fu_select1 16:%h",        	processor_0.ID_fu_select1);
    $display("dID_op_type1 5:%h",   			processor_0.ID_op_type1);
    $display("dID_inst1_is_cond_branch 1:%h",   processor_0.ID_inst1_is_cond_branch);
    $display("dID_inst1_is_uncond_branch 1:%h",	processor_0.ID_inst1_is_uncond_branch);
    $display("dID_inst1_is_valid 1:%h",   		processor_0.ID_inst1_is_valid);
    $display("dID_inst1_is_halt 1:%h",   		processor_0.ID_inst1_is_halt);
    $display("dID_inst1_is_illegal 1:%h",		processor_0.ID_inst1_is_illegal);//13
        
    $display("dID_inst2_opa 16:%h",        		processor_0.ID_inst2_opa);
    $display("dID_inst2_opb 16:%h",        		processor_0.ID_inst2_opb);
    $display("dID_inst2_opa_valid 1:%h",   		processor_0.ID_inst2_opa_valid);
    $display("dID_inst2_opb_valid 1:%h",   		processor_0.ID_inst2_opb_valid); 
    $display("dID_dest_ARF_idx2 5:%d",			processor_0.ID_dest_ARF_idx2);
    $display("dID_alu_func2 16:%h",     		processor_0.ID_alu_func1);
    $display("dID_fu_select2 16:%h",        	processor_0.ID_fu_select1);
    $display("dID_op_type2 5:%h",   			processor_0.ID_op_type1);
    $display("dID_inst2_is_cond_branch 1:%b",   processor_0.ID_inst1_is_cond_branch);
    $display("dID_inst2_is_uncond_branch 1:%b",	processor_0.ID_inst1_is_uncond_branch);
    $display("dID_inst2_is_valid 1:%b",   		processor_0.ID_inst1_is_valid);
    $display("dID_inst2_is_halt 1:%b",   		processor_0.ID_inst1_is_halt);
    $display("dID_inst2_is_illegal 1:%b",		processor_0.ID_inst1_is_illegal);
    


    // RAT signals (16) - prefix 'i'
    $display("iRAT1_PRF_opa_idx1 6:%h",         processor_0.RAT1_PRF_opa_idx1);
    $display("iRAT1_PRF_opb_idx1 6:%h",         processor_0.RAT1_PRF_opb_idx1);
    $display("iRAT1_PRF_opa_idx2 6:%h",         processor_0.RAT1_PRF_opa_idx2);
    $display("iRAT1_PRF_opb_idx2 6:%h",         processor_0.RAT1_PRF_opb_idx2);
    $display("iRAT1_PRF_free_list 6:%h",        processor_0.RAT1_PRF_free_list);
    
    $display("iRAT2_PRF_opa_idx1 6:%h",         processor_0.RAT2_PRF_opa_idx1);
    $display("iRAT2_PRF_opb_idx1 6:%h",         processor_0.RAT2_PRF_opb_idx1);
    $display("iRAT2_PRF_opa_idx2 6:%h",         processor_0.RAT2_PRF_opa_idx2);
    $display("iRAT2_PRF_opb_idx2 6:%h",         processor_0.RAT2_PRF_opb_idx2);
    $display("iRAT2_PRF_free_list 6:%h",        processor_0.RAT2_PRF_free_list);  //10
    
    $display("iRAT1_PRF_allocate_req1 1:%h",    processor_0.RAT1_PRF_allocate_req1);
    $display("iRAT1_PRF_allocate_req2 1:%h",    processor_0.RAT1_PRF_allocate_req2);
    $display("irat1_prf_free_valid 1:%h",       processor_0.rat1_prf_free_valid);
    $display("iRAT2_PRF_allocate_req1 1:%h",    processor_0.RAT2_PRF_allocate_req1);
    $display("iRAT2_PRF_allocate_req2 1:%h",    processor_0.RAT2_PRF_allocate_req2);
    $display("irat2_prf_free_valid 1:%h",       processor_0.rat2_prf_free_valid);  //6
    
    $display("ir0 6:%d",processor_0.rat1.rat_reg[0]);
    $display("ir1 6:%d",processor_0.rat1.rat_reg[1]);
    $display("ir2 6:%d",processor_0.rat1.rat_reg[2]);
    $display("ir3 6:%d",processor_0.rat1.rat_reg[3]);
    $display("ir4 6:%d",processor_0.rat1.rat_reg[4]);
    $display("ir5 6:%d",processor_0.rat1.rat_reg[5]);
    $display("ir6 6:%d",processor_0.rat1.rat_reg[6]);
 	$display("ir7 6:%d",processor_0.rat1.rat_reg[7]);
  	$display("ir8 6:%d",processor_0.rat1.rat_reg[8]);
  	$display("ir9 6:%d",processor_0.rat1.rat_reg[9]);
  	$display("ir10 6:%d",processor_0.rat1.rat_reg[10]);
	$display("ir11 6:%d",processor_0.rat1.rat_reg[11]);
    $display("ir12 6:%d",processor_0.rat1.rat_reg[12]);
    $display("ir13 6:%d",processor_0.rat1.rat_reg[13]);
    $display("ir14 6:%d",processor_0.rat1.rat_reg[14]);
    $display("ir15 6:%d",processor_0.rat1.rat_reg[15]);
    $display("ir16 6:%d",processor_0.rat1.rat_reg[16]);
 	$display("ir17 6:%d",processor_0.rat1.rat_reg[17]);
  	$display("ir18 6:%d",processor_0.rat1.rat_reg[18]);
  	$display("ir19 6:%d",processor_0.rat1.rat_reg[19]);
  	$display("ir20 6:%d",processor_0.rat1.rat_reg[20]);
  	$display("ir21 6:%d",processor_0.rat1.rat_reg[21]);
    $display("ir22 6:%d",processor_0.rat1.rat_reg[22]);
    $display("ir23 6:%d",processor_0.rat1.rat_reg[23]);
    $display("ir24 6:%d",processor_0.rat1.rat_reg[24]);
    $display("ir25 6:%d",processor_0.rat1.rat_reg[25]);
    $display("ir26 6:%d",processor_0.rat1.rat_reg[26]);
 	$display("ir27 6:%d",processor_0.rat1.rat_reg[27]);
  	$display("ir28 6:%d",processor_0.rat1.rat_reg[28]);
  	$display("ir29 6:%d",processor_0.rat1.rat_reg[29]);
  	$display("ir30 6:%d",processor_0.rat1.rat_reg[30]);
  	$display("ir31 6:%d",processor_0.rat1.rat_reg[31]);
    // PRF signals (17) - prefix 'f'
   /* $display("fPRF_RAT1_rename_valid1 1:%h",    processor_0.PRF_RAT1_rename_valid1);
    $display("fPRF_RAT1_rename_valid2 1:%h",    processor_0.PRF_RAT1_rename_valid2);
    $display("fPRF_RAT2_rename_valid1 1:%h",    processor_0.PRF_RAT2_rename_valid1);
    $display("fPRF_RAT2_rename_valid2 1:%h",    processor_0.PRF_RAT2_rename_valid2);
    $display("fPRF_RS_inst1_opa_valid 1:%h",    processor_0.PRF_RS_inst1_opa_valid);
    $display("fPRF_RS_inst1_opb_valid 1:%h",    processor_0.PRF_RS_inst1_opb_valid);  
    $display("fPRF_RS_inst2_opa_valid 1:%h",    processor_0.PRF_RS_inst2_opa_valid);
    $display("fPRF_RS_inst2_opb_valid 1:%h",    processor_0.PRF_RS_inst2_opb_valid);
    $display("fPRF_is_full 1:%h",       		processor_0.PRF_is_full); //9
    
    $display("fPRF_RS_inst1_opa 16:%h",         processor_0.PRF_RS_inst1_opa); 
    $display("fPRF_RS_inst1_opb 16:%h",         processor_0.PRF_RS_inst1_opb); 
    $display("fPRF_RS_inst2_opa 16:%h",         processor_0.PRF_RS_inst2_opa); 
    $display("fPRF_RS_inst2_opb 16:%h",         processor_0.PRF_RS_inst2_opb); 
    
    $display("fPRF_RAT1_rename_idx1 16:%h",     processor_0.PRF_RAT1_rename_idx1); 
    $display("fPRF_RAT1_rename_idx2 16:%h",     processor_0.PRF_RAT1_rename_idx2); 
    $display("fPRF_RAT2_rename_idx1 16:%h",     processor_0.PRF_RAT2_rename_idx1); 
    $display("fPRF_RAT2_rename_idx2 16:%h",     processor_0.PRF_RAT2_rename_idx2); //17

*/

    // RRAT signals (10) - prefix 'j'
    $display("jRRAT1_PRF_free_valid1 1:%h",     	processor_0.RRAT1_PRF_free_valid1);
    $display("jRRAT1_PRF_free_valid2 1:%h",     	processor_0.RRAT1_PRF_free_valid2);
    $display("jRRAT2_PRF_free_valid1 1:%h",     	processor_0.RRAT2_PRF_free_valid1);
    $display("jRRAT2_PRF_free_valid2 1:%h",     	processor_0.RRAT2_PRF_free_valid2);//4
    
    $display("jRRAT1_PRF_free_idx1 16:%h",      	processor_0.RRAT1_PRF_free_idx1); 
    $display("jRRAT1_PRF_free_idx2 16:%h",      	processor_0.RRAT1_PRF_free_idx2); 
    $display("jRRAT2_PRF_free_idx1 16:%h",      	processor_0.RRAT2_PRF_free_idx1); 
    $display("jRRAT2_PRF_free_idx2 16:%h",      	processor_0.RRAT2_PRF_free_idx2);  
    $display("jRRAT1_PRF_free_enable_list 16:%h",   processor_0.RRAT1_PRF_free_enable_list); 
    $display("jRRAT2_PRF_free_enable_list 16:%h",   processor_0.RRAT2_PRF_free_enable_list);     //10
//logic [`ARF_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]		RRAT_RAT_mispredict_up_idx1;
//logic [`ARF_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]		RRAT_RAT_mispredict_up_idx2;
    $display("jr0 6:%d",   processor_0.rrat1.rrat_reg[0]);
    $display("jr1 6:%d",   processor_0.rrat1.rrat_reg[1]);
    $display("jr2 6:%d",   processor_0.rrat1.rrat_reg[2]);
    $display("jr3 6:%d",   processor_0.rrat1.rrat_reg[3]);
    $display("jr4 6:%d",   processor_0.rrat1.rrat_reg[4]);
    $display("jr5 6:%d",   processor_0.rrat1.rrat_reg[5]);
    $display("jr6 6:%d",   processor_0.rrat1.rrat_reg[6]);
    $display("jr7 6:%d",   processor_0.rrat1.rrat_reg[7]);
    $display("jr8 6:%d",   processor_0.rrat1.rrat_reg[8]);
    $display("jr9 6:%d",   processor_0.rrat1.rrat_reg[9]);
    $display("jr10 6:%d",   processor_0.rrat1.rrat_reg[10]);
    $display("jr11 6:%d",   processor_0.rrat1.rrat_reg[11]);
    $display("jr12 6:%d",   processor_0.rrat1.rrat_reg[12]);
    $display("jr13 6:%d",   processor_0.rrat1.rrat_reg[13]);
    $display("jr14 6:%d",   processor_0.rrat1.rrat_reg[14]);
    $display("jr15 6:%d",   processor_0.rrat1.rrat_reg[15]);
    $display("jr16 6:%d",   processor_0.rrat1.rrat_reg[16]);
    $display("jr17 6:%d",   processor_0.rrat1.rrat_reg[17]);
    $display("jr18 6:%d",   processor_0.rrat1.rrat_reg[18]);
    $display("jr19 6:%d",   processor_0.rrat1.rrat_reg[19]);
    $display("jr20 6:%d",   processor_0.rrat1.rrat_reg[20]);
    $display("jr21 6:%d",   processor_0.rrat1.rrat_reg[21]);
    $display("jr22 6:%d",   processor_0.rrat1.rrat_reg[22]);
    $display("jr23 6:%d",   processor_0.rrat1.rrat_reg[23]);
    $display("jr24 6:%d",   processor_0.rrat1.rrat_reg[24]);
    $display("jr25 6:%d",   processor_0.rrat1.rrat_reg[25]);
    $display("jr26 6:%d",   processor_0.rrat1.rrat_reg[26]);
    $display("jr27 6:%d",   processor_0.rrat1.rrat_reg[27]);
    $display("jr28 6:%d",   processor_0.rrat1.rrat_reg[28]);
    $display("jr29 6:%d",   processor_0.rrat1.rrat_reg[29]);
    $display("jr30 6:%d",   processor_0.rrat1.rrat_reg[30]);
    $display("jr31 6:%d",   processor_0.rrat1.rrat_reg[31]);
    // rob signals (22) - prefix 'i'
    $display("hROB_commit1_mispredict 1:%h",        processor_0.ROB_commit1_mispredict);
    $display("hROB_t1_is_full 1:%h",       			processor_0.ROB_t1_is_full);
    $display("hROB_t2_is_full 1:%h",       			processor_0.ROB_t2_is_full);//4
    $display("hROB_commit2_mispredict 1:%h",        processor_0.ROB_commit2_mispredict);
    $display("hcdb1_branch_taken 1:%h",       		processor_0.cdb1_branch_taken);
    $display("hcdb2_branch_taken 1:%h",       		processor_0.cdb2_branch_taken);//4
    $display("hROB_commit1_is_thread1 1:%h",        processor_0.ROB_commit1_is_thread1);
    $display("hROB_commit1_is_branch 1:%h",         processor_0.ROB_commit1_is_branch);
    $display("hROB_commit2_is_thread1 1:%h",        processor_0.ROB_commit2_is_thread1);
    $display("hROB_commit2_is_branch 1:%h",         processor_0.ROB_commit2_is_branch);//4
    $display("hROB_commit1_is_halt 1:%h",           processor_0.ROB_commit1_is_halt);
    $display("hROB_commit1_is_illegal 1:%h",        processor_0.ROB_commit1_is_illegal);
    $display("hROB_commit2_is_halt 1:%h",           processor_0.ROB_commit2_is_halt);
    $display("hROB_commit2_is_illegal 1:%h",        processor_0.ROB_commit2_is_illegal);//16
    
    $display("hROB_inst1_rob_idx 16:%h",            processor_0.ROB_inst1_rob_idx); 
    $display("hROB_inst2_rob_idx 16:%h",            processor_0.ROB_inst2_rob_idx); 
    $display("hROB_commit1_target_pc 16:%h",        processor_0.ROB_commit1_target_pc); 
    $display("hROB_commit2_target_pc 16:%h",        processor_0.ROB_commit2_target_pc);  
    $display("hROB_commit1_prn_dest 16:%h",         processor_0.ROB_commit1_prn_dest); 
    $display("hROB_commit2_prn_dest 16:%h",         processor_0.ROB_commit2_prn_dest);     //22
    
    $display("hRob_t1_head 1:%h",         processor_0.rob1.t1_head);  
    $display("hRob_t1_tail 1:%h",         processor_0.rob1.t1_tail);  
    $display("hRob_t2_head 1:%h",         processor_0.rob1.t2_head);  
    $display("hRob_t2_tail 1:%h",         processor_0.rob1.t2_tail);  
   


    // RS signals (13) - prefix 'g'
    $display("gRS_EX_out_valid1 6:%b",     			processor_0.RS_EX_out_valid[0]);
    $display("gRS_EX_out_valid2 6:%b",     			processor_0.RS_EX_out_valid[1]);
    $display("gRS_EX_out_valid3 6:%b",     			processor_0.RS_EX_out_valid[2]);
    $display("gRS_EX_out_valid4 6:%b",     			processor_0.RS_EX_out_valid[3]);
    $display("gRS_EX_out_valid5 6:%b",     			processor_0.RS_EX_out_valid[4]);
    $display("gRS_EX_out_valid6 6:%b",     			processor_0.RS_EX_out_valid[5]);
    $display("gRS_EX_alu_func1 6:%b",   			processor_0.RS_EX_alu_func[0]);
    $display("gRS_EX_alu_func2 6:%b",   			processor_0.RS_EX_alu_func[1]);
    $display("gRS_EX_alu_func3 6:%b",   			processor_0.RS_EX_alu_func[2]);
    $display("gRS_EX_alu_func4 6:%b",   			processor_0.RS_EX_alu_func[3]);
    $display("gRS_EX_alu_func5 6:%b",   			processor_0.RS_EX_alu_func[4]);
    $display("gRS_EX_alu_func6 6:%b",   			processor_0.RS_EX_alu_func[5]);
    $display("gRS_full 1:%b",   					processor_0.RS_full);
    
    //rs output
//logic [5:0][63:0]		RS_EX_opa;
//logic [5:0][63:0]		RS_EX_opb;
//[5:0][$clog2(`PRF_SIZE)-1:0]	RS_EX_dest_tag;
//logic [5:0][$clog2(`ROB_SIZE):0]	RS_EX_rob_idx;
//logic [5:0][5:0]			RS_EX_op_type;

    // EX signals (9) - prefix 'e'
    $display("eEX_RS_fu_is_available 6:%h",         processor_0.EX_RS_fu_is_available);
    $display("eEX_CDB_fu_result_is_valid 6:%h",     processor_0.EX_CDB_fu_result_is_valid);
    $display("eEX_CDB_mispredict_sig 2:%h",         processor_0.EX_CDB_mispredict_sig);
    $display("eadder1_send_in_success 1:%h",        processor_0.adder1_send_in_success);
    $display("eadder2_send_in_success 1:%h",        processor_0.adder2_send_in_success);
    $display("emult1_send_in_success 1:%h",     	processor_0.mult1_send_in_success);
    $display("emult2_send_in_success 1:%h",     	mult2_send_in_success);
    $display("ememory1_send_in_success 1:%h",       processor_0.memory1_send_in_success);
    $display("ememory2_send_in_success 1:%h",       processor_0.memory2_send_in_success);//9
    
    //CDB signals(10) --prefix 'd'
    $display("wcdb1_valid 1:%h",        			processor_0.cdb1_valid);
    $display("wcdb1_value 16:%h",         			processor_0.cdb1_value); 
    $display("wcdb1_tag 16:%h",         			processor_0.cdb1_tag); 
    $display("wcdb1_rob_idx 16:%h",         		processor_0.cdb1_rob_idx); 
    $display("wthread1_target_pc 16:%h",         	processor_0.thread1_target_pc); 
    $display("wcdb2_valid 1:%h",        			processor_0.cdb2_valid); 
    $display("wcdb2_value 16:%h",         			processor_0.cdb2_value); 
    $display("wcdb2_tag 16:%h",         			processor_0.cdb2_tag);
    $display("wcdb2_rob_idx 16:%h",         		processor_0.cdb2_rob_idx); 
    $display("wthread2_target_pc 16:%h",         	processor_0.thread2_target_pc); //10
    
    // MEM signals (10) - prefix 'm'*****Writeback
      
    $display("mwr_data1 16:%h",     				processor_0.PRF_writeback_value1);
    $display("mROB_commit1_pc 16:%h",     			processor_0.ROB_commit1_pc);
    $display("mROB_commit1_arn_dest 16:%h",     	processor_0.ROB_commit1_arn_dest);
    $display("mROB_commit1_wr_en 1:%h",     		processor_0.ROB_commit1_wr_en);
    $display("mROB_commit1_valid 1:%h",     		processor_0.ROB_commit1_valid);
    $display("mwr_data1 16:%h",     				processor_0.PRF_writeback_value2);
    $display("mROB_commit2_pc 16:%h",     			processor_0.ROB_commit2_pc);
    $display("mROB_commit2_arn_dest 16:%h",     	processor_0.ROB_commit2_arn_dest);
    $display("mROB_commit2_wr_en 1:%h",     		processor_0.ROB_commit2_wr_en);
    $display("mROB_commit2_valid 1:%h",     		processor_0.ROB_commit2_valid);//10
    
    // Misc signals(2) - prefix 'v'
    $display("vcompleted 1:%h",     				processor_0.pipeline_completed_insts);
    $display("vpipe_err 1:%h",      				pipeline_error_status);
//ex output
//logic [5:0][$clog2(`PRF_SIZE)-1:0]	EX_CDB_dest_tag;
//logic [5:0][63:0]					EX_CDB_fu_result_out;
//logic [5:0][$clog2(`ROB_SIZE):0]	EX_CDB_rob_idx;


    // must come last
    $display("break");

    // This is a blocking call to allow the debugger to control when we
    // advance the simulation
    waitforresponse();
  end

endmodule  // module testbench


