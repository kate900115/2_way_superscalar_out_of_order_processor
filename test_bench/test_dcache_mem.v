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
	logic									cache_is_full;
	
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
		.load_data_in(load_data_in),
	
		// output
		.store_data_out(store_data_out),
		.data_is_valid(data_is_valid),
		.data_is_dirty(data_is_dirty),
		.data_is_miss(data_is_miss),
		.data_out(read_data_out),
		.cache_is_full(cache_is_full)
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
						read_data_out:%h,\n\
						cache_is_full:%b",//for debug
				$time, clock, 
				store_data_out,data_is_valid,data_is_dirty,data_is_miss,read_data_out,cache_is_full);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");
		$display("@@@ the first request send in, miss, not dirty");
		$display("@@@ index=2, tag=1");
		reset 					= 0;						
		index_in 				= 4'b0010;
		tag_in					= 54'h0_0000_0000_0001;
		read_enable				= 1'b1;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 4'b0001;
		mem_tag					= 0;
		load_data_in			= 0;
		
		@(negedge clock);
		$display("@@@ the second request send in, miss, not dirty");
		$display("@@@ index=3, tag=2");
		reset 					= 0;						
		index_in 				= 4'b0011;
		tag_in					= 54'h0_0000_0000_0002;
		read_enable				= 1'b1;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 4'b0010;
		mem_tag					= 0;
		load_data_in			= 0;
		
		@(negedge clock);
		$display("@@@ the third request send in, miss, not dirty");
		$display("@@@ index=4, tag=3");
		reset 					= 0;						
		index_in 				= 4'b0100;
		tag_in					= 54'h0_0000_0000_0003;
		read_enable				= 1'b1;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 4'b0011;
		mem_tag					= 0;
		load_data_in			= 0;
		
		@(negedge clock);
		$display("@@@ the 4th request send in, miss, not dirty");
		$display("@@@ index=5, tag=4");
		$display("@@@ the first result return");
		reset 					= 0;						
		index_in 				= 4'b0101;
		tag_in					= 54'h0_0000_0000_0004;
		read_enable				= 1'b1;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 4'b0100;
		mem_tag					= 4'b0001;
		load_data_in			= 64'h0000_0000_0000_ffff;
		
		@(negedge clock);
		$display("@@@ the 5th request send in, miss, not dirty");
		$display("@@@ index=6, tag=1");
		$display("@@@ the second result return");
		reset 					= 0;						
		index_in 				= 4'b0110;
		tag_in					= 54'h0_0000_0000_0001;
		read_enable				= 1'b1;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 4'b0101;
		mem_tag					= 4'b0010;
		load_data_in			= 64'h0000_0000_0000_abcd;
		
		@(negedge clock);
		$display("@@@ the 6th request send in, not miss, not dirty");
		$display("@@@ index=2, tag=1");
		reset 					= 0;						
		index_in 				= 4'b0010;
		tag_in					= 54'h0_0000_0000_0001;
		read_enable				= 1'b1;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 4'b0000;
		mem_tag					= 4'b0000;
		load_data_in			= 64'h0000_0000_0000_0000;
		
		@(negedge clock);
		$display("@@@ the 7th request send in, not miss, not dirty");
		$display("@@@ index=3, tag=2, it is write!");
		$display("@@@ the third result return");
		reset 					= 0;						
		index_in 				= 4'b0011;
		tag_in					= 54'h0_0000_0000_0002;
		read_enable				= 1'b0;
		write_enable			= 1'b1;
		write_data_in			= 64'h0000_0000_0000_cccc;
		mem_response			= 4'b0000;
		mem_tag					= 4'b0011;
		load_data_in			= 64'h0000_0000_0000_bcde;
		
		@(negedge clock);
		$display("@@@ the 8th request send in, not miss, dirty");
		$display("@@@ index=3, tag=2, it is read!");
		reset 					= 0;						
		index_in 				= 4'b0011;
		tag_in					= 54'h0_0000_0000_0002;
		read_enable				= 1'b1;
		write_enable			= 1'b0;
		write_data_in			= 0;
		mem_response			= 4'b0000;
		mem_tag					= 4'b0000;
		load_data_in			= 64'h0000_0000_0000_0000;
		
		@(negedge clock);
		$display("@@@ the 9th request send in, miss, not dirty");
		$display("@@@ index=3, tag=5, it is read! ");
		$display("@@@ the fourth result return");
		reset 					= 0;						
		index_in 				= 4'b0011;
		tag_in					= 54'h0_0000_0000_0005;
		read_enable				= 1'b1;
		write_enable			= 1'b0;
		write_data_in			= 0;
		mem_response			= 4'b0001;
		mem_tag					= 4'b0100;
		load_data_in			= 64'h0000_0000_5678_1234;
		
		@(negedge clock);
		$display("@@@ the 10th request send in, miss, not dirty");
		$display("@@@ index=14, tag=9, it is write!");
		$display("@@@ the fifth result return");
		reset 					= 0;						
		index_in 				= 4'b1110;
		tag_in					= 54'h0_0000_0000_0009;
		read_enable				= 1'b0;
		write_enable			= 1'b1;
		write_data_in			= 64'h0000_0000_0010_0111;
		mem_response			= 4'b0000;
		mem_tag					= 4'b0101;
		load_data_in			= 64'h0000_0000_1234_1234;
		
		@(negedge clock);
		$display("@@@ send in the write instruction again");
		$display("@@@ index=14, tag=9, it is write!");
		$display("@@@ the sixth result return");
		reset 					= 0;						
		index_in 				= 4'b1110;
		tag_in					= 54'h0_0000_0000_0009;
		read_enable				= 1'b0;
		write_enable			= 1'b1;
		write_data_in			= 64'h0000_0000_0010_0111;
		mem_response			= 4'b1110;
		mem_tag					= 4'b0001;
		load_data_in			= 64'h0000_0000_7777_7007;
		
		@(negedge clock);
		$display("@@@ send in the write instruction again");
		$display("@@@ index=14, tag=9, it is write!");
		$display("@@@ the result is hitted");
		reset 					= 0;						
		index_in 				= 4'b1110;
		tag_in					= 54'h0_0000_0000_0009;
		read_enable				= 1'b0;
		write_enable			= 1'b1;
		write_data_in			= 64'h0000_0000_0010_0111;
		mem_response			= 4'b0000;
		mem_tag					= 4'b1110;
		load_data_in			= 64'h0000_0000_cccc_7007;
		
		@(negedge clock);
		$display("@@@ the 11st request send in, miss, not dirty");
		$display("@@@ index=15, tag=6, it is read!");
		reset 					= 0;						
		index_in 				= 4'b1111;
		tag_in					= 54'h0_0000_0000_0006;
		read_enable				= 1'b1;
		write_enable			= 1'b0;
		write_data_in			= 64'h0;
		mem_response			= 4'b1001;
		mem_tag					= 4'b0000;
		load_data_in			= 64'h0;
		
		@(negedge clock);
		$display("@@@ the 12nd request send in, miss, not dirty");
		$display("@@@ index=15, tag=3, it is read!");
		reset 					= 0;						
		index_in 				= 4'b1111;
		tag_in					= 54'h0_0000_0000_0003;
		read_enable				= 1'b1;
		write_enable			= 1'b0;
		write_data_in			= 64'h0;
		mem_response			= 4'b1101;
		mem_tag					= 4'b0000;
		load_data_in			= 64'h0;
		
		@(negedge clock);
		$display("@@@ the 12nd request send in, miss, not dirty");
		$display("@@@ index=15, tag=2, it is read!");
		reset 					= 0;						
		index_in 				= 4'b1111;
		tag_in					= 54'h0_0000_0000_0002;
		read_enable				= 1'b1;
		write_enable			= 1'b0;
		write_data_in			= 64'h0;
		mem_response			= 4'b0000;
		mem_tag					= 4'b0000;
		load_data_in			= 64'h0;
		
		@(negedge clock);
		reset 					= 0;						
		index_in 				= 0;
		tag_in					= 0;
		read_enable				= 0;
		write_enable			= 0;
		write_data_in			= 0;
		mem_response			= 0;
		mem_tag					= 0;
		load_data_in			= 0;
		@(negedge clock);
		$finish;
	end
		
endmodule
