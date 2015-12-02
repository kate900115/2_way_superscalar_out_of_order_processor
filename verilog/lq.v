module lq(
	input	clock,
	input	reset,
	
	input	[63:0] 					lq_opa_in1,      	// Operand a from Rename  data
	input	[63:0] 					lq_opb_in1,      	// Operand a from Rename  tag or data from prf
	input         					lq_opb_valid1,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]	lq_rob_idx_in1,  	// The rob index of instruction 1
	input							lq_mem_in1,
	input	[$clog2(`PRF_SIZE)-1:0]	lq_dest_idx1,
	input	[`LQ_SIZE-1:0]			lq_free_enable,

    //for instruction2
	input	[63:0] 					lq_opa_in2,      	// Operand a from Rename  data
	input	[63:0] 					lq_opb_in2,     	// Operand b from Rename  tag or data from prf
	input         					lq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input	[$clog2(`ROB_SIZE):0]	lq_rob_idx_in2,  	// The rob index of instruction 2
	input							lq_mem_in2,			//ldq
	input	[$clog2(`PRF_SIZE)-1:0] lq_dest_idx2,
	
	input	[63:0]					lq_cdb1_in,     		// CDB bus from functional units 
	input	[$clog2(`PRF_SIZE)-1:0]	lq_cdb1_tag,    		// CDB tag bus from functional units 
	input							lq_cdb1_valid,  		// The data on the CDB is valid 
	input	[63:0]					lq_cdb2_in,     		// CDB bus from functional units 
	input	[$clog2(`PRF_SIZE)-1:0]	lq_cdb2_tag,    		// CDB tag bus from functional units 
	input							lq_cdb2_valid,  		// The data on the CDB is valid

	//mispredict	
	input	thread1_mispredict,
	input	thread2_mispredict,
	
	output logic	[`LQ_SIZE-1:0]							lq_is_available,
	output logic	[`LQ_SIZE-1:0]							lq_is_ready,
	//logic	[`LQ_SIZE-1:0][63:0]	lq_reg_data, next_lq_reg_data;
	output logic	[`LQ_SIZE-1:0][$clog2(`ROB_SIZE):0]		lq_rob_idx,
	output logic	[`LQ_SIZE-1:0][63:0]					lq_opa,
	output logic	[`LQ_SIZE-1:0][63:0]					lq_opb,
	output logic	[`LQ_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]	lq_dest_tag,
	output logic	[`LQ_SIZE-1:0]							lq_addr_valid
);

	logic	[`LQ_SIZE-1:0]							inuse;
	logic	[`LQ_SIZE-1:0]							next_inuse;
	logic	[`LQ_SIZE-1:0][63:0]					next_lq_addr;
	logic	[`LQ_SIZE-1:0][$clog2(`ROB_SIZE):0]		next_lq_rob_idx;
	logic	[`LQ_SIZE-1:0][63:0]					next_lq_opa;
	logic	[`LQ_SIZE-1:0][63:0]					next_lq_opb;
	logic	[`LQ_SIZE-1:0][4:0]						next_lq_dest_tag;
	logic	[`LQ_SIZE-1:0]							next_lq_addr_valid;
	logic	[`LQ_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]	next_lq_dest_tag;
	
	logic	[`LQ_SIZE-1:0]							lq_free;
	logic	[`LQ_SIZE-1:0]							lq_mem_load1;
	logic	[`LQ_SIZE-1:0]							lq_mem_load2;
	
	priority_selector #(2,`LQ_SIZE)load(
		req(lq_is_available),
		en(1'b1),
    	// Outputs
		gnt_bus({lq_mem_load1,lq_mem_load2}),
	);
	
	always_ff @(posedge clock) begin
		for (int i = 0; i < `LQ_SIZE; i++) begin
			if(reset) begin
				lq_addr[i] 			<= #1 0;
				lq_rob_idx[i] 		<= #1 0;
				lq_opa[i] 			<= #1 0;
				lq_opb[i] 			<= #1 0;
				lq_dest_tag[i]	 	<= #1 0;
				lq_addr_valid[i] 	<= #1 0;
				inuse[i]			<= #1 0;
			end
			else begin
				lq_reg_addr[i] 			<= #1 next_lq_reg_addr[i];
				lq_rob_idx[i] 			<= #1 next_lq_rob_idx[i];
				lq_reg_opa[i] 			<= #1 next_lq_reg_opa[i];
				lq_reg_opb[i] 			<= #1 next_lq_reg_opb[i];
				lq_reg_addr_valid[i] 	<= #1 next_lq_reg_addr_valid[i];
				lq_reg_dest_tag[i]		<= #1 next_lq_reg_dest_tag[i];
				inuse[i]				<= #1 next_inuse[i];
			end
		end
	end

	always_comb begin
		lq_free[i] = 0;
		if (thread1_mispredict) begin
			for (int i = 0; i < `LQ_SIZE; i++) begin
				if (lq_rob_idx[i][$clog2(`ROB_SIZE)] == 0) begin
					lq_free[i] = 1;
				end
			end
		end
		if (thread2_mispredict) begin
			for (int i = 0; i < `LQ_SIZE; i++) begin
				if (lq_rob_idx[i][$clog2(`ROB_SIZE)] == 1) begin
					lq_free[i] = 1;
				end
			end
		end
	end

	always_comb begin
		for (int i = 0; i < `LQ_SIZE; i++) begin
			lq_is_available[i]		= lq_is_ready[i] ? lq_free_enable[i] : ~inuse[i];
			lq_is_ready[i]			= inuse[i] && lq_addr_valid[i];
			next_inuse[i]			= inuse[i];
			next_lq_addr[i]			= lq_addr[i];
			next_lq_rob_idx[i]		= lq_rob_idx[i];
			next_lq_opa[i]			= lq_opa[i];
			next_lq_opb[i]			= lq_opb[i];
			next_lq_addr_valid[i]	= lq_addr_valid[i];
			next_lq_dest_tag[i]		= lq_dest_tag[i];
			if (lq_free[i]) begin
				next_inuse[i]		= 0;
			end
			else if (lq_free_enable[i] && lq_mem_load1[i]) begin
				next_inuse[i]			= 1;
				next_lq_opa[i]			= lq_opa_in1[i];
				next_lq_opb[i]			= lq_opb_in1[i];
				next_lq_rob_idx[i]		= lq_rob_idx_in1[i];
				next_lq_opb[i]			= lq_opa_in1[i];
				next_lq_addr_valid[i]	= lq_opb_valid1[i];
				next_lq_dest_tag[i]		= dest_reg_idx1[i];
			end
			else if (lq_free_enable[i] && lq_mem_load2[i]) begin
				next_inuse[i]			= 1;
				next_lq_opa[i]			= lq_opa_in2[i];
				next_lq_opb[i]			= lq_opb_in2[i];
				next_lq_rob_idx[i]		= lq_rob_idx_in2[i];
				next_lq_opb[i]			= lq_opa_in2[i];
				next_lq_addr_valid[i]	= lq_opb_valid2[i];
				next_lq_dest_tag[i]		= dest_reg_idx2[i];
			end
			else if (lq_free_enable[i]) begin
				next_inuse[i]			= 0;
			end
			else if (lq_mem_load1[i]) begin
				next_inuse[i]			= 1;
				next_lq_opa[i]			= lq_opa_in1[i];
				next_lq_opb[i]			= lq_opb_in1[i];
				next_lq_rob_idx[i]		= lq_rob_idx_in1[i];
				next_lq_opb[i]			= lq_opa_in1[i];
				next_lq_addr_valid[i]	= lq_opb_valid1[i];
				next_lq_dest_tag[i]		= dest_reg_idx1[i];
			end
			else if (lq_mem_load2[i]) begin
				next_inuse[i]			= 1;
				next_lq_opa[i]			= lq_opa_in2[i];
				next_lq_opb[i]			= lq_opb_in2[i];
				next_lq_rob_idx[i]		= lq_rob_idx_in2[i];
				next_lq_opb[i]			= lq_opa_in2[i];
				next_lq_addr_valid[i]	= lq_opb_valid2[i];
				next_lq_dest_tag[i]		= dest_reg_idx2[i];
			end
			else begin
				if (~lq_addr_valid[i] && (lq_opb[i][$clog2(`PRF_SIZE)-1:0] == cdb1_tag[i]) && inuse[i] && lq_cdb1_valid[i]) begin
					lq_opb[i]			= lq_cdb1_in[i];
					lq_addr_valid[i]	= 1;
				end
				if (~lq_addr_valid[i] && (lq_opb[i][$clog2(`PRF_SIZE)-1:0] == cdb1_tag[i]) && inuse[i] && lq_cdb2_valid[i]) begin
					lq_opb[i]			= lq_cdb2_in[i];
					lq_addr_valid[i]	= 1;
				end
			end
		end
	end
endmodule

