module test_rob_one_entry;
	logic	reset;
	logic	clock;

//after dispatch 
	logic	[31:0]					inst1_pc_in;                                    //pc in
	logic	[4:0]					inst1_arn_dest_in;                              //the architected register number of the destination of this instruction
	logic	[$clog2(`PRF_SIZE)-1:0] inst1_prn_dest_in;                              //the prf number assigned to the destination of this instruction
	logic							inst1_is_branch_in;             				//if this instruction is a branch
	logic 							inst1_rob_load_in;								//tell this entry if we want to load this instruction
	logic							inst1_if_thread1;								//the it is for thread1, else it is for thread2


	logic	[31:0]					inst2_pc_in;                                    //pc in
	logic	[4:0]					inst2_arn_dest_in;                              //the architected register number of the destination of this instruction
	logic	[$clog2(`PRF_SIZE)-1:0] inst2_prn_dest_in;                              //the prf number assigned to the destination of this instruction
	logic							inst2_is_branch_in;                             //if this instruction is a branch
	logic 							inst2_rob_load_in;				//tell this entry if we want to load this instruction
	logic							inst2_if_thread1;				//the it is for thread1, else it is for thread2
//after execution
	logic							is_ex_in;                                      	//if this instruciont has been executed so that the value of the prf number assigned is valid
	logic							mispredict_in;                                 	//after execution, if this instruction is a branch and it has been taken , this logic should be "1"
	logic							enable;					       	//if the logic can be loaded to this entry
 	logic							if_committed;		                       	//if this ROB entry hit the head of the ROB and is about to be committed

//logic:
//is this entry is about to be commmited, the logic takes effect
	logic							is_ex_out;
	logic							is_branch_out;				       	//if this instruction is a branch
	logic							available_out;				       	//if this rob entry is available
	logic							mispredict_out;				       	//if this instrucion is mispredicted
	logic	[4:0]					arn_dest_out;                                  	//the architected register number of the destination of this instruction
	logic	[$clog2(`PRF_SIZE)-1:0]	prn_dest_out;                                  	//the prf number of the destination of this instruction
	logic							if_rename_out;				       	//if this entry is committed at this moment(tell RRAT)

	rob_one_entry roe(
		//logic
		reset,
		clock,
		
		//after dispatch
		inst1_pc_in,            //pc in
		inst1_arn_dest_in,      //the architected register number of the destination of this instruction
		inst1_prn_dest_in,      //the prf number assigned to the destination of this instruction
		inst1_is_branch_in,     //if this instruction is a branch
		inst1_rob_load_in,		//tell this entry if we want to load this instruction
		inst1_if_thread1,		//the it is for thread1, else it is for thread2

		inst2_pc_in,            //pc in
		inst2_arn_dest_in,		//the architected register number of the destination of this instruction
		inst2_prn_dest_in,		//the prf number assigned to the destination of this instruction
		inst2_is_branch_in,		//if this instruction is a branch
		inst2_rob_load_in,		//tell this entry if we want to load this instruction
		inst2_if_thread1,		//the it is for thread1, else it is for thread2

		//after execution
		is_ex_in,                                      	//if this instruciont has been executed so that the value of the prf number assigned is valid
		mispredict_in,                                 	//after execution, if this instruction is a branch and it has been taken , this logic should be "1"
		enable,					       	//if the logic can be loaded to this entry
		if_committed,		                       	//if this ROB entry hit the head of the ROB and is about to be committed

		//is this entry is about to be commmited, the logic takes effect
		is_ex_out,
		is_branch_out,				       	//if this instruction is a branch
		available_out,				       	//if this rob entry is available
		mispredict_out,				       	//if this instrucion is mispredicted
		arn_dest_out,                                  	//the architected register number of the destination of this instruction
		prn_dest_out,                                  	//the prf number of the destination of this instruction
		if_rename_out				       	//if this entry is committed at this moment(tell RRAT)
	);
	
	always #5 clock = ~clock;
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask
	
	initial 
	begin
		$monitor("time:%d, clk:%b, is_ex_out:%h, is_branch_out:%h, available_out:%h, mispredict_out:%h, arn_dest_out:%h, prn_dest_out:%h, if_rename_out:%h\n",
			$time, clock, is_ex_out, is_branch_out, available_out,	mispredict_out,	arn_dest_out, prn_dest_out,	if_rename_out);

		clock = 0;
		//RESET
		reset = 1;
		@(negedge clock);
		reset = 0;
		inst1_pc_in = 4;
		inst1_arn_dest_in = 1;
		inst1_prn_dest_in =	4;
		inst1_is_branch_in = 0;
		inst1_rob_load_in = 1;
		inst2_rob_load_in = 0;
		inst1_if_thread1 = 1;
		inst1_is_branch_in = 0;
		is_ex_in = 1;
		enable = 1;
		if_committed = 0;
		@(negedge clock);
		inst1_rob_load_in = 0;
		is_ex_in = 1;
		mispredict_in = 0;
		@(negedge clock);
		is_ex_in = 0;
		if_committed = 1;
		mispredict_in = 1;
		@(negedge clock);
		@(negedge clock);
		$finish;
	end
endmodule
