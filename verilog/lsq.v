
//////////////////////////////////
//								//
//		  LSQ					//
//								//
//////////////////////////////////


module lsq(
	input	clock,
	input	reset,
	
	input  [63:0]								lsq_cdb1_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  			lsq_cdb1_tag,    		// CDB tag bus from functional units 
	input										lsq_cdb1_valid,  		// The data on the CDB is valid 
	input  [63:0]								lsq_cdb2_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  			lsq_cdb2_tag,    		// CDB tag bus from functional units 
	input										lsq_cdb2_valid,  		// The data on the CDB is valid 
	
    //for instruction1
   	input										inst1_valid,
	input	[5:0]								inst1_op_type,
	input	[63:0]								inst1_pc,
	input	[31:0]								inst1_in,
	input	[63:0]								lsq_rega_in1,
	input										lsq_rega_valid1,
	input	[63:0] 								lsq_opa_in1,      	// Operand a from Rename  data
	input	[63:0] 								lsq_opb_in1,      	// Operand a from Rename  tag or data from prf
	input         								lsq_opb_valid1,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]				lsq_rob_idx_in1,  	// The rob index of instruction 1
	input	[$clog2(`PRF_SIZE)-1:0]				dest_reg_idx1,		//`none_reg if store


    //for instruction2
   	input										inst2_valid,
   	input	[5:0]								inst2_op_type,
	input	[63:0]								inst2_pc,
	input	[31:0]								inst2_in,
	input	[63:0]								lsq_rega_in2,
	input										lsq_rega_valid2,
	input	[63:0] 								lsq_opa_in2,      	// Operand a from Rename  data
	input	[63:0] 								lsq_opb_in2,     	// Operand b from Rename  tag or data from prf
	input         								lsq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]				lsq_rob_idx_in2,  	// The rob index of instruction 2
	input	[$clog2(`PRF_SIZE)-1:0]				dest_reg_idx2,
	//from mem
	input	[63:0]								mem_data_in,		//when no forwarding possible, load from memory
	input	[4:0]								mem_response_in,
	input	[4:0]								mem_tag_in,
	input										cache_hit,
	
	//retired store idx
	input	[$clog2(`ROB_SIZE)-1:0]				t1_head,
	input	[$clog2(`ROB_SIZE)-1:0]				t2_head,

	//we need to know weather the instruction commited is a mispredict
	input	thread1_mispredict,
	input	thread2_mispredict,
	//output
	//cdb
	output logic [$clog2(`PRF_SIZE)-1:0]		cdb_dest_tag1,
	output logic [63:0]							cdb_result_out1,
	output logic 								cdb_result_is_valid1,
	output logic [$clog2(`ROB_SIZE):0]			cdb_rob_idx1,
	output logic [$clog2(`PRF_SIZE)-1:0]		cdb_dest_tag2,
	output logic [63:0]							cdb_result_out2,
	output logic 								cdb_result_is_valid2,
	output logic [$clog2(`ROB_SIZE):0]			cdb_rob_idx2,
	
	//mem
	output logic	[63:0]						mem_data_out,
	output logic	[63:0]						mem_address_out,
	output BUS_COMMAND							lsq2Dcache_command,

	output logic								lsq_is_full
);
	logic	[63:0]			inst1_opb;
	logic					inst1_opb_valid;
	logic	[63:0]			inst2_opb;
	logic					inst2_opb_valid;
	logic	[63:0]			inst1_rega;
	logic					inst1_rega_valid;
	logic	[63:0]			inst2_rega;
	logic					inst2_rega_valid;
	//LQ
	//the relative ages of two instructions can be determined by examing the physical locations they occupied in LSQ
	//for example, instruction at slot 5 is older than instruction at slot 8
	//lq_reg stores address
	logic	[`LQ_SIZE-1:0]			lq_mem_in1, lq_mem_in2;
	logic	[`LQ_SIZE-1:0]			lq1_clean, lq2_clean;
	logic	[`LQ_SIZE-1:0]			lq1_free_en, lq2_free_en;
	logic	[`LQ_SIZE-1:0]			lq1_is_ready, lq2_is_ready;
	logic 	[$clog2(`LQ_SIZE)-1:0]	lq_head1, n_lq_head1, lq_head2, n_lq_head2;
	logic	[$clog2(`LQ_SIZE)-1:0]	lq_tail1, n_lq_tail1, lq_tail2, n_lq_tail2;
	logic	[`LQ_SIZE-1:0]			lq1_mem_data_in_valid, lq2_mem_data_in_valid;
	logic	[`LQ_SIZE-1:0]			lq1_is_available, lq2_is_available;
	logic	[`LQ_SIZE-1:0]			lq1_addr_valid, lq2_addr_valid;
	logic	[`LQ_SIZE-1:0][63:0]	lq1_opa, lq1_opb, lq2_opa, lq2_opb;
	logic	[`LQ_SIZE-1:0][$clog2(`ROB_SIZE):0]		lq1_rob_idx, lq2_rob_idx;
	logic	[`LQ_SIZE-1:0][63:0]					lq1_pc, lq2_pc;
	logic	[`LQ_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]	lq1_dest_tag, lq2_dest_tag;
	logic	[`LQ_SIZE-1:0][63:0]	lq1_mem_value, lq2_mem_value;
	logic	[`LQ_SIZE-1:0]			lq1_mem_value_valid, lq2_mem_value_valid;
	
	//SQ
	logic	[`SQ_SIZE-1:0]			sq_mem_in1;
	logic	[`SQ_SIZE-1:0]			sq_mem_in2;
	logic	[`SQ_SIZE-1:0]			sq1_clean, sq2_clean;
	logic	[`LQ_SIZE-1:0]			sq1_free_en, sq2_free_en;
	logic	[`SQ_SIZE-1:0]			sq1_is_ready, sq2_is_ready;
	logic 	[$clog2(`SQ_SIZE)-1:0]	sq_head1, n_sq_head1, sq_head2, n_sq_head2;
	logic	[$clog2(`SQ_SIZE)-1:0]	sq_tail1, n_sq_tail1, sq_tail2, n_sq_tail2;
	logic	[`SQ_SIZE-1:0]			sq1_is_available, sq2_is_available;
	logic	[`SQ_SIZE-1:0][63:0]	sq1_opa, sq1_opb, sq2_opa, sq2_opb;
	logic	[`SQ_SIZE-1:0][$clog2(`ROB_SIZE):0]		sq1_rob_idx, sq2_rob_idx;
	logic	[`SQ_SIZE-1:0][63:0]					sq1_pc, sq2_pc;
	logic	[`SQ_SIZE-1:0][63:0]					sq1_store_data, sq2_store_data;
	logic	[`SQ_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]	sq1_dest_tag, sq2_dest_tag;
	
	MEM_INST_TYPE	inst1_type;
	MEM_INST_TYPE	inst2_type;
	logic	inst1_is_lq1, inst1_is_lq2, inst1_is_sq1, inst1_is_sq2;
	logic	inst2_is_lq1, inst2_is_lq2, inst2_is_sq1, inst2_is_sq2;
	logic	out1_is_lq1, out1_is_lq2, out1_is_sq1, out1_is_sq2;
	logic	out2_is_lq1, out2_is_lq2, out2_is_sq1, out2_is_sq2;
	
	//tag table
	logic	[$clog2(`SQ_SIZE)+1:0]			current_mem_inst;//{thread,load/store,queue_idx}
	logic	[15:0][$clog2(`SQ_SIZE)+1:0]	tag_table;
	logic	[15:0]							tag_valid;
	
	//lda
	logic	[$clog2(`PRF_SIZE)-1:0]	lda1_dest_tag;
	logic	[63:0]					lda1_result;
	logic							lda1_valid;
	logic	[$clog2(`ROB_SIZE):0]	lda1_rob_idx;
	logic	[$clog2(`PRF_SIZE)-1:0]	lda2_dest_tag;
	logic	[63:0]					lda2_result;
	logic							lda2_valid;
	logic	[$clog2(`ROB_SIZE):0]	lda2_rob_idx;
	
	assign inst1_type = (inst1_op_type == `LDQ_L_INST)	? IS_LDQ_L_INST	: 
						(inst1_op_type == `LDQ_INST)	? IS_LDQ_INST	: 
						(inst1_op_type == `STQ_C_INST)	? IS_STQ_C_INST	: 
						(inst1_op_type == `STQ_INST)	? IS_STQ_INST	: 
						(inst1_op_type == `LDA_INST) 	? IS_LDA_INST	: 
						NO_INST;
	
	assign inst2_type = (inst2_op_type == `LDQ_L_INST)	? IS_LDQ_L_INST	: 
						(inst2_op_type == `LDQ_INST)	? IS_LDQ_INST	: 
						(inst2_op_type == `STQ_C_INST)	? IS_STQ_C_INST	: 
						(inst2_op_type == `STQ_INST)	? IS_STQ_INST	: 
						(inst2_op_type == `LDA_INST) 	? IS_LDA_INST	: 
						NO_INST;
	
	lq_one_entry lq_t1[`LQ_SIZE-1:0](
		.clock(clock),
		.reset(reset),
		
		.lq_clean(lq1_clean),
		.lq_free_enable(lq1_free_en),
		
		//for instruction1
		//.lq_mem_in1(),
		.lq_pc_in1(inst2_pc),
		.lq_inst1_in(inst1_in),
		.lq_opa_in1(lsq_opa_in1),			// Operand a from Rename  data
		.lq_opb_in1(inst1_opb),			// Operand a from Rename  tag or data from prf
		.lq_opb_valid1(inst1_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.lq_rob_idx_in1(lsq_rob_idx_in1),  	// The rob index of instruction 1
		.lq_dest_idx1(dest_reg_idx1),
		.lq_mem_in1(lq_mem_in1),

		//for instruction2
	    //.lq_mem_in2(),
		.lq_pc_in2(inst2_pc),
		.lq_inst2_in(inst2_in),
		.lq_opa_in2(lsq_opa_in2),      		// Operand a from Rename  data
		.lq_opb_in2(inst2_opb),     		// Operand b from Rename  tag or data from prf
		.lq_opb_valid2(inst2_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.lq_rob_idx_in2(lsq_rob_idx_in2),  	// The rob index of instruction 2
		.lq_dest_idx2(dest_reg_idx2),
		.lq_mem_in2(lq_mem_in1),    		//ldq
		//cdb
		.lq_cdb1_in(lsq_cdb1_in),     		// CDB bus from functional units 
		.lq_cdb1_tag(lsq_cdb1_tag),    		// CDB tag bus from functional units 
		.lq_cdb1_valid(lsq_cdb1_valid),  	// The data on the CDB is valid 
		.lq_cdb2_in(lsq_cdb2_in),     		// CDB bus from functional units 
		.lq_cdb2_tag(lsq_cdb2_tag),    		// CDB tag bus from functional units 
		.lq_cdb2_valid(lsq_cdb2_valid),  	// The data on the CDB is valid
		//mem
		.lq_mem_data_in(mem_data_in),
		.lq_mem_data_in_valid(lq1_mem_data_in_valid),
		//output
		.lq_is_available(lq1_is_available),
		.lq_is_ready(lq1_is_ready),
		.lq_pc(lq1_pc),
		//.lq_inst(),
		.lq_opa(lq1_opa),
		.lq_opb(lq1_opb),
		.lq_addr_valid(lq1_addr_valid),
		.lq_rob_idx(lq1_rob_idx),
		.lq_dest_tag(lq1_dest_tag),
		.lq_mem_value(lq1_mem_value),
		.lq_mem_value_valid(lq1_mem_value_valid)
	);
	
	lq_one_entry lq_t2[`LQ_SIZE-1:0](
		.clock(clock),
		.reset(reset),
		
		.lq_clean(lq2_clean),
		.lq_free_enable(lq2_free_en),
		
		//for instruction1
		.lq_pc_in1(inst1_pc),
		.lq_inst1_in(inst1_in),
		.lq_opa_in1(lsq_opa_in1),			// Operand a from Rename  data
		.lq_opb_in1(inst1_opb),			// Operand a from Rename  tag or data from prf
		.lq_opb_valid1(inst1_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.lq_rob_idx_in1(lsq_rob_idx_in1),  	// The rob index of instruction 1
		.lq_dest_idx1(dest_reg_idx1),
		.lq_mem_in1(lq_mem_in2),

		//for instruction2
		.lq_pc_in2(inst2_pc),
		.lq_inst2_in(inst2_in),
		.lq_opa_in2(lsq_opa_in2),      		// Operand a from Rename  data
		.lq_opb_in2(inst2_opb),     		// Operand b from Rename  tag or data from prf
		.lq_opb_valid2(inst2_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.lq_rob_idx_in2(lsq_rob_idx_in2),  	// The rob index of instruction 2
		.lq_dest_idx2(dest_reg_idx2),
		.lq_mem_in2(lq_mem_in2),    		//ldq
		//cdb
		.lq_cdb1_in(lsq_cdb1_in),     		// CDB bus from functional units 
		.lq_cdb1_tag(lsq_cdb1_tag),    		// CDB tag bus from functional units 
		.lq_cdb1_valid(lsq_cdb1_valid),  	// The data on the CDB is valid 
		.lq_cdb2_in(lsq_cdb2_in),     		// CDB bus from functional units 
		.lq_cdb2_tag(lsq_cdb2_tag),    		// CDB tag bus from functional units 
		.lq_cdb2_valid(lsq_cdb2_valid),  	// The data on the CDB is valid
		//mem
		.lq_mem_data_in(mem_data_in),
		.lq_mem_data_in_valid(lq2_mem_data_in_valid),
		//output
		.lq_is_available(lq2_is_available),
		.lq_is_ready(lq2_is_ready),
		.lq_pc(lq2_pc),
		//.lq_inst(),
		.lq_opa(lq2_opa),
		.lq_opb(lq2_opb),
		.lq_addr_valid(lq2_addr_valid),
		.lq_rob_idx(lq2_rob_idx),
		.lq_dest_tag(lq2_dest_tag),
		.lq_mem_value(lq2_mem_value),
		.lq_mem_value_valid(lq2_mem_value_valid)
	);
	
	sq_one_entry sq_t1[`SQ_SIZE-1:0](
		.clock(clock),
		.reset(reset),
		
		.sq_clean(sq1_clean),
		.sq_free_enable(sq1_free_en),
	
		//for instruction1
		.sq_mem_in1(sq_mem_in1),
		.sq_pc_in1(inst1_pc),
		.sq_inst1_in(inst1_in),
		.sq_inst1_rega(inst1_rega),
		.sq_inst1_rega_valid(inst1_rega_valid),
		.sq_opa_in1(lsq_opa_in1),      	// Operand a from Rename  data
		.sq_opb_in1(inst1_opb),      	// Operand a from Rename  tag or data from prf
		.sq_opb_valid1(inst1_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.sq_rob_idx_in1(lsq_rob_idx_in1),  	// The rob index of instruction 1
		.sq_dest_idx1(dest_reg_idx1),

		//for instruction2
		.sq_mem_in2(sq_mem_in1),
		.sq_pc_in2(inst2_pc),
		.sq_inst2_in(inst2_in),
		.sq_inst2_rega(inst2_rega),
		.sq_inst2_rega_valid(inst2_rega_valid),
		.sq_opa_in2(lsq_opa_in2),      	// Operand a from Rename  data
		.sq_opb_in2(inst2_opb),     	// Operand b from Rename  tag or data from prf
		.sq_opb_valid2(inst2_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.sq_rob_idx_in2(lsq_rob_idx_in2),  	// The rob index of instruction 2
		.sq_dest_idx2(dest_reg_idx2),
	
		.sq_cdb1_in(lsq_cdb1_in),     		// CDB bus from functional units 
		.sq_cdb1_tag(lsq_cdb1_tag),    		// CDB tag bus from functional units 
		.sq_cdb1_valid(lsq_cdb1_valid),  		// The data on the CDB is valid 
		.sq_cdb2_in(lsq_cdb2_in),     		// CDB bus from functional units 
		.sq_cdb2_tag(lsq_cdb2_tag),    		// CDB tag bus from functional units 
		.sq_cdb2_valid(lsq_cdb2_valid),  		// The data on the CDB is valid

		.sq_is_available(sq1_is_available),
		.sq_is_ready(sq1_is_ready),
		.sq_pc(sq1_pc),
		//.sq_inst(),
		.sq_opa(sq1_opa),
		.sq_opb(sq1_opb),
		.sq_rob_idx(sq1_rob_idx),
		.sq_store_data(sq1_store_data),
		.sq_dest_tag(sq1_dest_tag)
	);

	sq_one_entry sq_t2[`SQ_SIZE-1:0](
		.clock(clock),
		.reset(reset),
		
		.sq_clean(sq2_clean),
		.sq_free_enable(sq2_free_en),
	
		//for instruction1
		.sq_mem_in1(sq_mem_in2),
		.sq_pc_in1(inst1_pc),
		.sq_inst1_in(inst1_in),
		.sq_inst1_rega(inst1_rega),
		.sq_inst1_rega_valid(inst1_rega_valid),
		.sq_opa_in1(lsq_opa_in1),      	// Operand a from Rename  data
		.sq_opb_in1(inst1_opb),      	// Operand a from Rename  tag or data from prf
		.sq_opb_valid1(inst1_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.sq_rob_idx_in1(lsq_rob_idx_in1),  	// The rob index of instruction 1
		.sq_dest_idx1(dest_reg_idx1),

		//for instruction2
		.sq_mem_in2(sq_mem_in2),
		.sq_pc_in2(inst2_pc),
		.sq_inst2_in(inst2_in),
		.sq_inst2_rega(inst2_rega),
		.sq_inst2_rega_valid(inst2_rega_valid),
		.sq_opa_in2(lsq_opa_in2),      	// Operand a from Rename  data
		.sq_opb_in2(inst2_opb),     	// Operand b from Rename  tag or data from prf
		.sq_opb_valid2(inst2_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.sq_rob_idx_in2(lsq_rob_idx_in2),  	// The rob index of instruction 2
		.sq_dest_idx2(dest_reg_idx2),
	
		.sq_cdb1_in(lsq_cdb1_in),     		// CDB bus from functional units 
		.sq_cdb1_tag(lsq_cdb1_tag),    		// CDB tag bus from functional units 
		.sq_cdb1_valid(lsq_cdb1_valid),  		// The data on the CDB is valid 
		.sq_cdb2_in(lsq_cdb2_in),     		// CDB bus from functional units 
		.sq_cdb2_tag(lsq_cdb2_tag),    		// CDB tag bus from functional units 
		.sq_cdb2_valid(lsq_cdb2_valid),  		// The data on the CDB is valid

		.sq_is_available(sq2_is_available),
		.sq_is_ready(sq2_is_ready),
		.sq_pc(sq2_pc),
		//.sq_inst(),
		.sq_opa(sq2_opa),
		.sq_opb(sq2_opb),
		.sq_rob_idx(sq2_rob_idx),
		.sq_store_data(sq2_store_data),
		.sq_dest_tag(sq2_dest_tag)
	);
	
	//read inst
	always_comb begin
		inst1_is_lq1 = 0;
		inst1_is_lq2 = 0;
		inst1_is_sq1 = 0;
		inst1_is_sq2 = 0;
		inst2_is_lq1 = 0;
		inst2_is_lq2 = 0;
		inst2_is_sq1 = 0;
		inst2_is_sq2 = 0;
		n_lq_tail1	= lq_tail1;
		n_lq_tail2	= lq_tail2;
		n_sq_tail1	= sq_tail1;
		n_sq_tail2	= sq_tail2;
		lq1_clean	= 0;
		lq2_clean	= 0;
		sq1_clean	= 0;
		sq2_clean	= 0;
		lq_mem_in1	= 0;
		lq_mem_in2	= 0;
		sq_mem_in1	= 0;
		sq_mem_in2	= 0;
		//mispredict
		if (thread1_mispredict || thread2_mispredict) begin
			if (thread1_mispredict) begin
				n_sq_tail1 = sq_head1;
				n_lq_tail1 = lq_head1;
				for (int i = 0; i < `SQ_SIZE; i++) begin
					lq1_clean[i] = 1;
					sq1_clean[i] = 1;
				end
			end
			if (thread2_mispredict) begin
				n_sq_tail2 = sq_head2;
				n_lq_tail2 = lq_head2;
				for (int i = 0; i < `SQ_SIZE; i++) begin
					lq2_clean[i] = 1;
					sq2_clean[i] = 1;
				end
			end
			for (int i = 0; i < `SQ_SIZE; i++) begin
				lq_mem_in1[i] = 0;
				lq_mem_in2[i] = 0;
				sq_mem_in1[i] = 0;
				sq_mem_in2[i] = 0;
			end
		end
		else begin//
			if (lsq_rob_idx_in1[$clog2(`ROB_SIZE)] == 0) begin
				if (inst1_type == IS_LDQ_INST || inst1_type == IS_LDQ_L_INST)
					inst1_is_lq1 = 1;
				else if (inst1_type == IS_STQ_INST || inst1_type == IS_STQ_C_INST)
					inst1_is_sq1 = 1;
			end
			else begin
				if (inst1_type == IS_LDQ_INST || inst1_type == IS_LDQ_L_INST)
					inst1_is_lq2 = 1;
				else if (inst1_type == IS_STQ_INST || inst1_type == IS_STQ_C_INST)
					inst1_is_sq2 = 1;
			end
		
			if (lsq_rob_idx_in2[$clog2(`ROB_SIZE)] == 0) begin
				if (inst2_type == IS_LDQ_INST || inst2_type == IS_LDQ_L_INST)
					inst2_is_lq1 = 1;
				else if (inst2_type == IS_STQ_INST || inst2_type == IS_STQ_C_INST)
					inst2_is_sq1 = 1;
				end
			else begin
				if (inst2_type == IS_LDQ_INST || inst2_type == IS_LDQ_L_INST)
					inst2_is_lq2 = 1;
				else if (inst2_type == IS_STQ_INST || inst2_type == IS_STQ_C_INST)
					inst2_is_sq2 = 1;
			end
			n_lq_tail1 = lq_tail1 + inst1_is_lq1 + inst2_is_lq1;
			n_lq_tail2 = lq_tail2 + inst1_is_lq2 + inst2_is_lq2;
			n_sq_tail1 = sq_tail1 + inst1_is_sq1 + inst2_is_sq1;
			n_sq_tail2 = sq_tail2 + inst1_is_sq2 + inst2_is_sq2;
			if (inst1_is_lq1)
				lq_mem_in1[lq_tail1] = 1;
			if (inst2_is_lq1)
				lq_mem_in1[lq_tail1+1] = 1;
			if (inst1_is_lq2)
				lq_mem_in2[lq_tail2] = 1;
			if (inst2_is_lq2)
				lq_mem_in2[lq_tail2+1] = 1;
			if (inst1_is_sq1)
				sq_mem_in1[sq_tail1] = 1;
			if (inst2_is_sq1)
				sq_mem_in1[sq_tail1+1] = 1;
			if (inst1_is_sq2)
				sq_mem_in2[sq_tail2] = 1;
			if (inst2_is_sq2)
				lq_mem_in2[lq_tail2+1] = 1;
		end
	end
	
	always_comb begin
		lsq_is_full = 0;
		if ((lq_tail1 + 4'b1 == lq_head1) || (lq_tail1 == lq_head1 && !lq1_is_available[lq_tail1]))
			lsq_is_full = 1;
		if ((lq_tail2 + 4'b1 == lq_head2) || (lq_tail2 == lq_head2 && !lq2_is_available[lq_tail2]))
			lsq_is_full = 1;
		if ((sq_tail1 + 4'b1 == sq_head1) || (sq_tail1 == sq_head1 && !sq1_is_available[sq_tail1]))
			lsq_is_full = 1;
		if ((sq_tail2 + 4'b1 == sq_head2) || (sq_tail2 == sq_head2 && !sq2_is_available[sq_tail2]))
			lsq_is_full = 1;
	end
	
	//lda
	always_ff @ (posedge clock) begin
		if (lda1_valid) begin
			lda1_valid		<= `SD 0;
		end
		if (lda2_valid) begin
			lda2_valid		<= `SD 0;
		end
		if (inst1_type == IS_LDA_INST) begin
			lda1_dest_tag	<= `SD dest_reg_idx1;
			lda1_result		<= `SD lsq_opa_in1 + lsq_opb_in1;
			lda1_valid		<= `SD 1;
			lda1_rob_idx	<= `SD lsq_rob_idx_in1;
		end
		if (inst2_type == IS_LDA_INST) begin
			lda2_dest_tag	<= `SD dest_reg_idx2;
			lda2_result		<= `SD lsq_opa_in2 + lsq_opb_in2;
			lda2_valid		<= `SD 1;
			lda2_rob_idx	<= `SD lsq_rob_idx_in2;
		end
	end
	
	//cdb output
	always_comb begin
		out1_is_lq1 = 0;
		out1_is_lq2 = 0;
		out1_is_sq1 = 0;
		out1_is_sq2 = 0;
		out2_is_lq1 = 0;
		out2_is_lq2 = 0;
		out2_is_sq1 = 0;
		out2_is_sq2 = 0;
		cdb_rob_idx1	= 0;
		cdb_rob_idx2	= 0;
		cdb_result_out1	= 0;
		cdb_result_out2	= 0;
		cdb_result_is_valid1	= 0;
		cdb_result_is_valid2	= 0;
		cdb_dest_tag1	= 0;
		cdb_dest_tag2	= 0;
		lq1_free_en		= 0;
		lq2_free_en		= 0;
		sq1_free_en		= 0;
		sq2_free_en		= 0;
		if (lda1_valid) begin
			cdb_dest_tag1			= lda1_dest_tag;
			cdb_result_out1			= lda1_result;
			cdb_result_is_valid1	= 1;
			cdb_rob_idx1			= lda1_rob_idx;
		end
		else if (lq1_is_ready[lq_head1]) begin
			cdb_dest_tag1			= lq1_dest_tag[lq_head1];
			cdb_result_out1			= lq1_mem_value;
			cdb_result_is_valid1	= 1;
			cdb_rob_idx1			= lq1_rob_idx;
			out1_is_lq1				= 1;
			lq1_free_en[lq_head1]	= 1;
		end
		else if (lq2_is_ready[lq_head2]) begin
			cdb_dest_tag1			= lq2_dest_tag[lq_head2];
			cdb_result_out1			= lq2_mem_value;
			cdb_result_is_valid1	= 1;
			cdb_rob_idx1			= lq2_rob_idx;
			out1_is_lq2				= 1;
			lq2_free_en[lq_head2]	= 1;
		end
		else if (sq1_is_ready[sq_head1]) begin
			cdb_dest_tag1			= sq1_dest_tag[sq_head1];
			cdb_result_out1			= sq1_opa[sq_head1] + sq1_opb[sq_head1];
			cdb_result_is_valid1	= 1;
			cdb_rob_idx1			= sq1_rob_idx;
			out1_is_sq1				= 1;
			sq1_free_en[sq_head1]	= 1;
		end
		else if (sq2_is_ready[sq_head2]) begin
			cdb_dest_tag1			= sq2_dest_tag[sq_head2];
			cdb_result_out1			= sq2_opa[sq_head2] + sq2_opb[sq_head2];
			cdb_result_is_valid1	= 1;
			cdb_rob_idx1			= sq2_rob_idx;
			out1_is_sq2				= 1;
			sq2_free_en[sq_head2]	= 1;
		end
		//
		if (lda2_valid) begin
			cdb_dest_tag2			= lda2_dest_tag;
			cdb_result_out2			= lda2_result;
			cdb_result_is_valid2	= 1;
			cdb_rob_idx2			= lda2_rob_idx;
		end
		else if (lq1_is_ready[lq_head1+out1_is_lq1]) begin
			cdb_dest_tag2			= lq1_dest_tag[lq_head1+out1_is_lq1];
			cdb_result_out2			= lq1_mem_value;
			cdb_result_is_valid2	= 1;
			cdb_rob_idx2			= lq1_rob_idx;
			out2_is_lq1				= 1;
			lq1_free_en[lq_head1+out1_is_lq1]	= 1;
		end
		else if (lq2_is_ready[lq_head2+out1_is_lq2]) begin
			cdb_dest_tag2			= lq2_dest_tag[lq_head2+out1_is_lq2];
			cdb_result_out2			= lq2_mem_value;
			cdb_result_is_valid2	= 1;
			cdb_rob_idx2			= lq2_rob_idx;
			out2_is_lq2				= 1;
			lq2_free_en[lq_head2+out1_is_lq2]	= 1;
		end
		else if (sq1_is_ready[sq_head1+out1_is_sq1]) begin
			cdb_dest_tag2			= sq1_dest_tag[sq_head1+out1_is_sq1];
			cdb_result_out2			= sq1_opa[sq_head1+out1_is_sq1] + sq1_opb[sq_head1+out1_is_sq1];
			cdb_result_is_valid2	= 1;
			cdb_rob_idx2			= sq1_rob_idx;
			out2_is_sq1				= 1;
			sq1_free_en[sq_head1+out1_is_sq1]	= 1;
		end
		else if (sq2_is_ready[sq_head2+out1_is_sq2]) begin
			cdb_dest_tag2			= sq2_dest_tag[sq_head2+out1_is_sq2];
			cdb_result_out2			= sq2_opa[sq_head2+out1_is_sq2] + sq2_opb[sq_head2+out1_is_sq2];
			cdb_result_is_valid2	= 1;
			cdb_rob_idx2			= sq2_rob_idx;
			out2_is_sq2				= 1;
			sq2_free_en[sq_head2+out1_is_sq2]	= 1;
		end
		n_lq_head1 = lq_head1+out1_is_lq1+out2_is_lq1;
		n_lq_head2 = lq_head2+out1_is_lq2+out2_is_lq2;
		n_sq_head1 = sq_head1+out1_is_sq1+out2_is_sq1;
		n_sq_head2 = sq_head2+out1_is_sq2+out2_is_sq2;
	end
	
	//memory wr/rd
	always_comb begin
		mem_data_out 		= 0;
		mem_address_out		= 0;
		current_mem_inst	= 0;
		lsq2Dcache_command	= BUS_NONE;
		if ((mem_response_in || cache_hit)) begin
			if (lq1_addr_valid[lq_head1] && ~lq1_is_ready[lq_head1] && (lq1_pc[lq_head1] < sq1_pc[sq_head1] || sq1_is_available[sq_head1])) begin
				current_mem_inst	= {1'b0,1'b0,lq_head1};
				mem_address_out		= lq1_opa[lq_head1] + lq1_opb[lq_head1];
				lsq2Dcache_command	= BUS_LOAD;
			end
			else if (lq2_addr_valid[lq_head2] && ~lq2_is_ready[lq_head2] && (lq2_pc[lq_head2] < sq2_pc[sq_head2] || sq2_is_available[sq_head2]) && mem_response_in) begin
				current_mem_inst	= {1'b1,1'b0,lq_head2};
				mem_address_out		= lq2_opa[lq_head2] + lq2_opb[lq_head2];
				lsq2Dcache_command	= BUS_LOAD;
			end
			else if (sq1_is_ready[sq_head1] && ({1'b0,t1_head} == sq1_rob_idx || {1'b0,t1_head} == sq1_rob_idx)) begin
				current_mem_inst	= {1'b0,1'b1,sq_head1};
				mem_data_out 		= sq1_store_data;
				mem_address_out		= sq1_opa[sq_head1] + sq1_opb[sq_head1];
				lsq2Dcache_command	= BUS_STORE;
			end
			else if (sq1_is_ready[sq_head2] && ({1'b0,t2_head} == sq2_rob_idx || {1'b0,t2_head} == sq2_rob_idx)) begin
				current_mem_inst	= {1'b1,1'b1,sq_head2};
				mem_data_out 		= sq2_store_data;
				mem_address_out		= sq2_opa[sq_head1] + sq2_opb[sq_head1];
				lsq2Dcache_command	= BUS_STORE;
			end
		end
	end
	
	//cdb
	always_comb begin
		inst1_opb			= lsq_opb_in1;
		inst1_opb_valid		= lsq_opb_valid1;
		inst1_rega			= lsq_rega_in1;
		inst1_rega_valid	= lsq_rega_valid1;
		inst2_opb			= lsq_opb_in2;
		inst2_opb_valid		= lsq_opb_valid2;
		inst2_rega			= lsq_rega_in2;
		inst2_rega_valid	= lsq_rega_valid2;
		if ((lsq_cdb1_tag == lsq_opb_in1[$clog2(`PRF_SIZE)-1:0]) && !lsq_opb_valid1 && lsq_cdb1_valid)
		begin
			inst1_opb		= lsq_cdb1_in;
			inst1_opb_valid	= 1'b1;
		end
		else if ((lsq_cdb2_tag == lsq_opb_in1[$clog2(`PRF_SIZE)-1:0]) && !lsq_opb_valid1 && lsq_cdb2_valid)
		begin
			inst1_opb		= lsq_cdb2_in;
			inst1_opb_valid	= 1'b1;
		end
		if ((lsq_cdb1_tag == lsq_opb_in2[$clog2(`PRF_SIZE)-1:0]) && !lsq_opb_valid2 && lsq_cdb1_valid)
		begin
			inst2_opb		= lsq_cdb1_in;
			inst2_opb_valid	= 1'b1;
		end
		else if ((lsq_cdb2_tag == lsq_opb_in2[$clog2(`PRF_SIZE)-1:0]) && !lsq_opb_valid2 && lsq_cdb2_valid)
		begin
			inst2_opb		= lsq_cdb2_in;
			inst2_opb_valid	= 1'b1;
		end
		if ((lsq_cdb1_tag == lsq_rega_in1[$clog2(`PRF_SIZE)-1:0]) && !lsq_rega_valid1 && lsq_cdb1_valid)
		begin
			inst1_rega			= lsq_cdb1_in;
			inst1_rega_valid	= 1'b1;
		end
		else if ((lsq_cdb2_tag == lsq_rega_in1[$clog2(`PRF_SIZE)-1:0]) && !lsq_rega_valid1 && lsq_cdb2_valid)
		begin
			inst1_rega			= lsq_cdb2_in;
			inst1_rega_valid	= 1'b1;
		end
		if ((lsq_cdb1_tag == lsq_rega_in2[$clog2(`PRF_SIZE)-1:0]) && !lsq_rega_valid2 && lsq_cdb1_valid)
		begin
			inst2_rega			= lsq_cdb1_in;
			inst2_rega_valid	= 1'b1;
		end
		else if ((lsq_cdb2_tag == lsq_rega_in2[$clog2(`PRF_SIZE)-1:0]) && !lsq_rega_valid2 && lsq_cdb2_valid)
		begin
			inst2_rega			= lsq_cdb2_in;
			inst2_rega_valid	= 1'b1;
		end
	end
	
	//tag table
	always_comb begin
		lq1_mem_data_in_valid	= 0;
		lq2_mem_data_in_valid	= 0;
		if (cache_hit) begin
			if (~current_mem_inst[$clog2(`LQ_SIZE)+1] && ~current_mem_inst[$clog2(`LQ_SIZE)])
				lq1_mem_data_in_valid[current_mem_inst[$clog2(`SQ_SIZE)-1:0]] = 1;
			else if (current_mem_inst[$clog2(`LQ_SIZE)+1] && ~current_mem_inst[$clog2(`LQ_SIZE)])
				lq2_mem_data_in_valid[current_mem_inst[$clog2(`SQ_SIZE)-1:0]] = 1;
		end
		else begin
			if (~tag_table[$clog2(`LQ_SIZE)+1] && ~tag_table[$clog2(`LQ_SIZE)])
				lq1_mem_data_in_valid[tag_table[$clog2(`SQ_SIZE)-1:0]] = 1;
			else if (tag_table[$clog2(`LQ_SIZE)+1] && ~tag_table[$clog2(`LQ_SIZE)])
				lq2_mem_data_in_valid[tag_table[$clog2(`SQ_SIZE)-1:0]] = 1;
		end
	end
	
	//tag table update
	always_ff @ (posedge clock) begin
		if (reset) begin
			tag_valid	<= #1 0;
			tag_table	<= #1 0;
		end
		else begin
			if (mem_response_in != mem_tag_in) begin
				tag_valid[mem_response_in]	<= #1 1;
				tag_table[mem_response_in]	<= #1 current_mem_inst;
			end
			tag_valid[mem_tag_in]	<= #1 0;
		end
	end
	
	//head and tail move
	always_ff @ (posedge clock) begin
		if(reset) begin
			sq_head1	<= #1 0;
			sq_tail1	<= #1 0;
			sq_head2	<= #1 0;
			sq_tail2	<= #1 0;
			lq_head1	<= #1 0;
			lq_tail1	<= #1 0;
			lq_head2	<= #1 0;
			lq_tail2	<= #1 0;
		end
		else begin
			sq_head1	<= #1 n_sq_head1;
			sq_tail1	<= #1 n_sq_tail1;
			sq_head2	<= #1 n_sq_head2;
			sq_tail2	<= #1 n_sq_tail2;
			lq_head1	<= #1 n_lq_head1;
			lq_tail1	<= #1 n_lq_tail1;
			lq_head2	<= #1 n_lq_head2;
			lq_tail2	<= #1 n_lq_tail2;
		end
	end
endmodule
