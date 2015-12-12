module test_int_rat_rrat;

	//rat input
	logic	reset;	//reset signal
	logic	clock;	//the clock
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
	
	//rrat input
	logic [$clog2(`PRF_SIZE)-1:0]	RoB_PRF_idx1;
	logic [$clog2(`ARF_SIZE)-1:0] 	RoB_ARF_idx1;
	logic 				RoB_retire_in1;	//high when instruction retires
	logic 				mispredict_sig1;

	logic [$clog2(`PRF_SIZE)-1:0]	RoB_PRF_idx2;
	logic [$clog2(`ARF_SIZE)-1:0] 	RoB_ARF_idx2;
	logic 				RoB_retire_in2;	//high when instruction retires
	logic 				mispredict_sig2;
	
	//prf input
	logic							cdb1_valid;
	logic	[$clog2(`PRF_SIZE)-1:0]	cdb1_tag;
	logic   [63:0]					cdb1_out;
	logic							cdb2_valid;
	logic	[$clog2(`PRF_SIZE)-1:0]	cdb2_tag;
	logic   [63:0]					cdb2_out;

	logic							inst1_opa_valid;					//whether opa load from prf of instruction1 is valid
	logic							inst1_opb_valid;					//whether opb load from prf of instruction1 is valid
	logic							inst2_opa_valid;					//whether opa load from prf of instruction2 is valid
	logic							inst2_opb_valid;					//whether opa load from prf of instruction2 is valid
	
	logic	[$clog2(`PRF_SIZE)-1:0]	rob1_retire_idx;					// when rob1 retires an instruction, prf gives out the corresponding value.
	logic	[$clog2(`PRF_SIZE)-1:0]	rob2_retire_idx;					// when rob2 retires an instruction, prf gives out the corresponding value.
	
	
	//prf output
	logic	[$clog2(`PRF_SIZE)-1:0]	opa_PRF_idx1;
	logic	[$clog2(`PRF_SIZE)-1:0]	opb_PRF_idx1;
	logic	request1;  //send to PRF indicate weather it request data
	logic	RAT_allo_halt1;

	logic	[$clog2(`PRF_SIZE)-1:0]	opa_PRF_idx2;
	logic	[$clog2(`PRF_SIZE)-1:0]	opb_PRF_idx2;
	logic	request2;  //send to PRF indicate weather it request data
	logic	RAT_allo_halt2;

	logic	[`PRF_SIZE-1:0]	PRF_free_list_out;
	logic	PRF_free_valid;

	
	//rrat output
	logic 						PRF_free_valid1;
	logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx1;
	logic 						PRF_free_valid2;
	logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx2;
	logic [`ARF_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0]	mispredict_up_idx;
	logic [`PRF_SIZE-1:0]							PRF_free_enable_list;
	logic correct1, correct2, correct;
	

	
	//rat output

	logic							rat1_prf1_rename_valid_out;			//when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	logic							rat1_prf2_rename_valid_out;			//when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.

	logic	[$clog2(`PRF_SIZE)-1:0]	rat1_prf1_rename_idx_out;			//when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	logic	[$clog2(`PRF_SIZE)-1:0]	rat1_prf2_rename_idx_out;			//when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.

	logic   [63:0]					inst1_opa_prf_value;				//opa prf value of instruction1
	logic	[63:0]					inst1_opb_prf_value;				//opb prf value of instruction1
	logic   [63:0]					inst2_opa_prf_value;				//opa prf value of instruction2
	logic	[63:0]					inst2_opb_prf_value;				//opb prf value of instruction2
	logic							prf_is_full;	
	
	// for writeback
	logic   [63:0]					writeback_value1;
	logic   [63:0]					writeback_value2;

	prf prf1(
		//input
		.clock(clock),
		.reset(reset),

		.cdb1_valid(cdb1_valid),  //initialize the data
		.cdb1_tag(cdb1_tag),
		.cdb1_out(cdb1_out),
		.cdb2_valid(cdb2_valid),
		.cdb2_tag(cdb2_tag),
		.cdb2_out(cdb2_out),		

		.rat1_inst1_opa_prf_idx(opa_PRF_idx1),		//this part done
		.rat1_inst1_opb_prf_idx(opb_PRF_idx1),
		.rat1_inst2_opa_prf_idx(opa_PRF_idx2),
		.rat1_inst2_opb_prf_idx(opb_PRF_idx2),
		.rat2_inst1_opa_prf_idx(0),
		.rat2_inst1_opb_prf_idx(0),
		.rat2_inst2_opa_prf_idx(0),
		.rat2_inst2_opb_prf_idx(0),

		.rat1_allocate_new_prf1(request1),			//h
		.rat1_allocate_new_prf2(request2),			//h
		.rat2_allocate_new_prf1(0),					//h
		.rat2_allocate_new_prf2(0),					//h

		.rrat1_prf_free_list(PRF_free_enable_list),			//h
		.rrat2_prf_free_list(0),							//h
		.rat1_prf_free_list(PRF_free_list_out),				//h
		.rat2_prf_free_list(0),								//h
		.rrat1_branch_mistaken_free_valid(mispredict_sig1),	//h
		.rrat2_branch_mistaken_free_valid(mispredict_sig2),	//h
		
		.rrat1_prf1_free_valid(PRF_free_valid1),				
		.rrat2_prf1_free_valid(0),				
		.rrat1_prf1_free_idx(PRF_free_idx1),			
		.rrat2_prf1_free_idx(0),				
		.rrat1_prf2_free_valid(PRF_free_valid2),			
		.rrat2_prf2_free_valid(0),			
		.rrat1_prf2_free_idx(PRF_free_idx1),			
		.rrat2_prf2_free_idx(0),	
		.rob1_retire_idx(rob1_retire_idx),
		.rob2_retire_idx(rob2_retire_idx),				
		
		//output
		.rat1_prf1_rename_valid_out(rat1_prf1_rename_valid_out),		
		.rat1_prf2_rename_valid_out(rat1_prf2_rename_valid_out),	
		.rat2_prf1_rename_valid_out(0),		
		.rat2_prf2_rename_valid_out(0),		
		.rat1_prf1_rename_idx_out(rat1_prf1_rename_idx_out),		
		.rat1_prf2_rename_idx_out(rat1_prf2_rename_idx_out),
		.rat2_prf1_rename_idx_out(0),		
		.rat2_prf2_rename_idx_out(0),

		.inst1_opa_valid(inst1_opa_valid),			
		.inst1_opb_valid(inst1_opb_valid),			
		.inst2_opa_valid(inst2_opa_valid),			
		.inst2_opb_valid(inst2_opb_valid),		

		.inst1_opa_prf_value(inst1_opa_prf_value),			
		.inst1_opb_prf_value(inst1_opb_prf_value),			
		.inst2_opa_prf_value(inst2_opa_prf_value),			
		.inst2_opb_prf_value(inst2_opb_prf_value),
		
		.prf_is_full(prf_is_full),
		
		//for writeback
		.writeback_value1(writeback_value1),
		.writeback_value2(writeback_value2)

);


	rat rat1(
	//input
	.reset(reset),
	.clock(clock),
	.inst1_enable(1),
	.inst2_enable(1),

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

	.PRF_rename_valid1(rat1_prf1_rename_valid_out),
	.PRF_rename_idx1(rat1_prf1_rename_idx_out),

	.PRF_rename_valid2(rat1_prf2_rename_valid_out),
	.PRF_rename_idx2(rat1_prf2_rename_idx_out),

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
	.mispredict_up_idx(mispredict_up_idx),
	.PRF_free_enable_list(PRF_free_enable_list)
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

	inst2_enable		= 1;
	opa_ARF_idx2 		= 0;
	opb_ARF_idx2 		= 0;
	dest_ARF_idx2 		= 1;
	dest_rename_sig2 	= 1;
	opa_valid_in2 		= 1;
	opb_valid_in2 		= 1;
	mispredict_sig2 	= 0;

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
