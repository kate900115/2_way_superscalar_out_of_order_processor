module test_rrat;
	
	//input
	logic 				reset;
	logic 				clock;

	logic				inst1_enable;
	logic				inst2_enable;
	logic [$clog2(`PRF_SIZE)-1:0]	RoB_PRF_idx1;
	logic [$clog2(`ARF_SIZE)-1:0] 	RoB_ARF_idx1;
	logic 				RoB_retire_in1;	//high when instruction retires
	logic 				mispredict_sig1;

	logic [$clog2(`PRF_SIZE)-1:0]	RoB_PRF_idx2;
	logic [$clog2(`ARF_SIZE)-1:0] 	RoB_ARF_idx2;
	logic 				RoB_retire_in2;	//high when instruction retires
	logic 				mispredict_sig2;
	
	//output
	logic 						PRF_free_valid1;
	logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx1;
	logic 						PRF_free_valid2;
	logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx2;
	logic [`ARF_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0]	mispredict_up_idx;
	logic correct1, correct2, correct;

rrat rrat1(
	//input
	.reset(reset),
	.clock(clock),
	.inst1_enable(inst1_enable),
	.inst2_enable(inst2_enable),

	.RoB_PRF_idx1(RoB_PRF_idx1),
	.RoB_ARF_idx1(RoB_ARF_idx1),
	.RoB_retire_in1(RoB_retire_in1),
	.mispredict_sig1(mispredict_sig1),

	.RoB_PRF_idx2(RoB_PRF_idx2),
	.RoB_ARF_idx2(RoB_ARF_idx2),
	.RoB_retire_in2(RoB_retire_in2),
	.mispredict_sig2(mispredict_sig2),

	//output
	.PRF_free_valid1(PRF_free_valid1),
	.PRF_free_idx1(PRF_free_idx1),
	.PRF_free_valid2(PRF_free_valid2),
	.PRF_free_idx2(PRF_free_idx2),
	.mispredict_up_idx(mispredict_up_idx)
	);


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
		        PRF_free_valid1:%b, \
			PRF_free_idx1:%b, \
		        PRF_free_valid2:%b, \
			PRF_free_idx2:%b, \
			mispredict_up_idx:%b, rrat_reg[RoB_ARF_idx1]:%b, RoB_ARF_idx1:%b",
			$time, clock, PRF_free_valid1, PRF_free_idx1, PRF_free_valid2, PRF_free_idx2,mispredict_up_idx, rrat1.rrat_reg[RoB_ARF_idx1], RoB_ARF_idx1);


	clock = 0;
	//***RESET*** //1
	reset = 1;
	correct = 1;

	//HERE we initial the reg
	#5; //2

	@(negedge clock);

	reset = 0;
	inst1_enable = 1;
	RoB_retire_in1 = 1;
	RoB_ARF_idx1 = 0;
	RoB_PRF_idx1 = 2;
	mispredict_sig1 = 0;

	inst2_enable = 1;
	RoB_retire_in2 = 1;
	RoB_ARF_idx2 = 1;
	RoB_PRF_idx2 = 3;
	mispredict_sig2 = 0;

	#1
	correct1 = (PRF_free_valid1 == 1 && PRF_free_idx1 == 0 && mispredict_up_idx == 0);
	correct2 = (PRF_free_valid2 == 1 && PRF_free_idx2 == 0 && mispredict_up_idx == 0);
	correct = correct1 & correct2;
	assert(correct) $display("@@@passed1");
		else #1 exit_on_error;

	@(negedge clock);


	reset = 0;
	inst1_enable = 1;
	RoB_retire_in1 = 1;
	RoB_ARF_idx1 = 2;
	RoB_PRF_idx1 = 4;
	mispredict_sig1 = 0;

	inst2_enable = 1;
	RoB_retire_in2 = 1;
	RoB_ARF_idx2 = 3;
	RoB_PRF_idx2 = 6;
	mispredict_sig2 = 0;

	#1
	correct1 = (PRF_free_valid1 == 1 && PRF_free_idx1 == 0 && mispredict_up_idx == 0);
	correct2 = (PRF_free_valid2 == 1 && PRF_free_idx2 == 0 && mispredict_up_idx == 0);
	correct = correct1 & correct2;
	assert(correct) $display("@@@passed2");
		else #1 exit_on_error;

	@(negedge clock);


	reset = 0;
	inst1_enable = 1;
	RoB_retire_in1 = 1;
	RoB_ARF_idx1 = 4;
	RoB_PRF_idx1 = 5;
	mispredict_sig1 = 0;

	inst2_enable = 1;
	RoB_retire_in2 = 1;
	RoB_ARF_idx2 = 0;
	RoB_PRF_idx2 = 7;
	mispredict_sig2 = 0;

	#1
	correct1 = (PRF_free_valid1 == 1 && PRF_free_idx1 == 0 && mispredict_up_idx == 0);
	correct2 = (PRF_free_valid2 == 1 && PRF_free_idx2 == 2 && mispredict_up_idx == 0);
	correct = correct1 & correct2;
	assert(correct) $display("@@@passed3");
		else #1 exit_on_error;

	@(negedge clock);
	reset = 0;
	inst1_enable = 1;
	RoB_retire_in1 = 1;
	RoB_ARF_idx1 = 0;
	RoB_PRF_idx1 = 8;
	mispredict_sig1 = 0;

	inst2_enable = 1;
	RoB_retire_in2 = 1;
	RoB_ARF_idx2 = 2;
	RoB_PRF_idx2 = 9;
	mispredict_sig2 = 0;

	#1
	correct1 = (PRF_free_valid1 == 1 && PRF_free_idx1 == 7 && mispredict_up_idx == 0);
	correct2 = (PRF_free_valid2 == 1 && PRF_free_idx2 == 4 && mispredict_up_idx == 0);
	correct = correct1 & correct2;
	assert(correct) $display("@@@passed4");
		else #1 exit_on_error;

	@(negedge clock);
	reset = 0;
	inst1_enable = 1;
	RoB_retire_in1 = 0;
	RoB_ARF_idx1 = 0;
	RoB_PRF_idx1 = 0;
	mispredict_sig1 = 1;

	inst2_enable = 1;
	RoB_retire_in2 = 0;
	RoB_ARF_idx2 = 0;
	RoB_PRF_idx2 = 0;
	mispredict_sig2 = 0;
	
	#1
	correct1 = (PRF_free_valid1 == 0 && PRF_free_idx1 == 0 && 
			mispredict_up_idx[0] == 8 &&
			mispredict_up_idx[1] == 3 &&
			mispredict_up_idx[2] == 9 &&
			mispredict_up_idx[3] == 6 &&
			mispredict_up_idx[4] == 5);
	correct2 = PRF_free_valid2 == 0 && PRF_free_idx2 == 0;
	correct = correct1 & correct2;
	assert(correct) $display("@@@passed5");
		else #1 exit_on_error;


	reset = 0;
	inst1_enable = 0;
	RoB_retire_in1 = 0;
	RoB_ARF_idx1 = 0;
	RoB_PRF_idx1 = 0;
	mispredict_sig1 = 1;

	inst2_enable = 1;
	RoB_retire_in2 = 0;
	RoB_ARF_idx2 = 0;
	RoB_PRF_idx2 = 0;
	mispredict_sig2 = 0;
	
	#1
	correct1 = (PRF_free_valid1 == 0 && PRF_free_idx1 == 0 && mispredict_up_idx == 0);
	correct2 = (PRF_free_valid2 == 0 && PRF_free_idx2 == 0 && mispredict_up_idx == 0);
	correct = correct1 & correct2;
	assert(correct) $display("@@@passed6");
		else #1 exit_on_error;


	$finish;
	end

endmodule




























