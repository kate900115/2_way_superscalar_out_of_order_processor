/*******************************************************************************//
//      	modulename: rob.v													//
//      								       									//
//      		Description:					       							//
//      								       									//
//      								       									//
//      								       									//
//      								       									//
//      								       									//
//      								       									//
//      								       									//
//////////////////////////////////////////////////////////////////////////////////

module rob(
	
//normal input
	input						reset,
	input						clock,
	input						rs_rull,
//instruction1 input
	input	[31:0]				inst1_pc_in,						//the pc of the instruction
	input	[4:0]				inst1_arn_dest_in,					//the arf number of the destinaion of the instruction
	input	[`PRF_SIZE-1:0] 	inst1_prn_dest_in,					//the prf number of the destination of this instruction
	input						inst1_is_branch_in,					//if this instruction is a branch
	input 						inst1_load_in,						//tell rob if instruction1 is valid
	input						inst1_is_thread1,					//if it ==1, it is for thread1, else it is for thread 2
//instruction2 input
	input	[31:0]				inst2_pc_in,						//the pc of the instruction
	input	[4:0]				inst2_arn_dest_in,					//the arf number of the destinaion of the instruction
	input	[`PRF_SIZE-1:0] 	inst2_prn_dest_in,                                   	//the prf number of the destination of this instruction
	input						inst2_is_branch_in,                                  	//if this instruction is a branch
	input 						inst2_load_in,				       		//tell rob if instruction2 is valid
	input						inst2_is_thread1,	
//when executed,for each function unit,  the number of rob need to know so we can set the if_executed to of the entry to be 1
	input									if_fu1_mult_executed,					//if the instruction in the first multiplyer has been executed
	input	[$clog2(`ROB_SIZE)-1:0]			fu1_mult_rob_idx,					//the rob number of the instruction in the first multiplyer
	input									if_fu2_mult_executed,
	input	[$clog2(`ROB_SIZE)-1:0]			fu2_mult_rob_idx,
	input									if_fu1_add_executed,
	input	[$clog2(`ROB_SIZE)-1:0]			fu1_add_rob_idx,
	input									if_fu2_add_executed,
	input	[$clog2(`ROB_SIZE)-1:0]			fu2_add_rob_idx,
	input									if_fu1_memory_executed,
	input	[$clog2(`ROB_SIZE)-1:0]			fu1_memory_rob_idx,
	input									if_fu2_memory_executed,
	input	[$clog2(`ROB_SIZE)-1:0]			fu2_memory_rob_idx,
//after dispatching, we need to send rs the rob number we assigned to instruction1 and instruction2
	output	logic	[$clog2(`ROB_SIZE)-1:0]		inst1_rs_rob_idx_in,					//it is combinational logic so that the output is dealt with right after a
																						//instruction comes in, and then this signal is immediately sent to rs to
																						//store in rs
	output	logic	[$clog2(`ROB_SIZE)-1:0]		inst2_rs_rob_idx_in,
//when committed, the output of the first instrucion committed
	output	logic							commit1_is_branch_out,				       	//if this instruction is a branch
	output	logic							commit1_mispredict_out,				       	//if this instrucion is mispredicted
	output	logic	[4:0]					commit1_arn_dest_out,                       //the architected register number of the destination of this instruction
	output	logic	[`PRF_SIZE-1:0]			commit1_prn_dest_out,						//the prf number of the destination of this instruction
	output	logic							commit1_if_rename_out,				       	//if this entry is committed at this moment(tell RRAT)
	output	logic							commit1_valid,
//when committed, the output of the second instruction committed
	output	logic							commit2_is_branch_out,				       	//if this instruction is a branch
	output	logic							commit2_mispredict_out,				       	//if this instrucion is mispredicted
	output	logic	[4:0]					commit2_arn_dest_out,                                  	//the architected register number of the destination of this instruction
	output	logic	[`PRF_SIZE-1:0]			commit2_prn_dest_out,                                  	//the prf number of the destination of this instruction
	output	logic							commit2_if_rename_out,				       	//if this entry is committed at this moment(tell RRAT)
	output	logic							commit2_valid
);

