module lq_one_entry(
	input	clock,
	input	reset,

	input							lq_clean,	
	input							lq_free_enable,
	input							lq_request2mem,
	
	//inst1
	input							lq_mem_in1,
	input	[5:0]					lq_inst_op_type1,
	input	[63:0]					lq_pc_in1,
	input	[31:0]					lq_inst1_in,
	input	[63:0] 					lq_opa_in1,      	// Operand a from Rename  data
	input	[63:0] 					lq_opb_in1,      	// Operand a from Rename  tag or data from prf
	input         					lq_opb_valid1,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]	lq_rob_idx_in1,  	// The rob index of instruction 1
	input	[$clog2(`PRF_SIZE)-1:0]	lq_dest_idx1,

    //for instruction2
   	input							lq_mem_in2,    		//ldq
   	input	[5:0]					lq_inst_op_type2,
	input	[63:0]					lq_pc_in2,
	input	[31:0]					lq_inst2_in,
	input	[63:0] 					lq_opa_in2,      	// Operand a from Rename  data
	input	[63:0] 					lq_opb_in2,     	// Operand b from Rename  tag or data from prf
	input         					lq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]	lq_rob_idx_in2,  	// The rob index of instruction 2
	input	[$clog2(`PRF_SIZE)-1:0] lq_dest_idx2,
	
	input	[63:0]					lq_cdb1_in,     		// CDB bus from functional units 
	input	[$clog2(`PRF_SIZE)-1:0]	lq_cdb1_tag,    		// CDB tag bus from functional units 
	input							lq_cdb1_valid,  		// The data on the CDB is valid 
	input	[63:0]					lq_cdb2_in,     		// CDB bus from functional units 
	input	[$clog2(`PRF_SIZE)-1:0]	lq_cdb2_tag,    		// CDB tag bus from functional units 
	input							lq_cdb2_valid,  		// The data on the CDB is valid
	
	//from mem
	input	[63:0]					lq_mem_data_in,	//when no forwarding possible, load from memory
	input  							lq_mem_data_in_valid,

	output logic							lq_is_available,
	output logic							lq_is_ready,
	output logic	[5:0]					lq_inst_op_type,
	output logic	[63:0]					lq_pc,
	output logic	[31:0]					lq_inst,
	output logic	[63:0]					lq_opa,
	output logic	[63:0]					lq_opb,
	output logic							lq_addr_valid,
	output logic	[$clog2(`ROB_SIZE):0]	lq_rob_idx,
	output logic	[$clog2(`PRF_SIZE)-1:0] lq_dest_tag,
	output logic	[63:0]					lq_mem_value,
	output logic							lq_mem_value_valid,
	output logic							lq_requested
);

	logic							inuse, next_inuse;
	logic	[63:0]					next_lq_pc;
	logic	[31:0]					next_lq_inst;
	logic	[63:0]					next_lq_opa;
	logic	[63:0]					next_lq_opb;
	logic							next_lq_addr_valid;
	logic	[$clog2(`ROB_SIZE):0]	next_lq_rob_idx;
	logic	[$clog2(`PRF_SIZE)-1:0]	next_lq_dest_tag;
	logic	[63:0]					next_lq_mem_value;
	logic							next_lq_mem_value_valid;
	logic							next_lq_requested;
	logic	[5:0]					next_lq_inst_op_type;
	
	assign lq_is_available 	= lq_is_ready ? lq_free_enable : ~inuse;
	assign lq_is_ready		= inuse && lq_addr_valid && lq_requested && lq_mem_value_valid;//(inuse || next_inuse) && (lq_addr_valid || next_lq_addr_valid) && (lq_mem_value_valid || next_lq_mem_value_valid);
	
	always_ff @(posedge clock) begin
		if(reset) begin
			inuse			<= #1 0;
			lq_inst_op_type	<= #1 0;
			lq_pc			<= #1 0;
			lq_inst			<= #1 0;
			lq_opa 			<= #1 0;
			lq_opb 			<= #1 0;
			lq_addr_valid 	<= #1 0;
			lq_rob_idx 		<= #1 0;
			lq_dest_tag 	<= #1 0;
			lq_mem_value	<= #1 0;
			lq_mem_value_valid	<= #1 0;
			lq_requested	<= #1 0;
		end
		else begin
			inuse			<= #1 next_inuse;
			lq_inst_op_type	<= #1 next_lq_inst_op_type;
			lq_pc			<= #1 next_lq_pc;
			lq_inst			<= #1 next_lq_inst;
			lq_opa 			<= #1 next_lq_opa;
			lq_opb	 		<= #1 next_lq_opb;
			lq_addr_valid 	<= #1 next_lq_addr_valid;
			lq_rob_idx 		<= #1 next_lq_rob_idx;
			lq_dest_tag 	<= #1 next_lq_dest_tag;
			lq_mem_value	<= #1 next_lq_mem_value;
			lq_mem_value_valid	<= #1 next_lq_mem_value_valid;
			lq_requested	<= #1 next_lq_requested;
		end
	end

	always_comb begin
		next_inuse			= inuse;
		next_lq_pc			= lq_pc;
		next_lq_inst		= lq_inst;
		next_lq_opa			= lq_opa;
		next_lq_opb			= lq_opb;
		next_lq_addr_valid	= lq_addr_valid;
		next_lq_rob_idx 	= lq_rob_idx;
		next_lq_dest_tag	= lq_dest_tag;
		next_lq_mem_value	= lq_mem_value;
		next_lq_mem_value_valid	= lq_mem_value_valid;
		next_lq_requested	= lq_requested;
		next_lq_inst_op_type= lq_inst_op_type;
		if (lq_clean) begin
			next_inuse			= 0;
			next_lq_addr_valid	= 0;
			next_lq_mem_value_valid = 0;
			next_lq_requested	= 0;
			next_lq_pc			= 0;
			next_lq_inst		= 0;
			next_lq_opa			= 0;
			next_lq_opb			= 0;
			next_lq_rob_idx 	= 0;
			next_lq_dest_tag	= 0;
			next_lq_mem_value	= 0;
			next_lq_inst_op_type= 0;
		end
		else if (lq_free_enable && lq_mem_in1) begin
			next_inuse			= 1;
			next_lq_inst_op_type= lq_inst_op_type1;
			next_lq_pc			= lq_pc_in1;
			next_lq_inst		= lq_inst1_in;
			next_lq_opa			= lq_opa_in1;
			next_lq_opb			= lq_opb_in1;
			next_lq_addr_valid	= lq_opb_valid1;
			next_lq_rob_idx		= lq_rob_idx_in1;
			next_lq_dest_tag	= lq_dest_idx1;
			if (lq_inst_op_type1 == `LDA_INST) begin
				next_lq_mem_value_valid = lq_opb_valid1;
				next_lq_requested	= 1;
				next_lq_mem_value	= lq_opa_in1+lq_opb_in1;
			end
			else begin
				next_lq_mem_value_valid = 0;
				next_lq_requested	= 0;
				next_lq_mem_value	= 0;
			end
		end
		else if (lq_free_enable && lq_mem_in2) begin
			next_inuse			= 1;
			next_lq_inst_op_type= lq_inst_op_type2;
			next_lq_pc			= lq_pc_in2;
			next_lq_inst		= lq_inst2_in;
			next_lq_opa			= lq_opa_in2;
			next_lq_opb			= lq_opb_in2;
			next_lq_addr_valid	= lq_opb_valid2;
			next_lq_rob_idx		= lq_rob_idx_in2;
			next_lq_dest_tag	= lq_dest_idx2;
			if (lq_inst_op_type2 == `LDA_INST) begin
				next_lq_mem_value_valid = lq_opb_valid2;
				next_lq_requested	= 1;
				next_lq_mem_value	= lq_opa_in2+lq_opb_in2;
			end
			else begin
				next_lq_mem_value_valid = 0;
				next_lq_requested	= 0;
				next_lq_mem_value	= 0;
			end
		end
		else if (lq_free_enable) begin
			next_inuse			= 0;
			next_lq_addr_valid	= 0;
			next_lq_mem_value_valid = 0;
			next_lq_requested	= 0;
			next_lq_pc			= 0;
			next_lq_inst		= 0;
			next_lq_opa			= 0;
			next_lq_opb			= 0;
			next_lq_rob_idx 	= 0;
			next_lq_dest_tag	= 0;
			next_lq_mem_value	= 0;
			next_lq_inst_op_type= 0;
		end
		else if (lq_mem_in1) begin
			next_inuse			= 1;
			next_lq_inst_op_type= lq_inst_op_type1;
			next_lq_pc			= lq_pc_in1;
			next_lq_inst		= lq_inst1_in;
			next_lq_opa			= lq_opa_in1;
			next_lq_opb			= lq_opb_in1;
			next_lq_addr_valid	= lq_opb_valid1;
			next_lq_rob_idx		= lq_rob_idx_in1;
			next_lq_dest_tag	= lq_dest_idx1;
			if (lq_inst_op_type1 == `LDA_INST) begin
				next_lq_mem_value_valid = lq_opb_valid1;
				next_lq_requested	= 1;
				next_lq_mem_value	= lq_opa_in1+lq_opb_in1;
			end
			else begin
				next_lq_mem_value_valid = 0;
				next_lq_requested	= 0;
				next_lq_mem_value	= 0;
			end
		end
		else if (lq_mem_in2) begin
			next_inuse			= 1;
			next_lq_inst_op_type= lq_inst_op_type2;
			next_lq_pc			= lq_pc_in2;
			next_lq_inst		= lq_inst2_in;
			next_lq_opa			= lq_opa_in2;
			next_lq_opb			= lq_opb_in2;
			next_lq_addr_valid	= lq_opb_valid2;
			next_lq_rob_idx		= lq_rob_idx_in2;
			next_lq_dest_tag	= lq_dest_idx2;
			if (lq_inst_op_type2 == `LDA_INST) begin
				next_lq_mem_value_valid = lq_opb_valid2;
				next_lq_requested	= 1;
				next_lq_mem_value	= lq_opa_in2+lq_opb_in2;
			end
			else begin
				next_lq_mem_value_valid = 0;
				next_lq_requested	= 0;
				next_lq_mem_value	= 0;
			end
		end
		else begin
			if (~lq_addr_valid && (lq_opb[$clog2(`PRF_SIZE)-1:0] == lq_cdb1_tag) && inuse && lq_cdb1_valid) begin
				next_lq_opb			= lq_cdb1_in;
				next_lq_addr_valid	= 1;
				if (lq_inst_op_type == `LDA_INST) begin
					next_lq_mem_value_valid = 1;
					next_lq_mem_value	= lq_opa+next_lq_opb;
				end
			end
			if (~lq_addr_valid && (lq_opb[$clog2(`PRF_SIZE)-1:0] == lq_cdb2_tag) && inuse && lq_cdb2_valid) begin
				next_lq_opb			= lq_cdb2_in;
				next_lq_addr_valid	= 1;
				if (lq_inst_op_type == `LDA_INST) begin
					next_lq_mem_value_valid = 1;
					next_lq_mem_value	= lq_opa+next_lq_opb;
				end
			end
			if (~lq_mem_value_valid && lq_mem_data_in_valid && inuse) begin
				next_lq_mem_value = lq_mem_data_in;
				next_lq_mem_value_valid = 1;
			end
			if (lq_request2mem) begin
				next_lq_requested = 1;
			end
		end
	end
endmodule
