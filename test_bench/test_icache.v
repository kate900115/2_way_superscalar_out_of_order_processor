module test_icache;
	logic								clock;
	logic								reset;
	// input from processor.v
	logic	[63:0]						proc2Icache_addr;
	BUS_COMMAND							proc2Icache_command;
	// input from memory
	logic	[3:0]						Imem2proc_response;
	logic	[3:0]						Imem2proc_tag;
	logic	[`ICACHE_BLOCK_SIZE-1:0]	Imem2proc_data;
	// output to mem.v
	BUS_COMMAND							proc2Imem_command;
	logic	[63:0]						proc2Imem_addr;
	// output to processor.v
	logic	[63:0]						Icache_data_out;
	logic								Icache_valid_out;
	logic [3:0]							Icache2proc_tag;	 	
	logic [3:0]							Icache2proc_response;

	icache(
		// input	
		clock(clock),
		reset(reset),
		proc2Icache_addr(proc2Icache_addr),	
		proc2Icache_command(proc2Icache_command),
		Imem2proc_response(Imem2proc_response),
		Imem2proc_tag(Imem2proc_tag),
		Imem2proc_data(Imem2proc_data),
		// output
		proc2Imem_command(proc2Imem_command),
		proc2Imem_addr(proc2Imem_addr),
		Icache_data_out(Icache_data_out),
		Icache_valid_out(Icache_valid_out),
		Icache2proc_tag(Icache2proc_tag),	 	
		Icache2proc_response(Icache2proc_response)
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
						proc2Icache_addr:%h ,\n\
						proc2Icache_command:%d,\n\
						Imem2proc_response:%d,\n\
						Imem2proc_tag:%d,\n\
						Imem2proc_data:%h,\n\
				   @@@  output: \n\
				   		proc2Imem_command:%d,\n\
				   		proc2Imem_addr:%h,\n\
				   		Icache_data_out:%h,\n\
				   		Icache_valid_out:%b,\n\
				   		Icache2proc_tag:%d,\n\
				   		Icache2proc_response:%d",
				$time, clock, 
				proc2Icache_addr, proc2Icache_command, Imem2proc_response, Imem2proc_tag, Imem2proc_data,
				proc2Imem_command, proc2Imem_addr, Icache_data_out, Icache_valid_out, Icache2proc_tag, Icache2proc_response);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1'b1;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");
		$display("@@@ first data in!!");
		proc2Icache_addr	=0;
		proc2Icache_command	=0;
		Imem2proc_response	=0;
		Imem2proc_tag		=0;
		Imem2proc_data		=0;
		
		@(negedge clock);
		$display("@@@ !!");
		proc2Icache_addr	=0;
		proc2Icache_command	=0;
		Imem2proc_response	=0;
		Imem2proc_tag		=0;
		Imem2proc_data		=0;
		@(negedge clock);
		$finish;
	end
	
endmodule
