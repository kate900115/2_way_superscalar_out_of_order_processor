module icache(
	input							clock,
	input							reset,
	input thread1_branch_is_taken,
	// input from processor.v
	input	[63:0]							proc2Icache_addr,	
	input  BUS_COMMAND						proc2Icache_command,
	
	// input from memory
	input	[3:0]							Imem2proc_response,
	input	[3:0]							Imem2proc_tag,
	input	[`ICACHE_BLOCK_SIZE-1:0]		Imem2proc_data,
	
	// output to mem.v
	output	BUS_COMMAND						proc2Imem_command,
	output	logic	[63:0]					proc2Imem_addr,
	
	// output to processor.v
	output	logic	[63:0]					Icache_data_out,
	output	logic							Icache_valid_out,
	output  logic [3:0]						Icache2proc_tag,	 	
	output  logic [3:0]						Icache2proc_response
	
	);
	
	// input from Icachemem.v
	logic  [`ICACHE_BLOCK_SIZE-1:0]			cachemem_data;
	logic 									cachemem_valid;
	logic									cachemem_is_full;
	logic									cachemem_is_miss;	
	// output to Icachemem.v
	logic [`ICACHE_INDEX_SIZE-1:0]  		index;
	logic [`ICACHE_TAG_SIZE-1:0]			tag; 
	logic									read_enable;    
	logic [3:0]								mem_response;
	logic [3:0]								mem_tag;
	logic Icache_valid_out1;
	logic load_valid;
	icache_controller ic(
		// input from Mem.v									
		.Imem2proc_response(Imem2proc_response),
		.Imem2proc_tag(Imem2proc_tag),
		// input from processor.v
		.proc2Icache_addr(proc2Icache_addr),	
		.proc2Icache_command(proc2Icache_command),
		// input from Icache.v
		.cachemem_data(cachemem_data),
		.cachemem_valid(cachemem_valid),
		.cachemem_is_full(cachemem_is_full),
		.cachemem_is_miss(cachemem_is_miss),
	
		// output to mem.v
		.proc2Imem_command(proc2Imem_command),
		.proc2Imem_addr(proc2Imem_addr),
		// output to processor.v
		.Icache_data_out(Icache_data_out),
		.Icache_data_valid(Icache_valid_out1),
		.Icache2proc_tag(Icache2proc_tag),	 	
		.Icache2proc_response(Icache2proc_response),
		// output to Icache.v
		.index(index),
		.tag(tag),  
		.read_enable(read_enable),    
		.mem_response(mem_response),
		.mem_tag(mem_tag)
);
assign Icache_valid_out = Icache_valid_out1 || load_valid;
	
	
	icachemem im(
		.clock(clock),
		.reset(reset|| thread1_branch_is_taken),
		// input from icache_controller.v
		.index_in(index),
		.tag_in(tag),
		.read_enable(read_enable),
		.mem_response(mem_response),
		.mem_tag(mem_tag),						
	
		// input from mem.v
		.load_data_in(Imem2proc_data),
	
		// output to icache_controller.v
		.data_is_valid(cachemem_valid),
		.data_is_miss(cachemem_is_miss),
		.cache_is_full(cachemem_is_full),
		.read_data(cachemem_data),
		.load_valid(load_valid)
	);

endmodule
