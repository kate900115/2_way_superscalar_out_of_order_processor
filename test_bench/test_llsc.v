module test_llsc;
	
	//logic
	logic	clock;
	logic	reset;
	
	MEM_INST_TYPE	mem_inst_type;
	logic	[63:0]			mem_addr;
	
	//output	
	logic			store_success;
	logic			full;

llsc llsc1(
	.clock(clock),
	.reset(reset),
	
	.mem_inst_type(mem_inst_type),
	.mem_addr(mem_addr),
	
	.store_success(store_success),
	.full(full)
);

logic correct1;

always #5 clock = ~clock;
	
task exit_on_error;
	begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
	end
endtask

initial begin
	$monitor (" @@@ time:%d, \
			clock:%b, \
		       mem_inst_type:%b, \
			mem_addr:%b, \
		        store_success:%b, \
		        address_tag[7]:%h, \
		        address_tag[6]:%h, \
		        address_valid[7]:%h, \
			full:%b",
			$time, clock, mem_inst_type, mem_addr, store_success, llsc1.address_tag[7], llsc1.address_tag[6],llsc1.valid[7], full);


	clock = 0;
	//***RESET*** //1
	reset = 1;
	correct1 = 1;

	//HERE we initial the reg
	#5; //2

	@(negedge clock);

	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0000ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed1");
		else #1 exit_on_error;

	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0000ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed2");
		else #1 exit_on_error;

	@(negedge clock);




	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0001ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed3");
		else #1 exit_on_error;

	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0002ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed4");
		else #1 exit_on_error;

	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0003ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed5");
		else #1 exit_on_error;

	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0004ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed6");
		else #1 exit_on_error;
		
	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0005ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed7");
		else #1 exit_on_error;
		
	@(negedge clock);


	reset = 0;
	mem_inst_type = NO_INST;
	mem_addr = 64'h000;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed8");
		else #1 exit_on_error;
		
	@(negedge clock);
	reset = 0;
	mem_inst_type = IS_STQ_C_INST;
	mem_addr = 64'h0005ffff;

	#1
	correct1 = (store_success == 1 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed9");
		else #1 exit_on_error;
		
	@(negedge clock);
	reset = 0;
	mem_inst_type = IS_STQ_C_INST;
	mem_addr = 64'h0000ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed10");
		else #1 exit_on_error;
		
		
	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0006ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed11");
		else #1 exit_on_error;
		
	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0007ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed12");
		else #1 exit_on_error;
		
	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0008ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed13");
		else #1 exit_on_error;
		
		
	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h0009ffff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed12");
		else #1 exit_on_error;
		
				
	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_STQ_C_INST;
	mem_addr = 64'h0009ffff;

	#1
	correct1 = (store_success == 1 && full == 1);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed13");
		else #1 exit_on_error;
		
	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h000affff;

	#1
	correct1 = (store_success == 0 && full == 0);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed14");
		else #1 exit_on_error;
		
	@(negedge clock);


	reset = 0;
	mem_inst_type = IS_LDL_INST;
	mem_addr = 64'h000bffff;

	#1
	correct1 = (store_success == 0 && full == 1);
//	correct = correct1 & correct2;
	assert(correct1) $display("@@@passed15");
		else #1 exit_on_error;

	$finish;
	end

endmodule




























