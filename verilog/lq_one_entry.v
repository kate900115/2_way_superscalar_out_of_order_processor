module lq_one_entry(
	input	clock,
	input	reset,
	
	input	[63:0] 					lq_opa_in1,      	// Operand a from Rename  data
	input	[63:0] 					lq_opb_in1,      	// Operand a from Rename  tag or data from prf
	input         					lq_opb_valid1,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]	lq_rob_idx_in1,  	// The rob index of instruction 1
	input							lq_mem_in1,
	input	[$clog2(`PRF_SIZE)-1:0]	lq_dest_idx1,
	input							lq_free,	
	input							lq_free_enable,	

    //for instruction2
	input	[63:0] 					lq_opa_in2,      	// Operand a from Rename  data
	input	[63:0] 					lq_opb_in2,     	// Operand b from Rename  tag or data from prf
	input         					lq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]	lq_rob_idx_in2,  	// The rob index of instruction 2
	input							lq_mem_in2,    //ldq
	input	[$clog2(`PRF_SIZE)-1:0] lq_dest_idx2,
	
	input  [63:0]					lq_cdb1_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  lq_cdb1_tag,    		// CDB tag bus from functional units 
	input							lq_cdb1_valid,  		// The data on the CDB is valid 
	input  [63:0]					lq_cdb2_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  lq_cdb2_tag,    		// CDB tag bus from functional units 
	input							lq_cdb2_valid,  		// The data on the CDB is valid 
	
	output logic							lq_is_available,
	output logic							lq_is_ready,
	//logic	[`LQ_SIZE-1:0][63:0]	lq_reg_data, next_lq_reg_data;
	output logic	[$clog2(`ROB_SIZE):0]	lq_rob_idx,
	output logic	[63:0]					lq_opa,
	output logic	[63:0]					lq_opb,
	output logic	[$clog2(`PRF_SIZE)-1:0] lq_dest_tag,
	output logic							lq_addr_valid
);

	logic							inuse;
	

	
	logic							next_inuse;
	logic	[63:0]					next_lq_addr;
	logic	[$clog2(`ROB_SIZE):0]	next_lq_rob_idx;
	logic	[63:0]					next_lq_opa;
	logic	[63:0]					next_lq_opb;
	logic	[4:0]					next_lq_dest_tag;
	logic							next_lq_addr_valid;
	logic	[$clog2(`PRF_SIZE)-1:0]	next_lq_dest_tag;
	
	assign lq_is_available 	= lq_is_ready ? lq_free_enable : ~inuse;
	assign lq_is_ready		= inuse && lq_addr_valid;
	
	always_ff @(posedge clock) begin
		if(reset) begin
			lq_addr 		<= #1 0;
			lq_rob_idx 		<= #1 0;
			lq_opa 			<= #1 0;
			lq_opb 			<= #1 0;
			lq_dest_tag 	<= #1 0;
			lq_addr_valid 	<= #1 0;
			inuse			<= #1 0;
		end
		else begin
			lq_reg_addr 		<= #1 next_lq_reg_addr;
			lq_rob_idx 			<= #1 next_lq_rob_idx;
			lq_reg_opa 			<= #1 next_lq_reg_opa;
			lq_reg_opb 			<= #1 next_lq_reg_opb;
			lq_reg_addr_valid 	<= #1 next_lq_reg_addr_valid;
			lq_reg_dest_tag		<= #1 next_lq_reg_dest_tag;
			inuse				<= #1 next_inuse;
		end
	end

	always_comb begin
		next_inuse			= inuse;
		next_lq_addr 		= lq_addr;
		next_lq_rob_idx 	= lq_rob_idx;
		next_lq_opa			= lq_opa;
		next_lq_opb			= lq_opb;
		next_lq_addr_valid	= lq_addr_valid;
		next_lq_dest_tag	= lq_dest_tag;
		if (lq_free) begin
			next_inuse			= 0;
		end
		else if (lq_free_enable && lq_mem_in1) begin
			next_inuse			= 1;
			next_lq_opa			= lq_opa_in1;
			next_lq_opb			= lq_opb_in1;
			next_lq_rob_idx		= lq_rob_idx_in1;
			next_lq_opb			= lq_opa_in1;
			next_lq_addr_valid	= lq_opb_valid1;
			next_lq_dest_tag	= dest_reg_idx1;
		end
		else if (lq_free_enable && lq_mem_in2) begin
			next_inuse			= 1;
			next_lq_opa			= lq_opa_in2;
			next_lq_opb			= lq_opb_in2;
			next_lq_rob_idx		= lq_rob_idx_in2;
			next_lq_opb			= lq_opa_in2;
			next_lq_addr_valid	= lq_opb_valid2;
			next_lq_dest_tag	= dest_reg_idx2;
		end
		else if (lq_free_enable) begin
			next_inuse			= 0;
		end
		else if (lq_mem_in1) begin
			next_inuse			= 1;
			next_lq_opa			= lq_opa_in1;
			next_lq_opb			= lq_opb_in1;
			next_lq_rob_idx		= lq_rob_idx_in1;
			next_lq_opb			= lq_opa_in1;
			next_lq_addr_valid	= lq_opb_valid1;
			next_lq_dest_tag	= dest_reg_idx1;
		end
		else if (lq_mem_in2) begin
			next_inuse			= 1;
			next_lq_opa			= lq_opa_in2;
			next_lq_opb			= lq_opb_in2;
			next_lq_rob_idx		= lq_rob_idx_in2;
			next_lq_opb			= lq_opa_in2;
			next_lq_addr_valid	= lq_opb_valid2;
			next_lq_dest_tag	= dest_reg_idx2;
		end
		else begin
			if (~lq_addr_valid && (lq_opb[$clog2(`PRF_SIZE)-1:0] == cdb1_tag) && inuse && lq_cdb1_valid) begin
				lq_opb			= lq_cdb1_in;
				lq_addr_valid	= 1;
			end
			if (~lq_addr_valid && (lq_opb[$clog2(`PRF_SIZE)-1:0] == cdb1_tag) && inuse && lq_cdb2_valid) begin
				lq_opb			= lq_cdb2_in;
				lq_addr_valid	= 1;
			end
		end
	end
endmodule

