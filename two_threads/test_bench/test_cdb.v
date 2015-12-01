module test_cdb;
	//input
	logic  								adder1_result_ready;
	logic  	[63:0]						adder1_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		adder1_dest_reg_idx;
	logic	[$clog2(`ROB_SIZE):0]		adder1_rob_idx;
	logic								adder1_branch_taken;
	logic  								mult1_result_ready;
	logic  	[63:0]						mult1_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		mult1_dest_reg_idx;
	logic	[$clog2(`ROB_SIZE):0]		mult1_rob_idx;
	logic  								memory1_result_ready;
	logic  	[63:0]						memory1_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		memory1_dest_reg_idx;
	logic	[$clog2(`ROB_SIZE):0]		memory1_rob_idx;
	logic  								adder2_result_ready;
	logic  	[63:0]						adder2_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		adder2_dest_reg_idx;
	logic   [$clog2(`ROB_SIZE):0]		adder2_rob_idx;
	logic								adder2_branch_taken;
	logic  								mult2_result_ready;
	logic  	[63:0]						mult2_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		mult2_dest_reg_idx;
	logic	[$clog2(`ROB_SIZE):0]		mult2_rob_idx;
	logic  								memory2_result_ready;
	logic  	[63:0]						memory2_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		memory2_dest_reg_idx;
	logic	[$clog2(`ROB_SIZE):0]		memory2_rob_idx;

	//output	
	logic								cdb1_valid;
	logic   [$clog2(`PRF_SIZE)-1:0]		cdb1_tag;
	logic 	[63:0]						cdb1_out;
	logic								cdb1_branch_is_taken;
	logic   [$clog2(`ROB_SIZE):0]		cdb1_rob_idx;
	logic								cdb2_valid;
	logic 	[$clog2(`PRF_SIZE)-1:0]		cdb2_tag;
	logic 	[63:0]						cdb2_out;
	logic								cdb2_branch_is_taken;
	logic  [$clog2(`ROB_SIZE):0]		cdb2_rob_idx;
	logic								adder1_send_in_success;
	logic								adder2_send_in_success;
	logic								mult1_send_in_success;
	logic								mult2_send_in_success;
	logic								memory1_send_in_success;
	logic								memory2_send_in_success;

	cdb cdb34(
		//input
		.adder1_result_ready(adder1_result_ready),
		.adder1_result_in(adder1_result_in),
		.adder1_dest_reg_idx(adder1_dest_reg_idx),
		.adder1_rob_idx(adder1_rob_idx),
		.adder1_branch_taken(adder1_branch_taken),
		.mult1_result_ready(mult1_result_ready),
		.mult1_result_in(mult1_result_in),
		.mult1_dest_reg_idx(mult1_dest_reg_idx),
		.mult1_rob_idx(mult1_rob_idx),
		.memory1_result_ready(memory1_result_ready),
		.memory1_result_in(memory1_result_in),
		.memory1_dest_reg_idx(memory1_dest_reg_idx),
		.memory1_rob_idx(memory1_rob_idx),
		.adder2_result_ready(adder2_result_ready),
		.adder2_result_in(adder2_result_in),
		.adder2_dest_reg_idx(adder2_dest_reg_idx),
		.adder2_rob_idx(adder2_rob_idx),
		.adder2_branch_taken(adder2_branch_taken),
		.mult2_result_ready(mult2_result_ready),
		.mult2_result_in(mult2_result_in),
		.mult2_dest_reg_idx(mult2_dest_reg_idx),
		.mult2_rob_idx(mult2_rob_idx),
		.memory2_result_ready(memory2_result_ready),
		.memory2_result_in(memory2_result_in),
		.memory2_dest_reg_idx(memory2_dest_reg_idx),
		.memory2_rob_idx(memory2_rob_idx),

		//output	
		.cdb1_valid(cdb1_valid),
		.cdb1_tag(cdb1_tag),
		.cdb1_out(cdb1_out),
		.cdb1_branch_is_taken(cdb1_branch_is_taken),
		.cdb1_rob_idx(cdb1_rob_idx),
		.cdb2_valid(cdb2_valid),
		.cdb2_tag(cdb2_tag),
		.cdb2_out(cdb2_out),
		.cdb2_branch_is_taken(cdb2_branch_is_taken),
		.cdb2_rob_idx(cdb2_rob_idx),
		.adder1_send_in_success(adder1_send_in_success),
		.adder2_send_in_success(adder2_send_in_success),
		.mult1_send_in_success(mult1_send_in_success),
		.mult2_send_in_success(mult2_send_in_success),
		.memory1_send_in_success(memory1_send_in_success),
		.memory2_send_in_success(memory2_send_in_success)
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
						cdb1_valid:%b, \n\
						cdb1_tag:%b, \n\
						cdb1_out:%d, \n\
						cdb1_branch_is_taken:%b\n\
						cdb1_rob_idx:%b\n\
						cdb2_valid:%b, \n\
						cdb2_tag:%b, \n\
						cdb2_out:%d, \n\
						cdb2_branch_is_taken:%b\n\
						cdb2_rob_idx:%b\n\
						adder1_send_in_success:%b,\n\
						adder2_send_in_success:%b,\n\
						mult1_send_in_success:%b,\n\
						mult2_send_in_success:%b,\n\
						memory1_send_in_success:%b,\n\
						memory2_send_in_success:%b",
				$time, cdb1_valid, cdb1_tag, cdb1_out, cdb1_branch_is_taken, cdb1_rob_idx, 
					   cdb2_valid, cdb2_tag, cdb2_out, cdb2_branch_is_taken, cdb2_rob_idx,
				adder1_send_in_success,adder2_send_in_success,mult1_send_in_success,
				mult2_send_in_success,memory1_send_in_success,memory2_send_in_success);

	#10;
	$display("@@@ adder1 and mult2 are ready!!");
		adder1_result_ready	= 1;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		adder1_rob_idx		= 5'b00101;
		adder1_branch_taken = 1;
		mult1_result_ready	= 0;
		mult1_result_in		= 0;
		mult1_dest_reg_idx	= 0;
		mult1_rob_idx		= 0;
		memory1_result_ready= 0;
		memory1_result_in	= 0;
		memory1_dest_reg_idx= 0;
		memory1_rob_idx		= 0;
		adder2_result_ready	= 0;
		adder2_result_in	= 0;
		adder2_dest_reg_idx	= 0;
		adder2_rob_idx		= 0;
		adder2_branch_taken = 0;
		mult2_result_ready	= 1;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		mult2_rob_idx		= 5'b00001;
		memory2_result_ready= 0;
		memory2_result_in	= 0;
		memory2_dest_reg_idx= 0;
		memory2_rob_idx	 	= 0;

	#10;
	$display("@@@ adder2, mult1, memory2 are ready!!");
		adder1_result_ready	= 0;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		adder1_rob_idx		= 5'b00011;
		adder1_branch_taken = 0;
		mult1_result_ready	= 1;
		mult1_result_in		= 45;
		mult1_dest_reg_idx	= 6'b110110;
		mult1_rob_idx		= 5'b00010;
		memory1_result_ready= 0;
		memory1_result_in	= 0;
		memory1_dest_reg_idx= 0;
		memory1_rob_idx		= 0;
		adder2_result_ready	= 1;
		adder2_result_in	= 67;
		adder2_dest_reg_idx	= 6'b100000;
		adder2_rob_idx		= 5'b00100;
		adder2_branch_taken = 0;
		mult2_result_ready	= 0;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		mult2_rob_idx		= 5'b01100;
		memory2_result_ready= 1;
		memory2_result_in	= 6'b000100;
		memory2_dest_reg_idx= 8;
		memory2_rob_idx		= 5'b00111;
	
		#10;
		$display("@@@ mult1,mem1,adder2 and memory2 are ready!!");
		adder1_result_ready	= 0;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		adder1_rob_idx		= 5'b01101;
		adder1_branch_taken = 1;
		mult1_result_ready	= 1;
		mult1_result_in		= 45;
		mult1_dest_reg_idx	= 6'b110110;
		mult1_rob_idx		= 5'b00110;
		memory1_result_ready= 1;
		memory1_result_in	= 4;
		memory1_dest_reg_idx= 6'b110111;
		memory1_rob_idx		= 5'b00000;
		adder2_result_ready	= 1;
		adder2_result_in	= 67;
		adder2_dest_reg_idx	= 6'b100000;
		adder2_rob_idx		= 5'b01001;
		adder2_branch_taken = 0;
		mult2_result_ready	= 0;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		mult2_rob_idx		= 5'b00101;
		memory2_result_ready= 1;
		memory2_result_in	= 6'b000100;
		memory2_dest_reg_idx= 8;
		memory2_rob_idx		= 5'b00000;

		#10;
		$display("@@@ all are ready!!");
		adder1_result_ready	= 1;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		adder1_rob_idx		= 5'b00101;
		adder1_branch_taken = 0;
		mult1_result_ready	= 1;
		mult1_result_in		= 45;
		mult1_dest_reg_idx	= 6'b110110;
		mult1_rob_idx		= 5'b01000;
		memory1_result_ready= 1;
		memory1_result_in	= 101;
		memory1_dest_reg_idx= 6'b010101;
		memory1_rob_idx		= 5'b01010;
		adder2_result_ready	= 1;
		adder2_result_in	= 67;
		adder2_dest_reg_idx	= 6'b100000;
		adder2_rob_idx		= 5'b00111;
		adder2_branch_taken = 1;
		mult2_result_ready	= 1;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		mult2_rob_idx		= 5'b00001;
		memory2_result_ready= 1;
		memory2_result_in	= 6'b000100;
		memory2_dest_reg_idx= 8;
		memory2_rob_idx		= 5'b00010;

		#10;
		$display("@@@ nothing is ready!!");
		adder1_result_ready	= 0;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		adder1_rob_idx		= 5'b01001;
		adder1_branch_taken = 1;
		mult1_result_ready	= 0;
		mult1_result_in		= 45;
		mult1_dest_reg_idx	= 6'b110110;
		mult1_rob_idx		= 5'b00101;
		memory1_result_ready= 0;
		memory1_result_in	= 101;
		memory1_dest_reg_idx= 6'b010101;
		memory1_rob_idx		= 5'b10110;
		adder2_result_ready	= 0;
		adder2_result_in	= 67;
		adder2_dest_reg_idx	= 6'b100000;
		adder2_rob_idx		= 5'b00010;
		adder2_branch_taken = 0;
		mult2_result_ready	= 0;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		mult2_rob_idx		= 5'b00100;
		memory2_result_ready= 0;
		memory2_result_in	= 6'b000100;
		memory2_dest_reg_idx= 8;
		memory2_rob_idx		= 5'b10110;
	end



endmodule
