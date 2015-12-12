module icache(
	input									clock,
	input									reset,
	// input from processor.v  thread 1
	input	[63:0]							proc2Icache_addr,	
	input  BUS_COMMAND						proc2Icache_command,
	input  									branch_mispredict,
	input	[63:0]							pc_target,
	
	//Imem2proc tag==0 means the load failed
	// input from memory
	input	[3:0]							Imem2proc_response,
	input	[3:0]							Imem2proc_tag,
	input	[`ICACHE_BLOCK_SIZE-1:0]		Imem2proc_data,
	
	// output to mem.v
	output	BUS_COMMAND						proc2Imem_command,
	output	logic	[63:0]					proc2Imem_addr,
	
	// output to processor.v
	output	logic	[63:0]					Icache2proc_data,
	output	logic							Icache2proc_valid
	);
	
	// input from Icachemem.v
	logic  [`ICACHE_BLOCK_SIZE-1:0]			cachemem_data;
	logic 									cachemem_valid;
	logic									cachemem_is_full;
	logic									cachemem_is_miss;
	logic									cachemem_is_miss_pref;
	//logic	[63:0]							Icache_data_out;	
	// output to Icachemem.v
	logic [`ICACHE_INDEX_SIZE-1:0]  		index,index_pref;
	logic [`ICACHE_TAG_SIZE-1:0]			tag, tag_pref; 
	logic									read_enable, read_enable_pref;    
	logic [3:0]								mem_response;
	logic [3:0]								mem_tag;

	//for prefetch
	logic [63:0] pc_address, n_pc_address;
	logic pre_enable;
	BUS_COMMAND pre_command;
	
	always_ff @(posedge clock) begin
		if (reset) begin
			pc_address						<= `SD 0;
			end
		else if(branch_mispredict) begin
			pc_address						<= `SD {pc_target[63:3],3'b0};
			end
		else begin
			pc_address  					<= `SD n_pc_address;//prefetch
			end
	end
	
	assign pre_enable = !reset;
	assign pre_command = (pre_enable)?BUS_LOAD: BUS_NONE;
	always_comb begin
		if(!pre_enable || (read_enable && cachemem_is_miss)) begin //this clock cycle not prefetch, this cc release no use
			n_pc_address = pc_address;
		end
		else if(pre_enable) begin //this cc prefetch, this cc release and use
			n_pc_address = pc_address +8;
		end
	end
	

	
	icache_controller ic(
		// input from Mem.v									
		.Imem2proc_response(Imem2proc_response),
		.Imem2proc_tag(Imem2proc_tag),
		.Imem2proc_data(Imem2proc_data),
		// input from processor.v
		.pref2Icache_addr(pc_address),	
		.pref2Icache_command(pre_command),
		.proc2Icache_addr(proc2Icache_addr),	
		.proc2Icache_command(proc2Icache_command),
		// input from Icache.v
		.cachemem_data(cachemem_data),
		.cachemem_valid(cachemem_valid),
		.cachemem_is_full(cachemem_is_full),
		.cachemem_is_miss(cachemem_is_miss),
		.cachemem_is_miss_pref(cachemem_is_miss_pref),
		
		// output to mem.v
		.proc2Imem_command(proc2Imem_command),
		.proc2Imem_addr(proc2Imem_addr),
		// output to processor.v
		.Icache_data_out(Icache2proc_data),
		.Icache_data_valid(Icache2proc_valid),
		// output to Icache.v
		.index(index),
		.index_pref(index_pref),
		.tag(tag),  
		.tag_pref(tag_pref),
		.read_enable(read_enable),    
		.read_enable_pref(read_enable_pref),
		.mem_response(mem_response),
		.mem_tag(mem_tag)
);


	
	icachemem im(
		.clock(clock),
		.reset(reset),
		// input from icache_controller.v
		.index_in(index),
		.index_in_pref(index_pref),
		.tag_in(tag),  
		.tag_in_pref(tag_pref),
		.read_enable(read_enable),    
		.read_enable_pref(read_enable_pref),
		.mem_response(mem_response),
		.mem_tag(mem_tag),						
	
		// input from mem.v
		.load_data_in(Imem2proc_data),
	
		// output to icache_controller.v
		.data_is_valid(cachemem_valid),
		.data_is_miss(cachemem_is_miss),
		.pref_is_miss(cachemem_is_miss_pref),
		.cache_is_full(cachemem_is_full),
		.read_data(cachemem_data)
	);

endmodule
