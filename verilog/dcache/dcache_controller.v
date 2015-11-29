module dcache_controller(
	input							clock,
	input							reset,
	
	// input from Mem.v
	input  [3:0] 					Dmem2proc_response,
	input  [63:0] 					Dmem2proc_data,
	input  [3:0] 					Dmem2proc_tag,
	
	// input from Dcache.v
	input  [63:0]					cachemem_data,
	input 							cachemem_valid,
	input							cachemem_is_dirty,
	input							cachemem_is_miss,
	
	// input from processor.v
	input  [63:0]					proc2Dcache_addr,
	input  BUS_COMMAND				proc2Dcache_command,
	input  [63:0] 					proc2Dcache_data,	
	
	// output to mem.v
	output BUS_COMMAND				proc2Dmem_command,
	output logic [63:0]				proc2Dmem_addr,
	
	// output to processor.v
	output logic [63:0]				Dcache_data_out,	 
	output logic [3:0]				Dcache2proc_tag,	 	// to tell processor the tag of the previous load which is finished
	output logic [3:0]				Dcache2proc_response,	// to tell processor the tag of present load
	output logic 					Dcache_data_hit,

	// output to Dcache.v
	output logic [`INDEX_SIZE-1:0]  index,
	output logic [`TAG_SIZE-1:0]	tag,  
	output logic					read_enable,
	output logic					write_enable,     
	output logic [63:0]				write_data_to_Dcache,	// data that send to dcache.v
	output logic [3:0]				mem_response,
	output logic [3:0]				mem_tag,
	output logic					invalid_cache_block,
	output logic					invalid_index,
	output logic					invalid_tag
);

	logic							invalid_cache_block_next;
	logic							invalid_index_next;
	logic							invalid_tag_next;
		
	// output to dcache.v
	assign {tag, index} 				= proc2Dcache_addr[63:`BLOCK_OFFSET];
	assign data_to_Dcache 	 			= proc2Dcache_data;
	
	// output to mem.v
	assign proc2Dmem_addr 	 			= {proc2Dcache_addr[63:0],3'b0};
	
	always_ff@(posedge clock)
	begin
		if (reset)
		begin
			invalid_cache_block 		<= `SD 1'b0;
			invalid_index				<= `SD 0;
			invalid_tag					<= `SD 0;
		end
		else
		begin
			invalid_cache_block 		<= `SD invalid_cache_block_next;
			invalid_index				<= `SD index;
			invalid_tag					<= `SD tag;
		end
	end
	
	always_comb
	begin
		case(proc2Dcache_command)
			BUS_LOAD:
				begin
					// to dcache.v
					read_enable 		    	 = 1'b1;
					write_enable			 	 = 0;    
					if (cachemem_is_miss && (!cache_is_dirty))
					begin
						// to mem.v
						proc2Dmem_command 		 = BUS_LOAD;
						proc2Dmem_addr 	 		 = {proc2Dcache_addr[63:0],3'b0};
						// to dcache.v
						// for present inst
						mem_response	  		 = Dmem2proc_response;
						invalid_cache_block_next = 1'b0;
						// for previous inst
						mem_tag			  	 	 = Dmem2proc_tag;
						// to proc.v
						// for current instruction
						Dcache2proc_response 	 = Dmem2proc_response;
						Dcache_data_hit		 	 = 0;
						// for previous instruction
						Dcache_data_out  		 = Dmem2proc_data;
						Dcache2proc_tag  		 = Dmem2proc_tag;
					end
					else if (cachemem_is_miss && cache_is_dirty)
					begin
						// to mem.v
						proc2Dmem_command		 = BUS_STORE;
						proc2Dmem_addr 	 		 = {proc2Dcache_addr[63:0],3'b0};
						// to dcache.v
						mem_response			 = Dmem2proc_response;
						mem_tag			  		 = Dmem2proc_tag;
						invalid_cache_block_next = 1'b1;
						// to proc.v
						// for current instruction
						Dcache2proc_response	 = Dmem2proc_response;
						Dcache_data_hit			 = 0;
						// for previous instruction
						Dcache_data_out  	 	 = Dmem2proc_data;
						Dcache2proc_tag  		 = Dmem2proc_tag;
					end
					else if ((cachemem_is_miss==0) && (Dmem2proc_tag!=0))
					begin
						// to mem.v
						proc2Dmem_command		 = BUS_NONE;
						proc2Dmem_addr 	 		 = 0;
						// to dcache.v
						mem_response			 = Dmem2proc_response;
						mem_tag			  		 = Dmem2proc_tag;
						invalid_cache_block_next = 1'b0;
						// to proc.v
						// for current instruction
						Dcache2proc_response	 = Dmem2proc_response;
						Dcache_data_hit			 = 0;
						// for previous instruction
						Dcache_data_out  		 = Dmem2proc_data;
						Dcache2proc_tag  		 = mem_tag;
					end
					else
					begin
						// to mem.v
						proc2Dmem_command		 = BUS_NONE;
						proc2Dmem_addr 	 		 = 0;
						// to dcache.v
						mem_response			 = Dmem2proc_response;
						mem_tag			  		 = Dmem2proc_tag;
						invalid_cache_block_next = 1'b0;
						// to proc.v
						// for current instruction
						Dcache2proc_response	 = Dmem2proc_response;
						Dcache_data_hit			 = 1;
						// for previous instruction
						Dcache_data_out  		 = cachemem_data;
						Dcache2proc_tag  		 = 0;
					end
				end
			BUS_STORE:
				begin
					read_enable 		    	 = 0;
					write_enable			 	 = 1'b1;    
					if (cachemem_is_miss && (!cache_is_dirty))
					begin
						// to mem.v
						proc2Dmem_command 		 = BUS_LOAD;
						proc2Dmem_addr 	 		 = {proc2Dcache_addr[63:0],3'b0};
						// to dcache.v
						mem_response	  		 = Dmem2proc_response;
						mem_tag			  	 	 = Dmem2proc_tag;
						invalid_cache_block_next = 1'b0;
						// to proc.v
						// for current instruction
						Dcache2proc_response 	 = Dmem2proc_response;
						Dcache_data_hit		 	 = 0;
						// for previous instruction
						Dcache_data_out  		 = Dmem2proc_data;
						Dcache2proc_tag  		 = Dmem2proc_tag;
					end
					else if (cachemem_is_miss && cache_is_dirty)
					begin
						// to mem.v
						proc2Dmem_command 		 = BUS_STORE;
						proc2Dmem_addr 	 		 = {proc2Dcache_addr[63:0],3'b0};
						// to dcache.v
						mem_response	  		 = Dmem2proc_response;
						mem_tag			  	 	 = Dmem2proc_tag;
						invalid_cache_block_next = 1'b1;
						// to proc.v
						// for current instruction
						// when Dcache2proc_response=0 and Dcache_data_hit are both 0, 
						// lsq will send the data, tag and index again 
						Dcache2proc_response 	 = Dmem2proc_response;
						Dcache_data_hit		 	 = 0;
						// for previous instruction
						Dcache_data_out  		 = Dmem2proc_data;
						Dcache2proc_tag  		 = Dmem2proc_tag;
					end
					else 
					begin
						// to mem.v
						proc2Dmem_command		 = BUS_NONE;
						proc2Dmem_addr 	 		 = 0;
						// to dcache.v
						mem_response			 = Dmem2proc_response;
						mem_tag			  		 = Dmem2proc_tag;
						invalid_cache_block_next = 1'b0;
						// to proc.v
						// for current instruction
						Dcache2proc_response	 = Dmem2proc_response;
						Dcache_data_hit			 = 1;
						// for previous instruction
						Dcache_data_out  		 = cachemem_data;
						Dcache2proc_tag  		 = 0;
					end
				end	
			BUS_NONE:
				begin
						// to mem.v
						proc2Dmem_command		 = BUS_NONE;
						proc2Dmem_addr 	 		 = 0;
						// to dcache.v
						mem_response			 = Dmem2proc_response;
						mem_tag			  		 = Dmem2proc_tag;
						invalid_cache_block_next = 1'b0;
						// to proc.v
						// for current instruction
						Dcache2proc_response	 = Dmem2proc_response;
						Dcache_data_hit			 = 0;
						// for previous instruction
						Dcache_data_out  		 = cachemem_data;
						Dcache2proc_tag  		 = 0;
				end
		endcase
	end	
endmodule
