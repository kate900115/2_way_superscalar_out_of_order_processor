module test_dcache;
	logic 									clock;
	logic									reset;
	// input from Mem.v
	logic  [3:0] 							Dmem2proc_response;
	logic  [3:0] 							Dmem2proc_tag;
	logic  [`DCACHE_BLOCK_SIZE-1:0]			Dmem2proc_data;
	// input from processor.v
	logic  [63:0]							proc2Dcache_addr;
	BUS_COMMAND						proc2Dcache_command;
	logic  [`DCACHE_BLOCK_SIZE-1:0] 		proc2Dcache_data;
	// output to mem.v
	BUS_COMMAND								proc2Dmem_command;
	logic [63:0]							proc2Dmem_addr;
	logic [`DCACHE_BLOCK_SIZE-1:0]			proc2Dmem_data;
	// output to processor.v
	logic [`DCACHE_BLOCK_SIZE-1:0]			Dcache2proc_data;	 
	logic [3:0]								Dcache2proc_tag;	 	// to tell processor the tag of the previous load which is finished
	logic [3:0]								Dcache2proc_response;	// to tell processor the tag of present load
	logic 									Dcache_data_hit;

	dcache dc(
		// input
		.clock(clock),
		.reset(reset),
		.Dmem2proc_response(Dmem2proc_response),
		.Dmem2proc_tag(Dmem2proc_tag),
		.Dmem2proc_data(Dmem2proc_data),
		.proc2Dcache_addr(proc2Dcache_addr),
		.proc2Dcache_command(proc2Dcache_command),
		.proc2Dcache_data(proc2Dcache_data),
		// output
		.proc2Dmem_command(proc2Dmem_command),
		.proc2Dmem_addr(proc2Dmem_addr),
		.proc2Dmem_data(proc2Dmem_data),
		.Dcache2proc_data(Dcache2proc_data),	 
		.Dcache2proc_tag(Dcache2proc_tag),	 	
		.Dcache2proc_response(Dcache2proc_response),
		.Dcache_data_hit(Dcache_data_hit)
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
						Dmem2proc_response:%d, \n\
						Dmem2proc_tag:%d,\n\
						Dmem2proc_data:%h,\n\
						proc2Dcache_addr:%h,\n\
						proc2Dcache_command:%b,\n\
						proc2Dcache_data:%h,\n\
				   @@@  output: \n\
						proc2Dmem_command:%b, \n\
						proc2Dmem_addr:%h, \n\
						proc2Dmem_data:%h, \n\
						Dcache2proc_data:%d,\n\
						Dcache2proc_tag:%b,\n\
						Dcache2proc_response:%b,\n\
						Dcache_data_hit:%b",
				$time, clock, 
				Dmem2proc_response,Dmem2proc_tag,Dmem2proc_data,proc2Dcache_addr,proc2Dcache_command,proc2Dcache_data,
				proc2Dmem_command,proc2Dmem_addr,proc2Dmem_data,Dcache2proc_data,Dcache2proc_tag,Dcache2proc_response,Dcache_data_hit);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1'b1;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");
		$display("@@@ first data in!!");
		reset				= 1'b0;
		Dmem2proc_response	= 4'b0001;
		Dmem2proc_tag		= 0;
		Dmem2proc_data		= 0;
		proc2Dcache_addr	= 64'h0000_0000_0000_1230;
		proc2Dcache_command = BUS_LOAD;
		proc2Dcache_data	= 64'h0;
		
		@(negedge clock);
		$display("@@@ !!");
		Dmem2proc_response	= 0;
		Dmem2proc_tag		= 0;
		Dmem2proc_data		= 0;
		proc2Dcache_addr	= 0;
		proc2Dcache_command = 0;
		proc2Dcache_data	= 0;
		@(negedge clock);
		$finish;
	end
endmodule
