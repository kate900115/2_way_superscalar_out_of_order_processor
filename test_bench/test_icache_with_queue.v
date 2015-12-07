module test_icache_with_queue;
	logic									clock;
	logic									reset;
	// input from processor.v
	logic	[63:0]							proc2Icache_addr;	
	BUS_COMMAND								proc2Icache_command;
	logic  									branch_mispredict;
	
	// input from memory
	logic	[3:0]							Imem2proc_response;
	logic	[3:0]							Imem2proc_tag;
	logic	[`ICACHE_BLOCK_SIZE-1:0]		Imem2proc_data;
	
	// output to mem.v
	BUS_COMMAND								proc2Imem_command;
	logic	[63:0]							proc2Imem_addr;
	
	// output to processor.v
	logic	[63:0]							Icache2proc_data;
	logic									Icache2proc_valid;
	logic	[63:0]							Icache_address_out;
	logic									Icache_buffer_full;
	
	icache_with_queue ica(
		.clock(clock),
		.reset(reset),
		.proc2Icache_addr(proc2Icache_addr),	
		.proc2Icache_command(proc2Icache_command),
		.branch_mispredict(branch_mispredict),
		.Imem2proc_response(Imem2proc_response),
		.Imem2proc_tag(Imem2proc_tag),
		.Imem2proc_data(Imem2proc_data),
	
		// output
		.proc2Imem_command(proc2Imem_command),
		.proc2Imem_addr(proc2Imem_addr),
		.Icache2proc_data(Icache2proc_data),
		.Icache_address_out(Icache_address_out),
		.Icache2proc_valid(Icache2proc_valid),
		.Icache_buffer_full(Icache_buffer_full)
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
				   @@@	input: \n\
						proc2Icache_addr:%h, \n\
						proc2Icache_command:%d, \n\
						branch_mispredict:%b, \n\
						Imem2proc_response:%b, \n\
						Imem2proc_tag:%b, \n\
						Imem2proc_data:%h, \n\
				   @@@  output: \n\
				   		proc2Imem_command:%b,\n\
						proc2Imem_addr:%h,\n\
						Icache2proc_data:%h,\n\
						Icache2proc_valid:%b,\n\
						Icache_address_out:%h,\n\
						Icache_buffer_full:%b",
				$time, clock, 
				proc2Icache_addr,proc2Icache_command,branch_mispredict,Imem2proc_response,Imem2proc_tag,Imem2proc_data,
				proc2Imem_command,proc2Imem_addr,Icache2proc_data,Icache2proc_valid,Icache_address_out,Icache_buffer_full);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1'b1;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");
		$display("@@@ pc request for the first instuction!!");
		reset 				= 1'b0;
		proc2Icache_addr	= 64'h0000_0000_0000_0000;
		proc2Icache_command	= 0;
		branch_mispredict	= 0;
		Imem2proc_response	= 0;
		Imem2proc_tag		= 0;
		Imem2proc_data		= 0;
		@(negedge clock);
		$finish;
	end
endmodule
