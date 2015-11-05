module test_rrat;
	
	//input
	logic 				reset;
	logic 				clock;
	logic [$clog2(`PRF_SIZE)-1:0]	RoB_PRF_idx;
	logic [$clog2(`ARF_SIZE)-1:0] 	RoB_ARF_idx;
	logic 				RoB_rename_in;	//high when instruction retires
	logic 				mispredict_sig;
	
	//output
	logic 						PRF_free_valid;
	logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx;
	logic [`ARF_SIZE-1:0] [clog2(`PRF_SIZE)-1:0]	mispredict_up_idx;
	logic correct;

rrat rrat1(
	//input
	.reset(reset),
	.clock(clock),
	.RoB_PRF_idx(RoB_PRF_idx),
	.RoB_ARF_idx(RoB_ARF_idx),
	.RoB_rename_in(RoB_rename_in),
	.mispredict_sig(mispredict_sig),

	//output
	.PRF_free_valid(PRF_free_valid),
	.PRF_free_idx(PRF_free_idx),
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
	$monitor (" @@@ time:%d, \n\
					PRF_free_valid:%b, \n\
					PRF_free_idx:%b, \n\
					mispredict_up_idx:%b",
			$time, PRF_free_valid, PRF_free_idx, mispredict_up_idx);


	clock = 0;
	//***RESET*** //1
	reset = 1;
	correct = 1;

	//HERE we initial the reg
	#5 //2
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 1;
	RoB_ARF_idx = 0;
	RoB_PRF_idx = 2;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 0 && PRF_free_idx == 0 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	#5 //3
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 1;
	RoB_ARF_idx = 1;
	RoB_PRF_idx = 3;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 0 && PRF_free_idx == 0 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	#5 //4
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 1;
	RoB_ARF_idx = 2;
	RoB_PRF_idx = 4;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 0 && PRF_free_idx == 0 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	#5 //5
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 1;
	RoB_ARF_idx = 3;
	RoB_PRF_idx = 6;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 0 && PRF_free_idx == 0 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	#5 //6
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 1;
	RoB_ARF_idx = 4;
	RoB_PRF_idx = 5;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 0 && PRF_free_idx == 0 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	//Now we try to replace things
	#5; //7
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 1;
	RoB_ARF_idx = 0;
	RoB_PRF_idx = 7;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 1 && PRF_free_idx == 2 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	#5 //8
	@(negedge clock);	
	reset = 0;
	RoB_rename_in = 1;
	RoB_ARF_idx = 0;
	RoB_PRF_idx = 8;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 1 && PRF_free_idx == 7 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	#5 //9
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 1;
	RoB_ARF_idx = 2;
	RoB_PRF_idx = 9;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 1 && PRF_free_idx == 4 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	#5 //10
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 0;
	RoB_ARF_idx = 0;
	RoB_PRF_idx = 0;
	mispredict_sig = 1;
	correct = (PRF_free_valid == 0 && PRF_free_idx == 0 && 
			mispredict_up_idx[0] == 8 &&
			mispredict_up_idx[1] == 3 &&
			mispredict_up_idx[2] == 9 &&
			mispredict_up_idx[3] == 6 &&
			mispredict_up_idx[4] == 5);
	if(!correct) exit_on_error;

	#5 //11
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 0;
	RoB_ARF_idx = 0;
	RoB_PRF_idx = 0;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 0 && PRF_free_idx == 0 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;

	#5 //12
	@(negedge clock);
	reset = 0;
	RoB_rename_in = 0;
	RoB_ARF_idx = 0;
	RoB_PRF_idx = 0;
	mispredict_sig = 0;
	correct = (PRF_free_valid == 0 && PRF_free_idx == 0 && mispredict_up_idx == 0);
	if(!correct) exit_on_error;



	end

endmodule




























