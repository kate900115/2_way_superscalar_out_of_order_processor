module test_lsq();
	logic	clock;
	logic	reset;
	
	logic  [63:0]								lsq_cdb1_in;     		// CDB bus from functional units 
	logic  [$clog2(`PRF_SIZE)-1:0]  			lsq_cdb1_tag;    		// CDB tag bus from functional units 
	logic										lsq_cdb1_valid;  		// The data on the CDB is valid 
	logic  [63:0]								lsq_cdb2_in;     		// CDB bus from functional units 
	logic  [$clog2(`PRF_SIZE)-1:0]  			lsq_cdb2_tag;    		// CDB tag bus from functional units 
	logic										lsq_cdb2_valid;  		// The data on the CDB is valid 
	
    //for instruction1
   	logic										inst1_valid;
	logic	[5:0]								inst1_op_type;
	logic	[63:0]								inst1_pc;
	logic	[31:0]								inst1_in;
	logic	[63:0]								inst1_rega;
	logic	[63:0] 								lsq_opa_in1;      	// Operand a from Rename  data
	logic	[63:0] 								lsq_opb_in1;      	// Operand a from Rename  tag or data from prf
	logic         								lsq_opb_valid1;   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic	[$clog2(`ROB_SIZE):0]				lsq_rob_idx_in1;  	// The rob index of instruction 1
	logic	[$clog2(`PRF_SIZE)-1:0]				dest_reg_idx1;		//`none_reg if store


    //for instruction2
   	logic										inst2_valid;
   	logic	[5:0]								inst2_op_type;
	logic	[63:0]								inst2_pc;
	logic	[31:0]								inst2_in;
	logic	[63:0]								inst2_rega;
	logic	[63:0] 								lsq_opa_in2;      	// Operand a from Rename  data
	logic	[63:0] 								lsq_opb_in2;     	// Operand b from Rename  tag or data from prf
	logic         								lsq_opb_valid2;   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic	[$clog2(`ROB_SIZE):0]				lsq_rob_idx_in2;  	// The rob index of instruction 2
	logic	[$clog2(`PRF_SIZE)-1:0]				dest_reg_idx2;
	//from mem
	logic	[63:0]								mem_data_in;		//when no forwarding possible; load from memory
	logic	[4:0]								mem_response_in;
	logic	[4:0]								mem_tag_in;
	
	//retired store idx
	logic	[$clog2(`ROB_SIZE)-1:0]				t1_head;
	logic	[$clog2(`ROB_SIZE)-1:0]				t2_head;

	//we need to know weather the instruction commited is a mispredict
	logic	thread1_mispredict;
	logic	thread2_mispredict;
	//output
	//cdb
	logic [$clog2(`PRF_SIZE)-1:0]		cdb_dest_tag1;
	logic [63:0]						cdb_result_out1;
	logic 								cdb_result_is_valid1;
	logic [$clog2(`ROB_SIZE):0]			cdb_rob_idx1;
	logic [$clog2(`PRF_SIZE)-1:0]		cdb_dest_tag2;
	logic [63:0]						cdb_result_out2;
	logic 								cdb_result_is_valid2;
	logic [$clog2(`ROB_SIZE):0]			cdb_rob_idx2;
	
	//mem
	logic	[63:0]						mem_data_out;
	logic	[63:0]						mem_address_out;
	BUS_COMMAND							lsq2Dcache_command;
	logic								lsq_is_full;
	
	lsq lsq(
		clock,
		reset,
	
	 	lsq_cdb1_in,     		// CDB bus from functional units 
	 	lsq_cdb1_tag,    		// CDB tag bus from functional units 
		lsq_cdb1_valid,  		// The data on the CDB is valid 
	  	lsq_cdb2_in,     		// CDB bus from functional units 
	  	lsq_cdb2_tag,    		// CDB tag bus from functional units 
		lsq_cdb2_valid,  		// The data on the CDB is valid 
	
    //for instruction1
   		inst1_valid,
		inst1_op_type,
		inst1_pc,
		inst1_in,
		inst1_rega,
		lsq_opa_in1,      	// Operand a from Rename  data
		lsq_opb_in1,      	// Operand a from Rename  tag or data from prf
	    lsq_opb_valid1,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		lsq_rob_idx_in1,  	// The rob index of instruction 1
		dest_reg_idx1,		//`none_reg if store


    //for instruction2
   		inst2_valid,
   		inst2_op_type,
		inst2_pc,
		inst2_in,
		inst2_rega,
		lsq_opa_in2,      	// Operand a from Rename  data
		lsq_opb_in2,     	// Operand b from Rename  tag or data from prf
	    lsq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		lsq_rob_idx_in2,  	// The rob index of instruction 2
		dest_reg_idx2,
	//from mem
		mem_data_in,		//when no forwarding possible, load from memory
		mem_response_in,
		mem_tag_in,
	
	//retired store idx
		t1_head,
		t2_head,

	//we need to know weather the instruction commited is a mispredict
		thread1_mispredict,
		thread2_mispredict,
	//output
	//cdb
		cdb_dest_tag1,
		cdb_result_out1,
		cdb_result_is_valid1,
		cdb_rob_idx1,
		cdb_dest_tag2,
		cdb_result_out2,
		cdb_result_is_valid2,
		cdb_rob_idx2,
	//mem
		mem_data_out,
		mem_address_out,
		lsq2Dcache_command,

		lsq_is_full
	);
	
	initial begin
	
		$monitor("@@@time:%d, clock:%b,\
				cdb_dest_tag1:%h\n\
				cdb_result_out1:%h\n\
				cdb_result_is_valid1:%h\n\
				cdb_rob_idx1:%h\n\
				cdb_dest_tag2:%h\n\
				cdb_result_out2:%h\n\
				cdb_result_is_valid2:%h\n\
				cdb_rob_idx2:%h\n\
				mem_data_out:%h\n\
				mem_address_out:%h\n\
				lsq2Dcache_command:%h\n\
				lsq_is_full:%h",
				$time,clock,
				cdb_dest_tag1,
				cdb_result_out1,
				cdb_result_is_valid1,
				cdb_rob_idx1,
				cdb_dest_tag2,
				cdb_result_out2,
				cdb_result_is_valid2,
				cdb_rob_idx2,
				mem_data_out,
				mem_address_out,
				lsq2Dcache_command,
				lsq_is_full);
		clock = 0;
		reset = 0;
		#5
		@(negedge clock);
		reset = 1;
		lsq_cdb1_in			=     		
		lsq_cdb1_tag		=    		
		lsq_cdb1_valid		=  		
		lsq_cdb2_in			=     		
		lsq_cdb2_tag		=    		
		lsq_cdb2_valid		=
		inst1_valid			=
		inst1_op_type		=
		inst1_pc			=
		inst1_in			=
		inst1_rega			=
		lsq_opa_in1			=      	
		lsq_opb_in1			=      	
		lsq_opb_valid1		=   	
		lsq_rob_idx_in1		=  	
		dest_reg_idx1		=	
   		inst2_valid			=
   		inst2_op_type		=
		inst2_pc			=
		inst2_in			=
		inst2_rega			=
		lsq_opa_in2			=      	
		lsq_opb_in2			=     
		lsq_opb_valid2		=   	
		lsq_rob_idx_in2		=  	
		dest_reg_idx2		=
		mem_data_in			=			
		mem_response_in		=
		mem_tag_in			=
		t1_head				=
		t2_head				=
		thread1_mispredict	=
		thread2_mispredict	=
		@(negedge clock);
		$finish;
	end
	
	always begin
		#5
		clock = ~clock;
	end
	
	
endmodule
