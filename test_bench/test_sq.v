module test_sq;
	
	//logic
	logic	clock;
	logic	reset;
	
	logic	id_wr_mem_in1;
	logic	id_wr_mem_in2;		//stq
	
	logic	is_thread1;
	
	//for instruction1
	logic  [63:0] 								lsq_opa_in1;      	// Operand a from Rename  data
	logic  [63:0] 								lsq_opb_in1;      	// Operand a from Rename  tag or data from prf
	logic         								lsq_opb_valid1;   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [$clog2(`ROB_SIZE):0]				lsq_rob_idx_in1;  	// The rob index of instruction 1
	logic  [63:0]								lsq_ra_data1;	//comes from prf according to idx request; 0 if load
	logic										lsq_ra_data_valid1; //weather data comes form prf is valid; if not; get from cdb
        
    //for instruction2
	logic  [63:0] 								lsq_opa_in2;      	// Operand a from Rename  data
	logic  [63:0] 								lsq_opb_in2;     	// Operand b from Rename  tag or data from prf
	logic         								lsq_opb_valid2;   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [$clog2(`ROB_SIZE)-1:0]				lsq_rob_idx_in2;  	// The rob index of instruction 2
	logic  [63:0]								lsq_ra_data2; 	//comes from prf according to idx request; 0 if load
	logic										lsq_ra_data_valid2;	//weather data comes form prf is valid; if not; get from cdb

	//we need rob age for store to commit
	logic	[$clog2(`ROB_SIZE):0]		rob_commit_idx1;
	logic	[$clog2(`ROB_SIZE):0]		rob_commit_idx2;
	
	//we need to know weather the instruction commited is a mispredict
	logic	thread1_mispredict;
	logic	thread2_mispredict;
	
	logic	[63:0]						instr_store_to_mem1;
	logic								instr_store_to_mem_valid1;
	logic	[4:0]						mem_store_idx;
	
	logic								rob1_excuted;
	logic								rob2_excuted;
	logic								t1_is_full;
	logic								t2_is_full;
	logic 	correct;

sq sq1(
	//logic
	.clock(clock),
	.reset(reset),
	.id_wr_mem_in1(id_wr_mem_in1),
	.id_wr_mem_in2(id_wr_mem_in2),		//stq
	.is_thread1(is_thread1),
	.lsq_opa_in1(lsq_opa_in1),      	// Operand a from Rename  data
	.lsq_opb_in1(lsq_opb_in1),      	// Operand a from Rename  tag or data from prf
	.lsq_opb_valid1(lsq_opb_valid1),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	.lsq_rob_idx_in1(lsq_rob_idx_in1),  	// The rob index of instruction 1
	.lsq_ra_data1(lsq_ra_data1),	//comes from prf according to idx request, 0 if load
	.lsq_ra_data_valid1(lsq_ra_data_valid1), //weather data comes form prf is valid, if not, get from cdb
	.lsq_opa_in2(lsq_opa_in2),      	// Operand a from Rename  data
	.lsq_opb_in2(lsq_opb_in2),     	// Operand b from Rename  tag or data from prf
	.lsq_opb_valid2(lsq_opb_valid2),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	.lsq_rob_idx_in2(lsq_rob_idx_in2),  	// The rob index of instruction 2
	.lsq_ra_data2(lsq_ra_data2), 	//comes from prf according to idx request, 0 if load
	.lsq_ra_data_valid2(lsq_ra_data_valid2),	//weather data comes form prf is valid, if not, get from cdb
	
	//we need rob age for store to commit
	.rob_commit_idx1(rob_commit_idx1),
	.rob_commit_idx2(rob_commit_idx2),
	
	//we need to know weather the instruction commited is a mispredict
	.thread1_mispredict(thread1_mispredict),
	.thread2_mispredict(thread2_mispredict),
	
	.instr_store_to_mem1(instr_store_to_mem1),
	.instr_store_to_mem_valid1(instr_store_to_mem_valid1),
	.mem_store_idx(mem_store_idx),
	.rob1_excuted(rob1_excuted),
	.rob2_excuted(rob2_excuted),
	.t1_is_full(t1_is_full),
	.t2_is_full(t2_is_full)
	);


always #5 clock = ~clock;
	
task exit_on_error;
	begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
	end
endtask

