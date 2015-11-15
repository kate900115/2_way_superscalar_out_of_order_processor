module test_rob;
	logic						reset;
	logic						clock;
	
	logic							is_thread1;					//if it ==1, it is for thread1, else it is for thread 2
//instruction1 logic
	logic	[31:0]					inst1_pc_in;				//the pc of the instruction
	logic	[4:0]					inst1_arn_dest_in;			//the arf number of the destinaion of the instruction
	logic	[$clog2(`PRF_SIZE)-1:0] inst1_prn_dest_in;			//the prf number of the destination of this instruction
	logic							inst1_is_branch_in;			//if this instruction is a branch
	logic 							inst1_load_in;				//tell rob if instruction1 is valid

//instruction2 logic
	logic	[31:0]					inst2_pc_in;				//the pc of the instruction
	logic	[4:0]					inst2_arn_dest_in;			//the arf number of the destinaion of the instruction
	logic	[$clog2(`PRF_SIZE)-1:0] inst2_prn_dest_in;          //the prf number of the destination of this instruction
	logic							inst2_is_branch_in;			//if this instruction is a branch
	logic 							inst2_load_in;		       	//tell rob if instruction2 is valid
//when executed,for each function unit,  the number of rob need to know so we can set the if_executed to of the entry to be 1
	logic	[5:0]							if_fu_executed;		//if the instruction in the first multiplyer has been executed
	logic	[5:0][$clog2(`ROB_SIZE)-1:0]	fu_rob_idx;			//the rob number of the instruction in the first multiplyer
	logic	[5:0]							fu_is_thread1;			//the rob number of the instruction in the first multiplyer
	logic	[5:0]							mispredict_in;

	logic						if_fu_executed1;		//if the instruction in the first multiplyer has been executed
	logic	[$clog2(`ROB_SIZE):0]			fu_rob_idx1;			//the rob number of the instruction in the first multiplyer
	logic						mispredict_in1;			//the rob number of the instruction in the first multiplyer
	logic						target_pc_in1;
	logic						if_cdb1_is_thread1;

	logic						if_fu_executed2;		//if the instruction in the first multiplyer has been executed
	logic	[$clog2(`ROB_SIZE):0]			fu_rob_idx2;			//the rob number of the instruction in the first multiplyer
	logic						mispredict_in2;			//the rob number of the instruction in the first multiplyer
	logic						target_pc_in2;
	logic						if_cdb2_is_thread1;

//after dispatching, we need to send rs the rob number we assigned to instruction1 and instruction2
	logic	[$clog2(`ROB_SIZE):0]		inst1_rs_rob_idx_in;					//it is combinational logic so that the  is dealt with right after a
	logic	[$clog2(`ROB_SIZE):0]		inst2_rs_rob_idx_in;					//instruction comes in, and then this signal is immediately sent to rs to
																					//store in rs
//when committed, the  of the first instrucion committed

	logic	[63:0]							commit1_pc_out;
	logic	[63:0]							commit1_target_pc_out;

	logic								commit1_is_branch_out;				       	//if this instruction is a branch
	logic								commit1_mispredict_out;				       	//if this instrucion is mispredicted
	logic	[4:0]							commit1_arn_dest_out;                       //the architected register number of the destination of this instruction
	logic	[$clog2(`PRF_SIZE)-1:0]					commit1_prn_dest_out;						//the prf number of the destination of this instruction
	logic								commit1_if_rename_out;				       	//if this entry is committed at this moment(tell RRAT)
	logic								commit1_valid;
	logic								commit1_is_thread1;
