module icachemem(
	input 											clock,
	input											reset,
	// input from icache_controller.v
	input [`ICACHE_INDEX_SIZE-1:0]					index_in,
	input [`ICACHE_TAG_SIZE-1:0]     				tag_in,
	input											read_enable,
	input [3:0]										mem_response,
	input [3:0]										mem_tag,						
	
	// input from mem.v
	input [`ICACHE_BLOCK_SIZE-1:0]  				load_data_in,
	
	// output to icache_controller.v
	output logic									data_is_valid,
	output logic									data_is_miss,
	output logic									cache_is_full,
	//output logic [`ICACHE_BLOCK_SIZE-1:0]			data_out
	output logic [`ICACHE_BLOCK_SIZE-1:0]			read_data,
	output logic load_valid
	);
	
	// internal registers
	logic [`ICACHE_ENTRY_NUM-1:0][`ICACHE_WAY-1:0][`ICACHE_BLOCK_SIZE-1:0]	internal_data;
	logic [`ICACHE_ENTRY_NUM-1:0][`ICACHE_WAY-1:0][`ICACHE_BLOCK_SIZE-1:0]	internal_data_in;
	logic [`ICACHE_ENTRY_NUM-1:0][`ICACHE_WAY-1:0][`ICACHE_TAG_SIZE-1:0] 	internal_tag;
	logic [`ICACHE_ENTRY_NUM-1:0][`ICACHE_WAY-1:0][`ICACHE_TAG_SIZE-1:0] 	internal_tag_in;
		
	logic [`ICACHE_ENTRY_NUM-1:0][`ICACHE_WAY-1:0]							internal_valid;
	logic [`ICACHE_ENTRY_NUM-1:0][`ICACHE_WAY-1:0]							internal_valid_in;
	
	logic [`ICACHE_ENTRY_NUM-1:0][`ICACHE_WAY-1:0][3:0]						internal_response;
	logic [`ICACHE_ENTRY_NUM-1:0][`ICACHE_WAY-1:0][3:0]						internal_response_in;

	//logic [`ICACHE_BLOCK_SIZE-1:0]											read_data;
	
	// for LRU
	logic [`ICACHE_ENTRY_NUM-1:0]											internal_way;
	logic [`ICACHE_ENTRY_NUM-1:0]											internal_way_next;
	
					
	
	always_ff@(negedge clock)
	begin
		if (reset)
		begin
			internal_data 						<= `SD 0;
			internal_tag  						<= `SD 0;
			internal_valid						<= `SD 0;
			internal_response					<= `SD 0;
			internal_way						<= `SD 0;
		//	data_out 							<= `SD 0;
		end
		else
		begin
			internal_data 						<= `SD internal_data_in;
			internal_tag  						<= `SD internal_tag_in;
			internal_valid						<= `SD internal_valid_in;
			internal_response					<= `SD internal_response_in;
			internal_way						<= `SD internal_way_next;
		//	data_out 							<= `SD read_data;
		end
	end
	
	
	always_comb
	begin	
		internal_data_in 						= internal_data;
		internal_tag_in  						= internal_tag;
		internal_valid_in						= internal_valid;
		internal_response_in					= internal_response;
		internal_way_next						= internal_way;
		data_is_valid							= 1'b0;
		data_is_miss							= 1'b0;
		read_data								= load_data_in;
		cache_is_full							= 1'b0;
		load_valid = 0;
		// for read
		if (read_enable)
		begin
			// is data miss?
			for (int j=0; j<`ICACHE_WAY; j++)
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
					//read_data	 		  		= load_data_in;
					internal_way_next[index_in]	= internal_way[index_in];
					data_is_valid 		  		= 1'b0;
					data_is_miss  		  		= 1'b1;
				end
			end 
			
			// if miss, is it dirty?
			if (data_is_miss)
			begin
				if (((internal_way[index_in]==0) && (internal_response[index_in][0]!=0))||
				   ((internal_way[index_in]==1) && (internal_response[index_in][1]!=0)))
				begin
					cache_is_full						= 1'b1;
				end

				if (internal_way[index_in]==0)
				begin
					internal_way_next[index_in]			= 1'b1;
					internal_response_in[index_in][0]	= mem_response;
					internal_tag_in[index_in][0]		= tag_in;
					internal_valid_in[index_in][0] 		= 1'b0;
				end
				else  if (internal_way[index_in]==1)
				begin
					internal_way_next[index_in]			= 1'b0;
					internal_response_in[index_in][1]	= mem_response;
					internal_tag_in[index_in][1]		= tag_in;
					internal_valid_in[index_in][1] 		= 1'b0;
				end
			end
		end
		
		// load from memory
		for (int i=0; i<`ICACHE_ENTRY_NUM; i++)
		begin
			for (int j=0; j<`ICACHE_WAY; j++)
			begin
				if ((mem_tag == internal_response[i][j]) && (mem_tag!=0))
				begin
					internal_data_in[i][j] 			= load_data_in;
					internal_valid_in[i][j]			= 1'b1;
					internal_response_in[i][j]		= 0;
					load_valid 						=0;
					//read_data						= load_data_in;
					//internal_way_next[i]			= ~j;
					break;
				end
			end
		end
	end
endmodule