initial begin
	$monitor ("@@@ time:%d, \
			clock:%b, \
		    instr_store_to_mem1:%b, \
			instr_store_to_mem_valid1:%b, \
		    mem_store_idx:%b, \
			rob1_excuted:%b, \
			sq_t1_head:%b, \
			sq_t1_tail:%b, \
			sq_t2_head:%b, \
			sq_t2_tail:%b, \
			rob2_excuted:%b, \
			t1_is_full:%b, \
			t2_is_full:%b",
			$time, clock, instr_store_to_mem1, instr_store_to_mem_valid1, mem_store_idx, rob1_excuted, sq1.sq_t1_head, sq1.sq_t1_tail, sq1.sq_t2_head, sq1.sq_t2_tail,rob2_excuted, t1_is_full, t2_is_full);


	clock = 0;
	//***RESET*** //1
	reset = 1;
	correct = 1;

	//HERE we initial the reg
	#5; //2


	@(negedge clock);

	reset = 0;
	id_wr_mem_in1 = 1;
	id_wr_mem_in2 = 1;		//stq
	is_thread1 = 1;
	lsq_opa_in1 = 32'h0000_0001; 	// Operand a from Rename  data
	lsq_opb_in1 = 32'h0000_00f0;    	// Operand a from Rename  tag or data from prf
	lsq_opb_valid1 = 1; 					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in1 = 12;					// The rob index of instruction 1
	lsq_ra_data1 = 1016;					//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid1 = 1;				//weather data comes form prf is valid, if not, get from cdb
	lsq_opa_in2  = 32'h0000_0002; 	// Operand a from Rename  data
	lsq_opb_in2  = 32'h0000_00f0;	// Operand b from Rename  tag or data from prf
	lsq_opb_valid2  = 1;					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in2 = 13;	// The rob index of instruction 2
	lsq_ra_data2 = 1032;	//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid2 = 1;	//weather data comes form prf is valid, if not, get from cdb
	
	//we need rob age for store to commit
	rob_commit_idx1 = 12;
	rob_commit_idx2 = 13;
	
	//we need to know weather the instruction commited is a mispredict
	thread1_mispredict = 0;
	thread2_mispredict = 0;

	#1
	correct = (instr_store_to_mem1 ==0 && instr_store_to_mem_valid1 == 0 && mem_store_idx == 0 && rob1_excuted==0 && rob2_excuted==0 && !t1_is_full && !t2_is_full);
	assert(correct) $display("@@@passed1");
		else #1 exit_on_error;

	@(negedge clock);


	reset = 0;
	id_wr_mem_in1 = 1;
	id_wr_mem_in2 = 1;		//stq
	is_thread1 = 1;
	lsq_opa_in1 = 32'h0000_0001; 	// Operand a from Rename  data
	lsq_opb_in1 = 32'h0000_00f0;    	// Operand a from Rename  tag or data from prf
	lsq_opb_valid1 = 1; 					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in1 = 12;					// The rob index of instruction 1
	lsq_ra_data1 = 1016;					//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid1 = 1;				//weather data comes form prf is valid, if not, get from cdb
	lsq_opa_in2  = 32'h0000_0002; 	// Operand a from Rename  data
	lsq_opb_in2  = 32'h0000_00f0;	// Operand b from Rename  tag or data from prf
	lsq_opb_valid2  = 1;					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in2 = 13;	// The rob index of instruction 2
	lsq_ra_data2 = 1032;	//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid2 = 1;	//weather data comes form prf is valid, if not, get from cdb
	
	//we need rob age for store to commit
	rob_commit_idx1 = 40;
	rob_commit_idx2 = 13;
	
	//we need to know weather the instruction commited is a mispredict
	thread1_mispredict = 0;
	thread2_mispredict = 0;

	#1
	correct = (instr_store_to_mem1 ==1016 && instr_store_to_mem_valid1 == 1 && mem_store_idx == 32'h0000_00f1 && rob1_excuted==1 && rob2_excuted==0 && !t1_is_full && !t2_is_full);
	assert(correct) $display("@@@passed2");
		else #1 exit_on_error;

	@(negedge clock);

	reset = 0;
	id_wr_mem_in1 = 0;
	id_wr_mem_in2 = 1;		//stq
	is_thread1 = 1;
	lsq_opa_in1 = 32'h0000_0001; 	// Operand a from Rename  data
	lsq_opb_in1 = 32'h0000_00f0;    	// Operand a from Rename  tag or data from prf
	lsq_opb_valid1 = 1; 					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in1 = 12;					// The rob index of instruction 1
	lsq_ra_data1 = 1016;					//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid1 = 1;				//weather data comes form prf is valid, if not, get from cdb
	lsq_opa_in2  = 32'h0000_0002; 	// Operand a from Rename  data
	lsq_opb_in2  = 32'h0000_00f0;	// Operand b from Rename  tag or data from prf
	lsq_opb_valid2  = 1;					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in2 = 13;	// The rob index of instruction 2
	lsq_ra_data2 = 1032;	//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid2 = 1;	//weather data comes form prf is valid, if not, get from cdb
	
	//we need rob age for store to commit
	rob_commit_idx1 = 40;
	rob_commit_idx2 = 18;
	
	//we need to know weather the instruction commited is a mispredict
	thread1_mispredict = 0;
	thread2_mispredict = 0;

	#1
	correct = (instr_store_to_mem1 ==1032 && instr_store_to_mem_valid1 == 1 && mem_store_idx == 32'h0000_00f2 && rob1_excuted==0 && rob2_excuted==1 && !t1_is_full && !t2_is_full);
	assert(correct) $display("@@@passed3");
		else #1 exit_on_error;

	@(negedge clock);

	reset = 0;
	id_wr_mem_in1 = 0;
	id_wr_mem_in2 = 0;		//stq
	is_thread1 = 1;
	lsq_opa_in1 = 32'h0000_0001; 	// Operand a from Rename  data
	lsq_opb_in1 = 32'h0000_00f0;    	// Operand a from Rename  tag or data from prf
	lsq_opb_valid1 = 1; 					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in1 = 12;					// The rob index of instruction 1
	lsq_ra_data1 = 1016;					//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid1 = 1;				//weather data comes form prf is valid, if not, get from cdb
	lsq_opa_in2  = 32'h0000_0002; 	// Operand a from Rename  data
	lsq_opb_in2  = 32'h0000_00f0;	// Operand b from Rename  tag or data from prf
	lsq_opb_valid2  = 1;					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in2 = 13;	// The rob index of instruction 2
	lsq_ra_data2 = 1032;	//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid2 = 1;	//weather data comes form prf is valid, if not, get from cdb
	
	//we need rob age for store to commit
	rob_commit_idx1 = 40;
	rob_commit_idx2 = 13;
	
	//we need to know weather the instruction commited is a mispredict
	thread1_mispredict = 0;
	thread2_mispredict = 0;

	#1
	correct = (instr_store_to_mem1 == 0 && instr_store_to_mem_valid1 == 0 && mem_store_idx == 0 && rob1_excuted==0 && rob2_excuted==0 && !t1_is_full && !t2_is_full);
	assert(correct) $display("@@@passed4");
		else #1 exit_on_error;

	@(negedge clock);

	reset = 0;
	id_wr_mem_in1 = 0;
	id_wr_mem_in2 = 0;		//stq
	is_thread1 = 1;
	lsq_opa_in1 = 32'h0000_0001; 	// Operand a from Rename  data
	lsq_opb_in1 = 32'h0000_00f0;    	// Operand a from Rename  tag or data from prf
	lsq_opb_valid1 = 1; 					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in1 = 12;					// The rob index of instruction 1
	lsq_ra_data1 = 1016;					//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid1 = 1;				//weather data comes form prf is valid, if not, get from cdb
	lsq_opa_in2  = 32'h0000_0002; 	// Operand a from Rename  data
	lsq_opb_in2  = 32'h0000_00f0;	// Operand b from Rename  tag or data from prf
	lsq_opb_valid2  = 1;					// Is Opb a tag or immediate data (READ THIS COMMENT) 
	lsq_rob_idx_in2 = 13;	// The rob index of instruction 2
	lsq_ra_data2 = 1032;	//comes from prf according to idx request, 0 if load
	lsq_ra_data_valid2 = 1;	//weather data comes form prf is valid, if not, get from cdb
	
	//we need rob age for store to commit
	rob_commit_idx1 = 40;
	rob_commit_idx2 = 13;
	
	//we need to know weather the instruction commited is a mispredict
	thread1_mispredict = 0;
	thread2_mispredict = 0;

	#1
	correct = (instr_store_to_mem1 ==0 && instr_store_to_mem_valid1 == 0 && mem_store_idx ==0 && rob1_excuted==0 && rob2_excuted==0 && !t1_is_full && !t2_is_full);
	assert(correct) $display("@@@passed5");
		else #1 exit_on_error;
	$finish;
	end

endmodule




























