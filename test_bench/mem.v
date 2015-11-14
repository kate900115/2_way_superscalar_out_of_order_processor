//input
module mem;
input		clock;
input [63:0]	proc2mem_addr;
input [63:0]	proc2mem_data;
input [1:0]	proc2mem_command;

output [3:0]	mem2proc_response; // 0= cannot accept
output [63:0]	mem2proc_data;
output [3:0]	mem2proc_tag;

reg [63:0]	mem2proc_data, next_mem2proc_data;
reg [3:0]	mem2proc_responce, mem2proc_tag, next_mem2proc_responce, next_mem2proc_tag;

reg [63:0]	unified_memory 	[`MEM_64BIT_LINES -1 :0];
reg [63:0]	loaded_data	[`NUM_MEM_TAGS :1];
reg [15:0]	cycles_left	[`NUM_MEM_TAGS :1];
reg 		waiting_for_bus [`NUM_MEM_TAGS :1];

reg acquire_tag;
reg bus_filled;

wire valid_address = (proc2mem_addr[2:0] == 3'b0) &
		     (proc2mem_add < `MEM_SIZE_IN_BYTES);
integer i;

// Implement the Memory function
always @(negedge clock) begin
	next_mem2proc_tag     	= 4'b0;  
	next_mem2proc_response	= 4'b0;
	next_mem2proc_data     	= 64'bx; 
	bus_filled		= 1'b0;
	acquire_tag		= ((proc2mem_command==`BUS_LOAD) ||
			(proc2mem_command==`BUS_STORE)) && valid_address;
	for(i=1;i<=`NUM_MEM_TAGS;i=i+1) begin
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
end //always_ff
endmodule

