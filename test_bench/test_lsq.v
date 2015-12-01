module test_lsq();
	logic	clock;
	logic	reset;
	//sequential???? comb????
	logic	id_rd_mem_in1;
	logic	id_rd_mem_in2;    //ldq
	logic	id_wr_mem_in1;
	logic	id_wr_mem_in2;		//stq
	
	logic  [63:0]								lsq_cdb1_in;     		// CDB bus from functional units 
	logic  [$clog2(`PRF_SIZE)-1:0]  			lsq_cdb1_tag;    		// CDB tag bus from functional units 
	logic										lsq_cdb1_valid;  		// The data on the CDB is valid 
	logic  [63:0]								lsq_cdb2_in;     		// CDB bus from functional units 
	logic  [$clog2(`PRF_SIZE)-1:0]  			lsq_cdb2_tag;    		// CDB tag bus from functional units 
	logic										lsq_cdb2_valid;  		// The data on the CDB is valid 
	
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

	logic	[4:0]								dest_reg_idx1; //`none_reg if store
	logic	[4:0]								dest_reg_idx2;

	logic	[63:0]						instr_load_from_mem1;	//when no forwarding possible; load from memory
	logic								instr_load_mem_in_valid1;
	logic	[4:0]						mem_load_tag_in;
	
	//we need rob age for store to commit
	logic	[$clog2(`ROB_SIZE)-1:0]		rob_commit_idx1;
	logic	[$clog2(`ROB_SIZE)-1:0]		rob_commit_idx2;

	//we need to know weather the instruction commited is a mispredict
	logic	thread1_mispredict;
	logic	thread2_mispredict;

	//load instruction is  when corresponding dest_tag get value from store_in
	// to prf -- prf_tag		
	//store instructions are  when instruction retires and store write to memory
	// to prf -- L1 cache (prf48)

	 logic [$clog2(`PRF_SIZE)-1:0]	lsq_CDB_dest_tag1;
	 logic [63:0]						lsq_CDB_result_out1;
	 logic 							lsq_CDB_result_is_valid1;

	 logic [$clog2(`PRF_SIZE)-1:0]	lsq_CDB_dest_tag2;
	 logic [63:0]						lsq_CDB_result_out2;
	 logic 							lsq_CDB_result_is_valid2;

	//sedn idx to prf to get value
	logic [$clog2(`PRF_SIZE)-1:0]	lsq_opb_idx1;
	logic							lsq_opb_request1;
	logic [$clog2(`PRF_SIZE)-1:0]	lsq_opb_idx2;
	logic							lsq_opb_request2;
	logic [$clog2(`PRF_SIZE)-1:0]	lsq_ra_dest_idx1;
	logic							lsq_ra_request1;	//request = 0 if load
	logic [$clog2(`PRF_SIZE)-1:0]	lsq_ra_dest_idx2;
	logic							lsq_ra_request2;


