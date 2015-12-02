module test_dcache_controller;
	// input from Mem.v
	logic  [3:0] 					Dmem2proc_response;
	logic  [3:0] 					Dmem2proc_tag;
	
	// input from Dcache.v
	logic  [63:0]					cachemem_data;
	logic 							cachemem_valid;
	logic							cachemem_is_dirty;
	logic							cachemem_is_miss;
	logic							cachemem_is_full;
	
	// input from processor.v
	logic  [63:0]					proc2Dcache_addr;
	BUS_COMMAND						proc2Dcache_command;
	logic  [63:0] 					proc2Dcache_data;	
	
	// output to mem.v
	BUS_COMMAND						proc2Dmem_command;
	logic [63:0]					proc2Dmem_addr;
	
	// output to processor.v
	logic [63:0]					Dcache_data_out;	 
	logic [3:0]						Dcache2proc_tag;	 	// to tell processor the tag of the previous load which is finished
	logic [3:0]						Dcache2proc_response;	// to tell processor the tag of present load
	logic 							Dcache_data_hit;

	// output to Dcache.v
	logic [`DCACHE_INDEX_SIZE-1:0]  index;
	logic [`DCACHE_TAG_SIZE-1:0]	tag;
	logic							read_enable;
	logic							write_enable;     
	logic [63:0]					write_data_to_Dcache;	// data that send to dcache.v
	logic [3:0]						mem_response;
	logic [3:0]						mem_tag;

	dcache_controller(
		// input 
		.Dmem2proc_response(Dmem2proc_response),
		.Dmem2proc_tag(Dmem2proc_tag),
		.cachemem_data(cachemem_data),
		.cachemem_valid(cachemem_valid),
		.cachemem_is_dirty(cachemem_is_dirty),
		.cachemem_is_miss(cachemem_is_miss),
		.cachemem_is_full(cachemem_is_full),
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
		.mem_tag(mem_tag)
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
						proc2Dmem_addr:%b, \n\
						Dcache_data_out:%h, \n\
						Dcache2proc_tag:%d\n\
						Dcache2proc_response:%d\n\
						Dcache_data_hit:%b, \n\
						index:%b, \n\
						tag:%b, \n\
						read_enable:%b\n\
						write_enable:%b\n\
						write_data_to_Dcache:%h,\n\
						mem_response:%b,\n\
						mem_tag:%d",
				$time, proc2Dmem_command, proc2Dmem_addr, Dcache_data_out, Dcache2proc_tag, Dcache2proc_response, Dcache_data_hit, index,
				tag, read_enable, write_enable, write_data_to_Dcache, mem_response, mem_tag);

	#10;
	$display("@@@ load data and hit!");
		Dmem2proc_response=0;
		Dmem2proc_tag=0;
		cachemem_data=64'h0000_0000_0000_ffff;
		cachemem_valid=1;
		cachemem_is_dirty=0;
		cachemem_is_miss=0;
		cachemem_is_full = 0;
		proc2Dcache_addr=64'h0000_0000_0000_8888;
		proc2Dcache_command=BUS_LOAD;
		proc2Dcache_data=0;
	#10;
	$display("@@@ load data and miss, not dirty!");
		Dmem2proc_response=4'b0001;
		Dmem2proc_tag=0;
		cachemem_data=0;
		cachemem_valid=0;
		cachemem_is_dirty=0;
		cachemem_is_miss=1;
		cachemem_is_full =0;
		proc2Dcache_addr=64'h0000_0000_0000_8008;
		proc2Dcache_command=BUS_LOAD;
		proc2Dcache_data=0;
	#10;
	$display("@@@ load data and miss, dirty!");
		Dmem2proc_response=4'b0010;
		Dmem2proc_tag=0;
		cachemem_data=0;
		cachemem_valid=0;
		cachemem_is_dirty=1;
		cachemem_is_miss=1;
		proc2Dcache_addr=64'h0000_0000_0001_9208;
		proc2Dcache_command=BUS_LOAD;
		proc2Dcache_data=0;
	#10;
	$display("@@@ load data and hit!");
	$display("@@@ data from memory is returned!");
	$display("@@@ we will only receive the data from memory!");
		Dmem2proc_response=4'b0000;
		Dmem2proc_tag=4'b0001;
		cachemem_data=15;
		cachemem_valid=1;
		cachemem_is_dirty=0;
		cachemem_is_miss=0;
		proc2Dcache_addr=64'h0000_0000_0002_7238;
		proc2Dcache_command=BUS_LOAD;
		proc2Dcache_data=0;
	#10;
	$display("@@@ store data and hit!");
	$display("@@@ data from memory is returned!");
		Dmem2proc_response=4'b0000;
		Dmem2proc_tag=4'b0010;
		cachemem_data=4;
		cachemem_valid=1;
		cachemem_is_dirty=0;
		cachemem_is_miss=0;
		proc2Dcache_addr=64'h0000_0000_0000_3746;
		proc2Dcache_command=BUS_STORE;
		proc2Dcache_data=64'h0100_0100_1000_3947;
	#10;
	$display("@@@ store data and miss, not dirty!");
		Dmem2proc_response=4'b0011;
		Dmem2proc_tag=4'b0000;
		cachemem_data=0;
		cachemem_valid=0;
		cachemem_is_dirty=0;
		cachemem_is_miss=1;
		proc2Dcache_addr=64'h0000_0000_0000_6666;
		proc2Dcache_command=BUS_STORE;
		proc2Dcache_data=64'h0000_0000_0100_6789;
	#10;
	$display("@@@ store data and miss, dirty!");
		Dmem2proc_response=4'b0100;
		Dmem2proc_tag=4'b0100;
		cachemem_data=0;
		cachemem_valid=0;
		cachemem_is_dirty=1;
		cachemem_is_miss=1;
		proc2Dcache_addr=64'h0000_0000_1111_6666;
		proc2Dcache_command=BUS_STORE;
		proc2Dcache_data=64'h0000_0010_0100_6789;
	#10;
	$display("@@@ store data and cache is full!");
		Dmem2proc_response=4'b0100;
		Dmem2proc_tag=4'b0100;
		cachemem_data=0;
		cachemem_valid=0;
		cachemem_is_dirty=1;
		cachemem_is_miss=1;
		cachemem_is_full =1;
		proc2Dcache_addr=64'h0000_0000_0011_6166;
		proc2Dcache_command=BUS_STORE;
		proc2Dcache_data=64'h0000_0010_0101_6709;
	#10;
	$finish;
end
	
endmodule
