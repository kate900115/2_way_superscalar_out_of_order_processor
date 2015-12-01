module test_prf_one_entry;
	logic                	     clock;
	logic                	     reset;
	logic			     free_this_entry;
    	logic   [63:0]		     data_in;
	logic                	     write_prf_enable;
	logic                        assign_a_free_reg;
	logic		             prf_available;
	logic	 	             prf_ready;
	logic	[63:0]               data_out;

	prf_one_entry poe(
		//output
		.clock(clock),
		.reset(reset),
	        .free_this_entry(free_this_entry),
    		.data_in(data_in),
		.write_prf_enable(write_prf_enable),
		.assign_a_free_reg(assign_a_free_reg),
		
		//input
		.prf_available(prf_available),
		.prf_ready(prf_ready),
		.data_out(data_out)
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
		$monitor("time:%d, clk:%b, prf_available:%h, prf_ready:%h, data_out:%h, \n",//for debug
			$time, clock, prf_available,prf_ready,data_out);

	


		clock = 0;
		//RESET
		reset = 1;
		#10;
		@(negedge clock);
		@(negedge clock);
		$display("@@@ stop reset!");
		reset = 0;
		@(negedge clock);
		@(negedge clock);
		$display("@@@ assign a new reg!");
		free_this_entry=0;		
		assign_a_free_reg=1;		
		
		@(negedge clock);
		$display("@@@ write_prf_enable!");
		assign_a_free_reg=0;
		write_prf_enable=1;
		data_in=5;
		$display("@@@ free this register!");	
		@(negedge clock);		
		free_this_entry=1;
		@(negedge clock);
		$finish;
	end

endmodule