//data logic variable needed

//function variable needed
	logic 	[ROB_SIZE-1:0]				t1_head;						//head of thread1
	logic 	[ROB_SIZE-1:0]				t1_tail;						//tail of tail1
	logic 	[ROB_SIZE-1:0]				t2_head;
	logic 	[ROB_SIZE-1:0]				t2_tail;
//internal logic variable needed
	logic	[`ROB_SIZE-1:0]				rob1_internal_is_branch_out;
	logic	[`ROB_SIZE-1:0]				rob1_internal_available_out;
	logic	[`ROB_SIZE-1:0]				rob1_internal_mispredict_out;
	logic	[`ROB_SIZE-1:0][4:0]		rob1_internal_arn_dest_out;
	logic	[`ROB_SIZE-1:0][[$clog2(`PRF_SIZE)-1:0]	rob1_internal_prn_dest_out;
	logic	[`ROB_SIZE-1:0]				rob1_internal_if_rename_out;
//internal_inst1_rob_load_in and internal_inst2_rob_load_in determine the number of entry we want to load instruction1 and instruction2
	logic	[`ROB_SIZE-1:0]				rob1_internal_inst1_rob_load_in;
	logic	[`ROB_SIZE-1:0]				rob1_internal_inst2_rob_load_in;  
	logic	[`ROB_SIZE-1:0]				rob1_internal_is_ex_out;