//when committed, the  of the second instruction committed

	logic	[63:0]							commit2_pc_out;
	logic	[63:0]							commit2_target_pc_out;
	logic								commit2_is_branch_out;						//if this instruction is a branch
	logic								commit2_mispredict_out;				       	//if this instrucion is mispredicted
	logic	[4:0]						commit2_arn_dest_out;						//the architected register number of the destination of this instruction
	logic	[$clog2(`PRF_SIZE)-1:0]		commit2_prn_dest_out;						//the prf number of the destination of this instruction
	logic								commit2_if_rename_out;				       	//if this entry is committed at this moment(tell RRAT)
	logic								commit2_valid;
	logic								commit2_is_thread1;
	logic								t1_is_full;
	logic								t2_is_full;

	rob r1(
		//logic
		.reset(reset),
		.clock(clock),
	
		.is_thread1(is_thread1),					//if it ==1, it is for thread1, else it is for thread 2
//instruction1 
		.inst1_pc_in(inst1_pc_in),				//the pc of the instruction
		.inst1_arn_dest_in(inst1_arn_dest_in),			//the arf number of the destinaion of the instruction
		.inst1_prn_dest_in(inst1_prn_dest_in),			//the prf number of the destination of this instruction
		.inst1_is_branch_in(inst1_is_branch_in),			//if this instruction is a branch
	 	.inst1_load_in(inst1_load_in),				//tell rob if instruction1 is valid

//instruction2 
		.inst2_pc_in(inst2_pc_in),				//the pc of the instruction
		.inst2_arn_dest_in(inst2_arn_dest_in),			//the arf number of the destinaion of the instruction
		.inst2_prn_dest_in(inst2_prn_dest_in),          //the prf number of the destination of this instruction
		.inst2_is_branch_in(inst2_is_branch_in),			//if this instruction is a branch
	 	.inst2_load_in(inst2_load_in),		       	//tell rob if instruction2 is valid
//when executed,for each function unit,  the number of rob need to know so we can set the if_executed to of the entry to be 1
		.if_fu_executed1(if_fu_executed1),		//if the instruction in the first multiplyer has been executed
		.fu_rob_idx1(fu_rob_idx1),			//the rob number of the instruction in the first multiplyer
		.mispredict_in1(mispredict_in1),			//the rob number of the instruction in the first multiplyer
		.target_pc_in1(target_pc_in1),
		.if_cdb1_is_thread1(if_cdb1_is_thread1),

		.if_fu_executed2(if_fu_executed2),		//if the instruction in the first multiplyer has been executed
		.fu_rob_idx2(fu_rob_idx2),			//the rob number of the instruction in the first multiplyer
		.mispredict_in2(mispredict_in2),			//the rob number of the instruction in the first multiplyer
		.target_pc_in2(target_pc_in2),
		.if_cdb2_is_thread1(if_cdb2_is_thread1),

//after dispatching, we need to send rs the rob number we assigned to instruction1 and instruction2
		.inst1_rs_rob_idx_in(inst1_rs_rob_idx_in),					//it is combinational logic so that the  is dealt with right after a
		.inst2_rs_rob_idx_in(inst2_rs_rob_idx_in),					//instruction comes in, and then this signal is immediately sent to rs to
																						//store in rs
//when committed, the  of the first instrucion committed
		.commit1_pc_out(commit1_pc_out),
		.commit1_target_pc_out(commit1_target_pc_out),
		.commit1_is_branch_out(commit1_is_branch_out),				       	//if this instruction is a branch
		.commit1_mispredict_out(commit1_mispredict_out),				       	//if this instrucion is mispredicted
		.commit1_arn_dest_out(commit1_arn_dest_out),                       //the architected register number of the destination of this instruction
		.commit1_prn_dest_out(commit1_prn_dest_out),						//the prf number of the destination of this instruction
		.commit1_if_rename_out(commit1_if_rename_out),				       	//if this entry is committed at this moment(tell RRAT)
		.commit1_valid(commit1_valid),
		.commit1_is_thread1(commit1_is_thread1),
//when committed, the  of the second instruction committed
		.commit2_is_branch_out(commit2_is_branch_out),						//if this instruction is a branch
		.commit2_mispredict_out(commit2_mispredict_out),				       	//if this instrucion is mispredicted
		.commit2_arn_dest_out(commit2_arn_dest_out),						//the architected register number of the destination of this instruction
		.commit2_prn_dest_out(commit2_prn_dest_out),						//the prf number of the destination of this instruction
		.commit2_if_rename_out(commit2_if_rename_out),				       	//if this entry is committed at this moment(tell RRAT)
		.commit2_valid(commit2_valid),
		.commit2_is_thread1(commit2_is_thread1),
		.t1_is_full(t1_is_full),
		.t2_is_full(t2_is_full)
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
		$monitor("@@@time:%.0f, clk:%b, \n\
		inst1_load_in:%h, \n\
		 inst1_rs_rob_idx_in:%h, commit1_is_branch_out:%h, commit1_mispredict_out:%h, commit1_arn_dest_out:%h, commit1_prn_dest_out:%h, commit1_if_rename_out:%h, commit1_valid:%h, commit1_is_thread1:%h, t1_is_full:%h,\n\
		inst2_rs_rob_idx_in:%h, commit2_is_branch_out:%h, commit2_mispredict_out:%h, commit2_arn_dest_out:%h, commit2_prn_dest_out:%h, commit2_if_rename_out:%h, commit2_valid:%h, commit2_is_thread1:%h, t2_is_full:%h",
			$time, clock, 
			inst1_load_in, inst1_rs_rob_idx_in, commit1_is_branch_out, commit1_mispredict_out, commit1_arn_dest_out, commit1_prn_dest_out, commit1_if_rename_out, commit1_valid, commit1_is_thread1, t1_is_full,
			inst2_rs_rob_idx_in, commit2_is_branch_out, commit2_mispredict_out, commit2_arn_dest_out, commit2_prn_dest_out, commit2_if_rename_out, commit2_valid, commit2_is_thread1, t2_is_full);

		clock = 0;
		//RESET
		reset = 1;
		inst1_load_in = 0;
		inst2_load_in = 0;
		@(negedge clock);
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 4;
		inst1_arn_dest_in = 1;
		inst1_prn_dest_in = 1;
		inst1_is_branch_in = 0;
		inst2_pc_in = 8;
		inst2_arn_dest_in = 2;
		inst2_prn_dest_in = 2;
		inst2_is_branch_in = 1;
		@(negedge clock);
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 12;
		inst1_arn_dest_in = 3;
		inst1_prn_dest_in = 3;
		inst1_is_branch_in = 0;
		inst2_pc_in = 16;
		inst2_arn_dest_in = 4;
		inst2_prn_dest_in = 4;
		inst2_is_branch_in = 0;

		for(int i=1;i<8;i++)
		begin
		@(negedge clock);
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = i*8+12;
		inst1_arn_dest_in = i*2+3;
		inst1_prn_dest_in = i*2+3;
		inst1_is_branch_in = 0;
		inst2_pc_in = i*8+16;
		inst2_arn_dest_in = i*2+4;
		inst2_prn_dest_in = i*2+4;
		inst2_is_branch_in = 0;

		end
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		
		$finish;
	end
endmodule




/*
@(negedge clock);
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 4;
		inst1_arn_dest_in = 1;
		inst1_prn_dest_in = 1;
		inst1_is_branch_in = 0;
		inst2_pc_in = 8;
		inst2_arn_dest_in = 2;
		inst2_prn_dest_in = 2;
		inst2_is_branch_in = 1;
		@(negedge clock);
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 12;
		inst1_arn_dest_in = 3;
		inst1_prn_dest_in = 3;
		inst1_is_branch_in = 0;
		inst2_pc_in = 16;
		inst2_arn_dest_in = 4;
		inst2_prn_dest_in = 4;
		inst2_is_branch_in = 0;
		@(negedge clock);
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 4;
		inst1_arn_dest_in = 1;
		inst1_prn_dest_in = 1;
		inst1_is_branch_in = 0;
		inst2_pc_in = 8;
		inst2_arn_dest_in = 2;
		inst2_prn_dest_in = 2;
		inst2_is_branch_in = 1;
		@(negedge clock);
		if_fu_executed1=1;		//if the instruction in the first multiplyer has been executed
		fu_rob_idx1=0;			//the rob number of the instruction in the first multiplyer
		mispredict_in1=0;			//the rob number of the instruction in the first multiplyer
		target_pc_in1=4;
		if_cdb1_is_thread1=1;

		if_fu_executed2=1;		//if the instruction in the first multiplyer has been executed
		fu_rob_idx2=`ROB_SIZE'd1;			//the rob number of the instruction in the first multiplyer
		mispredict_in2=0;			//the rob number of the instruction in the first multiplyer
		target_pc_in2=8;
		if_cdb2_is_thread1=1;
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		if_fu_executed1=1;		//if the instruction in the first multiplyer has been executed
		fu_rob_idx1=`ROB_SIZE'd2;			//the rob number of the instruction in the first multiplyer
		mispredict_in1=0;			//the rob number of the instruction in the first multiplyer
		target_pc_in1=12;
		if_cdb1_is_thread1=1;

		if_fu_executed2=1;		//if the instruction in the first multiplyer has been executed
		fu_rob_idx2=`ROB_SIZE'd3;			//the rob number of the instruction in the first multiplyer
		mispredict_in2=0;			//the rob number of the instruction in the first multiplyer
		target_pc_in2=16;
		if_cdb2_is_thread1=1;
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
*/
