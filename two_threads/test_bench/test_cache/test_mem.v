module test_mem;

	logic         clock;              // Memory clock
    	logic  [63:0] proc2mem_addr;    // address for current command
    	logic  [63:0] proc2mem_data;    // address for current command
    	BUS_COMMAND   proc2mem_command; // `BUS_NONE `BUS_LOAD or `BUS_STORE

    	logic  [3:0] mem2proc_response;// 0 = can't accept, other=tag of transaction
    	logic [63:0] mem2proc_data;   // data resulting from a load
    	logic  [3:0] mem2proc_tag;


	mem mem1(.clk(clock),.proc2mem_addr(proc2mem_addr),.proc2mem_data(proc2mem_data),
		.proc2mem_command(proc2mem_command),.mem2proc_response(mem2proc_response),
		.mem2proc_data(mem2proc_data),.mem2proc_tag(mem2proc_tag) 
		);

	always #10 clock = ~clock;
	
	initial
	begin
		$monitor("@@time:%.0f, clock:%b, \n\
		mem2proc_response:%h, \n\
		mem2proc_data:%h, \n\
		 mem2proc_tag: %h \n\
		proc2mem_addr:%h \n\
		proc2mem_data:%h \n\
		proc2mem_command:%h ",
		$time,clock,mem2proc_response,mem2proc_data,mem2proc_tag,proc2mem_addr,
		proc2mem_data,proc2mem_command);

		clock=0;
		proc2mem_addr=64'd0;
		proc2mem_data=64'd0;
		proc2mem_command=BUS_NONE;
		@(posedge clock);
		proc2mem_addr[63:3]=61'd1;
		proc2mem_data=64'd1;
		proc2mem_command=BUS_STORE;
		@(posedge clock);
		proc2mem_addr[63:3]=61'd2;
		proc2mem_data=64'd2;
		proc2mem_command=BUS_STORE;

		@(posedge clock);
		proc2mem_addr[63:3]=61'd3;
		proc2mem_data=64'd3;
		proc2mem_command=BUS_STORE;
		@(posedge clock);
		proc2mem_addr[63:3]=61'd3;
		proc2mem_data=64'd3;
		proc2mem_command=BUS_NONE;
		@(posedge clock);
		@(posedge clock);
		@(posedge clock);
		@(posedge clock);
		@(posedge clock);
		@(posedge clock);
		proc2mem_addr[63:3]=61'd1;
		proc2mem_command=BUS_LOAD;
		@(posedge clock);
		proc2mem_addr[63:3]=61'd2;
		proc2mem_command=BUS_LOAD;

		@(posedge clock);
		proc2mem_addr[63:3]=61'd3;
		proc2mem_command=BUS_LOAD;
		@(posedge clock);
		proc2mem_addr[63:3]=61'd0;
		proc2mem_command=BUS_NONE;
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		$finish;
		


	end

endmodule







