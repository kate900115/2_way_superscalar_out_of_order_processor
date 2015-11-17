///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//  Modulename : mem.v                                                       //
//                                                                           //
// Description : This is a clock-based latency, pipelined memory with        //
//               3 buses (address in, data in, data out) and a limit         //
//               on the number of outstanding memory operations allowed      //
//               at any time.                                                //
//                                                                           // 
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module mem(
		input		clock,
		input [63:0]	proc2mem_addr,
		input [63:0]	proc2mem_data,
		BUS_COMMAND	proc2mem_command,

		output logic [3:0]	mem2proc_response, // 0= cannot accept
		output logic [63:0]	mem2proc_data,
		output logic [3:0]	mem2proc_tag
		);

	logic [63:0]	next_mem2proc_data;
	logic [3:0]	next_mem2proc_response, next_mem2proc_tag;

	logic [63:0]	unified_memory 	[`MEM_64BIT_LINES -1 :0];
	logic [63:0]	loaded_data	[`NUM_MEM_TAGS :1];
	logic [15:0]	cycles_left	[`NUM_MEM_TAGS :1];
	logic 		waiting_for_bus [`NUM_MEM_TAGS :1];

	logic acquire_tag;
	logic bus_filled;

	wire valid_address = (proc2mem_addr[2:0] == 3'b0) &&
		     (proc2mem_addr < `MEM_SIZE_IN_BYTES);

// Implement the Memory function
	always @(negedge clock) begin
		next_mem2proc_tag     	= 4'b0;  
		next_mem2proc_response	= 4'b0;
		next_mem2proc_data     	= 64'bx; 
		bus_filled		= 1'b0;
		acquire_tag		= ((proc2mem_command==`BUS_LOAD) ||
					(proc2mem_command==`BUS_STORE)) && valid_address;

		for(int i=1;i<=`NUM_MEM_TAGS;i=i+1) begin
			if(cycles_left[i]>16'd0) /*IF CYCLES ARE LEFT*/
				cycles_left[i] = cycles_left[i]-16'd1; /*DECREMENT CYCLES LEFT*/
			else if(acquire_tag&& !waiting_for_bus[i] && (cycles_left[i]==0)) begin /*INCOMING*/
				next_mem2proc_response = i;
				acquire_tag= 1'b0; 
				cycles_left[i] = `MEM_LATENCY_IN_CYCLES; 
				// must add support for random lantencies
				if(proc2mem_command==`BUS_LOAD) begin /*LOAD*/
			  		waiting_for_bus[i] = 1'b1;
			  		loaded_data[i]     = unified_memory[proc2mem_addr[63:3]];
				end
	  			else unified_memory[proc2mem_addr[63:3]]=proc2mem_data; /*STORE*/
			end
	  		if((cycles_left[i]==16'd0) && waiting_for_bus[i] && !bus_filled) begin /*OUTGOING*/
				bus_filled= 1'b1;
				next_mem2proc_tag  = i;
				next_mem2proc_data = loaded_data[i];
				waiting_for_bus[i] = 1'b0;
	  		end
		end  //for
		mem2proc_response <= `SD next_mem2proc_response;
		mem2proc_data     <= `SD next_mem2proc_data;
		mem2proc_tag      <= `SD next_mem2proc_tag;
		$display("proc2mem_addr:%h", proc2mem_addr);
	end //always_ff

//initialize
 	initial begin
    		for(int i=0; i<`MEM_64BIT_LINES; i=i+1) begin
      			unified_memory[i] = 64'h0;
    		end
    		mem2proc_data=64'bx;
    		mem2proc_tag=4'd0;
    		mem2proc_response=4'd0;
    		for(int i=1;i<=`NUM_MEM_TAGS;i=i+1) begin
      			loaded_data[i]=64'bx;
      			cycles_left[i]=16'd0;
      			waiting_for_bus[i]=1'b0;
    		end
  	end

endmodule

