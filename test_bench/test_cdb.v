module test_cdb;
	//input
	logic  					adder1_result_ready;
	logic  	[63:0]				adder1_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		adder1_dest_reg_idx;
	logic  					mult1_result_ready;
	logic  	[63:0]				mult1_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		mult1_dest_reg_idx;
	logic  					memory1_result_ready;
	logic  	[63:0]				memory1_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		memory1_dest_reg_idx;
	logic  					adder2_result_ready;
	logic  	[63:0]				adder2_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		adder2_dest_reg_idx;
	logic  					mult2_result_ready;
	logic  	[63:0]				mult2_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		mult2_dest_reg_idx;
	logic  					memory2_result_ready;
	logic  	[63:0]				memory2_result_in;
	logic	[$clog2(`PRF_SIZE)-1:0]		memory2_dest_reg_idx;

	//output	
	logic					cdb1_valid;
	logic   [$clog2(`PRF_SIZE)-1:0]		cdb1_tag;
	logic 	[63:0]				cdb1_out;
	logic					cdb2_valid;
	logic 	[$clog2(`PRF_SIZE)-1:0]		cdb2_tag;
	logic 	[63:0]				cdb2_out;
	logic					adder1_send_in_fail;
	logic					adder2_send_in_fail;
	logic					mult1_send_in_fail;
	logic					mult2_send_in_fail;
	logic					memory1_send_in_fail;
	logic					memory2_send_in_fail;

	cdb cdb34(
		//input
		.adder1_result_ready(adder1_result_ready),
		.adder1_result_in(adder1_result_in),
		.adder1_dest_reg_idx(adder1_dest_reg_idx),
		.mult1_result_ready(mult1_result_ready),
		.mult1_result_in(mult1_result_in),
		.mult1_dest_reg_idx(mult1_dest_reg_idx),
		.memory1_result_ready(memory1_result_ready),
		.memory1_result_in(memory1_result_in),
		.memory1_dest_reg_idx(memory1_dest_reg_idx),
		.adder2_result_ready(adder2_result_ready),
		.adder2_result_in(adder2_result_in),
		.adder2_dest_reg_idx(adder2_dest_reg_idx),
		.mult2_result_ready(mult2_result_ready),
		.mult2_result_in(mult2_result_in),
		.mult2_dest_reg_idx(mult2_dest_reg_idx),
		.memory2_result_ready(memory2_result_ready),
		.memory2_result_in(memory2_result_in),
		.memory2_dest_reg_idx(memory2_dest_reg_idx),

		//output	
		.cdb1_valid(cdb1_valid),
		.cdb1_tag(cdb1_tag),
		.cdb1_out(cdb1_out),
		.cdb2_valid(cdb2_valid),
		.cdb2_tag(cdb2_tag),
		.cdb2_out(cdb2_out),
		.adder1_send_in_fail(adder1_send_in_fail),
		.adder2_send_in_fail(adder2_send_in_fail),
		.mult1_send_in_fail(mult1_send_in_fail),
		.mult2_send_in_fail(mult2_send_in_fail),
		.memory1_send_in_fail(memory1_send_in_fail),
		.memory2_send_in_fail(memory2_send_in_fail)
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
						cdb2_valid:%b, \n\
						cdb2_tag:%b, \n\
						cdb2_out:%d, \n\
						adder1_send_in_fail:%b,\n\
						adder2_send_in_fail:%b,\n\
						mult1_send_in_fail:%b,\n\
						mult2_send_in_fail:%b,\n\
						memory1_send_in_fail:%b,\n\
						memory2_send_in_fail:%b",
				$time, cdb1_valid, cdb1_tag, cdb1_out, cdb2_valid, cdb2_tag, cdb2_out,
				adder1_send_in_fail,adder2_send_in_fail,mult1_send_in_fail,
				mult2_send_in_fail,memory1_send_in_fail,memory2_send_in_fail);

	#10;
	$display("@@@ adder1 and mult2 are ready!!");
		adder1_result_ready	= 1;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		mult1_result_ready	= 0;
		mult1_result_in		= 0;
		mult1_dest_reg_idx	= 0;
		memory1_result_ready	= 0;
		memory1_result_in	= 0;
		memory1_dest_reg_idx	= 0;
		adder2_result_ready	= 0;
		adder2_result_in	= 0;
		adder2_dest_reg_idx	= 0;
		mult2_result_ready	= 1;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		memory2_result_ready	= 0;
		memory2_result_in	= 0;
		memory2_dest_reg_idx	= 0;

	#10;
	$display("@@@ adder2, mult1, memory2 are ready!!");
		adder1_result_ready	= 0;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		mult1_result_ready	= 1;
		mult1_result_in		= 45;
		mult1_dest_reg_idx	= 6'b110110;
		memory1_result_ready	= 0;
		memory1_result_in	= 0;
		memory1_dest_reg_idx	= 0;
		adder2_result_ready	= 1;
		adder2_result_in	= 67;
		adder2_dest_reg_idx	= 6'b100000;
		mult2_result_ready	= 0;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		memory2_result_ready	= 1;
		memory2_result_in	= 6'b000100;
		memory2_dest_reg_idx	= 8;
	
		#10;
		$display("@@@ mult1,mem1,adder2 and memory2 are ready!!");
		adder1_result_ready	= 0;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		mult1_result_ready	= 1;
		mult1_result_in		= 45;
		mult1_dest_reg_idx	= 6'b110110;
		memory1_result_ready	= 1;
		memory1_result_in	= 4;
		memory1_dest_reg_idx	= 6'b110111;
		adder2_result_ready	= 1;
		adder2_result_in	= 67;
		adder2_dest_reg_idx	= 6'b100000;
		mult2_result_ready	= 0;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		memory2_result_ready	= 1;
		memory2_result_in	= 6'b000100;
		memory2_dest_reg_idx	= 8;

		#10;
		$display("@@@ all are ready!!");
		adder1_result_ready	= 1;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		mult1_result_ready	= 1;
		mult1_result_in		= 45;
		mult1_dest_reg_idx	= 6'b110110;
		memory1_result_ready	= 1;
		memory1_result_in	= 101;
		memory1_dest_reg_idx	= 6'b010101;
		adder2_result_ready	= 1;
		adder2_result_in	= 67;
		adder2_dest_reg_idx	= 6'b100000;
		mult2_result_ready	= 1;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		memory2_result_ready	= 1;
		memory2_result_in	= 6'b000100;
		memory2_dest_reg_idx	= 8;

		#10;
		$display("@@@ nothing is ready!!");
		adder1_result_ready	= 0;
		adder1_result_in	= 5;
		adder1_dest_reg_idx	= 6'b000001;
		mult1_result_ready	= 0;
		mult1_result_in		= 45;
		mult1_dest_reg_idx	= 6'b110110;
		memory1_result_ready	= 0;
		memory1_result_in	= 101;
		memory1_dest_reg_idx	= 6'b010101;
		adder2_result_ready	= 0;
		adder2_result_in	= 67;
		adder2_dest_reg_idx	= 6'b100000;
		mult2_result_ready	= 0;
		mult2_result_in		= 7;
		mult2_dest_reg_idx	= 6'b000010;
		memory2_result_ready	= 0;
		memory2_result_in	= 6'b000100;
		memory2_dest_reg_idx	= 8;
	end



endmodule
