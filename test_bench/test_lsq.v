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
	logic	[63:0]								lsq_rega_in1;
	logic										lsq_rega_valid1;
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
	logic	[63:0]								lsq_rega_in2;
	logic										lsq_rega_valid2;
	logic	[63:0] 								lsq_opa_in2;      	// Operand a from Rename  data
	logic	[63:0] 								lsq_opb_in2;     	// Operand b from Rename  tag or data from prf
	logic         								lsq_opb_valid2;   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic	[$clog2(`ROB_SIZE):0]				lsq_rob_idx_in2;  	// The rob index of instruction 2
	logic	[$clog2(`PRF_SIZE)-1:0]				dest_reg_idx2;
	//from mem
	logic	[63:0]								mem_data_in;		//when no forwarding possible; load from memory
	logic	[4:0]								mem_response_in;
	logic	[4:0]								mem_tag_in;
	logic										cache_hit;
	
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
		lsq_rega_in1,
		lsq_rega_valid1,
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
		lsq_rega_in2,
		lsq_rega_valid2,
		lsq_opa_in2,      	// Operand a from Rename  data
		lsq_opb_in2,     	// Operand b from Rename  tag or data from prf
	    lsq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		lsq_rob_idx_in2,  	// The rob index of instruction 2
		dest_reg_idx2,
	//from mem
		mem_data_in,		//when no forwarding possible, load from memory
		mem_response_in,
		mem_tag_in,
		cache_hit,
	
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
		reset = 1;
		#5
		@(negedge clock);
		reset 				= 0;
		
		$display("@@@ stop reset!");
		$display("@@@ the first instruction in! opb_invalid");
		$display("@@@ load! waiting for CDB calculate the address!");
		lsq_cdb1_in			= 0;
		lsq_cdb1_tag		= 0;
		lsq_cdb1_valid		= 0;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDQ_INST;
		inst1_pc			= 64'h0000_0000_0000_0008;
		inst1_in			= 64'h1234_4534_8971_1536;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0010;
		lsq_opb_in1			= 64'h0000_0000_0000_0004;
		lsq_opb_valid1		= 0;
		lsq_rob_idx_in1		= 4'b0001;
		dest_reg_idx1		= 6'd17;
   		inst2_valid			= 0;
   		inst2_op_type		= 0;
		inst2_pc			= 0;
		inst2_in			= 0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 0;
		lsq_opb_in2			= 0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 0;
		mem_data_in			= 64'h0;			
		mem_response_in		= 4'b0;
		mem_tag_in			= 4'b0;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		@(negedge clock);
		$display("@@@ the 2nd instruction in! opb invalid");
		$display("@@@ load! CDB send the 1st instruction result in!");
		lsq_cdb1_in			= 64'h0000_0000_0000_0100;
		lsq_cdb1_tag		= 6'h4;
		lsq_cdb1_valid		= 1;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDQ_INST;
		inst1_pc			= 64'h0000_0000_0000_0008;
		inst1_in			= 64'h1200_1435_7341_0987;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0018;
		lsq_opb_in1			= 64'h0000_0000_0000_0009;
		lsq_opb_valid1		= 0;
		lsq_rob_idx_in1		= 4'b0010;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 0;
   		inst2_op_type		= 0;
		inst2_pc			= 0;
		inst2_in			= 0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 0;
		lsq_opb_in2			= 0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 0;
		mem_data_in			= 64'h0;			
		mem_response_in		= 4'b0;
		mem_tag_in			= 4'b0;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		@(negedge clock);
		$display("@@@ the 3rd instruction in! opb invalid");
		$display("@@@ load! CDB send the 2nd instruction result in!");
		$display("@@@ memory send the 1st result in! cache doesn't miss");
		lsq_cdb1_in			= 64'h0000_0000_0000_0123;
		lsq_cdb1_tag		= 6'h9;
		lsq_cdb1_valid		= 1;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDQ_INST;
		inst1_pc			= 64'h0000_0000_0000_0008;
		inst1_in			= 64'h1200_1435_7341_0987;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0018;
		lsq_opb_in1			= 64'h0000_0000_0000_0001;
		lsq_opb_valid1		= 0;
		lsq_rob_idx_in1		= 4'b0010;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 0;
   		inst2_op_type		= 0;
		inst2_pc			= 0;
		inst2_in			= 0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 0;
		lsq_opb_in2			= 0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 0;
		mem_data_in			= 64'h5696;			
		mem_response_in		= 4'b0;
		mem_tag_in			= 4'b0000;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 1;
		
		
		@(negedge clock);
		$display("@@@ the 4th instruction in! 4th opb valid");
		$display("@@@ load! CDB send the 3rd instruction result in!");
		$display("@@@ the first load broadcast!");
		$display("@@@ memory send the 2nd response in! cache miss");
		lsq_cdb1_in			= 64'h0000_0000_0000_0193;
		lsq_cdb1_tag		= 6'h1;
		lsq_cdb1_valid		= 1;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDQ_INST;
		inst1_pc			= 64'h0000_0000_0000_1450;
		inst1_in			= 64'h1200_1000_7900_0909;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_00bc;
		lsq_opb_in1			= 64'h0000_bbbb_0000_0061;
		lsq_opb_valid1		= 1;
		lsq_rob_idx_in1		= 4'b1011;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 0;
   		inst2_op_type		= 0;
		inst2_pc			= 0;
		inst2_in			= 0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 0;
		lsq_opb_in2			= 0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 0;
		mem_data_in			= 64'h0;			
		mem_response_in		= 4'b0001;
		mem_tag_in			= 4'b0000;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		@(negedge clock);
		$display("@@@ the 5th and 6th instructions in! 5th opb is valid, 6th opb is not valid");
		$display("@@@ memory send the 2nd tag in and 3rd response in! cache miss");
		lsq_cdb1_in			= 64'h0000_0000_0000_0000;
		lsq_cdb1_tag		= 6'h0;
		lsq_cdb1_valid		= 0;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDQ_INST;
		inst1_pc			= 64'h0000_0000_0000_1450;
		inst1_in			= 64'h1200_1000_7900_0909;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_00bc;
		lsq_opb_in1			= 64'h0000_bbbb_0000_8501;
		lsq_opb_valid1		= 1;
		lsq_rob_idx_in1		= 4'b1011;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 1'b1;
   		inst2_op_type		= `LDQ_INST;
		inst2_pc			= 64'h0000_0000_0000_1050;
		inst2_in			= 64'h1210_1020_7900_0909;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 64'd12;
		lsq_opb_in2			= 64'h7;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 6'h13;
		mem_data_in			= 64'h789;			
		mem_response_in		= 4'b0010;
		mem_tag_in			= 4'b0001;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		@(negedge clock);
		$display("@@@ the 7th instructions in! opb valid");
		$display("@@@ CDB send the 6th opb in!");
		$display("@@@ memory send the 4th response in and the 3rd tag in ! ");
		$display("@@@ the 2nd result is broadcast!");
		lsq_cdb1_in			= 64'h0000_0000_0000_7777;
		lsq_cdb1_tag		= 6'h7;
		lsq_cdb1_valid		= 1;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b0;
		inst1_op_type		= 0;
		inst1_pc			= 64'h0;
		inst1_in			= 64'h0;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0;
		lsq_opb_in1			= 64'h0;
		lsq_opb_valid1		= 0;
		lsq_rob_idx_in1		= 4'b1011;
		dest_reg_idx1		= 6'd9;
		
   		inst2_valid			= 1'b1;
   		inst2_op_type		= `LDQ_INST;
		inst2_pc			= 64'h0000_0000_0000_1050;
		inst2_in			= 64'h1210_1020_7900_0909;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 64'd12;
		lsq_opb_in2			= 64'd97;
		lsq_opb_valid2		= 1;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 6'h13;
		mem_data_in			= 64'h666;			
		mem_response_in		= 4'b0111;
		mem_tag_in			= 4'b0010;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		
		
		@(negedge clock);
		$display("@@@ the 8th instructions in! opb is valid");
		$display("@@@ memory send the 4rd tag in ! 5th instruction cache miss! response = 0(dirty)");
		$display("@@@ the 3rd result is ready!");
		lsq_cdb1_in			= 64'h0;
		lsq_cdb1_tag		= 6'h0;
		lsq_cdb1_valid		= 0;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b0;
		inst1_op_type		= 0;
		inst1_pc			= 64'h0;
		inst1_in			= 64'h0;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0;
		lsq_opb_in1			= 64'h0;
		lsq_opb_valid1		= 0;
		lsq_rob_idx_in1		= 4'b0;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 1'b1;
   		inst2_op_type		= `LDQ_INST;
		inst2_pc			= 64'h0000_0000_0000_1050;
		inst2_in			= 64'h1210_1020_7900_0909;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 64'd12;
		lsq_opb_in2			= 64'd7787;
		lsq_opb_valid2		= 1;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 6'h13;
		mem_data_in			= 64'h345;			
		mem_response_in		= 4'b0000;
		mem_tag_in			= 4'b0111;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		
		@(negedge clock);
		$display("@@@ the request for the 5th instruction send in again!");
		$display("@@@ the 9th instructions in! opb is invalid");
		$display("@@@ memory send  5th response in");
		$display("@@@ the 4th result is ready!");
		lsq_cdb1_in			= 64'h0;
		lsq_cdb1_tag		= 6'h0;
		lsq_cdb1_valid		= 0;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDQ_INST;
		inst1_pc			= 64'h0000_0000_0000_1450;
		inst1_in			= 64'h1246_2954_9483_2341;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0002;
		lsq_opb_in1			= 64'hf;
		lsq_opb_valid1		= 0;
		lsq_rob_idx_in1		= 4'b0;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 1'b0;
   		inst2_op_type		= 0;
		inst2_pc			= 64'h0;
		inst2_in			= 64'h0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 64'd0;
		lsq_opb_in2			= 64'd0;
		lsq_opb_valid2		= 1;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 6'h18;
		mem_data_in			= 64'h0;			
		mem_response_in		= 4'b0101;
		mem_tag_in			= 4'b0000;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		@(negedge clock);
		$display("@@@ the 10th instructions and 11th instrution in! opbs are both invalid");
		$display("@@@ memory send 5th tag in");
		lsq_cdb1_in			= 64'h0;
		lsq_cdb1_tag		= 6'h0;
		lsq_cdb1_valid		= 0;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDQ_INST;
		inst1_pc			= 64'h0000_0000_0000_1450;
		inst1_in			= 64'h1246_2954_9483_2341;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0002;
		lsq_opb_in1			= 64'hf;
		lsq_opb_valid1		= 0;
		lsq_rob_idx_in1		= 4'b0;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 1'b1;
   		inst2_op_type		= 0;
		inst2_pc			= 64'h0000_0000_0010_0018;
		inst2_in			= 64'h0123_4567_8970_1235;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 64'd0;
		lsq_opb_in2			= 64'd0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 6'h18;
		mem_data_in			= 64'h2657_1546;			
		mem_response_in		= 4'b0000;
		mem_tag_in			= 4'b0101;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		@(negedge clock);
		$display("@@@ the 12th instructions and 13th instrution in! opbs are both invalid");
		$display("@@@ 5th instruction is broadcast!!");
		lsq_cdb1_in			= 64'h0;
		lsq_cdb1_tag		= 6'h0;
		lsq_cdb1_valid		= 0;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDQ_INST;
		inst1_pc			= 64'h0000_0000_0112_1450;
		inst1_in			= 64'h1246_2954_9909_9765;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0002;
		lsq_opb_in1			= 64'hf;
		lsq_opb_valid1		= 0;
		lsq_rob_idx_in1		= 4'b0;
		dest_reg_idx1		= 6'd17;
   		inst2_valid			= 1'b1;
   		inst2_op_type		= 0;
		inst2_pc			= 64'h0000_0000_1320_0020;
		inst2_in			= 64'h6803_4567_8970_5555;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 64'd0;
		lsq_opb_in2			= 64'd0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 6'h19;
		mem_data_in			= 64'h0;			
		mem_response_in		= 4'b0000;
		mem_tag_in			= 4'b0000;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		@(negedge clock);
		$finish;
	end
	
	always begin
		#5
		clock = ~clock;
	end
	
	
endmodule


/*$display("@@@ the first instruction in!");
		$display("@@@ load! waiting for CDB calculate the address!");
		lsq_cdb1_in			= 0;
		lsq_cdb1_tag		= 0;
		lsq_cdb1_valid		= 0;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDA_INST;
		inst1_pc			= 64'h0000_0000_0000_0008;
		inst1_in			= 64'h1234_4534_8971_1536;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0010;
		lsq_opb_in1			= 64'h0000_0000_0000_0004;
		lsq_opb_valid1		= 1;
		lsq_rob_idx_in1		= 4'b0001;
		dest_reg_idx1		= 6'd17;
   		inst2_valid			= 0;
   		inst2_op_type		= 0;
		inst2_pc			= 0;
		inst2_in			= 0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 0;
		lsq_opb_in2			= 0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 0;
		mem_data_in			= 64'h0;			
		mem_response_in		= 4'b0;
		mem_tag_in			= 4'b0;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		@(negedge clock);
		$display("@@@ stop reset!");
		$display("@@@ the 2nd instruction in!");
		$display("@@@ load! CDB send the 1st instruction result in!");
		lsq_cdb1_in			= 64'h0000_0000_0000_0100;
		lsq_cdb1_tag		= 6'h4;
		lsq_cdb1_valid		= 1;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDA_INST;
		inst1_pc			= 64'h0000_0000_0000_0008;
		inst1_in			= 64'h1200_1435_7341_0987;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0018;
		lsq_opb_in1			= 64'h0000_0000_0000_0009;
		lsq_opb_valid1		= 1;
		lsq_rob_idx_in1		= 4'b0010;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 0;
   		inst2_op_type		= 0;
		inst2_pc			= 0;
		inst2_in			= 0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 0;
		lsq_opb_in2			= 0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 0;
		mem_data_in			= 64'h0;			
		mem_response_in		= 4'b0;
		mem_tag_in			= 4'b0;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		@(negedge clock);
		$display("@@@ stop reset!");
		$display("@@@ the 3rd instruction in!");
		$display("@@@ load! CDB send the second instruction result in!");
		$display("@@@ memory send the 1st result in! cache doesn't miss");
		lsq_cdb1_in			= 64'h0000_0000_0000_0123;
		lsq_cdb1_tag		= 6'h9;
		lsq_cdb1_valid		= 1;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDA_INST;
		inst1_pc			= 64'h0000_0000_0000_0008;
		inst1_in			= 64'h1200_1435_7341_0987;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_0018;
		lsq_opb_in1			= 64'h0000_0000_0000_0001;
		lsq_opb_valid1		= 1;
		lsq_rob_idx_in1		= 4'b0010;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 0;
   		inst2_op_type		= 0;
		inst2_pc			= 0;
		inst2_in			= 0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 0;
		lsq_opb_in2			= 0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 0;
		mem_data_in			= 64'h5696;			
		mem_response_in		= 4'b0;
		mem_tag_in			= 4'b0000;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 1;
		
		
		@(negedge clock);
		$display("@@@ stop reset!");
		$display("@@@ the 4th instruction in!");
		$display("@@@ load! CDB send the third instruction result in!");
		$display("@@@ memory send the 2st response in! cache miss");
		lsq_cdb1_in			= 64'h0000_0000_0000_0193;
		lsq_cdb1_tag		= 6'h1;
		lsq_cdb1_valid		= 1;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDA_INST;
		inst1_pc			= 64'h0000_0000_0000_1450;
		inst1_in			= 64'h1200_1000_7900_0909;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_00bc;
		lsq_opb_in1			= 64'h0000_bbbb_0000_686c;
		lsq_opb_valid1		= 1;
		lsq_rob_idx_in1		= 4'b1011;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 0;
   		inst2_op_type		= 0;
		inst2_pc			= 0;
		inst2_in			= 0;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 0;
		lsq_opb_in2			= 0;
		lsq_opb_valid2		= 0;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 0;
		mem_data_in			= 64'h0;			
		mem_response_in		= 4'b0001;
		mem_tag_in			= 4'b0000;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		
		@(negedge clock);
		$display("@@@ stop reset!");
		$display("@@@ the 5th and 6th instructions in!");
		$display("@@@ memory send the 2st tag in and 3rd response in! cache miss");
		lsq_cdb1_in			= 64'h0000_0000_0000_0000;
		lsq_cdb1_tag		= 6'h0;
		lsq_cdb1_valid		= 0;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b1;
		inst1_op_type		= `LDA_INST;
		inst1_pc			= 64'h0000_0000_0000_1450;
		inst1_in			= 64'h1200_1000_7900_0909;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_00bc;
		lsq_opb_in1			= 64'h0000_bbbb_0000_686c;
		lsq_opb_valid1		= 1;
		lsq_rob_idx_in1		= 4'b1011;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 1'b1;
   		inst2_op_type		= `LDA_INST;
		inst2_pc			= 64'h0000_0000_0000_1050;
		inst2_in			= 64'h1210_1020_7900_0909;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 64'd12;
		lsq_opb_in2			= 64'd7;
		lsq_opb_valid2		= 1;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 6'h13;
		mem_data_in			= 64'h789;			
		mem_response_in		= 4'b0010;
		mem_tag_in			= 4'b0001;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0;
		@(negedge clock);
		$display("@@@ stop reset!");
		$display("@@@ the 7th instructions in!");
		$display("@@@ memory send the 3rd tag in ! cache hit");
		lsq_cdb1_in			= 64'h0000_0000_0000_7777;
		lsq_cdb1_tag		= 6'h7;
		lsq_cdb1_valid		= 1;
		lsq_cdb2_in			= 0;
		lsq_cdb2_tag		= 0;
		lsq_cdb2_valid		= 0;
		inst1_valid			= 1'b0;
		inst1_op_type		= `LDA_INST;
		inst1_pc			= 64'h0000_0000_0000_0000;
		inst1_in			= 64'h0000_0000_0000_0000;
		lsq_rega_in1		= 64'h0;
		lsq_rega_valid1		= 0;
		lsq_opa_in1			= 64'h0000_0000_0000_00bc;
		lsq_opb_in1			= 64'h0000_bbbb_0000_686c;
		lsq_opb_valid1		= 1;
		lsq_rob_idx_in1		= 4'b1011;
		dest_reg_idx1		= 6'd9;
   		inst2_valid			= 1'b1;
   		inst2_op_type		= `LDA_INST;
		inst2_pc			= 64'h0000_0000_0000_1050;
		inst2_in			= 64'h1210_1020_7900_0909;
		lsq_rega_in2		= 0;
		lsq_rega_valid2		= 0;
		lsq_opa_in2			= 64'd12;
		lsq_opb_in2			= 64'd7;
		lsq_opb_valid2		= 1;
		lsq_rob_idx_in2		= 0;
		dest_reg_idx2		= 6'h13;
		mem_data_in			= 64'h666;			
		mem_response_in		= 4'b0000;
		mem_tag_in			= 4'b0010;
		t1_head				= 0;
		t2_head				= 0;
		thread1_mispredict	= 0;
		thread2_mispredict	= 0;
		cache_hit			= 0; */
