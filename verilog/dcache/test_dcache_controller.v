module test_dcache_controller;
	// input from Mem.v
	logic  [3:0] 					Dmem2proc_response;
	logic  [3:0] 					Dmem2proc_tag;
	
	// input from Dcache.v
	logic  [63:0]					cachemem_data;
	logic 							cachemem_valid;
	logic							cachemem_is_dirty;
	logic							cachemem_is_miss;
	
	// input from processor.v
	logic  [63:0]					proc2Dcache_addr;
	BUS_COMMAND						proc2Dcache_command;
	logic  [63:0] 					proc2Dcache_data;	
	
	// output to mem.v
	BUS_COMMAND						proc2Dmem_command;
	logic logic [63:0]				proc2Dmem_addr;
	
	// output to processor.v
	logic [63:0]					Dcache_data_out;	 
	logic [3:0]						Dcache2proc_tag;	 	// to tell processor the tag of the previous load which is finished
	logic [3:0]						Dcache2proc_response;	// to tell processor the tag of present load
	logic 							Dcache_data_hit;

	// output to Dcache.v
	logic [`INDEX_SIZE-1:0]  		index;
	logic [`TAG_SIZE-1:0]			tag;
	logic							read_enable;
	logic							write_enable;     
	logic [63:0]					write_data_to_Dcache;	// data that send to dcache.v
	logic [3:0]						mem_response;
	logic [3:0]						mem_tag;
	logic							store_to_mem_enable;
	
	dcache_controller(
		// input 
		.Dmem2proc_response(Dmem2proc_response),
		.Dmem2proc_tag(Dmem2proc_tag),
		.cachemem_data(cachemem_data),
		.cachemem_valid(cachemem_valid),
		.cachemem_is_dirty(cachemem_is_dirty),
		.cachemem_is_miss(cachemem_is_miss),
		.proc2Dcache_addr(proc2Dcache_addr),
		.proc2Dcache_command(proc2Dcache_command),
		.proc2Dcache_data(proc2Dcache_data),	
	
		// output 
		.proc2Dmem_command(proc2Dmem_command),
		.proc2Dmem_addr(proc2Dmem_addr),
		.Dcache_data_out(Dcache_data_out),	 
		.Dcache2proc_tag(Dcache2proc_tag),	 	
		.Dcache2proc_response(Dcache2proc_response),	
		.Dcache_data_hit(Dcache_data_hit),
		.index(index),
		.tag(tag),  
		.read_enable(read_enable),
		.write_enable(write_enable),     
		.write_data_to_Dcache(write_data_to_Dcache),	
		.mem_response(mem_response),
		.mem_tag(mem_tag),
		.store_to_mem_enable(store_to_mem_enable)
);

	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	initial begin
		$monitor(" @@@  time:%d, \n\
						proc2Dmem_command:%b, \n\
						proc2Dmem_addr:%h, \n\
						Dcache_data_out:%h, \n\
						Dcache2proc_tag:%d\n\
						Dcache2proc_response:%d\n\
						Dcache_data_hit:%b, \n\
						index:%h, \n\
						tag:%h, \n\
						read_enable:%b\n\
						write_enable:%b\n\
						write_data_to_Dcache:%h,\n\
						mem_response:%b,\n\
						mem_tag:%d,\n\
						store_to_mem_enable:%b",
				$time, proc2Dmem_command, proc2Dmem_addr, Dcache_data_out, Dcache2proc_tag, Dcache2proc_response, Dcache_data_hit, index,
				tag, read_enable, write_enable, write_data_to_Dcache, mem_response, mem_tag, store_to_mem_enable);

	#10;
	$display("@@@ ");
		Dmem2proc_response=0;
		Dmem2proc_tag=0;
		cachemem_data=0;
		cachemem_valid=0;
		cachemem_is_dirty=0;
		cachemem_is_miss=0;
		proc2Dcache_addr=0;
		proc2Dcache_command=0;
		proc2Dcache_data=0;
	#10;
	$display("@@@ ");
		Dmem2proc_response=0;
		Dmem2proc_tag=0;
		cachemem_data=0;
		cachemem_valid=0;
		cachemem_is_dirty=0;
		cachemem_is_miss=0;
		proc2Dcache_addr=0;
		proc2Dcache_command=0;
		proc2Dcache_data=0;
	$finish;
end
	
endmodule
