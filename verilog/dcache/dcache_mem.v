module dcache_mem(
	input 											clock,
	input											reset,
	// input from dcache_controller.v
	input [`DCACHE_INDEX_SIZE-1:0]					index_in,
	input [`DCACHE_TAG_SIZE-1:0]     				tag_in,
	input											read_enable,
	input											write_enable,
	input [`DCACHE_BLOCK_SIZE-1:0] 					write_data_in,
	input [3:0]										mem_response,
	input [3:0]										mem_tag,
	input 											store_to_memory_enable,							
	
	// input from mem.v
	input [`DCACHE_BLOCK_SIZE-1:0]  				load_data_in,
	
	// output to mem.v
	output logic[`DCACHE_BLOCK_SIZE-1:0] 			store_data_out,
	
	// output to dcache_controller.v
	output logic									data_is_valid,
	output logic									data_is_dirty,  // data which need to be replaced is dirty
	output logic									data_is_miss,
	output logic [`DCACHE_BLOCK_SIZE-1:0]			read_data_out
	);
	
	// internal registers
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0][`DCACHE_BLOCK_SIZE-1:0]	internal_data;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0][`DCACHE_BLOCK_SIZE-1:0]	internal_data_in;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0][`DCACHE_TAG_SIZE-1:0] 	internal_tag;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0][`DCACHE_TAG_SIZE-1:0] 	internal_tag_in;
		
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0]							internal_valid;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0]							internal_valid_in;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0]							internal_dirty;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0]							internal_dirty_in;
	
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0][3:0]						internal_response;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0][3:0]						internal_response_in;
	
	// to record if it is a load or a store instruction
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0]							internal_load_inst;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0]							internal_load_inst_in;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0]							internal_store_inst;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0][`DCACHE_WAY-1:0]							internal_store_inst_in;
	
	logic [63:0]																	read_data;
	
	// for LRU
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0]											internal_way;
	logic [`DCACHE_INDEX_ENTRY_SIZE-1:0]											internal_way_next;
	
					
	
	always_ff@(posedge clock)
	begin
		if (reset)
		begin
			internal_data 						<= `SD 0;
			internal_tag  						<= `SD 0;
			internal_valid						<= `SD 0;
			internal_dirty  					<= `SD 0;
			internal_response					<= `SD 0;
			internal_way						<= `SD 0;
			internal_load_inst					<= `SD 0;
			internal_store_inst 				<= `SD 0;
		end
		else
		begin
			internal_data 						<= `SD internal_data_in;
			internal_tag  						<= `SD internal_tag_in;
			internal_valid						<= `SD internal_valid_in;
			internal_dirty 	 					<= `SD internal_dirty_in;
			internal_response					<= `SD internal_response_in;
			internal_way						<= `SD internal_way_next;
			internal_load_inst					<= `SD internal_load_inst_in;
			internal_store_inst 				<= `SD internal_store_inst_in;
		end
	end
	
	
	always_comb
	begin	
		internal_data_in 						= internal_data;
		internal_tag_in  						= internal_tag;
		internal_valid_in						= internal_valid;
		internal_dirty_in 						= internal_dirty;
		internal_response_in					= internal_response;
		internal_way_next						= internal_way;
		internal_load_inst_in					= internal_load_inst;
		internal_store_inst_in 					= internal_store_inst;
		data_is_valid							= 0;
		data_is_miss							= 0;
		data_is_dirty 							= 0;
		store_data_out							= 0;
		read_data_out							= 0;
		read_data								= 0;
		// store to memory
		if (store_to_memory_enable)
		begin
			for (int j=0; j<`DCACHE_WAY; j++)
			begin
				if (internal_way[j]==1)
				begin
					store_data_out 				   = internal_data[index_in][j];
					internal_valid_in[index_in][j] = 1'b0;
					internal_way_next[j]		   = ~j;
					break;
				end
				else
				begin
					store_data_out 				   = 0;
					internal_valid_in[index_in][j] = internal_valid[index_in][j];
					internal_way_next[j]		   = internal_way[j];
				end
			end
		end	 
	
		// for read
		if (read_enable)
		begin
			// is data miss?
			for (int j=0; j<`DCACHE_WAY; j++)
			begin
				if ((tag_in==internal_tag[index_in][j]) && (internal_valid[index_in][j]))
				begin
					read_data	 		  		= internal_data[index_in][j];
					internal_way_next[index_in]	= ~j;
					data_is_valid 		  		= 1'b1;
					data_is_miss  		  		= 1'b0;
					break;
				end
				else
				begin
					read_data	 		  		= load_data_in;
					internal_way_next[index_in]	= internal_way[index_in];
					data_is_valid 		  		= 1'b0;
					data_is_miss  		  		= 1'b1;
				end
			end 
			
			// if miss, is it dirty?
			if (data_is_miss)
			begin
				if ((internal_way[index_in]==0)&&(internal_dirty[index_in][0]))
				begin
					internal_response_in[index_in][0]	= 0; //?
					internal_tag_in[index_in][0]		= internal_tag[index_in][0];
					internal_valid_in[index_in][0]      = internal_valid[index_in][0];
					data_is_dirty			  			= 1'b1;
					internal_load_inst_in[index_in][0]	= 1'b1;
					internal_store_inst_in[index_in][0]	= 1'b0;
				end
				else if ((internal_way[index_in]==1)&&(internal_dirty[index_in][1]))
				begin
					internal_response_in[index_in][1]	= 0; //?
					internal_tag_in[index_in][1]		= internal_tag[index_in][1];
					internal_valid_in[index_in][1] 		= internal_valid[index_in][1];
					data_is_dirty			  			= 1'b1;
					internal_load_inst_in[index_in][1]	= 1'b1;
					internal_store_inst_in[index_in][1]	= 1'b0;
				end
				else if ((internal_way[index_in]==0)&&(!internal_dirty[index_in][0]))
				begin
					internal_response_in[index_in][0]	= mem_response;
					internal_tag_in[index_in][0]		= tag_in;
					internal_valid_in[index_in][0] 		= 1'b0;
					data_is_dirty			  			= 1'b0;
					internal_load_inst_in[index_in][0]	= 1'b1;
					internal_store_inst_in[index_in][0]	= 1'b0;
				end
				else
				begin
					internal_response_in[index_in][1]	= mem_response;
					internal_tag_in[index_in][1]		= tag_in;
					internal_valid_in[index_in][0] 		= 1'b0;
					data_is_dirty			  			= 1'b0;
					internal_load_inst_in[index_in][1]	= 1'b1;
					internal_store_inst_in[index_in][1]	= 1'b0;
				end
			end
		end
		
		// load from memory
		for (int i=0; i<`DCACHE_INDEX_SIZE*`DCACHE_WAY; i++)
		begin
			if ((mem_tag == internal_response[i]) && (mem_tag!=0) && (internal_load_inst[i])) 
			begin
				internal_data_in[i] 			= load_data_in;
				internal_valid_in[i]			= 1'b1;
				internal_dirty_in[i]			= 1'b0;
				internal_response_in[i]			= 0;
				if (i%`DCACHE_WAY==0)
				begin
					internal_way_next[i/2]		=1'b1;
				end
				else
				begin
					internal_way_next[i/2]		=1'b0;
				end
				read_data_out					= load_data_in;
				break;
			end
			else if ((mem_tag == internal_response[i]) && (mem_tag!=0) && (internal_store_inst[i]))
			begin
				internal_data_in[i] 			= write_data_in;
				internal_valid_in[i]			= 1'b1;
				internal_dirty_in[i]			= 1'b1;
				internal_response_in[i]			= 0;
				read_data_out					= read_data;
				if (i%`DCACHE_WAY==0)
				begin
					internal_way_next[i/2]		=1'b1;
				end
				else
				begin
					internal_way_next[i/2]		=1'b0;
				end
				break;
			end
			else
			begin
				read_data_out					= read_data;
			end
		end
		
		/*for (int i=0; i<`DCACHE_INDEX_SIZE; i++)
		begin
			for (int j=0; j<`DCACHE_WAY; j++)
			begin
				if ((mem_tag == internal_response[i][j]) && (mem_tag!=0) && (internal_load_inst[i][j]))
				begin
					internal_data_in[i][j] 			= load_data_in;
					internal_valid_in[i][j]			= 1'b1;
					internal_dirty_in[i][j]			= 1'b0;
					internal_response_in[i]			= 0;
					read_data_out					= load_data_in;
					break;
				end
				else if ((mem_tag == internal_response[i][j]) && (mem_tag!=0) && (internal_store_inst[i][j]))
				begin
					internal_data_in[i][j] 			= write_data_in;
					internal_valid_in[i][j]			= 1'b1;
					internal_dirty_in[i][j]			= 1'b1;
					internal_response_in[i]			= 0;
					read_data_out					= load_data_in;
					break;
				end
				else
				begin
					internal_data_in[i][j] 			= internal_data[i][j];
					internal_valid_in[i][j]			= internal_valid[i][j];
					internal_dirty_in[i][j]			= internal_dirty[i][j];
					internal_response_in[i][j]		= internal_response[i][j];
					read_data_out					= load_data_in;
				end 
			end
		end*/
		
		// for write
		if (write_enable)
		begin
			for (int j=0; j<`DCACHE_WAY; j++)
			begin
				if ((tag_in==internal_tag[index_in][j]) && (internal_valid[index_in][j]))
				begin
					internal_data_in[index_in][j] 	= write_data_in;
					internal_tag_in[index_in][j]	= tag_in;
					internal_dirty_in[index_in][j] 	= 1'b1;
					internal_way_next[index_in]		= ~j;
					data_is_valid 		    		= 1'b1;
					data_is_miss  		  			= 1'b0;
					break;
				end
				else
				begin
					internal_data_in[index_in][j]	= internal_data[index_in][j];
					internal_tag_in[index_in][j]	= internal_tag[index_in][j];
					internal_dirty_in[index_in][j] 	= internal_dirty[index_in][j];
					internal_way_next[index_in]		= internal_way[index_in];
					data_is_valid 		 			= 1'b0;
					data_is_miss  		 			= 1'b1;
				end
			end
			
			if (data_is_miss)
			begin
				if ((internal_way==0) && (internal_dirty[index_in][0])) 
				begin
					internal_response_in[index_in][0]	= 0; //?
					internal_tag_in[index_in][0]		= internal_tag[index_in][0];
					data_is_dirty			  			= 1'b1;
					internal_load_inst_in[index_in][0]	= 1'b0;
					internal_store_inst_in[index_in][0]	= 1'b1;
				end
				else if ((internal_way==1) && (internal_dirty[index_in][1]))
				begin
					internal_response_in[index_in][1]	= 0; //?
					internal_tag_in[index_in][1]		= internal_tag[index_in][1];
					data_is_dirty			  			= 1'b1;
					internal_load_inst_in[index_in][1]	= 1'b0;
					internal_store_inst_in[index_in][1]	= 1'b1;
				end
				else if ((internal_way==0) && (!internal_dirty[index_in][0]))
				begin
					internal_response_in[index_in][0]	= mem_response;
					internal_tag_in[index_in][0]		= tag_in;
					data_is_dirty			  			= 1'b0;
					internal_load_inst_in[index_in][0]	= 1'b0;
					internal_store_inst_in[index_in][0]	= 1'b1;
				end
				else
				begin
					internal_response_in[index_in][1]	= mem_response;
					internal_tag_in[index_in][1]		= tag_in;
					data_is_dirty			  			= 1'b0;
					internal_load_inst_in[index_in][1]	= 1'b0;
					internal_store_inst_in[index_in][1] = 1'b1;
				end
			end
		end
	end
endmodule
