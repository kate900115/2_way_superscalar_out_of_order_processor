module dcache_one_entry(
	input 												reset,
	input												clock,
	input												read_value_enable,
	input												write_value_enable,
	input												load_value_enable,
	input [`TAG_SIZE-1:0]								tag_in,
	input [`DCACHE_BLOCK_SIZE-1:0] 						data_in,
	output logic [`DCACHE_BLOCK_SIZE-1:0] 				data_out,
	output logic [`DCACHE_WAY-1:0]						data_valid,
	output logic [`DCACHE_WAY-1:0][`TAG_SIZE-1:0]		tag_out,
	output logic [`DCACHE_WAY-1:0]						dirty_out,
	output logic [`DCACHE_WAY-1:0]						way_out

);

	logic [`DCACHE_WAY-1:0][`TAG_SIZE-1:0]				data_tag;
	logic [`DCACHE_WAY-1:0][`DCACHE_BLOCK_SIZE-1:0] 	data_stored;
	logic [`DCACHE_WAY-1:0][`TAG_SIZE-1:0]				data_tag_next;
	logic [`DCACHE_WAY-1:0][`DCACHE_BLOCK_SIZE-1:0] 	data_stored_next;
	logic [`DCACHE_WAY-1:0]								dirty_bit;
	logic [`DCACHE_WAY-1:0]								valid_bit;
	logic [`DCACHE_WAY-1:0]								dirty_bit_next;
	logic [`DCACHE_WAY-1:0]								valid_bit_next;

	// for LRU
	logic 												reg_00;
	logic												reg_00_next;
	
	assign dirty_out = dirty_bit;
	assign tag_out   = data_tag;
	assign way_out   = reg_00;

	always_ff@(posedge clock)
	begin
		if(reset)
		begin
			valid 			<= `SD 0;
			dirty_bit 		<= `SD 0;
			data_tag 		<= `SD 0;
			data_stored 	<= `SD 0;
			reg_00			<= `SD 0;
		end
		else
		begin
			valid 			<= `SD valid_bit_next;
			dirty_bit 		<= `SD dirty_bit_next;
			data_tag 		<= `SD data_tag_next;
			data_stored 	<= `SD data_stored_next;
			reg_00			<= `SD reg_00_next;
		end
	end
	
	
	always_comb
	begin
		reg_00_next   		  	  = reg_00;
		
		// read data from cache
		if (read_value_enable)
		begin
			for (int i=0; i<`DCACHE_WAY; i++)
			begin
				if ((tag_in == data_tag[i]) && valid)
				begin
					data_valid    = 1'b1;
					data_out      = data_stored[i];
					reg_00_next   = ~reg_00;
					break;
				end
				else
				begin
					data_valid    = 1'b0;
					data_out      = 0;
				end
			end
		end
		else
		begin
			data_valid			  = 1'b0;
			data_out   			  = 0;
		end

		// write data into cache
		if (write_value_enable)
		begin
			for (int i=0; i<`DCACHE_WAY; i++)
			begin
				if (reg_00==i)
				begin
					data_tag_next[i] 	= tag_in;
					data_stored_next[i]	= data_in;
					dirty_bit_next[i]	= 1'b1;
					reg_00_next   		= ~reg_00;
				end
				else
				begin
					data_tag_next[i] 	= data_tag[i];
					data_stored_next[i]	= data_stored[i];
					dirty_bit_next[i]	= dirty[i];
				end
			end
		end
		else
		begin
			data_tag_next 				= data_tag;
			data_stored_next			= data_stored;
			dirty_bit_next				= dirty_bit;
		end
		
		if (load_data_enable)
		begin
			for (int i=0; i<`DCACHE_WAY; i++)
			begin
				if (reg_00==i)
				begin
					data_tag_next[i] 	= tag_in;
					data_stored_next[i]	= data_in;
					dirty_bit_next[i]	= 1'b0;
					reg_00_next   		= ~reg_00;
				end
				else
				begin
					data_tag_next[i] 	= data_tag[i];
					data_stored_next[i]	= data_stored[i];
					dirty_bit_next[i]	= dirty_bit[i];
				end
			end
		end
	end	
endmodule
