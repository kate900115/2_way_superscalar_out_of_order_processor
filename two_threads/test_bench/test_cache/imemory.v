module	imemory(
	input			clock,
	input			reset,
	input	[63:0]		proc2Icache_addr,

	output	logic		Imem2proc_valid,
	output	logic	[63:0]	Imem2proc_data,
);

	wire		Imem2proc_response;
	wire	[63:0]	Imem2proc_data;
	wire	[3:0]	Imem2proc_tag;

	wire	[63:0]	cachemem_data;
	wire		cachemem_valid;

	wire	[1:0]	proc2Imem_command;
	wire	[63:0]	proc2Imem_addr;

	wire	[6:0]	current_index;
	wire	[21:0]	current_tag;
	wire	[6:0]	last_index;
	wire	[21:0]	last_tag;
	wire		data_write_enable;


	wire	[63:0]	proc2mem_data;
	
	wire	[63:0]	mem2proc_data;

	Icache_controller controller(										//this is a 128 line direct mapped cashe with 128 lines
	.clock(clock),
	.reset(reset),

	.Imem2proc_response(Imem2proc_response),
	.Imem2proc_data(Imem2proc_data),
	.Imem2proc_tag(Imem2proc_tag),
	
	.proc2Icache_addr(proc2Icache_addr),								//the address of the current instrucion
	.cachemem_data(cachemem_data),
	.cachemem_valid(cachemem_valid),
	
	.proc2Imem_command(proc2Imem_command),
	.proc2Imem_addr(proc2Imem_addr),
	
	.Icache_data_out(Imem2proc_data),
	.Icache_valid_out(Imem2proc_valid),
	
	.current_index(current_index),
	.current_tag(current_tag),
	.last_index(last_index),
	.last_tag(last_tag),
	.data_write_enable(data_write_enable)
	);

	mem mem(
	.clk(clock),
	.proc2mem_addr(proc2Imem_addr),
	.proc2mem_data(proc2mem_data),
	.proc2mem_command(proc2Imem_command),

	.mem2proc_response(Imem2proc_response),
	.mem2proc_data(mem2proc_data),
	.mem2proc_tag(Imem2proc_tag)
	);	

	cachemem Icache(
	.clock(clock),
	.reset(reset),
	.wr_en(data_write_enable),
	.wr_tag(last_tag),
	.wr_idx(last_idx),
	.rd_tag(current_tag),
	.rd_idx(current_idx),
	.wr_data(mem2proc_data),
	.rd_valid(cachemem_valid),
	.rd_data(cachemem_valid)
	);





endmodule


