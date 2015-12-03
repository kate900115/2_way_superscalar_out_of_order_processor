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

	icache ic(
		// input	
		.clock(clock),
		.reset(reset),
		.proc2Icache_addr(proc2Icache_addr),	
		.proc2Icache_command(proc2Icache_command),
		.Imem2proc_response(Imem2proc_response),
		.Imem2proc_tag(Imem2proc_tag),
		.Imem2proc_data(Imem2proc_data),
		// output
		.proc2Imem_command(proc2Imem_command),
		.proc2Imem_addr(proc2Imem_addr),
		.Icache_data_out(Icache_data_out),
		.Icache_valid_out(Icache_valid_out),
		.Icache2proc_tag(Icache2proc_tag),	 	
		.Icache2proc_response(Icache2proc_response)
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
		$display("@@@ pc request for the first instuction!!");
		reset =1'b0;
		proc2Icache_addr	=64'h0000_0000_0000_0000;
		proc2Icache_command	=BUS_LOAD;
		Imem2proc_response	=1;
		Imem2proc_tag		=0;
		Imem2proc_data		=0;
		
		@(negedge clock);
		$display("@@@ pc request for the second instruction!!");
		proc2Icache_addr	=64'h0000_0000_0000_0008;
		proc2Icache_command	=BUS_LOAD;
		Imem2proc_response	=2;
		Imem2proc_tag		=0;
		Imem2proc_data		=0;
		
		@(negedge clock);
		$display("@@@ pc request for the third instruction!!");
		proc2Icache_addr	=64'h0000_0000_0000_0010;
		proc2Icache_command	=BUS_LOAD;
		Imem2proc_response	=3;
		Imem2proc_tag		=0;
		Imem2proc_data		=0;
		
		@(negedge clock);
		$display("@@@ pc request for the 4th instruction!!");
		proc2Icache_addr	=64'h0000_0000_0000_0018;
		proc2Icache_command	=BUS_LOAD;
		Imem2proc_response	=4;
		Imem2proc_tag		=1;
		Imem2proc_data		=64'h1111_1111_1111_1111;
		
		@(negedge clock);
		$display("@@@ pc request for the 4th instruction!!");
		proc2Icache_addr	=64'h0000_0000_0000_0020;
		proc2Icache_command	=BUS_LOAD;
		Imem2proc_response	=5;
		Imem2proc_tag		=2;
		Imem2proc_data		=64'h2222_2222_2222_2222;
		@(negedge clock);
		$finish;
	end
	
endmodule
