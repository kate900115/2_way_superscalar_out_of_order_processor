module llsc(
	input	clock,
	input	reset,
	
	input			llsc_enable,
	input	[5:0]	inst_op_type,
	input	[63:0]	inst_mem_addr,
	
	output	logic	inst_store_success,
	output	logic	full
);

	logic	[`LLSC_SIZE-1:0][63:0]	address_tag;
	logic	[`LLSC_SIZE-1:0]		valid;
	logic	[`LLSC_SIZE-1:0]		good;
	
	logic	[`LLSC_SIZE-1:0][63:0]	next_address_tag;
	logic	[`LLSC_SIZE-1:0]		next_valid;
	logic	[`LLSC_SIZE-1:0]		next_good;
	
	logic							inst_find;
	
	always_ff @(posedge clock) begin
		if (reset)
		begin
			for (int i = 0; i < `LLSC_SIZE; i++) begin
				address_tag[i]	<= #1 0;
				valid[i]		<= #1 0;
				good[i]			<= #1 0;
			end
		end
		else if (llsc_enable) begin
			for (int i = 0; i < `LLSC_SIZE; i++) begin
				address_tag[i]	<= #1 next_address_tag[i];
				valid[i]		<= #1 next_valid[i];
				good[i]			<= #1 next_good[i];
			end
		end
	end
	
	always_comb begin
	//init
		inst_find			= 0;
		inst_store_success	= 1;
		for (int i=0; i < `LLSC_SIZE; i++) begin
			next_address_tag[i] = address_tag[i];
			next_valid[i]		= valid[i];
			next_good[i]		= good[i];
		end
		//three types of mem_inst
		if(inst_op_type == `LDQ_L_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst_mem_addr)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= valid[i];
					next_good[i]		= 0;
					inst_find			= 1;
					inst_store_success	= 1;
					break;
				end
			end
			if (inst_find == 0) begin
				for (int i=0; i < `LLSC_SIZE; i++) begin
					if (valid[i] == 0)begin
						next_address_tag[i] = inst_mem_addr;
						next_valid[i]		= 1;
						next_good[i]		= 1;
						inst_find			= 1;
						inst_store_success	= 1;
						break;
					end
				end
			end
		end
		else if (inst_op_type == `STQ_C_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst_mem_addr && good[i] == 1)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= 0;
					next_good[i]		= good[i];
					inst_find			= 1;
					inst_store_success	= 1;
					break;
				end
				else if (valid[i] == 1 && address_tag[i] == inst_mem_addr && good[i] == 0)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= 0;
					next_good[i]		= good[i];
					inst_find			= 1;
					inst_store_success	= 0;
					break;
				end
			end
			if (inst_find == 0) begin
				inst_store_success = 0;
			end
		end
		else if (inst_op_type == `STQ_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst_mem_addr)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= valid[i];
					next_good[i]		= 0;
					inst_find			= 1;
					inst_store_success	= 1;
					break;
				end
			end
		end
	//full
		full = &valid;
	end
endmodule
