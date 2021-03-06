module icache_controller(
	// input from Mem.v										
	input	[3:0]							Imem2proc_response,   //
	input	[3:0]							Imem2proc_tag,
	input	[`ICACHE_BLOCK_SIZE-1:0]		Imem2proc_data,
	
	// input from processor.v
	input	[63:0]							proc2Icache_addr,	
	input  BUS_COMMAND						proc2Icache_command,
	
	//input from prefetch
	input	[63:0]							pref2Icache_addr,	
	input  BUS_COMMAND						pref2Icache_command,
	
	// input from Icache.v
	input  [`ICACHE_BLOCK_SIZE-1:0]			cachemem_data,
	input 									cachemem_valid,
	input									cachemem_is_full,
	input									cachemem_is_miss,
	input									cachemem_is_miss_pref,	
	
	// output to mem.v
	output	BUS_COMMAND						proc2Imem_command,
	output	logic	[63:0]					proc2Imem_addr,
	
	// output to processor.v
	output	logic	[63:0]					Icache_data_out,
	output	logic							Icache_data_valid,
	
	// output to Icache.v
	output logic [`ICACHE_INDEX_SIZE-1:0]   index_pref,
	output logic [`ICACHE_TAG_SIZE-1:0]		tag_pref,  
	output logic							read_enable_pref,    
	output logic [3:0]						mem_response,   //when prefecth stores data
	
		// output to Icache.v
	output logic [`ICACHE_INDEX_SIZE-1:0]   index,
	output logic [`ICACHE_TAG_SIZE-1:0]		tag,  
	output logic							read_enable,    
	output logic [3:0]						mem_tag            // when inst look for data
);
	assign 	read_enable 		    	 = (proc2Icache_command==BUS_LOAD);
	assign 	read_enable_pref 	    	 = (pref2Icache_command==BUS_LOAD);
	// output to Icache.v
	assign {tag, index} 			= proc2Icache_addr[63:`ICACHE_BLOCK_OFFSET];
	assign {tag_pref, index_pref} 	= pref2Icache_addr[63:`ICACHE_BLOCK_OFFSET];
	assign mem_tag			  		= Imem2proc_tag;
	//only tag, index, read_enable are needed to get miss
	//input to mem.v
	always_comb begin
		proc2Imem_command		 = BUS_NONE;
		proc2Imem_addr 	 		 = 0;
		mem_response			 = Imem2proc_response;
		if(cachemem_is_miss)
			begin
					// to icache.v
				if (cachemem_is_miss && (cachemem_is_full)) 
					begin
						proc2Imem_command 		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						mem_response	  		 = 0;
					end
				else if (cachemem_is_miss && !cachemem_is_full)
					begin
						proc2Imem_command 		 = BUS_LOAD;
						proc2Imem_addr 	 		 = {proc2Icache_addr[63:3],3'b0};
						mem_response	 		 = Imem2proc_response;
					end
			end

		else if(cachemem_is_miss_pref)
				begin
					// to icache.v
					if (cachemem_is_full)
					begin
						proc2Imem_command 		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						mem_response	  		 = 0;
					end
					else if (!cachemem_is_full)
					begin
						proc2Imem_command 		 = BUS_LOAD;
						proc2Imem_addr 	 		 = {pref2Icache_addr[63:3],3'b0};
						mem_response	 		 = Imem2proc_response;
					end
					else if //((cachemem_is_miss==0) && (Imem2proc_tag!=0))
					(!cachemem_is_miss_pref)   //HIT!!!
					begin
						proc2Imem_command		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						mem_response			 = Imem2proc_response;
					end
				end
			
	end	
			
//output to processor	
	always_comb begin
	if(cachemem_valid && cachemem_data!=0) begin
		Icache_data_valid		 = 1;
		Icache_data_out  		 = cachemem_data;
		end
	else 	begin
		Icache_data_valid		 = 0;
		Icache_data_out  		 = 0;
		end	
	end
endmodule

