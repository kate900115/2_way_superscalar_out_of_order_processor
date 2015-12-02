module sq_one_entry(
	input	clock,
	input	reset,
	
	input	[63:0] 					sq_opa_in1,      	// Operand a from Rename  data
	input	[63:0] 					sq_opb_in1,      	// Operand a from Rename  tag or data from prf
	input         					sq_opb_valid1,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]	sq_rob_idx_in1,  	// The rob index of instruction 1
	input							sq_mem_in1,
	input	[$clog2(`PRF_SIZE)-1:0]	sq_dest_idx1,

    //for instruction2
	input	[63:0] 					sq_opa_in2,      	// Operand a from Rename  data
	input	[63:0] 					sq_opb_in2,     	// Operand b from Rename  tag or data from prf
	input         					sq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]	sq_rob_idx_in2,  	// The rob index of instruction 2
	input							sq_mem_in2,    //ldq
	input	[$clog2(`PRF_SIZE)-1:0] sq_dest_idx2,
	
	input  [63:0]					sq_cdb1_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  sq_cdb1_tag,    		// CDB tag bus from functional units 
	input							sq_cdb1_valid,  		// The data on the CDB is valid 
	input  [63:0]					sq_cdb2_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  sq_cdb2_tag,    		// CDB tag bus from functional units 
	input							sq_cdb2_valid,  		// The data on the CDB is valid
	input							if_committed,
	
	output logic							sq_is_available,
	output logic							sq_is_ready,
	//logic	[`sq_SIZE-1:0][63:0]	sq_reg_data, next_sq_reg_data;
	output logic	[$clog2(`ROB_SIZE):0]	sq_rob_idx,
	output logic	[63:0]					sq_opa,
	output logic	[63:0]					sq_opb,
	output logic	[$clog2(`PRF_SIZE)-1:0] sq_dest_tag,
	output logic							sq_addr_valid
);

	logic							inuse;
	

	
	logic							next_inuse;
	logic	[63:0]					next_sq_addr;
	logic	[$clog2(`ROB_SIZE):0]	next_sq_rob_idx;
	logic	[63:0]					next_sq_opa;
	logic	[63:0]					next_sq_opb;
	logic	[4:0]					next_sq_dest_tag;
	logic							next_sq_addr_valid;
	logic	[$clog2(`PRF_SIZE)-1:0]	next_sq_dest_tag;
	
	assign sq_is_available 	= ~inuse;
	assign sq_is_ready		= inuse && sq_addr_valid;
	
	always_ff @(posedge clock) begin
		if(reset) begin
			sq_addr 		<= #1 0;
			sq_rob_idx 		<= #1 0;
			sq_opa 			<= #1 0;
			sq_opb 			<= #1 0;
			sq_dest_tag 	<= #1 0;
			sq_addr_valid 	<= #1 0;
			inuse			<= #1 0;
		end
		else begin
			sq_reg_addr 		<= #1 next_sq_reg_addr;
			sq_rob_idx 			<= #1 next_sq_rob_idx;
			sq_reg_opa 			<= #1 next_sq_reg_opa;
			sq_reg_opb 			<= #1 next_sq_reg_opb;
			sq_reg_addr_valid 	<= #1 next_sq_reg_addr_valid;
			sq_reg_dest_tag		<= #1 next_sq_reg_dest_tag;
			inuse				<= #1 next_inuse;
		end
	end

	always_comb begin
		next_inuse			= inuse;
		next_sq_addr 		= sq_addr;
		next_sq_rob_idx 	= sq_rob_idx;
		next_sq_opa			= sq_opa;
		next_sq_opb			= sq_opb;
		next_sq_addr_valid	= sq_addr_valid;
		next_sq_dest_tag	= sq_dest_tag;
		else if (sq_mem_in1) begin
			next_inuse			= 1;
			next_sq_opa			= sq_opa_in1;
			next_sq_opb			= sq_opb_in1;
			next_sq_rob_idx		= sq_rob_idx_in1;
			next_sq_opb			= sq_opa_in1;
			next_sq_addr_valid	= sq_opb_valid1;
			next_sq_dest_tag	= dest_reg_idx1;
		end
		else if (sq_mem_in2) begin
			next_inuse			= 1;
			next_sq_opa			= sq_opa_in2;
			next_sq_opb			= sq_opb_in2;
			next_sq_rob_idx		= sq_rob_idx_in2;
			next_sq_opb			= sq_opa_in2;
			next_sq_addr_valid	= sq_opb_valid2;
			next_sq_dest_tag	= dest_reg_idx2;
		end
		else if (if_committed) begin
			inuse = 0;
		end
		else begin
			if (~sq_addr_valid && (sq_opb[$clog2(`PRF_SIZE)-1:0] == cdb1_tag) && inuse && sq_cdb1_valid) begin
				sq_opb			= sq_cdb1_in;
				sq_addr_valid	= 1;
			end
			if (~sq_addr_valid && (sq_opb[$clog2(`PRF_SIZE)-1:0] == cdb1_tag) && inuse && sq_cdb2_valid) begin
				sq_opb			= sq_cdb2_in;
				sq_addr_valid	= 1;
			end
		end
	end
endmodule
