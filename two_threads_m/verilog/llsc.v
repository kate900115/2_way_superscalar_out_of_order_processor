module llsc(
	input	clock,
	input	reset,
	
	input	MEM_INST_TYPE	mem_inst_type,
	input	[63:0]			mem_addr,
	
	output	logic			store_success,
	output	logic			full
}

	logic	[`LLSC_SIZE-1:0][63:0]	address_tag;
	logic	[`LLSC_SIZE-1:0]		valid;
	logic	[`LLSC_SIZE-1:0]		good;
	
	logic	[`LLSC_SIZE-1:0][63:0]	next_address_tag;
	logic	[`LLSC_SIZE-1:0]		next_valid;
	logic	[`LLSC_SIZE-1:0]		next_good;
	
	logic							find;
	
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
		find 			= 0;
		store_success	= 0;
		for (int i=0; i < `LLSC_SIZE; i++) begin
			next_address_tag[i] = address_tag[i];
			next_valid[i]		= valid[i];
			next_good[i]		= good[i];
		end
	//four type mem_inst
		if(mem_inst_type == IS_LDL_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == mem_addr)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= valid[i];
					next_good[i]		= 0;
					find				= 1;
					break;
				end
			end
			if (find == 0) begin
				for (int i=0; i < `LLSC_SIZE; i++) begin
					if (valid[i] == 0)begin
						next_address_tag[i] = mem_addr;
						next_valid[i]		= 1;
						next_good[i]		= 1;
						find				= 1;
						break;
					end
				end
			end
		end
		else if (mem_inst_type == IS_STQ_C_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == mem_addr && good[i] == 1)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= 0;
					next_good[i]		= good[i];
					find				= 1;
					store_success		= 1;
					break;
				end
				else if (valid[i] == 1 && address_tag[i] == mem_addr && good[i] == 0)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= 0;
					next_good[i]		= good[i];
					find				= 1;
					store_success		= 0;
					break;
				end
			end
			if (find == 0) begin
				store_success = 0;
			end
		end
		else if (mem_inst_type == IS_STQ_INST) begin
			for (int i=0; i < `LLSC_SIZE; i++) begin
				if (valid[i] == 1 && address_tag[i] == mem_addr)begin
					next_address_tag[i] = address_tag[i];
					next_valid[i]		= valid[i];
					next_good[i]		= 0;
					find				= 1;
					store_success		= 1;
					break;
				end
			end
		end
	//full
		full = &valid;
	end
end module