//if sq has storeA @pc=0x100 if loadA @pc=0x120 will load from the sq
//but later a storeA @pc=0x110 happens; we need to violate the forwarded data from rob
//or the lsq is filled inorder; which means when store A @pc=0x110 mast happen before loadA @pc=0x120?
//but lq/sq is independent...

	logic	[63:0]						instr_store_to_mem1;
	logic								instr_store_to_mem_valid1;
	logic	[4:0]						mem_store_idx;
	logic	[15:0]						load_from_mem_idx;//fifo
	logic								request_from_mem;
	logic	[4:0]						mem_load_tag_out;

	logic								rob1_excuted;
	logic								rob2_excuted;
	
	lsq lsq(
			clock,
			reset,
			//sequential???? comb????
			id_rd_mem_in1,
			id_rd_mem_in2,    //ldq
			id_wr_mem_in1,
			id_wr_mem_in2,		//stq
	
			lsq_cdb1_in,     		// CDB bus from functional units 
			lsq_cdb1_tag,    		// CDB tag bus from functional units 
			lsq_cdb1_valid,  		// The data on the CDB is valid 
			lsq_cdb2_in,     		// CDB bus from functional units 
			lsq_cdb2_tag,    		// CDB tag bus from functional units 
			lsq_cdb2_valid,  		// The data on the CDB is valid 
			//for instruction1
			lsq_opa_in1,      	// Operand a from Rename  data
			lsq_opb_in1,      	// Operand a from Rename  tag or data from prf
			lsq_opb_valid1,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
			lsq_rob_idx_in1,  	// The rob index of instruction 1
			lsq_ra_data1,	//comes from prf according to idx request, 0 if load
			lsq_ra_data_valid1, //weather data comes form prf is valid, if not, get from cdb
			//for instruction2
			lsq_opa_in2,      	// Operand a from Rename  data
			lsq_opb_in2,     	// Operand b from Rename  tag or data from prf
			lsq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
			lsq_rob_idx_in2,  	// The rob index of instruction 2
			lsq_ra_data2, 	//comes from prf according to idx request, 0 if load
			lsq_ra_data_valid2,	//weather data comes form prf is valid, if not, get from cdb

			dest_reg_idx1, //`none_reg if store
			dest_reg_idx2,

			instr_load_from_mem1,	//when no forwarding possible, load from memory
			instr_load_mem_in_valid1,
			mem_load_tag_in,
	
			//we need rob age for store to commit
			rob_commit_idx1,
			rob_commit_idx2,
			//we need to know weather the instruction commited is a mispredict
			thread1_mispredict,
			thread2_mispredict,

			//load instruction is output when corresponding dest_tag get value from store_in
			//output to prf -- prf_tag		
			//store instructions are output when instruction retires and store write to memory
			//output to prf -- L1 cache (prf48)

			lsq_CDB_dest_tag1,
			lsq_CDB_result_out1,
			lsq_CDB_result_is_valid1,

			lsq_CDB_dest_tag2,
			lsq_CDB_result_out2,
			lsq_CDB_result_is_valid2,

			//sedn idx to prf to get value
			lsq_opb_idx1,
			lsq_opb_request1,
			lsq_opb_idx2,
			lsq_opb_request2,
			lsq_ra_dest_idx1,
			lsq_ra_request1,	//request = 0 if load
			lsq_ra_dest_idx2,
			lsq_ra_request2,


			//if sq has storeA @pc=0x100 if loadA @pc=0x120 will load from the sq
			//but later a storeA @pc=0x110 happens, we need to violate the forwarded data from rob
			//or the lsq is filled inorder, which means when store A @pc=0x110 mast happen before loadA @pc=0x120?
			//but lq/sq is independent...
	
			instr_store_to_mem1,
			instr_store_to_mem_valid1,
			mem_store_idx,
			load_from_mem_idx,//fifo
			request_from_mem,
			mem_load_tag_out,

			rob1_excuted,
			rob2_excuted
	
			//when new store came in and find a instr following him in program order has been excuted, the LSQ must report a violation
			//Here we only forward the independent loads!!!!!
	);
	
	initial begin
	
		$monitor("@@@time:%d, clock:%b,\
				lsq_CDB_dest_tag1:%h,\
				lsq_CDB_result_out1:%h,\
				lsq_CDB_result_is_valid1:%h,\n\
				lsq_CDB_dest_tag2:%h,\
				lsq_CDB_result_out2:%h,\
				lsq_CDB_result_is_valid2:%h,\n\
				lsq_opb_idx1:%h,\n\
				lsq_opb_request1:%h,\
				lsq_opb_idx2:%h,\
				lsq_opb_request2:%h,\
				lsq_ra_dest_idx1:%h,\n\
				lsq_ra_request1:%h,\
				lsq_ra_dest_idx2:%h,\
				lsq_ra_request2:%h,\
				instr_store_to_mem1:%h,\n\
				instr_store_to_mem_valid1:%h,\
				mem_store_idx:%h,\
				load_from_mem_idx:%h,\
				request_from_mem:%h,\
				mem_load_tag_out:%h,\
				rob1_excuted:%h,\
				rob2_excuted:%h",
				$time,clock,
				lsq_CDB_dest_tag1,
				lsq_CDB_result_out1,
				lsq_CDB_result_is_valid1,
				lsq_CDB_dest_tag2,
				lsq_CDB_result_out2,
				lsq_CDB_result_is_valid2,
				lsq_opb_idx1,
				lsq_opb_request1,
				lsq_opb_idx2,
				lsq_opb_request2,
				lsq_ra_dest_idx1,
				lsq_ra_request1,	//request = 0 if load
				lsq_ra_dest_idx2,
				lsq_ra_request2,
				instr_store_to_mem1,
				instr_store_to_mem_valid1,
				mem_store_idx,
				load_from_mem_idx,//fifo
				request_from_mem,
				mem_load_tag_out,
				rob1_excuted,
				rob2_excuted);
		clock = 0;
		reset = 0;
		#5
		@(negedge clock);
		reset = 1;
		#5
		@(negedge clock);
		$finish;
	end
	
	always begin
		#5
		clock = ~clock;
	end
	
	
endmodule
