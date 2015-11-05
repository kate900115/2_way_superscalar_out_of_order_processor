module test_rat;

	//input
	logic	reset;	//reset signal
	logic	clock;	//the clock
	logic	[$clog2(`ARF_SIZE)-1:0]	opa_ARF_idx;	//we will use opa_ARF_idx to find PRF_idx
	logic	[$clog2(`ARF_SIZE)-1:0]	opb_ARF_idx;	//to find PRF_idx
	logic	[$clog2(`ARF_SIZE)-1:0]	dest_ARF_idx;	//the ARF index of dest reg
	logic	dest_rename_sig;	//if high; dest_reg need rename; imme => low

	logic	opa_valid_in;	//if high opa_valid is immediate
	logic	opb_valid_in;

	logic	[`ARF_SIZE-1:0]	[clog2(`PRF_SIZE)-1:0]	mispredict_up_idx;	//if mispredict happens; need to copy from rrat
	logic	mispredict_sig;	//indicate weather mispredict happened

	logic	PRF_rename_valid;	//we get valid signal from prf if the dest address has been request
	logic	[$clog2(`PRF_SIZE)-1:0]	PRF_rename_idx;	//the PRF going to allocate for dest

	//output
	logic	[$clog2(`PRF_SIZE)-1:0]	opa_PRF_idx;
	logic	[$clog2(`PRF_SIZE)-1:0]	opb_PRF_idx;
	logic	request;  //send to PRF indicate weather it request data
	logic	[`ARF_SIZE-1:0]	PRF_free_sig;
	logic	[`ARF_SIZE-1:0]	[$clog2(`PRF_SIZE)-1:0] PRF_free_list;
	logic	RAT_allo_halt;
	logic	opa_valid_out;	//if high opa_valid is immediate
	logic	opb_valid_out;

	logic correct;

rat rat1(

	//input
	.reset(reset),
	.clock(clock),
	.opa_ARF_idx(opa_ARF_idx),
	.opb_ARF_idx(opb_ARF_idx),
	.dest_ARF_idx(dest_ARF_idx),
	.dest_rename_sig(dest_rename_sig),
	.opa_valid_in(opa_valid_in),
	.opb_valid_in(opb_valid_in),
	.mispredict_up_idx(mispredict_up_idx),
	.mispredict_sig(mispredict_sig),
	.PRF_rename_valid(PRF_rename_valid),
	.PRF_rename_idx(PRF_rename_idx),

	//output
	.opa_PRF_idx(opa_PRF_idx),
	.opb_PRF_idx(opb_PRF_idx),
	.request(request),
	.PRF_free_sig(PRF_free_sig),
	.PRF_free_list(PRF_free_list),
	.RAT_allo_halt(RAT_allo_halt),
	.opa_valid_out(opa_valid_out),
	.opb_valid_out(opb_valid_out)
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
	$monitor (" @@@ time:%d, \n\
					opa_PRF_idx:%b, \n\
					opb_PRF_idx:%b, \n\
					request:%b, \n\
					PRF_free_sig:%b, \n\
					PRF_free_list:%b, \n\
					RAT_allo_halt:%b, \n\
					opa_valid_out:%b, \n\
					opb_valid_out:%b", \n\
			$time, opa_PRF_idx, opb_PRF_idx, request, PRF_free_sig, PRF_free_list, RAT_allo_halt, opa_valid_out, opb_valid_out);

	clock = 0;
	//***RESET**
	reset = 1;

	//HERE we initial the reg
	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 0;
	dest_ARF_idx 		= 0;
	dest_rename_sig 	= 1;
	opa_valid_in 		= 1;
	opb_valid_in 		= 1;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 1;
	PRF_rename_idx 		= 12;

	correct = 	opa_PRF_idx == 0 &&
				opb_PRF_idx == 0 &&
				request 	== 1 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 1 &&
				opb_valid_out == 1;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 0;
	dest_ARF_idx 		= 1;
	dest_rename_sig 	= 1;
	opa_valid_in 		= 1;
	opb_valid_in 		= 1;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 1;
	PRF_rename_idx 		= 3;

	correct = 	opa_PRF_idx == 0 &&
				opb_PRF_idx == 0 &&
				request 	== 1 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 1 &&
				opb_valid_out == 1;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 0;
	dest_ARF_idx 		= 2;
	dest_rename_sig 	= 1;
	opa_valid_in 		= 1;
	opb_valid_in 		= 1;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 1;
	PRF_rename_idx 		= 9;

	correct = 	opa_PRF_idx == 0 &&
				opb_PRF_idx == 0 &&
				request 	== 1 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 1 &&
				opb_valid_out == 1;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 0;
	dest_ARF_idx 		= 3;
	dest_rename_sig 	= 1;
	opa_valid_in 		= 1;
	opb_valid_in 		= 1;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 1;
	PRF_rename_idx 		= 10;

	correct = 	opa_PRF_idx == 0 &&
				opb_PRF_idx == 0 &&
				request 	== 1 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 1 &&
				opb_valid_out == 1;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 0;
	dest_ARF_idx 		= 4;
	dest_rename_sig 	= 1;
	opa_valid_in 		= 1;
	opb_valid_in 		= 1;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 1;
	PRF_rename_idx 		= 5;

	correct = 	opa_PRF_idx == 0 &&
				opb_PRF_idx == 0 &&
				request 	== 1 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 1 &&
				opb_valid_out == 1;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 0;
	dest_ARF_idx 		= 0;
	dest_rename_sig 	= 0;
	opa_valid_in 		= 0;
	opb_valid_in 		= 0;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 0;
	PRF_rename_idx 		= 0;

	correct = 	opa_PRF_idx == 0 &&
				opb_PRF_idx == 0 &&
				request 	== 0 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 0 &&
				opb_valid_out == 0;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 0;
	dest_ARF_idx 		= 0;
	dest_rename_sig 	= 0;
	opa_valid_in 		= 0;
	opb_valid_in 		= 0;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 0;
	PRF_rename_idx 		= 0;

	correct = 	opa_PRF_idx == 0 &&
				opb_PRF_idx == 0 &&
				request 	== 0 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 0 &&
				opb_valid_out == 0;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 0;
	dest_ARF_idx 		= 4;
	dest_rename_sig 	= 1;
	opa_valid_in 		= 1;
	opb_valid_in 		= 1;
	mispredict_up_idx[0]= 8;
	mispredict_up_idx[1]= 3;
	mispredict_up_idx[2]= 9;
	mispredict_up_idx[3]= 6;
	mispredict_up_idx[4]= 5;
	mispredict_sig 		= 1;
	PRF_rename_valid	= 1;
	PRF_rename_idx 		= 5;

	correct = 	opa_PRF_idx == 0 &&
				opb_PRF_idx == 0 &&
				request 	== 0 &&
				PRF_free_sig == 2'b01001 &&
				PRF_free_list[0] == 8 &&
				PRF_free_list[1] == 0 &&
				PRF_free_list[2] == 0 &&
				PRF_free_list[3] == 6 &&
				PRF_free_list[4] == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 1 &&
				opb_valid_out == 1;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 1;
	opb_ARF_idx 		= 4;
	dest_ARF_idx 		= 2;
	dest_rename_sig 	= 1;
	opa_valid_in 		= 0;
	opb_valid_in 		= 0;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 1;
	PRF_rename_idx 		= 0;

	correct = 	opa_PRF_idx == 3 &&
				opb_PRF_idx == 5 &&
				request 	== 1 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 0 &&
				opb_valid_out == 0;
	if(!correct) exit_on_error;

	#5
	reset 				= 0;
	opa_ARF_idx 		= 0;
	opb_ARF_idx 		= 2;
	dest_ARF_idx 		= 0;
	dest_rename_sig 	= 1;
	opa_valid_in 		= 0;
	opb_valid_in 		= 0;
	mispredict_up_idx 	= 0;
	mispredict_sig 		= 0;
	PRF_rename_valid	= 1;
	PRF_rename_idx 		= 1;

	correct = 	opa_PRF_idx == 12 &&
				opb_PRF_idx == 0 &&
				request 	== 1 &&
				PRF_free_sig == 0 &&
				PRF_free_list == 0 &&
				RAT_allo_halt == 0 &&
				opa_valid_out == 0 &&
				opb_valid_out == 0;
	if(!correct) exit_on_error;
end

endmodules