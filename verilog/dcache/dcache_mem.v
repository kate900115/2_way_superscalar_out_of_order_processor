module dcache(
	// input from dcache_controller.v
	input 											write_from_mem_enable,
	input											write_back_enable,
	input [`TAG_SIZE-1:0]							write_tag,
	input [`INDEX_SIZE-1:0]							write_index,
	input [`TAG_SIZE-1:0]     						read_tag,
	input [`INDEX_SIZE-1:0]   						read_index,
	input [`DCACHE_BLOCK_SIZE-1:0] 					write_data_in,
	input											read_enable,
	input											write_enable,
	
	// input from mem.v
	input [`DCACHE_BLOCK_SIZE-1:0]  				load_data_in,
	
	// output to mem.v
	output [`DCACHE_BLOCK_SIZE-1:0] 				store_data_out,
	
	// output to dcache_controller.v
	output logic									read_data_valid,
	output logic									read_data_dirty,
	output logic [63:0]								read_data_out
	);
	
	// internal input
	logic [`INDEX_SIZE-1:0]							internal_read_value_enable;
	logic [`INDEX_SIZE-1:0]							internal_write_value_enable;
	logic [`INDEX_SIZE-1:0]							internal_load_value_enable;
	
	// internal output
	logic [`INDEX_SIZE-1:0][63:0]					internal_data_out;	
	logic [2*`INDEX_SIZE-1:0]						internal_data_valid;
	logic [2*`INDEX_SIZE-1:0]						internal_dirty_out;
	logic [2*`INDEX_SIZE-1:0][`INDEX_SIZE-1:0] 		internal_tag_out;
	logic [`INDEX_SIZE-1:0]							internal_way_out;
	
	dcache_one_entry doe[`INDEX_SIZE:0](
		// input
		.reset(reset),
		.clock(clock),
		.read_value_enable(internal_read_value_enable),
		.write_value_enable(internal_write_value_enable),
		.load_value_enable(internal_load_value_enable),
		.tag_in(tag_in),
		.data_in(data_in),
		
		// output
		.data_out(internal_data_out),
		.data_valid(internal_data_valid),
		.tag_out(internal_tag_out),
		.dirty_out(internal_dirty_out),
		.way_out(internal_way_out)
	);
	
	
	always_comb
	begin
		// for read
		if (read_enable)
		begin
			for (int i; i<`INDEX_SIZE; i++)
			begin
				if (read_index==i) 
				begin
					for (int j; j<`DCACHE_WAY; j++)
					begin
						if ((internal_dirty_out[i][j]==0) && (tag_in==internal_tag_out[i]))
						begin
							internal_read_value_enable[i] = 1'b1;
							read_data_out			  	  = internal_data_out[i];
							read_data_valid			  	  = internal_data_valid[i];
							read_data_dirty			  	  = 1'b0;
							break;
						end
						else
						begin
							internal_read_value_enable[i] = 0;
							read_data_out			  	  = 0;
							read_data_valid			  	  = 0;
							read_data_dirty			  	  = 1'b1;
						end
					end
				end //((read_index==i) && (tag_in==internal_tag_out[i]))
				else
				begin
					internal_read_value_enable[i] = 0;
					read_data_out			  	  = 0;
					read_data_valid			  	  = 0;
					read_data_dirty			  	  = 1'b0;
				end
			end //if (read_index==i) 
		end //for (int i; i<`INDEX_SIZE; i++)
		else
		begin
			internal_read_value_enable	  		  = 0;
			read_data_out			  	  		  = 0;
			read_data_valid			  	          = 0;
			read_data_dirty			  	  		  = 0;
		end
	
		// for write
		if (write_enable)
		begin
			for (int i; i<`INDEX_SIZE; i++)
			begin
				if (write_index==i)
				begin
					if (internal_way_out[i]==0) && (internal_dirty_out[i][0]==0) 
					begin
						internal_write_value_enable[i] = 1'b1;
						tag_in						   = write_tag;
						data_in						   = write_data_in;
						read_data_dirty				   = 1'b0;
					end
					else if (internal_way_out[i]==1) && (internal_dirty_out[i][1]==0) 
					begin
						internal_write_value_enable[i] = 1'b1;
						tag_in						   = write_tag;
						data_in						   = write_data_in;
						read_data_dirty				   = 1'b0;
					end
					else
					begin
						internal_write_value_enable[i] = 1'b0;
						tag_in						   = 0;
						data_in						   = 0;
						read_data_dirty				   = 1'b1;
					end
				end
				else
				begin
					internal_write_value_enable 	   = 0;
					tag_in						   	   = 0;
					data_in						   	   = 0;
					read_data_dirty				   	   = 0;
				end
			end
		end
		
		// for load
		if (load_from_mem_enable)
		begin
			for (int i; i<`INDEX_SIZE; i++)
			begin
				if (read_index==i) && (read_enable =1'b1)
				begin
					internal_load_value_enable[i]  = 1'b1;
					tag_in						   = read_tag;
					data_in						   = load_data_in;
					break;
				end
				else if (write_index==i)&& (write_enable=1'b1)
				begin
					internal_load_value_enable[i]  = 1'b1;
					tag_in						   = write_tag;
					data_in						   = load_data_in;
					break;
				end
				else
				begin
					internal_load_value_enable[i]  = 0;
					tag_in						   = 0;
					data_in						   = 0;
				end
			end
		end

		if (store_to_mem_enable)
		begin
			for (int i, i<`INDEX_SIZE;i++ )
			begin
				if (read_index==i) && (read_enable)
				begin
					internal_store_value_enable[i] = 1'b1;
					tag_in						   = read_tag;
					store_data_out				   = internal_data_out[i];
					break;
				end
				else if (write_index==i) && (write_enable)
				begin
					internal_store_value_enable[i] = 1'b1;
					tag_in						   = write_tag;
					store_data_out				   = internal_data_out[i];
					break;
				end
				else
				begin
					internal_store_value_enable[i] = 0;
					tag_in						   = 0;
					store_data_out				   = 0;
				end
			end
		end
	end
endmodule
