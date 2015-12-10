module dcache(
	input 									clock,
	input									reset,
	// input from Mem.v
	input  [3:0] 							Dmem2proc_response,
	input  [3:0] 							Dmem2proc_tag,
	input  [`DCACHE_BLOCK_SIZE-1:0]			Dmem2proc_data,
	
	// input from processor.v
	input  [63:0]							proc2Dcache_addr,
	input  BUS_COMMAND						proc2Dcache_command,
	input  [`DCACHE_BLOCK_SIZE-1:0] 		proc2Dcache_data,
	
	// output to mem.v
	output BUS_COMMAND						proc2Dmem_command,
	output logic [63:0]						proc2Dmem_addr,
	output logic [`DCACHE_BLOCK_SIZE-1:0]	proc2Dmem_data,
	
	// output to processor.v
	output logic [`DCACHE_BLOCK_SIZE-1:0]	Dcache2proc_data,	 
	output logic [3:0]						Dcache2proc_tag,	 	// to tell processor the tag of the previous load which is finished
	output logic [3:0]						Dcache2proc_response,	// to tell processor the tag of present load
	output logic 							Dcache_data_hit
);
	
	// input from Dcache.v
	logic  [`DCACHE_BLOCK_SIZE-1:0]			cachemem_data;
	logic 									cachemem_valid;
	logic									cachemem_is_dirty;
	logic									cachemem_is_miss;
	logic									cachemem_is_full;
	
	// output to Dcache.v
	logic [`DCACHE_INDEX_SIZE-1:0]   		index;
	logic [`DCACHE_TAG_SIZE-1:0]			tag;
	logic									read_enable;
	logic									write_enable;     
	logic [`DCACHE_BLOCK_SIZE-1:0]			write_data_to_Dcache;	// data that send to dcache.v
	logic [3:0]								mem_response;
	logic [3:0]								mem_tag;
	
	dcache_controller dc(
		// input from Mem.v
		.Dmem2proc_response(Dmem2proc_response),
		.Dmem2proc_tag(Dmem2proc_tag),
		// input from Dcache.v
		.cachemem_data(cachemem_data),
		.cachemem_valid(cachemem_valid),
		.cachemem_is_dirty(cachemem_is_dirty),
		.cachemem_is_miss(cachemem_is_miss),
		.cachemem_is_full(cachemem_is_full),
		// input from processor.v
		.proc2Dcache_addr(proc2Dcache_addr),
		.proc2Dcache_command(proc2Dcache_command),
		.proc2Dcache_data(proc2Dcache_data),	
		// output to mem.v
		.proc2Dmem_command(proc2Dmem_command),
		.proc2Dmem_addr(proc2Dmem_addr),	
		// output to processor.v
		.Dcache_data_out(Dcache2proc_data),	 
		.Dcache2proc_tag(Dcache2proc_tag),	 	
		.Dcache2proc_response(Dcache2proc_response),	
		.Dcache_data_hit(Dcache_data_hit),
		// output to Dcache.v
		.index(index),
		.tag(tag),  
		.read_enable(read_enable),
		.write_enable(write_enable),     
		.write_data_to_Dcache(write_data_to_Dcache),	
		.mem_response(mem_response),
		.mem_tag(mem_tag)
	);

	dcache_mem dm(
		.clock(clock),
		.reset(reset),
		// input from dcache_controller.v
		.index_in(index),
		.tag_in(tag),
		.read_enable(read_enable),
		.write_enable(write_enable),
		.write_data_in(write_data_to_Dcache),
		.mem_response(mem_response),
		.mem_tag(mem_tag),							
		// input from mem.v
		.load_data_in(Dmem2proc_data),
		// output to mem.v
		.store_data_out(proc2Dmem_data),
		// output to dcache_controller.v
		.data_is_valid(cachemem_valid),
		.data_is_dirty(cachemem_is_dirty),  // data which need to be replaced is dirty
		.data_is_miss(cachemem_is_miss),
		.cache_is_full(cachemem_is_full),
		.data_out(cachemem_data)
	);
	
endmodule
