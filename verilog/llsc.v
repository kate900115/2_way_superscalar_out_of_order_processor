module llsc(
	input	clock,
	input	reset,
	
	input	MEM_INST_TYPE	inst1_mem_inst_type,
	input	[63:0]			inst1_mem_addr,
	input	MEM_INST_TYPE	inst2_mem_inst_type,
	input	[63:0]			inst2_mem_addr,
	
	output	logic			inst1_store_success,
	output	logic			inst2_store_success,
	output	logic			full
);

	logic	[`LLSC_SIZE-1:0][63:0]	address_tag;
	logic	[`LLSC_SIZE-1:0]		valid;
	logic	[`LLSC_SIZE-1:0]		good;
	
	logic	[`LLSC_SIZE-1:0][63:0]	next_address_tag;
	logic	[`LLSC_SIZE-1:0]		next_valid;
	logic	[`LLSC_SIZE-1:0]		next_good;
	
	logic							inst1_find;
	logic							inst2_find;
	
	always_ff @(posedge clock) begin
		if (reset)
		begin
			for (int i = 0; i < `LLSC_SIZE; i++) begin
				address_tag[i]	<= #1 0;
				valid[i]		<= #1 0;
				good[i]			<= #1 0;
			end
		end
		else begin
			for (int i = 0; i < `LLSC_SIZE; i++) begin
				address_tag[i]	<= #1 next_address_tag[i];
				valid[i]		<= #1 next_valid[i];
				good[i]			<= #1 next_good[i];
			end
		end
	end
	
	always_comb begin
	//init
		inst1_find			= 0;
		inst2_find			= 0;
		inst1_store_success	= 0;
		inst2_store_success	= 0;
		for (int i=0; i < `LLSC_SIZE; i++) begin
			next_address_tag[i] = address_tag[i];
			next_valid[i]		= valid[i];
			next_good[i]		= good[i];
		end
		//three types of mem_inst
		//inst1
		if(inst1_mem_inst_type == IS_LDL_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst1_mem_addr)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= valid[i];
					next_good[i]		= 0;
					inst1_find			= 1;
					break;
				end
			end
			if (inst1_find == 0) begin
				for (int i=0; i < `LLSC_SIZE; i++) begin
					if (valid[i] == 0)begin
						next_address_tag[i] = inst1_mem_addr;
						next_valid[i]		= 1;
						next_good[i]		= 1;
						inst1_find				= 1;
						break;
					end
				end
			end
		end
		else if (inst1_mem_inst_type == IS_STQ_C_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst1_mem_addr && good[i] == 1)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= 0;
					next_good[i]		= good[i];
					inst1_find			= 1;
					inst1_store_success		= 1;
					break;
				end
				else if (valid[i] == 1 && address_tag[i] == inst1_mem_addr && good[i] == 0)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= 0;
					next_good[i]		= good[i];
					inst1_find			= 1;
					inst1_store_success	= 0;
					break;
				end
			end
			if (inst1_find == 0) begin
				inst1_store_success = 0;
			end
		end
		else if (inst1_mem_inst_type == IS_STQ_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst1_mem_addr)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= valid[i];
					next_good[i]		= 0;
					inst1_find			= 1;
					inst1_store_success	= 1;
					break;
				end
			end
		end
		//inst2
		if(inst2_mem_inst_type == IS_LDL_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst2_mem_addr)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= valid[i];
					next_good[i]		= 0;
					inst2_find			= 1;
					break;
				end
			end
			if (inst2_find == 0) begin
				for (int i=0; i < `LLSC_SIZE; i++) begin
					if (valid[i] == 0)begin
						next_address_tag[i] = inst2_mem_addr;
						next_valid[i]		= 1;
						next_good[i]		= 1;
						inst2_find			= 1;
						break;
					end
				end
			end
		end
		else if (inst2_mem_inst_type == IS_STQ_C_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst2_mem_addr && good[i] == 1)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= 0;
					next_good[i]		= good[i];
					inst2_find			= 1;
					inst2_store_success		= 1;
					break;
				end
				else if (valid[i] == 1 && address_tag[i] == inst2_mem_addr && good[i] == 0)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= 0;
					next_good[i]		= good[i];
					inst2_find			= 1;
					inst2_store_success	= 0;
					break;
				end
			end
			if (inst2_find == 0) begin
				inst2_store_success = 0;
			end
		end
		else if (inst2_mem_inst_type == IS_STQ_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == inst2_mem_addr)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= valid[i];
					next_good[i]		= 0;
					inst2_find			= 1;
					inst2_store_success	= 1;
					break;
				end
			end
		end
	//full
		full = &valid;
	end
endmodule
