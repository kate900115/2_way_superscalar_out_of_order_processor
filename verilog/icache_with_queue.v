module icache_with_queue(
	input									clock,
	input									reset,
	
	// input from processor.v
	input	[63:0]							proc2Icache_addr,	
	input  BUS_COMMAND						proc2Icache_command,
	input  									branch_mispredict,
	
	// input from memory
	input	[3:0]							Imem2proc_response,
	input	[3:0]							Imem2proc_tag,
	input	[`ICACHE_BLOCK_SIZE-1:0]		Imem2proc_data,
	
	// output to mem.v
	output	BUS_COMMAND						proc2Imem_command,
	output	logic	[63:0]					proc2Imem_addr,
	
	// output to processor.v
	output	logic	[63:0]					Icache2proc_data,
	output	logic							Icache2proc_valid,
	output  logic	[63:0]					Icache_address_out,
	output  logic							Icache_buffer_full
	);
	
	// input from Icachemem.v
	logic  [`ICACHE_BLOCK_SIZE-1:0]			cachemem_data;
	logic 									cachemem_valid;
	logic									cachemem_is_full;
	logic									cachemem_is_miss;
	logic	[63:0]							Icache_data_out;	
	// output to Icachemem.v
	logic [`ICACHE_INDEX_SIZE-1:0]  		index;
	logic [`ICACHE_TAG_SIZE-1:0]			tag; 
	logic									read_enable;    
	logic [3:0]								mem_response;
	logic [3:0]								mem_tag;
	
	
	// buffer to store instruction
	logic [15:0][3:0]						response;
	logic [15:0][63:0]						instruction;
	logic [15:0][63:0]						PC_address;
	logic [15:0]							in_use;
	logic [15:0]							valid;
	
	logic [15:0][3:0]						response_in;
	logic [15:0][63:0]						instruction_in;
	logic [15:0][63:0]						PC_address_in;
	logic [15:0]							in_use_in;
	logic [15:0]							valid_in;
	
	logic [3:0]								buffer_head;
	logic [3:0]								buffer_tail;
	logic [3:0]								buffer_head_next;
	logic [3:0]								buffer_tail_next;	
	
	always_ff@(posedge clock)
	begin
		if (reset)
		begin
			buffer_head 					<= `SD 0;
			buffer_tail 					<= `SD 0;
			response    					<= `SD 0;
			instruction 					<= `SD 0;
			PC_address  					<= `SD 0;
			in_use							<= `SD 0;
			valid							<= `SD 0;
		end
		else
		begin
			buffer_head 					<= `SD buffer_head_next;
			buffer_tail 					<= `SD buffer_tail_next;
			response    					<= `SD response_in;
			instruction 					<= `SD instruction_in;
			PC_address  					<= `SD PC_address_in;
			in_use							<= `SD in_use_in;
			valid							<= `SD valid_in;
		end
	end
	
	always_comb
	begin
		buffer_head_next 					= buffer_head;
		buffer_tail_next 					= buffer_tail;
		response_in 	 					= response;
		instruction_in 	 					= instruction;
		PC_address_in    					= PC_address;
		in_use_in		 					= in_use;
		valid_in		 					= valid;
		//output
		Icache_buffer_full					= 1'b0;
		Icache2proc_data  		  			= 0;
		Icache_address_out		  			= 0;
		Icache2proc_valid		  			= 1'b0;
		
		if (buffer_head==buffer_tail+4'b1)
		begin
			Icache_buffer_full				= 1'b1;
		end
		
		if (proc2Icache_command == BUS_LOAD)
		begin
			if (cachemem_valid)
			begin
				PC_address_in[buffer_tail]  = proc2Icache_addr;
				instruction_in[buffer_tail] = Icache_data_out;
				in_use_in[buffer_tail]		= 1'b1;
				valid_in[buffer_tail]		= 1'b1;
				buffer_tail_next			= buffer_tail+4'b1;
			end
			else
			begin
				response_in[buffer_tail]    = Imem2proc_response;
				PC_address_in[buffer_tail]  = proc2Icache_addr;
				in_use_in[buffer_tail]		= 1'b1;
				valid_in[buffer_tail]		= 1'b0;
				buffer_tail_next			= buffer_tail+4'b1;
			end
		end
		
		if (Imem2proc_tag!=0)
		begin
			for (int i=0; i<16; i++)
			begin
				if ((response[i]==Imem2proc_tag) && in_use && (valid==0))
				begin
					instruction_in[i] 		= Imem2proc_data;
					valid_in[i]		 		= 1'b1;
				end
			end
		end
		
		if (valid[buffer_head])
		begin
			buffer_head_next     	  		= buffer_head + 1;
			Icache2proc_data  		  		= instruction[buffer_head];
			Icache_address_out		  		= PC_address[buffer_head];
			Icache2proc_valid		  		= 1'b1;
			valid_in[buffer_head]	  		= 1'b0;
			in_use_in[buffer_head]	  		= 1'b0;
		end
		
		if (branch_mispredict)
		begin
			buffer_head_next 				= 0;
			buffer_tail_next 				= 0;
			response_in 	 				= 0;
			instruction_in 	 				= 0;
			PC_address_in    				= 0;
			in_use_in		 				= 0;
			valid_in		 				= 0;
		end
		
		
		
	end	
	
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
		.Icache_data_valid(Icache_valid_out),
		.Icache2proc_tag(Icache2proc_tag),	 	
		.Icache2proc_response(Icache2proc_response),
		// output to Icache.v
		.index(index),
		.tag(tag),  
		.read_enable(read_enable),    
		.mem_response(mem_response),
		.mem_tag(mem_tag)
);

	
	
	icachemem im(
		.clock(clock),
		.reset(reset),
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
		.read_data(cachemem_data)
	);

endmodule
