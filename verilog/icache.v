module icache(
	input							clock,
	input							reset,
	// from processor
	input [63:0] 					proc2Icache_addr, 
	
	// from memory
	input [`ICACHE_BLOCK_SIZE-1:0] 	wr1_data,
	
	// to processor
	output[`ICACHE_BLOCK_SIZE-1:0]	Icache_data_out,
	output							Icache_valid_out,
	
	// to memory
	output[63:0]					proc2Imem_addr,
	output[3:0]						proc2Imem_command
	);
	
	logic	[3:0]	Imem2proc_response;
	logic	[63:0]	Imem2proc_data;
	logic	[3:0]	Imem2proc_tag;
	
	logic	[63:0]	proc2Icache_addr;								//the address of the current instrucion
	logic	[63:0]	cachemem_data;
	logic			cachemem_valid;
	
	logic	[`ICACHE_INDEX_SIZE-1:0]	current_index;
	logic	[`ICACHE_TAG_SIZE-1:0]		current_tag;
	logic	[`ICACHE_INDEX_SIZE-1:0]	last_index;
	logic	[`ICACHE_TAG_SIZE-1:0]		last_tag;
	logic								data_write_enable;
	
	icache_controller ic(	
		// input									
		.clock(clock),
		.reset(reset),
		.Imem2proc_response(Imem2proc_response),
		.Imem2proc_data(Imem2proc_data),
		.Imem2proc_tag(Imem2proc_tag),
		.proc2Icache_addr(proc2Icache_addr),								
		.cachemem_data(cachemem_data),
		.cachemem_valid(cachemem_valid),
	
		// output
		.proc2Imem_command(proc2Imem_command),
		.proc2Imem_addr(proc2Imem_addr),
		.Icache_data_out(Icache_data_out),
		.Icache_valid_out(Icache_valid_out),
		.current_index(current_index),
		.current_tag(current_tag),
		.last_index(last_index),
		.last_tag(last_tag),
		.data_write_enable(data_write_enable)
);
	
	
	icachemem im(
		// input
		.clock(clock),
		.reset(reset),						
		.wr_en(data_write_enable),
		.wr_tag(last_tag),
		.wr_idx(last_index),
		.rd_tag(current_tag),
		.rd_idx(current_index),
		.wr_data(wr1_data),
		// output
		.rd_valid(cachemem_valid),
		.rd_data(cachemem_data)
);
endmodule
