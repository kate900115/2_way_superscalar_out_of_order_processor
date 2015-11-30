module test_dcache_mem;
	// input
	logic 									clock;
	logic									reset;
	// input from dcache_controller.v
	logic [`DCACHE_INDEX_SIZE-1:0]			index_in;
	logic [`DCACHE_TAG_SIZE-1:0]     		tag_in;
	logic									read_enable;
	logic									write_enable;
	logic [`DCACHE_BLOCK_SIZE-1:0] 			write_data_in;
	logic [3:0]								mem_response;
	logic [3:0]								mem_tag;
	logic 									store_to_memory_enable;						
	// input from mem.v
	logic [`DCACHE_BLOCK_SIZE-1:0]  		load_data_in;
	
	// output
	// output to mem.v
	logic [`DCACHE_BLOCK_SIZE-1:0] 			store_data_out;
	// output to dcache_controller.v
	logic									data_is_valid;
	logic									data_is_dirty;
	logic									data_is_miss;
	logic [`DCACHE_BLOCK_SIZE-1:0]			read_data_out;
	
	dcache_mem dmem(
		// input
		.clock(clock),
		.reset(reset),
		.index_in(index_in),
		.tag_in(tag_in),
		.read_enable(read_enable),
		.write_enable(write_enable),
		.write_data_in(write_data_in),
		.mem_response(mem_response),
		.mem_tag(mem_tag),
		.store_to_memory_enable(store_to_memory_enable),							
		.load_data_in(load_data_in),
	
		// output
		.store_data_out(store_data_out),
		.data_is_valid(data_is_valid),
		.data_is_dirty(data_is_dirty),
		.data_is_miss(data_is_miss),
		.read_data_out(read_data_out)
	);
	
	always #5 clock = ~clock;
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask
	
	initial 
	begin
		$monitor(" @@@  time:%d, clk:%b, \n\
						store_data_out:%h, \n\
						data_is_valid:%d, \n\
						data_is_dirty:%d, \n\
						data_is_miss:%d,\n\
						read_data_out:%h",//for debug
				$time, clock, 
				store_data_out,data_is_valid,data_is_dirty,data_is_miss,read_data_out);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");
		reset 					= 0;						
		index_in 				= 0;
		tag_in					= 0;
		read_enable				= 0;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 0;
		mem_tag					= 0;
		store_to_memory_enable	= 0;
		load_data_in			= 0;
		
		@(negedge clock);
		$display("@@@ ");
		reset 					= 0;						
		index_in 				= 0;
		tag_in					= 0;
		read_enable				= 0;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 0;
		mem_tag					= 0;
		store_to_memory_enable	= 0;
		load_data_in			= 0;
		
		@(negedge clock);
		
		$finish;
	end
		
endmodule
