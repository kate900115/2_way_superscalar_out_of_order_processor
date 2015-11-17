module 	test_cachemem();

	logic		clock;
	logic		reset;

	logic		wr_en;
	logic	[21:0]	wr_tag;
	logic	[6:0]	wr_idx;
	logic	[21:0]	rd_tag;
	logic	[6:0]	rd_idx;
	logic	[63:0]	wr_data;
	
	logic		rd_valid;
	logic	[63:0]	rd_data;

	cachemem Icache(
	.clock(clock),
	.reset(reset),
	.wr_en(wr_en),
	.wr_tag(wr_tag),
	.wr_idx(wr_idx),
	.rd_tag(rd_tag),
	.rd_idx(rd_idx),
	.wr_data(wr_data),
	.rd_valid(rd_valid),
	.rd_data(rd_data)
	);
	
	always #10 clock = ~clock;
	initial 
	begin
		
	clock=0;

	wr_en=0;
	wr_tag=0;
	wr_idx=0;
	rd_tag=0;
	rd_idx=0;
	wr_data=0;

	@(negedge clock);
	wr_en=1;
	wr_tag=22'd1;
	wr_idx=7'd1;
	rd_tag=0;
	rd_idx=0;
	wr_data=64'd1;

	@(negedge clock);
	wr_en=1;
	wr_tag=22'd2;
	wr_idx=7'd2;
	rd_tag=0;
	rd_idx=0;
	wr_data=64'd2;

	@(negedge clock); //should hit
	wr_en=0;
	wr_tag=0;
	wr_idx=0;
	rd_tag=22'd1;
	rd_idx=7'd1;
	wr_data=0;

	@(negedge clock);  //should not miss
	wr_en=0;
	wr_tag=0;
	wr_idx=0;
	rd_tag=22'd3;
	rd_idx=7'd2;
	wr_data=0;

	@(negedge clock);
	$finish;
	
		

	end

endmodule
