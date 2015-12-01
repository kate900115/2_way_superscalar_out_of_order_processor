module cachemem(

	input			wr_en,
	input	[21:0]		wr_tag,
	input	[6:0]		wr_idx,
	input	[21:0]		rd_tag,
	input	[6:0]		rd_idx,
	input	[63:0]		wr_data,
	output	logic		rd_valid,
	output	logic	[63:0]	rd_data
	
);

	logic	[63:0]	cache_memory	[`CACHE_64BIT_LINES -1: 0];
	logic	[21:0]	cache_tag	[`CACHE_64BIT_LINES -1: 0];	
	logic		if_cache_hit;
	logic	[63:0]	next_write_data;
	logic	[6:0]	next_write_tag;

	assign	if_cache_hit= (rd_tag == cache_tag[rd_idx]);
	
	
	assign	rd_data	= if_cache_hit? cache_memory[rd_idx] : 0;		//if rd_tag = cache_tag[rd_idx], read data according to index
	
	assign	next_write_data = wr_en? wr_data : 0;
	assign	next_write_tag  = wr_en? wr_tag;
	
	always_ff
	begin
		for(int	i=0; i<`CACHE_64BIT_LINES;i=i+1)
		begin
			if( wr_en && wr_idx == i )
			begin
			cache_memory[i] <= next_write_data;				//initialize cashe_memory
			cache_tag[i]	<= next_write_tag;
			end
		end

	end




	initial	
	begin
		for(int	i=0; i<`CACHE_64BIT_LINES;i=i+1)
		begin
			cache_memory[i] = 64'h0;				//initialize cashe_memory
		end

	end
		





endmodule


//`define	CACHE_64BIT_LINES	128
