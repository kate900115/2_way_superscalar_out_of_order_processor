module test_rob;
	//input
	logic							reset;
	logic							clock;
	
	logic							is_thread1;					//the two instructions are thread1 or thread2 if it ==1, it is for thread1, else it is for thread 2
	//instruction1 input
	logic	[63:0]					inst1_pc_in;				//the pc of the instruction
	logic	[4:0]					inst1_arn_dest_in;			//the arf number of the destinaion of the instruction
	logic	[$clog2(`PRF_SIZE)-1:0] inst1_prn_dest_in;			//the prf number of the destination of this instruction
	logic							inst1_is_branch_in;			//if this instruction is a branch
	logic							inst1_is_halt_in;
	logic							inst1_is_illegal_in;
	logic 							inst1_load_in;				//tell rob if instruction1 is valid

	//instruction2 input
	logic	[63:0]					inst2_pc_in;				//the pc of the instruction
	logic	[4:0]					inst2_arn_dest_in;			//the arf number of the destinaion of the instruction
	logic	[$clog2(`PRF_SIZE)-1:0] inst2_prn_dest_in;          //the prf number of the destination of this instruction
	logic							inst2_is_branch_in;			//if this instruction is a branch
	logic							inst2_is_halt_in;
	logic							inst2_is_illegal_in;
	logic 							inst2_load_in;		       	//tell rob if instruction2 is valid
	
	//when executed,for each function unit,  the number of rob need to know so we can set the if_executed to of the entry to be 1
	logic							if_fu_executed1;			//if the instruction in the first FU has been executed 
	logic	[$clog2(`ROB_SIZE):0]	fu_rob_idx1;				//the rob number of the instruction in the first FU
	logic							mispredict_in1;
	logic	[63:0]					target_pc_in1;
	
	logic							if_fu_executed2;			//if the instruction in the second FU has been executed 
	logic	[$clog2(`ROB_SIZE):0]	fu_rob_idx2;				//the rob number of the instruction in the second FU
	logic							mispredict_in2;
	logic	[63:0]					target_pc_in2;

	//output
	//after dispatching, we need to send rs the rob number we assigned to instruction1 and instruction2
	logic	[$clog2(`ROB_SIZE):0]	inst1_rs_rob_idx_in;		//it is combinational logic so that the output is dealt with right after a
	logic	[$clog2(`ROB_SIZE):0]	inst2_rs_rob_idx_in;		//instruction comes in, and then this signal is immediately sent to rs to
																//store in rs
	//when committed, the output of the first instrucion committed
	logic	[63:0]					commit1_pc_out;
 	logic	[63:0]					commit1_target_pc_out;
	logic							commit1_is_branch_out;	     //if this instruction is a branch
	logic							commit1_mispredict_out;		 //if this instrucion is mispredicted
	logic	[4:0]					commit1_arn_dest_out;        //the architected register number of the destination of this instruction
	logic	[$clog2(`PRF_SIZE)-1:0]	commit1_prn_dest_out;		 //the prf number of the destination of this instruction
	logic							commit1_if_rename_out;		 //if this entry is committed at this moment(tell RRAT)
	logic							commit1_valid;
	logic							commit1_is_halt_out;
	logic							commit1_is_illegal_out;
	logic							commit1_is_thread1;
	//when committed, the output of the second instruction committed
	logic	[63:0]					commit2_pc_out;
	logic	[63:0]					commit2_target_pc_out;
	logic							commit2_is_branch_out;		  //if this instruction is a branch
	logic							commit2_mispredict_out;		  //if this instrucion is mispredicted
	logic	[4:0]					commit2_arn_dest_out;		  //the architected register number of the destination of this instruction
	logic	[$clog2(`PRF_SIZE)-1:0]	commit2_prn_dest_out;		  //the prf number of the destination of this instruction
	logic							commit2_if_rename_out;		  //if this entry is committed at this moment(tell RRAT)
	logic							commit2_is_halt_out;
	logic							commit2_is_illegal_out;
	logic							commit2_valid;
	logic							commit2_is_thread1;
	logic							t1_is_full;
	logic							t2_is_full;

	rob r1(
		//input
		//normal input
		.reset(reset),
		.clock(clock),
	
		.is_thread1(is_thread1),					
		.inst1_pc_in(inst1_pc_in),				
		.inst1_arn_dest_in(inst1_arn_dest_in),			
		.inst1_prn_dest_in(inst1_prn_dest_in),			
		.inst1_is_branch_in(inst1_is_branch_in),			
		.inst1_is_halt_in(inst1_is_halt_in),
		.inst1_is_illegal_in(inst1_is_illegal_in),
		.inst1_load_in(inst1_load_in),				


		.inst2_pc_in(inst2_pc_in),			
		.inst2_arn_dest_in(inst2_arn_dest_in),			
		.inst2_prn_dest_in(inst2_prn_dest_in),          
		.inst2_is_branch_in(inst2_is_branch_in),			
		.inst2_is_halt_in(inst2_is_halt_in),
		.inst2_is_illegal_in(inst2_is_illegal_in),
		.inst2_load_in(inst2_load_in),		       

		.if_fu_executed1(if_fu_executed1),		
		.fu_rob_idx1(fu_rob_idx1),			
		.mispredict_in1(mispredict_in1),
		.target_pc_in1(target_pc_in1),
		.if_fu_executed2(if_fu_executed2),	
		.fu_rob_idx2(fu_rob_idx2),			
		.mispredict_in2(mispredict_in2),
		.target_pc_in2(target_pc_in2),
//output

		.inst1_rs_rob_idx_in(inst1_rs_rob_idx_in),				
		.inst2_rs_rob_idx_in(inst2_rs_rob_idx_in),
																					
		.commit1_pc_out(commit1_pc_out),
		.commit1_target_pc_out(commit1_target_pc_out),
		.commit1_is_branch_out(commit1_is_branch_out),				       	
		.commit1_mispredict_out(commit1_mispredict_out),				       
		.commit1_arn_dest_out(commit1_arn_dest_out),                       
		.commit1_prn_dest_out(commit1_prn_dest_out),					
		.commit1_if_rename_out(commit1_if_rename_out),				       	
		.commit1_valid(commit1_valid),
		.commit1_is_halt_out(commit1_is_halt_out),
		.commit1_is_illegal_out(commit1_is_illegal_out),
		.commit1_is_thread1(commit1_is_thread1),

		.commit2_pc_out(commit2_pc_out),
		.commit2_target_pc_out(commit2_target_pc_out),
		.commit2_is_branch_out(commit2_is_branch_out),						
		.commit2_mispredict_out(commit2_mispredict_out),				       
		.commit2_arn_dest_out(commit2_arn_dest_out),					
		.commit2_prn_dest_out(commit2_prn_dest_out),						
		.commit2_if_rename_out(commit2_if_rename_out),				  
		.commit2_is_halt_out(commit2_is_halt_out),
		.commit2_is_illegal_out(commit2_is_illegal_out),
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
		inst1_pc_in:%d,\n\
		commit1_pc_out:%d,\n\
		inst1_load_in:%h, \n\
		inst1_rs_rob_idx_in:%h,\n\
		commit1_is_branch_out:%h\n\
		commit1_mispredict_out:%h, \n\
		commit1_arn_dest_out:%h, \n\
		commit1_prn_dest_out:%h, \n\
		commit1_if_rename_out:%h, \n\
		commit1_valid:%h, \n\
		commit1_is_thread1:%h, \n\
		commit1_is_halt_out:%b,\n\
		commit1_is_illegal_out:%b,\n\
		t1_is_full:%h,\n\
		inst2_pc_in:%d\n\
		commit2_pc_out:%d,\n\
		inst2_load_in:%b,\n\
		inst2_rs_rob_idx_in:%h,\n\
		commit2_is_branch_out:%h, \n\
		commit2_mispredict_out:%h, \n\
		commit2_arn_dest_out:%h, \n\
		commit2_prn_dest_out:%h, \n\
		commit2_if_rename_out:%h, \n\
		commit2_valid:%h, \n\
		commit2_is_thread1:%h, \n\
		commit2_is_halt_out:%b,\n\
		commit2_is_illegal_out:%b,\n\
		t2_is_full:%h",
			$time, clock, 
			inst1_pc_in, commit1_pc_out, inst1_load_in, inst1_rs_rob_idx_in, commit1_is_branch_out, commit1_mispredict_out, commit1_arn_dest_out, commit1_prn_dest_out, commit1_if_rename_out, commit1_valid, commit1_is_thread1,commit1_is_halt_out,commit1_is_illegal_out, t1_is_full,
			inst2_pc_in, commit2_pc_out, inst2_load_in, inst2_rs_rob_idx_in, commit2_is_branch_out, commit2_mispredict_out, commit2_arn_dest_out, commit2_prn_dest_out, commit2_if_rename_out, commit2_valid, commit2_is_thread1, commit2_is_halt_out,commit2_is_illegal_out,t2_is_full);

		clock = 0;
		//RESET
		reset = 1;
		$display("reset!");
		inst1_load_in = 0;
		inst2_load_in = 0;
		@(negedge clock);
		$display("\n @@@ load two instructions(4 & 8) in, the first one is a halt");
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
		
		inst1_is_halt_in = 1;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=0;	
		fu_rob_idx1	=0;		
		mispredict_in1=0;
		target_pc_in1=0;
		if_fu_executed2	=0;
		fu_rob_idx2	=0;		
		mispredict_in2=0;
		target_pc_in2=0;
		@(negedge clock);
		$display("\n @@@ load next two instructions(12 & 16) in, the second one is a branch");
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 12;
		inst1_arn_dest_in = 3;
		inst1_prn_dest_in = 3;
		inst1_is_branch_in = 1;
		inst2_pc_in = 16;
		inst2_arn_dest_in = 4;
		inst2_prn_dest_in = 4;
		inst2_is_branch_in = 0;
		
		inst1_is_halt_in = 0;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=0;	
		fu_rob_idx1	=0;		
		mispredict_in1=0;
		target_pc_in1=0;
		if_fu_executed2	=0;
		fu_rob_idx2	=0;		
		mispredict_in2=0;
		target_pc_in2=0;
		
		@(negedge clock);
		$display("\n @@@ load next two instructions(20 & 24) in");
		$display(" @@@ CDB send two result idx(2 & 3) in");
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 20;
		inst1_arn_dest_in = 3;
		inst1_prn_dest_in = 3;
		inst1_is_branch_in = 0;
		inst2_pc_in = 24;
		inst2_arn_dest_in = 4;
		inst2_prn_dest_in = 4;
		inst2_is_branch_in = 0;
		
		inst1_is_halt_in = 0;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=1;	
		fu_rob_idx1	=3;		
		mispredict_in1=0;
		target_pc_in1=0;
		if_fu_executed2	=1;
		fu_rob_idx2	=2;		
		mispredict_in2=0;
		target_pc_in2=0;
		@(negedge clock);
		$display("\n @@@ load next two instructions(28 & 32) in");
		$display(" @@@ CDB send two result idx(0 & 1)in");
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 28;
		inst1_arn_dest_in = 3;
		inst1_prn_dest_in = 3;
		inst1_is_branch_in = 0;
		inst2_pc_in = 32;
		inst2_arn_dest_in = 4;
		inst2_prn_dest_in = 4;
		inst2_is_branch_in = 0;
		
		inst1_is_halt_in = 0;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=1;	
		fu_rob_idx1	=0;		
		mispredict_in1=0;
		target_pc_in1=0;
		if_fu_executed2	=1;
		fu_rob_idx2	=1;		
		mispredict_in2=0;
		target_pc_in2=0;
		
		
		@(negedge clock);
		$display("\n @@@ load next two instructions(36 & 40) in");
		$display("\n @@@ instruction 36 is a branch");
		$display(" @@@ CDB send two result idx(4 & 5)in");
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 36;
		inst1_arn_dest_in = 5;
		inst1_prn_dest_in = 8;
		inst1_is_branch_in = 1;
		inst2_pc_in = 40;
		inst2_arn_dest_in = 4;
		inst2_prn_dest_in = 4;
		inst2_is_branch_in = 0;
		
		inst1_is_halt_in = 0;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=1;	
		fu_rob_idx1	=5;		
		mispredict_in1=0;
		target_pc_in1=0;
		if_fu_executed2	=1;
		fu_rob_idx2	=4;		
		mispredict_in2=0;
		target_pc_in2=0;
		
		@(negedge clock);
		$display("\n @@@ load next two instructions(44 & 48) in");
		$display("\n @@@ branch is mispredict (36)");
		$display(" @@@ CDB send two result idx(8 & 9)in");
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 44;
		inst1_arn_dest_in = 3;
		inst1_prn_dest_in = 5;
		inst1_is_branch_in = 0;
		inst2_pc_in = 48;
		inst2_arn_dest_in = 7;
		inst2_prn_dest_in = 1;
		inst2_is_branch_in = 0;
		
		inst1_is_halt_in = 0;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=1;	
		fu_rob_idx1	=8;		
		mispredict_in1=1;
		target_pc_in1=100;
		if_fu_executed2	=1;
		fu_rob_idx2	=9;		
		mispredict_in2=0;
		target_pc_in2=0;
		
		@(negedge clock);
		$display("\n @@@ load next two instructions(52 & 56) in");
		
		$display(" @@@ CDB send two result idx(6 & 7)in");
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 52;
		inst1_arn_dest_in = 11;
		inst1_prn_dest_in = 2;
		inst1_is_branch_in = 1;
		inst2_pc_in = 56;
		inst2_arn_dest_in = 5;
		inst2_prn_dest_in = 1;
		inst2_is_branch_in = 0;
		
		inst1_is_halt_in = 0;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=1;	
		fu_rob_idx1	=6;		
		mispredict_in1=1;
		target_pc_in1=0;
		if_fu_executed2	=1;
		fu_rob_idx2	=7;		
		mispredict_in2=0;
		target_pc_in2=0;
		
		@(negedge clock);
		$display("\n @@@ load next two instructions(60 & 64) in");
		$display(" @@@ CDB send two result idx(0a & 0b)in");
		reset = 0;
		is_thread1 = 1;
		inst1_load_in = 1;
		inst2_load_in = 1;
		inst1_pc_in = 60;
		inst1_arn_dest_in = 3;
		inst1_prn_dest_in = 5;
		inst1_is_branch_in = 0;
		inst2_pc_in = 64;
		inst2_arn_dest_in = 7;
		inst2_prn_dest_in = 1;
		inst2_is_branch_in = 0;
		
		inst1_is_halt_in = 0;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=1;	
		fu_rob_idx1	=10;		
		mispredict_in1=0;
		target_pc_in1=0;
		if_fu_executed2	=1;
		fu_rob_idx2	=11;		
		mispredict_in2=0;
		target_pc_in2=0;
		
		/*for(int i=1;i<8;i++)
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
		
		inst1_is_halt_in = 0;
		inst1_is_illegal_in	=0;
		inst2_is_halt_in =0;
		inst2_is_illegal_in =0;		       
		if_fu_executed1	=0;	
		fu_rob_idx1	=0;		
		mispredict_in1=0;
		target_pc_in1=0;
		if_fu_executed2	=0;
		fu_rob_idx2	=0;		
		mispredict_in2=0;
		target_pc_in2=0;
		end */
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
