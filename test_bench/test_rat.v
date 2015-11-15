module test_rat;

	//input
	logic	reset;	//reset signal
	logic	clock;	//the clock
	logic	inst1_enable;	//high if inst can run
	logic	inst2_enable;
	logic	[$clog2(`ARF_SIZE)-1:0]	opa_ARF_idx1;	//we will use opa_ARF_idx to find PRF_idx
	logic	[$clog2(`ARF_SIZE)-1:0]	opb_ARF_idx1;	//to find PRF_idx
	logic	[$clog2(`ARF_SIZE)-1:0]	dest_ARF_idx1;	//the ARF index of dest reg
	logic	dest_rename_sig1;	//if high; dest_reg need rename; imme => low

	logic	[$clog2(`ARF_SIZE)-1:0]	opa_ARF_idx2;	//we will use opa_ARF_idx to find PRF_idx
	logic	[$clog2(`ARF_SIZE)-1:0]	opb_ARF_idx2;	//to find PRF_idx
	logic	[$clog2(`ARF_SIZE)-1:0]	dest_ARF_idx2;	//the ARF index of dest reg
	logic	dest_rename_sig2;	//if high; dest_reg need rename; imme => low

	logic	opa_valid_in1;	//if high opa_valid is immediate
	logic	opb_valid_in1;
	logic	opa_valid_in2;	//if high opa_valid is immediate
	logic	opb_valid_in2;

	logic	[`ARF_SIZE-1:0]	[$clog2(`PRF_SIZE)-1:0]	mispredict_up_idx;	//if mispredict happens; need to copy from rrat
	logic	mispredict_sig1;	//indicate weather mispredict happened
	logic	mispredict_sig2;	//indicate weather mispredict happened

	logic	PRF_rename_valid1;	//we get valid signal from prf if the dest address has been request
	logic	[$clog2(`PRF_SIZE)-1:0]	PRF_rename_idx1;	//the PRF going to allocate for dest
	logic	PRF_rename_valid2;	//we get valid signal from prf if the dest address has been request
	logic	[$clog2(`PRF_SIZE)-1:0]	PRF_rename_idx2;	//the PRF going to allocate for dest

	//output
	logic	[$clog2(`PRF_SIZE)-1:0]	opa_PRF_idx1;
	logic	[$clog2(`PRF_SIZE)-1:0]	opb_PRF_idx1;
	logic	request1;  //send to PRF indicate weather it request data
	logic	RAT_allo_halt1;

	logic	[$clog2(`PRF_SIZE)-1:0]	opa_PRF_idx2;
	logic	[$clog2(`PRF_SIZE)-1:0]	opb_PRF_idx2;
	logic	request2;  //send to PRF indicate weather it request data
	logic	RAT_allo_halt2;

	logic	[`PRF_SIZE-1:0]	PRF_free_list_out;
	logic			PRF_free_valid;
	logic correct1, correct2, correct;

	rat ratrat(
	//input
	.reset(reset),
	.clock(clock),
	.inst1_enable(inst1_enable),
	.inst2_enable(inst2_enable),

	.opa_ARF_idx1(opa_ARF_idx1),
	.opb_ARF_idx1(opb_ARF_idx1),
	.dest_ARF_idx1(dest_ARF_idx1),
	.dest_rename_sig1(dest_rename_sig1),

	.opa_ARF_idx2(opa_ARF_idx2),
	.opb_ARF_idx2(opb_ARF_idx2),
	.dest_ARF_idx2(dest_ARF_idx2),
	.dest_rename_sig2(dest_rename_sig2),


	.opa_valid_in1(opa_valid_in1),
	.opb_valid_in1(opb_valid_in1),

	.opa_valid_in2(opa_valid_in2),
	.opb_valid_in2(opb_valid_in2),

	.mispredict_sig1(mispredict_sig1),
	.mispredict_sig2(mispredict_sig2),
	.mispredict_up_idx(mispredict_up_idx),

	.PRF_rename_valid1(PRF_rename_valid1),
	.PRF_rename_idx1(PRF_rename_idx1),

	.PRF_rename_valid2(PRF_rename_valid2),
	.PRF_rename_idx2(PRF_rename_idx2),

	//output
	.opa_PRF_idx1(opa_PRF_idx1),
	.opb_PRF_idx1(opb_PRF_idx1),
	.request1(request1),
	.RAT_allo_halt1(RAT_allo_halt1),

	.opa_PRF_idx2(opa_PRF_idx2),
	.opb_PRF_idx2(opb_PRF_idx2),
	.request2(request2),
	.RAT_allo_halt2(RAT_allo_halt2),

	//output together
	.PRF_free_list_out(PRF_free_list_out),
	.PRF_free_valid(PRF_free_valid)

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
	correct = 1;
	$monitor (" @@@ time:%d, \
		        clock:%b,\
			opa_PRF_idx1:%b, \
			opb_PRF_idx1:%b, \
			request1:%b, \
			RAT_allo_halt1:%b, \
			opa_PRF_idx2:%b, \
			opb_PRF_idx2:%b, \
			request2:%b, \
			RAT_allo_halt2:%b, \
			PRF_free_valid:%b, \
			PRF_free_list_out:%b", 
			$time, clock, opa_PRF_idx1, opb_PRF_idx1, request1,  RAT_allo_halt1,
			opa_PRF_idx2, opb_PRF_idx2, request2,  RAT_allo_halt2, 
			PRF_free_valid, PRF_free_list_out);

	clock = 0;
	//***RESET**
	reset = 1;
	@(negedge clock);
	reset = 0;
	//HERE we initial the reg
	//#5
	reset 			= 0;
	inst1_enable		= 1;
	opa_ARF_idx1 		= 0;
	opb_ARF_idx1 		= 0;
	dest_ARF_idx1 		= 0;
	dest_rename_sig1 	= 1;
	opa_valid_in1 		= 1;
	opb_valid_in1 		= 1;
	mispredict_sig1 	= 0;
	PRF_rename_valid1	= 1;
	PRF_rename_idx1 	= 12;

	inst2_enable		= 1;
	opa_ARF_idx2 		= 0;
	opb_ARF_idx2 		= 0;
	dest_ARF_idx2 		= 1;
	dest_rename_sig2 	= 1;
	opa_valid_in2 		= 1;
	opb_valid_in2 		= 1;
	mispredict_sig2 	= 0;
	PRF_rename_valid2	= 1;
	PRF_rename_idx2 	= 3;

	mispredict_up_idx 	= 0;

 	#1

	correct1 = 		opa_PRF_idx1 == 0 &&
				opb_PRF_idx1 == 0 &&
				request1 == 1 &&
				RAT_allo_halt1 == 0;

	correct2 = 		opa_PRF_idx2 == 0 &&
				opb_PRF_idx2 == 0 &&
				request2 == 1 &&
				RAT_allo_halt2 == 0;

	correct = correct1 && correct2 && PRF_free_valid == 0 && PRF_free_list_out == 0;
	assert(correct) $display("@@@passed1");
		else #1 exit_on_error;


	@(negedge clock);
	reset 			= 0;
	inst1_enable		= 1;
	opa_ARF_idx1 		= 0;
	opb_ARF_idx1		= 0;
	dest_ARF_idx1 		= 2;
	dest_rename_sig1 	= 1;
	opa_valid_in1 		= 1;
	opb_valid_in1 		= 1;
	mispredict_sig1 	= 0;
	PRF_rename_valid1	= 1;
	PRF_rename_idx1 	= 9;

	inst2_enable		= 1;
	opa_ARF_idx2 		= 0;
	opb_ARF_idx2 		= 0;
	dest_ARF_idx2 		= 3;
	dest_rename_sig2 	= 1;
	opa_valid_in2 		= 1;
	opb_valid_in2 		= 1;
	mispredict_sig2 	= 0;
	PRF_rename_valid2	= 1;
	PRF_rename_idx2		= 10;

	mispredict_up_idx 	= 0;

	#1
	correct1 = 		opa_PRF_idx1 == 0 &&
				opb_PRF_idx1 == 0 &&
				request1 == 1 &&
				RAT_allo_halt1 == 0;

	correct2 = 		opa_PRF_idx2 == 0 &&
				opb_PRF_idx2 == 0 &&
				request2 == 1 &&
				RAT_allo_halt2 == 0;

	correct = correct1 && correct2 && PRF_free_valid == 0 && PRF_free_list_out == 0;
	assert(correct) $display("@@@passed2");
		else #1 exit_on_error;

	@(negedge clock);
	reset 			= 0;
	opa_ARF_idx1 		= 0;
	opb_ARF_idx1 		= 0;
	dest_ARF_idx1 		= 4;
	dest_rename_sig1 	= 1;
	opa_valid_in1 		= 1;
	opb_valid_in1 		= 1;
	mispredict_sig1 	= 0;
	PRF_rename_valid1	= 1;
	PRF_rename_idx1 	= 5;

	opa_ARF_idx2 		= 0;
	opb_ARF_idx2 		= 0;
	dest_ARF_idx2 		= 0;
	dest_rename_sig2 	= 0;
	opa_valid_in2 		= 0;
	opb_valid_in2 		= 0;
	mispredict_sig2 	= 0;
	PRF_rename_valid2	= 0;
	PRF_rename_idx2 	= 0;

	mispredict_up_idx 	= 0;

	#1
	correct1 = 		opa_PRF_idx1 == 0 &&
				opb_PRF_idx1 == 0 &&
				request1 == 1 &&
				RAT_allo_halt1 == 0;

	correct2 = 		opa_PRF_idx2 == 0 &&
				opb_PRF_idx2 == 0 &&
				request2 == 0 &&
				RAT_allo_halt2 == 0;

	correct = correct1 && correct2 && PRF_free_valid == 0 && PRF_free_list_out == 0;
	assert(correct) $display("@@@passed3");
		else #1 exit_on_error;

	@(negedge clock);
	reset 			= 0;
	opa_ARF_idx1 		= 0;
	opb_ARF_idx1 		= 0;
	dest_ARF_idx1 		= 0;
	dest_rename_sig1 	= 0;
	opa_valid_in1 		= 0;
	opb_valid_in1 		= 0;
	mispredict_sig1 	= 0;
	PRF_rename_valid1	= 0;
	PRF_rename_idx1 	= 0;

	opa_ARF_idx2 		= 0;
	opb_ARF_idx2 		= 0;
	dest_ARF_idx2 		= 4;
	dest_rename_sig2 	= 1;
	opa_valid_in2 		= 1;
	opb_valid_in2 		= 1;
	mispredict_sig2 	= 1;
	PRF_rename_valid2	= 1;
	PRF_rename_idx2 	= 5;

	mispredict_up_idx[0]= 8;
	mispredict_up_idx[1]= 3;
	mispredict_up_idx[2]= 9;
	mispredict_up_idx[3]= 6;
	mispredict_up_idx[4]= 5;

	#1
	correct1 = 		opa_PRF_idx1 == 0 &&
				opb_PRF_idx1 == 0 &&
				request1 == 0 &&
				RAT_allo_halt1 == 0;

	correct2 = 		opa_PRF_idx2 == 0 &&
				opb_PRF_idx2 == 0 &&
				request2 == 0 &&
				PRF_free_valid == 1 &&
				PRF_free_list_out == {{`PRF_SIZE-13{1'b0}},{3'b101},{10{1'b0}}} &&
				RAT_allo_halt2 == 0;
	correct = correct1 && correct2;
	assert(correct) $display("@@@passed4");
		else #1 exit_on_error;


	@(negedge clock);
	reset 			= 0;
	opa_ARF_idx1 		= 1;
	opb_ARF_idx1 		= 4;
	dest_ARF_idx1 		= 2;
	dest_rename_sig1 	= 1;
	opa_valid_in1		= 0;
	opb_valid_in1 		= 0;
	mispredict_sig1 	= 0;
	PRF_rename_valid1	= 1;
	PRF_rename_idx1		= 0;

	opa_ARF_idx2 		= 0;
	opb_ARF_idx2 		= 2;
	dest_ARF_idx2 		= 0;
	dest_rename_sig2 	= 1;
	opa_valid_in2 		= 0;
	opb_valid_in2 		= 0;
	mispredict_sig2 	= 0;
	PRF_rename_valid2	= 1;
	PRF_rename_idx2 	= 1;

	mispredict_up_idx 	= 0;

	#1
	correct1 = 		opa_PRF_idx1 == 3 &&
				opb_PRF_idx1 == 5 &&
				request1 == 1 &&
				RAT_allo_halt1 == 0;

	correct2 = 		opa_PRF_idx2 == 8 &&
				opb_PRF_idx2 == 0 &&
				request2 == 1 &&
				PRF_free_valid == 0 &&
				PRF_free_list_out == 0 &&
				RAT_allo_halt2 == 0;
	correct = correct1 && correct2;
	assert(correct) $display("@@@passed5");
		else #1 exit_on_error;

	$finish;
end

endmodule