//internal logic variable needed
	logic	[`ROB_SIZE-1:0]				rob2_internal_is_ex_out;
	logic	[`ROB_SIZE-1:0]				rob2_internal_is_branch_out;
	logic	[`ROB_SIZE-1:0]				rob2_internal_available_out;
	logic	[`ROB_SIZE-1:0]				rob2_internal_mispredict_out;
	logic	[`ROB_SIZE-1:0][4:0]		rob2_internal_arn_dest_out;
	logic	[`ROB_SIZE-1:0][[$clog2(`PRF_SIZE)-1:0]	rob2_internal_prn_dest_out;
	logic	[`ROB_SIZE-1:0]				rob2_internal_if_rename_out;
//internal_inst1_rob_load_in and internal_inst2_rob_load_in determine the number of entry we want to load instruction1 and instruction2					//want to do for t1.head and t2.head
	logic	[`ROB_SIZE-1:0]				rob2_internal_inst1_rob_load_in;
	logic	[`ROB_SIZE-1:0]				rob2_internal_inst2_rob_load_in;  

	THREAD_NUMBER						thread_number;						//want to do for t1.head and t2.head

//reg for dealing with function units
	logic	[`ROB_SIZE-1:0]				fu1_mult_rob_entry_list;				//after tranlating the idx of fu1_mult rob number, we get this(SIZE OF ROB 															//bits) so we can operate on the rob entries
	logic	[`ROB_SIZE-1:0]				fu2_mult_rob_entry_list;
	logic	[`ROB_SIZE-1:0]				fu1_add_rob_entry_list;
	logic	[`ROB_SIZE-1:0]				fu2_add_rob_entry_list;
	logic	[`ROB_SIZE-1:0]				fu1_memory_rob_entry_list;
	logic	[`ROB_SIZE-1:0]				fu2_memory_rob_entry_list;
	
	logic 	[`ROB_SIZE-1:0]				fu_rob_entry_list;					// the OR of the previous 6 rob_entry_list so that we know which rob entry 															//is executed

	logic	[`ROB_SIZE-1:0]				commit1_list;
	logic	[`ROB_SIZE-1:0]				commit2_list;						
// for commit
	COMMIT_STATUS						commit_status;
	EXECUTION_STATUS_FOR_HEAD			rob1_execution_status;
	EXECUTION_STATUS_FOR_HEAD			rob2_execution_status;

//control the execution_STATUS
	always_comb
	begin
		for(int i=0;i<`ROB_SIZE;i++)
		begin
			if(t1_head[i]==1)
			begin
				if(rob1_internal_is_ex_out[i]==1 && rob1_internal_is_ex_out[i-1]==1 )
					rob1_execution_status=TWO_EXECUTED;
				else if( rob1_internal_is_ex_out[i]==1 && rob1_internal_is_ex_out[i-1]==0  )
					rob1_execution_status=ONE_EXECUTED;
				else
					rob1_execution_status=ZERO_EXECUTED;
			end
		end
	end

	always_comb
	begin
		for(int i=0;i<`ROB_SIZE;i++)
		begin
			if(t2_head[i]==1)										//find the head
			begin
				if(!t2_head[0])										//if the head is not in then end of thequeue				
				begin
					if(rob2_internal_is_ex_out[i]==1 && rob2_internal_is_ex_out[i-1]==1 )
						rob2_execution_status=TWO_EXECUTED;
					else if( rob2_internal_is_ex_out[i]==1 && rob2_internal_is_ex_out[i-1]==0  )
						rob2_execution_status=ONE_EXECUTED;
					else
						rob2_execution_status=ZERO_EXECUTED;
				end
				else
				begin
					if(rob2_internal_is_ex_out[i]==1 && rob2_internal_is_ex_out[`ROB_SIZE-1]==1 )
						rob2_execution_status=TWO_EXECUTED;
					else if( rob2_internal_is_ex_out[i]==1 && rob2_internal_is_ex_out[`ROB_SIZE-1]==0  )
						rob2_execution_status=ONE_EXECUTED;
					else
						rob2_execution_status=ZERO_EXECUTED;
				end
			end
		end
	end

//control the commit status
	always_comb
	begin
		if (rob1_execution_status==TWO_EXECUTED )
			commit_status=TWO_ZERO;
		else if(rob1_execution_status==ONE_EXECUTED && rob2_execution_status==ONE_EXECUTED )
			commit_status=ONE_ONE;
		else if(rob1_execution_status==ONE_EXECUTED && rob2_execution_status==ZERO_EXECUTED )
			commit_status=ONE_ZERO;
		else if(rob1_execution_status==ZERO_EXECUTED && rob2_execution_status==TWO_EXECUTED )
			commit_status=ZERO_TWO;
		else if(rob1_execution_status==ZERO_EXECUTED && rob2_execution_status==ONE_EXECUTED )
			commit_status=ZERO_ONE;
		else if(rob1_execution_status==ZERO_EXECUTED && rob2_execution_status==ZERO_EXECUTED )
			commit_status=ZERO_ZERO;
	end

//commit list
	always_comb
	begin
		if(commit_status==TWO_ZERO)
		begin
			for(int i=0;i<`ROB_SIZE;i++)
			begin
				if(t1_head[i]==1)
				begin
					if(!t1_head[0])
					begin
						commit1_is_branch_out=rob1_internal_is_branch_out[i];
						commit1_mispredict_out=rob1_internal_mispredict_out[i];
						commit1_arn_dest_out=rob1_internal_arn_dest_out[i];
						commit1_prn_dest_out=rob1_internal_prn_dest_out[i];
						commit1_if_rename_out=rob1_internal_if_rename_out[i];
						commit2_is_branch_out=rob1_internal_is_branch_out[i-1];
						commit2_mispredict_out=rob1_internal_mispredict_out[i-1];
						commit2_arn_dest_out=rob1_internal_arn_dest_out[i-1];
						commit2_prn_dest_out=rob1_internal_prn_dest_out[i-1];
						commit2_if_rename_out=rob1_internal_if_rename_out[i-1];
						commit1_valid=1;
						commit2_valid=1;
					end
					else
					begin
						commit1_is_branch_out=rob1_internal_is_branch_out[i];
						commit1_mispredict_out=rob1_internal_mispredict_out[i];
						commit1_arn_dest_out=rob1_internal_arn_dest_out[i];
						commit1_prn_dest_out=rob1_internal_prn_dest_out[i];
						commit1_if_rename_out=rob1_internal_if_rename_out[i];
						commit2_is_branch_out=rob1_internal_is_branch_out[`ROB_SIZE-1];
						commit2_mispredict_out=rob1_internal_mispredict_out[`ROB_SIZE-1];
						commit2_arn_dest_out=rob1_internal_arn_dest_out[`ROB_SIZE-1];
						commit2_prn_dest_out=rob1_internal_prn_dest_out[`ROB_SIZE-1];
						commit2_if_rename_out=rob1_internal_if_rename_out[`ROB_SIZE-1];
						commit1_valid=1;
						commit2_valid=1;
					end
				end
			end
		end
		else if(commit_status==ONE_ONE)
		begin
			for(int i=0;i<`ROB_SIZE;i++)
			begin
				if(t1_head[i]==1)
				begin
						commit1_is_branch_out=rob1_internal_is_branch_out[i];
						commit1_mispredict_out=rob1_internal_mispredict_out[i];
						commit1_arn_dest_out=rob1_internal_arn_dest_out[i];
						commit1_prn_dest_out=rob1_internal_prn_dest_out[i];
						commit1_if_rename_out=rob1_internal_if_rename_out[i];
						commit1_valid=1;
				end
				if(t2_head[i]==1)
				begin
						commit2_is_branch_out=rob2_internal_is_branch_out[i];
						commit2_mispredict_out=rob2_internal_mispredict_out[i];
						commit2_arn_dest_out=rob2_internal_arn_dest_out[i];
						commit2_prn_dest_out=rob2_internal_prn_dest_out[i];
						commit2_if_rename_out=rob2_internal_if_rename_out[i];
						commit2_valid=1;
				end
			end
		end
		else if(commit_status==ONE_ZERO)
		begin
			for(int i=0;i<`ROB_SIZE;i++)
			begin
				if(t1_head[i]==1)
				begin
						commit1_is_branch_out=rob1_internal_is_branch_out[i];
						commit1_mispredict_out=rob1_internal_mispredict_out[i];
						commit1_arn_dest_out=rob1_internal_arn_dest_out[i];
						commit1_prn_dest_out=rob1_internal_prn_dest_out[i];
						commit1_if_rename_out=rob1_internal_if_rename_out[i];
						commit2_is_branch_out=0;
						commit2_mispredict_out=0;
						commit2_arn_dest_out=0;
						commit2_prn_dest_out=0;
						commit2_if_rename_out=0;
						commit1_valid=1;
						commit2_valid=0;
				end
			end

		end
		else if(commit_status==ZERO_TWO)
		begin
			for(int i=0;i<`ROB_SIZE;i++)
			begin
				if(t2_head[i]==1)
				begin
					if(!t2_head[0])
					begin
						commit1_is_branch_out=rob2_internal_is_branch_out[i];
						commit1_mispredict_out=rob2_internal_mispredict_out[i];
						commit1_arn_dest_out=rob2_internal_arn_dest_out[i];
						commit1_prn_dest_out=rob2_internal_prn_dest_out[i];
						commit1_if_rename_out=rob2_internal_if_rename_out[i];
						commit2_is_branch_out=rob2_internal_is_branch_out[i-1];
						commit2_mispredict_out=rob2_internal_mispredict_out[i-1];
						commit2_arn_dest_out=rob2_internal_arn_dest_out[i-1];
						commit2_prn_dest_out=rob2_internal_prn_dest_out[i-1];
						commit2_if_rename_out=rob2_internal_if_rename_out[i-1];
						commit1_valid=1;
						commit2_valid=1;
					end
					else
					begin
						commit1_is_branch_out=rob2_internal_is_branch_out[i];
						commit1_mispredict_out=rob2_internal_mispredict_out[i];
						commit1_arn_dest_out=rob2_internal_arn_dest_out[i];
						commit1_prn_dest_out=rob2_internal_prn_dest_out[i];
						commit1_if_rename_out=rob2_internal_if_rename_out[i];
						commit2_is_branch_out=rob2_internal_is_branch_out[`ROB_SIZE-1];
						commit2_mispredict_out=rob2_internal_mispredict_out[`ROB_SIZE-1];
						commit2_arn_dest_out=rob2_internal_arn_dest_out[`ROB_SIZE-1];
						commit2_prn_dest_out=rob2_internal_prn_dest_out[`ROB_SIZE-1];
						commit2_if_rename_out=rob2_internal_if_rename_out[`ROB_SIZE-1];
						commit1_valid=1;
						commit2_valid=1;
					end
				end
			end
		end
		else if(commit_status==ZERO_ONE)
		begin
			for(int i=0;i<`ROB_SIZE;i++)
			begin
				if(t2_head[i]==1)
				begin
						commit1_is_branch_out=rob2_internal_is_branch_out[i];
						commit1_mispredict_out=rob2_internal_mispredict_out[i];
						commit1_arn_dest_out=rob2_internal_arn_dest_out[i];
						commit1_prn_dest_out=rob2_internal_prn_dest_out[i];
						commit1_if_rename_out=rob2_internal_if_rename_out[i];
						commit2_is_branch_out=0;
						commit2_mispredict_out=0;
						commit2_arn_dest_out=0;
						commit2_prn_dest_out=0;
						commit2_if_rename_out=0;
						commit1_valid=1;
						commit2_valid=0;

				end
			end
		end
		else                                 //if(commit_status==ZERO_ZERO)
		begin
						commit1_is_branch_out=0;
						commit1_mispredict_out=0;
						commit1_arn_dest_out=0;
						commit1_prn_dest_out=0;
						commit1_if_rename_out=0;
						commit2_is_branch_out=0;
						commit2_mispredict_out=0;
						commit2_arn_dest_out=0;
						commit2_prn_dest_out=0;
						commit2_if_rename_out=0;
						commit1_valid=0;
						commit2_valid=0;
		end

	end

//instantiate rob 1 for thread1
	rob_one_entry rob1[`ROB_SIZE-1:0] (
	.reset(reset),
	.clock(clock),
	.rs_full(rs_full),
//
	.inst1_pc_in(inst1_pc_in),
	.inst1_arn_dest_in(inst1_arn_dest_in),
	.inst1_prn_dest_in(inst1_prn_dest_in),
	.inst1_is_branch_in(inst1_is_branch_in),
	.inst1_rob_load_in(rob1_internal_inst1_rob_load_in),
	.inst1_if_thread1(inst1_if_thread1),

	.inst2_pc_in(inst2_pc_in),
	.inst2_arn_dest_in(inst2_arn_dest_in),
	.inst2_prn_dest_in(inst2_prn_dest_in),
	.inst2_is_branch_in(inst2_is_branch_in),
	.inst2_rob_load_in(rob1_internal_inst2_rob_load_in),
	.inst2_if_thread1(inst2_if_thread1),
//
	.is_ex_in(),
	.mispredict_in(),
	.enable(1'b1),
	.if_committed(1),            						//it must be 1 so that we can see all output
//
	.is_ex_out(rob1_internal_is_ex_out),
	.is_branch_out(rob1_internal_is_branch_out), 
	.available_out(rob1_internal_available_out),
	.mispredict_out(rob1_internal_mispredict_out),
	.arn_dest_out(rob1_internal_arn_dest_out),
	.prn_dest_out(rob1_internal_prn_dest_out),
	.if_rename_out(rob1_internal_if_rename_out)
	);

//initialte rob2 for thread2
	rob_one_entry rob2[`ROB_SIZE-1:0] (
	.reset(reset),
	.clock(clock),
	.rs_full(rs_full),
//
	.inst1_pc_in(inst1_pc_in),
	.inst1_arn_dest_in(inst1_arn_dest_in),
	.inst1_prn_dest_in(inst1_prn_dest_in),
	.inst1_is_branch_in(inst1_is_branch_in),
	.inst1_rob_load_in(rob2_internal_inst1_rob_load_in),
	.inst1_if_thread1(inst1_if_thread1),

	.inst2_pc_in(inst2_pc_in),
	.inst2_arn_dest_in(inst2_arn_dest_in),
	.inst2_prn_dest_in(inst2_prn_dest_in),
	.inst2_is_branch_in(inst2_is_branch_in),
	.inst2_rob_load_in(internal_inst2_rob_load_in),
	.inst2_if_thread1(inst2_if_thread1),
//
	.is_ex_in(),
	.mispredict_in(),
	.enable(1'b1),
	.if_committed(1),							//it must be 1 so that we can see all output
//
	.is_ex_out(rob2_internal_is_ex_out),
	.is_branch_out(rob2_internal_is_branch_out), 
	.available_out(rob2_internal_available_out),
	.mispredict_out(rob2_internal_mispredict_out),
	.arn_dest_out(rob2_internal_arn_dest_out),
	.prn_dest_out(rob2_internal_prn_dest_out),
	.if_rename_out(rob2_internal_if_rename_out)
	);


//tail_behavior is to determine how many of the two instructions are for thread1
	always_comb
	begin
		if(inst1_is_thread1&&inst2_is_thread1)
			thread_number=INST1_TWO_THREAD1;
		else if( (inst1_is_thread1&&(!inst2_is_thread1))					//if inst1 is thread1, and inst2 is thread2
			thread_number=INST1_THREAD1;
		else if(inst2_is_thread1&&(!inst1_is_thread1)) )					//if inst1 is thread2 ,and inst2 is thread1
			thread_number=INST2_THREAD1;
		else
			thread_number=INST1_ZERO_THREAD1;
	end

//control the commit_status
	always_comb
	begin
		for(int
	end

//control the load signal of rob1 and rob2
	always_comb				
	begin
		if(thread_number==INST1_TWO_THREAD1)
		begin
			if( !t1_tail[0] )
			begin
			rob1_internal_inst1_rob_load_in= t1_tail;
			rob1_internal_inst2_rob_load_in= t1_tail>>1;
			rob2_internal_inst1_rob_load_in= 0;
			rob2_internal_inst2_rob_load_in= 0;
			end
			else
			begin
			rob1_internal_inst1_rob_load_in= t1_tail;		                         //if tail is at the end of the rob
			rob1_internal_inst2_rob_load_in= { 1,t1_tail[`ROB_SIZE-1:1] };
			rob2_internal_inst1_rob_load_in= 0;
			rob2_internal_inst2_rob_load_in= 0;
			end			
		end
		else if(thread_number==INST1_THREAD1)
		begin
			rob1_internal_inst1_rob_load_in= t1_tail;
			rob1_internal_inst2_rob_load_in= 0;
			rob2_internal_inst1_rob_load_in= 0;
			rob2_internal_inst2_rob_load_in= t2_tail;
		end
		else if(thread_number==INST2_THREAD1)
		begin
			rob1_internal_inst1_rob_load_in= 0;
			rob1_internal_inst2_rob_load_in= t1_tail;
			rob2_internal_inst1_rob_load_in= t2_tail;
			rob2_internal_inst2_rob_load_in= 0;
		end
		else											//so inst1 and inst2 are all thread2
		begin
			if( !t2_tail[0] )
			begin
			rob2_internal_inst1_rob_load_in= t2_tail;
			rob2_internal_inst2_rob_load_in= t2_tail>>1;
			rob1_internal_inst1_rob_load_in= 0;
			rob1_internal_inst2_rob_load_in= 0;
			end
			else
			begin
			rob2_internal_inst1_rob_load_in= t2_tail;		                         //if tail is at the end of the rob
			rob2_internal_inst2_rob_load_in= { 1,t2_tail[`ROB_SIZE-1:1] };
			rob1_internal_inst1_rob_load_in= 0;
			rob1_internal_inst2_rob_load_in= 0;
			end
		end
	end
//when dispatching, we select two available rob entry from internal_available_out list
	/*two_stage_priority_selector	#(.p_SIZE(`ROB_SIZE))	tsps1(                                  
		.available(internal_available_out),                                                 
		.enable1(inst1_load_in),							       
		.enable2(inst2_load_in),
		.output1(internal_inst1_rob_load_in),
		.output2(internal_inst2_rob_load_in)
	);
*/
    	
//then we need to translate the internal_inst1_rob_load_in to be "$clog2(`ROB_SIZE)" bits, i have tested it to be good!
/*	always_comb
	begin
		for(int i=0;i<`ROB_SIZE;i++)
		begin
			if(internal_inst1_rob_load_in[i]==1)
				inst1_rs_rob_idx_in=i;
			else if(internal_inst2_rob_load_in[i]==1)
				inst2_rs_rob_idx_in=i;
			else
			begin
				inst1_rs_rob_idx_in=0;
				inst2_rs_rob_idx_in=0;
			end
		end
	end
*/

//instantiate the decoder, so we can output the number of rob assigned.it can translate a signal with "SIZE OF ROB" bits to $clog2(`ROB_SIZE) bits with the same value
 	decoder #(.SIZE(`RS_SIZE)) decoder1(.load(internal_inst1_rob_load_in),.idx(inst1_rs_rob_idx_in) );
	decoder #(.SIZE(`RS_SIZE)) decoder2(.load(internal_inst2_rob_load_in),.idx(inst2_rs_rob_idx_in) );
//***************************

//if one function unit finish execution, we need to read the number of rob of the instruction, so we need to translate it in to "ROB_SIZE" bits, then change the "execution" bit in 
//the corresponding rob entry
	translator #(.SIZE(`ROB_SIZE)) translator1(.idx(fu1_mult_rob_idx),.load(fu1_mult_rob_entry_list) );
	translator #(.SIZE(`ROB_SIZE)) translator2(.idx(fu2_mult_rob_idx),.load(fu2_mult_rob_entry_list) );
	translator #(.SIZE(`ROB_SIZE)) translator3(.idx(fu1_add_rob_idx),.load(fu1_add_rob_entry_list) );
	translator #(.SIZE(`ROB_SIZE)) translator4(.idx(fu2_add_rob_idx),.load(fu2_add_rob_entry_list) );
	translator #(.SIZE(`ROB_SIZE)) translator5(.idx(fu1_memory_rob_idx),.load(fu1_memory_rob_entry_list) );
	translator #(.SIZE(`ROB_SIZE)) translator6(.idx(fu2_memory_rob_idx),.load(fu2_memory_rob_entry_list) );	
//after tranlating the idx of fu1_mult rob number, we get this(SIZE OF ROB 														//bits) so we can operate on the rob entries					
	
	fu_rob_entry_list=fu1_mult_rob_entry_list | fu2_mult_rob_entry_list | fu1_add_rob_entry_list | fu2_add_rob_entry_list | fu1_memory_rob_entry_list | fu2_memory_rob_entry_list;
// the OR of the previous 6 rob_entry_list so that we know which rob entry is executed

//********************************************	
//next is the behavior of tail
	always_ff @(posedge clock)
	begin
		if (reset)
		begin
			//t1.head	<= `SD 0;
			t1_tail <= `SD {1,(`ROB_SIZE-1)'d0};
			t2_tail <= `SD {1,(`ROB_SIZE-1)'d0};							//we reset t2.head in the middle of the rob
			//t2.head <= `SD 0;
		end
		else
		begin
//the behavior	of tail when dispatching	
			if(thread_number==TWO_THREAD1)
			begin
				if( !t1_tail[0] && !t1_tail[1] )
				begin
					t1_tail <= `SD t1_tail>>2;
				end
				else if(t1_tail[1])
				begin										//if tail is at the end of the rob
					t1_tail <= `SD {1,(`ROB_SIZE-1)'d0};
				end
				else
				begin										// so that t1_tail[0]==1
					t1_tail <= `SD {0,1,(`ROB_SIZE-2)'d0};	
				end		
			end
			else if(thread_number==( INST1_THREAD1||INST2_THREAD1) )
			begin
				if( !t1_tail[0] && !t2_tail[0] )						//if t1_tail and t2_tail both not hit the end
				begin
					t1_tail <= `SD t1_tail>>1;
					t2_tail <= `SD t2_tail>>1;
				end
				else if( t1_tail[0] && t2_tail[0] )
				begin
					t1_tail <= `SD {1,(`ROB_SIZE-1)'d0};
					t2_tail <= `SD {1,(`ROB_SIZE-1)'d0};
				end
				else if( t1_tail[0] && !t2_tail[0] )
				begin
					t1_tail <= `SD {1,(`ROB_SIZE-1)'d0};
					t2_tail <= `SD t2_tail>>1;
				end
				else                      							// so that ( !t1_tail[0] && t2_tail[0] )
				begin
					t1_tail <= `SD t1_tail>>1;
					t2_tail <= `SD {1,(`ROB_SIZE-1)'d0};
				end
				
			end
			else											//so inst1 and inst2 are all thread2
			begin
				if( !t2_tail[0] && !t2_tail[1] )
				begin
					t2_tail <= `SD t2_tail>>2;
				end
				else if(t2_tail[1])
				begin										//if tail is at the end of the rob
					t2_tail <= `SD {1,(`ROB_SIZE-1)'d0};
				end
				else
				begin										// so that t2_tail[0]==1
					t2_tail <= `SD {0,1,(`ROB_SIZE-2)'d0};	
				end
			end

		end
	end

//next is the behavior of head
	always_ff @(posedge clock)
	begin
		if (reset)
		begin
			t1_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
			t2_head <= `SD {1,(`ROB_SIZE-1){1'd0}};	
		end
		else if(commit_status==TWO_ZERO)
		begin
			if( !t1_head[1] && !t1_head[0] )
				t1_head <= `SD t1_head>>2;
			else if( t1_head[1] )
				t1_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
			else
				t1_head <= `SD {0,1,(`ROB_SIZE-2){1'd0}};
		end
		else if(commit_status== ONE_ONE)
		begin
			if( !t1_head[0]&&!t2_head[0] )
			begin
				t1_head <= `SD t1_head>>1;
				t2_head <= `SD t2_head>>1;
			end
			else if( t1_head[0]&&!t2_head[0])
			begin
				t1_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
				t2_head <= `SD t2_head>>1;
			end
			else if( !t1_head[0]&&t2_head[0])
			begin
				t1_head <= `SD t1_head>>1;
				t2_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
			end
			else  //t1_head[0]&&t2_head[0]
			begin
				t1_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
				t2_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
			end
		end
		else if(commit_status== ONE_ZERO)
		begin
			if(!t1_head[0])
				t1_head <= `SD t1_head>>1;
			else
				t1_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
		end
		else if(commit_status==ZERO_ONE)
		begin
			if(!t2_head[0])
				t2_head <= `SD t2_head>>1;
			else
				t2_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
		end
		else if(commit_status==ZERO_TWO)
		begin
			if( !t2_head[1] && !t2_head[0] )
				t2_head <= `SD t2_head>>2;
			else if( t2_head[1] )
				t2_head <= `SD {1,(`ROB_SIZE-1){1'd0}};
			else
				t2_head <= `SD {0,1,(`ROB_SIZE-2){1'd0}};
		end
		else //commit_status==ZERO_ZERO
		begin
				t2_head <= `SD t2_head;
				t1_head <= `SD t1_head;
		end
	end

endmodule
