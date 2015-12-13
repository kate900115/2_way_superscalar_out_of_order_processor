/*******************************************************************************/
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
	//input
	//normal input
	input										reset,
	input										clock,
				
	input										is_thread1,							//the two instructions are thread1 or thread2 if it ==1, it is for thread1, else it is for thread 2
	//instruction1 input
	input	[63:0]								inst1_pc_in,						//the pc of the instruction
	input	[4:0]								inst1_arn_dest_in,					//the arf number of the destinaion of the instruction
	input	[$clog2(`PRF_SIZE)-1:0]				inst1_prn_dest_in,					//the prf number of the destination of this instruction
	input										inst1_is_branch_in,					//if this instruction is a branch
	input										inst1_is_uncond_branch_in,
	input										inst1_is_halt_in,
	input										inst1_is_illegal_in,
	input 										inst1_load_in,						//tell rob if instruction1 is valid

	//instruction2 input
	input	[63:0]								inst2_pc_in,						//the pc of the instruction
	input	[4:0]								inst2_arn_dest_in,					//the arf number of the destinaion of the instruction
	input	[$clog2(`PRF_SIZE)-1:0] 			inst2_prn_dest_in,      		    //the prf number of the destination of this instruction
	input										inst2_is_branch_in,					//if this instruction is a branch
	input										inst2_is_uncond_branch_in,
	input										inst2_is_halt_in,
	input										inst2_is_illegal_in,
	input 										inst2_load_in,		    		   	//tell rob if instruction2 is valid
	//when executed,for each function unit,  the number of rob need to know so we can set the if_executed to of the entry to be 1
	input										if_fu_executed1,					//if the instruction in the first FU has been executed 
	input	[$clog2(`ROB_SIZE):0]				fu_rob_idx1,						//the rob number of the instruction in the first FU
	input										mispredict_in1,
	input	[63:0]								target_pc_in1,
	input										if_fu_executed2,					//if the instruction in the second has been executed
	input	[$clog2(`ROB_SIZE):0]				fu_rob_idx2,						//the rob number of the instruction in the first multiplyer
	input										mispredict_in2,
	input	[63:0]								target_pc_in2,

	//input                                       inst1_mispredict_sig,
	//input                                       inst2_mispredict_sig,

	//output
	//after dispatching, we need to send rs the rob number we assigned to instruction1 and instruction2
	output	logic	[$clog2(`ROB_SIZE):0]		inst1_rs_rob_idx_in,				//it is combinational logic so that the output is dealt with right after a
	output	logic	[$clog2(`ROB_SIZE):0]		inst2_rs_rob_idx_in,				//instruction comes in, and then this signal is immediately sent to rs to
																					//store in rs
	//when committed, the output of the first instrucion committed
	output	logic	[63:0]						commit1_pc_out,
	output  logic	[63:0]						commit1_target_pc_out,
	output	logic								commit1_is_branch_out,				//if this instruction is a branch
	output	logic								commit1_is_uncond_branch_out,
	output	logic								commit1_mispredict_out,		       	//if this instrucion is mispredicted
	output	logic	[4:0]						commit1_arn_dest_out,               //the architected register number of the destination of this instruction
	output	logic	[$clog2(`PRF_SIZE)-1:0]		commit1_prn_dest_out,				//the prf number of the destination of this instruction
	output	logic								commit1_if_rename_out,		     	//if this entry is committed at this moment(tell RRAT)
	output	logic								commit1_valid,
	output  logic								commit1_is_halt_out,
	output  logic								commit1_is_illegal_out,
	output	logic								commit1_is_thread1,
	//when committed, the output of the second instruction committed
	output  logic	[63:0]						commit2_pc_out,
	output  logic	[63:0]						commit2_target_pc_out,
	output	logic								commit2_is_branch_out,				//if this instruction is a branch
	output	logic								commit2_is_uncond_branch_out,
	output	logic								commit2_mispredict_out,				//if this instrucion is mispredicted
	output	logic	[4:0]						commit2_arn_dest_out,				//the architected register number of the destination of this instruction
	output	logic	[$clog2(`PRF_SIZE)-1:0]		commit2_prn_dest_out,				//the prf number of the destination of this instruction
	output	logic								commit2_if_rename_out,				//if this entry is committed at this moment(tell RRAT)
	output  logic								commit2_is_halt_out,
	output  logic								commit2_is_illegal_out,
	output	logic								commit2_valid,
	output	logic								commit2_is_thread1,
	output	logic								t1_is_full,
	output	logic								t2_is_full,
	
	output	logic 	[$clog2(`ROB_SIZE)-1:0]		t1_head,
	output	logic 	[$clog2(`ROB_SIZE)-1:0]		t2_head,
	//for debug
	input	[31:0]								rob_inst1_in,
	input	[31:0]								rob_inst2_in,
	output	logic	[31:0]						commit1_inst_out,
	output	logic	[31:0]						commit2_inst_out
);

//data logic variable needed

//function variable needed
	logic 	[$clog2(`ROB_SIZE)-1:0]					t1_tail;
	logic 	[$clog2(`ROB_SIZE)-1:0]					t2_tail;
	logic	[$clog2(`ROB_SIZE)-1:0]					next_t1_head;
	logic	[$clog2(`ROB_SIZE)-1:0]					next_t1_tail;
	logic	[$clog2(`ROB_SIZE)-1:0]					next_t2_head;
	logic	[$clog2(`ROB_SIZE)-1:0]					next_t2_tail;
//internal logic variable needed
	logic	[`ROB_SIZE-1:0][63:0]					rob1_internal_pc_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_is_thread1_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_is_branch_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_is_uncond_branch_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_available_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_mispredict_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_mispredict_in;
	logic	[`ROB_SIZE-1:0][4:0]					rob1_internal_arn_dest_out;
	logic	[`ROB_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]	rob1_internal_prn_dest_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_if_rename_out;
//internal_inst1_rob_load_in and internal_inst2_rob_load_in determine the number of entry we want to load instruction1 and instruction2
	logic	[`ROB_SIZE-1:0]							rob1_internal_inst1_rob_load_in;
	logic	[`ROB_SIZE-1:0]							rob1_internal_inst2_rob_load_in;
	logic	[`ROB_SIZE-1:0]							rob1_internal_is_ex_in;
	logic	[`ROB_SIZE-1:0]							rob1_internal_is_ex_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_if_committed;
	logic	[`ROB_SIZE-1:0][63:0]					rob1_internal_target_pc_in;
	logic	[`ROB_SIZE-1:0][63:0]					rob1_internal_target_pc_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_is_halt_out;
	logic	[`ROB_SIZE-1:0]							rob1_internal_is_illegal_out;

	logic	[`ROB_SIZE-1:0][63:0]					rob2_internal_pc_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_is_thread1_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_is_branch_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_is_uncond_branch_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_available_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_mispredict_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_mispredict_in;
	logic	[`ROB_SIZE-1:0][4:0]					rob2_internal_arn_dest_out;
	logic	[`ROB_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]	rob2_internal_prn_dest_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_if_rename_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_inst1_rob_load_in;
	logic	[`ROB_SIZE-1:0]							rob2_internal_inst2_rob_load_in;
	logic	[`ROB_SIZE-1:0]							rob2_internal_is_ex_in;
	logic	[`ROB_SIZE-1:0]							rob2_internal_is_ex_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_if_committed;
	logic	[`ROB_SIZE-1:0][63:0]					rob2_internal_target_pc_in;
	logic	[`ROB_SIZE-1:0][63:0]					rob2_internal_target_pc_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_is_halt_out;
	logic	[`ROB_SIZE-1:0]							rob2_internal_is_illegal_out;
	
	//for debgu
	logic	[`ROB_SIZE-1:0][31:0]					rob2_internal_inst_out;
	logic	[`ROB_SIZE-1:0][31:0]					rob1_internal_inst_out;
	
	

//instantiate rob 1 for thread1
	rob_one_entry rob1[`ROB_SIZE-1:0] (
	//input
	.reset(reset),
	.clock(clock),

	.is_thread1(is_thread1),
	
	.inst1_pc_in(inst1_pc_in),
	.inst1_arn_dest_in(inst1_arn_dest_in),
	.inst1_prn_dest_in(inst1_prn_dest_in),
	.inst1_is_branch_in(inst1_is_branch_in),
	.inst1_is_uncond_branch_in(inst1_is_uncond_branch_in),
	.inst1_rob_load_in(rob1_internal_inst1_rob_load_in),
	.inst1_halt_in(inst1_is_halt_in),
	.inst1_illegal_in(inst1_is_illegal_in),

	.inst2_pc_in(inst2_pc_in),
	.inst2_arn_dest_in(inst2_arn_dest_in),
	.inst2_prn_dest_in(inst2_prn_dest_in),
	.inst2_is_branch_in(inst2_is_branch_in),
	.inst2_is_uncond_branch_in(inst2_is_uncond_branch_in),
	.inst2_rob_load_in(rob1_internal_inst2_rob_load_in),
	.inst2_halt_in(inst2_is_halt_in),
	.inst2_illegal_in(inst2_is_illegal_in),

	.is_ex_in(rob1_internal_is_ex_in),
	.mispredict_in(rob1_internal_mispredict_in),
	.target_pc_in(rob1_internal_target_pc_in),
	.enable(1'b1),
	.if_committed(rob1_internal_if_committed),

	.pc_out(rob1_internal_pc_out),
	.is_thread1_out(rob1_internal_is_thread1_out),
	.is_ex_out(rob1_internal_is_ex_out),
	.is_branch_out(rob1_internal_is_branch_out),
	.is_uncond_branch_out(rob1_internal_is_uncond_branch_out),
	.available_out(rob1_internal_available_out),
	.mispredict_out(rob1_internal_mispredict_out),
	.target_pc_out(rob1_internal_target_pc_out),
	.arn_dest_out(rob1_internal_arn_dest_out),
	.prn_dest_out(rob1_internal_prn_dest_out),
	.if_rename_out(rob1_internal_if_rename_out),
	.halt_out(rob1_internal_is_halt_out),
	.illegal_out(rob1_internal_is_illegal_out),
	
	//for debug
	.rob_inst1_in(rob_inst1_in),
	.rob_inst2_in(rob_inst2_in),
	.rob_inst_out(rob1_internal_inst_out)
	);
	
	
	
	
	
	rob_one_entry rob2[`ROB_SIZE-1:0] (
	.reset(reset),
	.clock(clock),
//
	.is_thread1(is_thread1),
	
	.inst1_pc_in(inst1_pc_in),
	.inst1_arn_dest_in(inst1_arn_dest_in),
	.inst1_prn_dest_in(inst1_prn_dest_in),
	.inst1_is_branch_in(inst1_is_branch_in),
	.inst1_is_uncond_branch_in(inst1_is_uncond_branch_in),
	.inst1_rob_load_in(rob2_internal_inst1_rob_load_in),
	.inst1_halt_in(inst1_is_halt_in),
	.inst1_illegal_in(inst1_is_illegal_in),

	.inst2_pc_in(inst2_pc_in),
	.inst2_arn_dest_in(inst2_arn_dest_in),
	.inst2_prn_dest_in(inst2_prn_dest_in),
	.inst2_is_branch_in(inst2_is_branch_in),
	.inst2_is_uncond_branch_in(inst2_is_uncond_branch_in),
	.inst2_rob_load_in(rob2_internal_inst2_rob_load_in),
	.inst2_halt_in(inst2_is_halt_in),
	.inst2_illegal_in(inst2_is_illegal_in),
//
	.is_ex_in(rob2_internal_is_ex_in),
	.mispredict_in(rob2_internal_mispredict_in),
	.target_pc_in(rob2_internal_target_pc_in),
	.enable(1'b1),
	.if_committed(rob2_internal_if_committed),
//
	.pc_out(rob2_internal_pc_out),
	.is_thread1_out(rob2_internal_is_thread1_out),
	.is_ex_out(rob2_internal_is_ex_out),
	.is_branch_out(rob2_internal_is_branch_out),
	.is_uncond_branch_out(rob2_internal_is_uncond_branch_out),
	.available_out(rob2_internal_available_out),
	.mispredict_out(rob2_internal_mispredict_out),
	.target_pc_out(rob2_internal_target_pc_out),
	.arn_dest_out(rob2_internal_arn_dest_out),
	.prn_dest_out(rob2_internal_prn_dest_out),
	.if_rename_out(rob2_internal_if_rename_out),
	.halt_out(rob2_internal_is_halt_out),
	.illegal_out(rob2_internal_is_illegal_out),
	
	//for debug
	.rob_inst1_in(rob_inst1_in),
	.rob_inst2_in(rob_inst2_in),
	.rob_inst_out(rob2_internal_inst_out)
	);
	
	//execution state input					
	always_comb
	begin
		for (int j = 0; j < `ROB_SIZE; j++)
		begin
			rob1_internal_is_ex_in[j] = 1'b0;
			rob2_internal_is_ex_in[j] = 1'b0;
			rob1_internal_mispredict_in[j] = 1'b0;
			rob2_internal_mispredict_in[j] = 1'b0;
			rob1_internal_target_pc_in[j] = 1'b0;
			rob2_internal_target_pc_in[j] = 1'b0;
			if (j == fu_rob_idx1[$clog2(`ROB_SIZE)-1:0] && !fu_rob_idx1[$clog2(`ROB_SIZE)] && if_fu_executed1 )
			begin
				rob1_internal_is_ex_in[j] = if_fu_executed1;
				rob1_internal_mispredict_in[j] = mispredict_in1;
				rob1_internal_target_pc_in[j] = target_pc_in1;
			end
			else if (j == fu_rob_idx1[$clog2(`ROB_SIZE)-1:0] && fu_rob_idx1[$clog2(`ROB_SIZE)] && if_fu_executed1 )
			begin
				rob2_internal_is_ex_in[j] = if_fu_executed1;
				rob2_internal_mispredict_in[j] = mispredict_in1;
				rob2_internal_target_pc_in[j] = target_pc_in1;
			end
			if (j == fu_rob_idx2[$clog2(`ROB_SIZE)-1:0] && !fu_rob_idx2[$clog2(`ROB_SIZE)] && if_fu_executed2 )
			begin
				rob1_internal_is_ex_in[j] = if_fu_executed2;
				rob1_internal_mispredict_in[j] = mispredict_in2;
				rob1_internal_target_pc_in[j] = target_pc_in2;
			end
			else if (j == fu_rob_idx2[$clog2(`ROB_SIZE)-1:0] && fu_rob_idx2[$clog2(`ROB_SIZE)] && if_fu_executed2 )
			begin
				rob2_internal_is_ex_in[j] = if_fu_executed2;
				rob2_internal_mispredict_in[j] = mispredict_in2;
				rob2_internal_target_pc_in[j] = target_pc_in2;
			end
		end
		/*if (rob1_internal_is_halt_out[t1_head])
			rob1_internal_is_ex_in[t1_head] = 1;
		if (rob2_internal_is_halt_out[t1_head])
			rob2_internal_is_ex_in[t1_head] = 1;*/
	end
	
	//commit									
	always_comb
	begin
	commit1_is_branch_out	= 0;
	commit1_is_uncond_branch_out	= 0;
	commit1_mispredict_out	= 0;
	commit1_arn_dest_out	= `ZERO_REG;
	commit1_prn_dest_out	= 0;
	commit1_if_rename_out	= 0;
	commit1_is_thread1		= 0;
	commit2_is_branch_out	= 0;
	commit2_is_uncond_branch_out	= 0;
	commit2_mispredict_out	= 0;
	commit2_arn_dest_out	= `ZERO_REG;
	commit2_prn_dest_out	= 0;
	commit2_if_rename_out	= 0;
	commit2_is_thread1		= 0;
	next_t1_head 			= t1_head;
	next_t2_head 			= t2_head;
	commit1_valid 			= 0;
	commit2_valid 			= 0;
	rob1_internal_if_committed = 0;
	rob2_internal_if_committed = 0;
	commit1_pc_out 			= 0;
	commit2_pc_out 			= 0;
	commit1_target_pc_out 	= 0;
	commit2_target_pc_out 	= 0;
	commit1_is_halt_out 	= 0;
	commit1_is_illegal_out 	= 0;
	commit2_is_halt_out 	= 0;
	commit2_is_illegal_out 	= 0;
	commit1_inst_out		= 0;
	commit2_inst_out		= 0;
		if (rob1_internal_is_ex_out[t1_head] && (t1_head != t1_tail || (t1_head == t1_tail && !rob1_internal_available_out[t1_tail])))
		begin
			commit1_pc_out			= rob1_internal_pc_out[t1_head];
			commit1_target_pc_out	= rob1_internal_target_pc_out[t1_head];
			commit1_is_branch_out	= rob1_internal_is_branch_out[t1_head];
			commit1_is_uncond_branch_out	= rob1_internal_is_uncond_branch_out[t1_head];
			commit1_mispredict_out	= rob1_internal_mispredict_out[t1_head];
			commit1_arn_dest_out	= rob1_internal_arn_dest_out[t1_head];
			commit1_prn_dest_out	= rob1_internal_prn_dest_out[t1_head];
			commit1_if_rename_out	= rob1_internal_if_rename_out[t1_head];
			commit1_is_thread1		= rob1_internal_is_thread1_out[t1_head];
			commit1_is_halt_out		= rob1_internal_is_halt_out[t1_head];
			commit1_is_illegal_out	= rob1_internal_is_illegal_out[t1_head];
			commit1_inst_out		= rob1_internal_inst_out[t1_head];
			rob1_internal_if_committed[t1_head] = 1;
			if (rob1_internal_is_ex_out[t1_head+4'b1] && t1_head+4'b1 != t1_tail && ~(commit1_is_branch_out && commit1_mispredict_out))
			begin
				commit2_pc_out			= rob1_internal_pc_out[t1_head+4'b1];
				commit2_target_pc_out	= rob1_internal_target_pc_out[t1_head+4'b1];
				commit2_is_branch_out	= rob1_internal_is_branch_out[t1_head+4'b1];
				commit2_is_uncond_branch_out	= rob1_internal_is_uncond_branch_out[t1_head+4'b1];
				commit2_mispredict_out	= rob1_internal_mispredict_out[t1_head+4'b1];
				commit2_arn_dest_out	= rob1_internal_arn_dest_out[t1_head+4'b1];
				commit2_prn_dest_out	= rob1_internal_prn_dest_out[t1_head+4'b1];
				commit2_if_rename_out	= rob1_internal_if_rename_out[t1_head+4'b1];
				commit2_is_thread1		= rob1_internal_is_thread1_out[t1_head+4'b1];
				commit2_is_halt_out		= rob1_internal_is_halt_out[t1_head+4'b1];
				commit2_is_illegal_out	= rob1_internal_is_illegal_out[t1_head+4'b1];
				commit2_inst_out		= rob1_internal_inst_out[t1_head+4'b1];
				rob1_internal_if_committed[t1_head+4'b1] = 1;
				next_t1_head = t1_head + 4'h2;
				commit1_valid = 1;
				commit2_valid = 1;
			end
			else if (rob2_internal_is_ex_out[t2_head] && (t2_head != t2_tail || (t2_head == t2_tail && !rob2_internal_available_out[t2_tail])))
			begin
				commit2_pc_out			= rob2_internal_pc_out[t2_head];
				commit2_target_pc_out	= rob2_internal_target_pc_out[t2_head];
				commit2_is_branch_out	= rob2_internal_is_branch_out[t2_head];
				commit2_is_uncond_branch_out	= rob2_internal_is_uncond_branch_out[t2_head];
				commit2_mispredict_out	= rob2_internal_mispredict_out[t2_head];
				commit2_arn_dest_out	= rob2_internal_arn_dest_out[t2_head];
				commit2_prn_dest_out	= rob2_internal_prn_dest_out[t2_head];
				commit2_if_rename_out	= rob2_internal_if_rename_out[t2_head];
				commit2_is_thread1		= rob2_internal_is_thread1_out[t2_head];
				commit2_is_halt_out		= rob2_internal_is_halt_out[t2_head];
				commit2_is_illegal_out	= rob2_internal_is_illegal_out[t2_head];
				commit2_inst_out		= rob2_internal_inst_out[t2_head];
				rob2_internal_if_committed[t2_head] = 1;
				next_t1_head = t1_head + 4'b1;
				next_t2_head = t2_head + 4'b1;
				commit1_valid = 1;
				commit2_valid = 1;
			end
			else begin
				next_t1_head = t1_head + 4'b1;
				commit1_valid = 1;
			end
		end
		else if (rob2_internal_is_ex_out[t2_head] && (t2_head != t2_tail || (t2_head == t2_tail && !rob2_internal_available_out[t2_tail])))
		begin
			commit1_pc_out			= rob2_internal_pc_out[t2_head];
			commit1_target_pc_out	= rob2_internal_target_pc_out[t2_head];
			commit1_is_branch_out	= rob2_internal_is_branch_out[t2_head];
			commit1_is_uncond_branch_out	= rob2_internal_is_uncond_branch_out[t2_head];
			commit1_mispredict_out	= rob2_internal_mispredict_out[t2_head];
			commit1_arn_dest_out	= rob2_internal_arn_dest_out[t2_head];
			commit1_prn_dest_out	= rob2_internal_prn_dest_out[t2_head];
			commit1_if_rename_out	= rob2_internal_if_rename_out[t2_head];
			commit1_is_thread1		= rob2_internal_is_thread1_out[t2_head];
			commit1_is_halt_out		= rob2_internal_is_halt_out[t2_head];
			commit1_is_illegal_out	= rob2_internal_is_illegal_out[t2_head];
			commit1_inst_out		= rob2_internal_inst_out[t2_head];
			rob2_internal_if_committed[t2_head] = 1;
			if (rob2_internal_is_ex_out[t2_head+4'b1] && t2_head+4'b1 != t2_tail && ~(commit1_is_branch_out && commit1_mispredict_out))
			begin
				commit2_pc_out			= rob2_internal_pc_out[t2_head+4'b1];
				commit2_target_pc_out	= rob2_internal_target_pc_out[t2_head+4'b1];
				commit2_is_branch_out	= rob2_internal_is_branch_out[t2_head+4'b1];
				commit2_is_uncond_branch_out	= rob2_internal_is_uncond_branch_out[t2_head+4'b1];
				commit2_mispredict_out	= rob2_internal_mispredict_out[t2_head+4'b1];
				commit2_arn_dest_out	= rob2_internal_arn_dest_out[t2_head+4'b1];
				commit2_prn_dest_out	= rob2_internal_prn_dest_out[t2_head+4'b1];
				commit2_if_rename_out	= rob2_internal_if_rename_out[t2_head+4'b1];
				commit2_is_thread1		= rob2_internal_is_thread1_out[t2_head+4'b1];
				commit2_is_halt_out		= rob2_internal_is_halt_out[t2_head+4'b1];
				commit2_is_illegal_out	= rob2_internal_is_illegal_out[t2_head+4'b1];
				commit2_inst_out		= rob2_internal_inst_out[t2_head+4'b1];
				rob2_internal_if_committed[t2_head+4'b1] = 1;
				next_t2_head = t2_head + 4'h2;
				commit1_valid = 1;
				commit2_valid = 1;
			end
			else begin
				next_t2_head = t2_head + 4'b1;
				commit1_valid = 1;
			end
		end
	//tail_behavior is to determine how many of the two instructions are for thread1 
		rob1_internal_inst1_rob_load_in = 0;
		rob1_internal_inst2_rob_load_in = 0;
		rob2_internal_inst1_rob_load_in = 0;
		rob2_internal_inst2_rob_load_in = 0;
		inst1_rs_rob_idx_in = 0;
		inst2_rs_rob_idx_in = 0;
		next_t1_tail = t1_tail;
		next_t2_tail = t2_tail;
		t1_is_full = 0;
		t2_is_full = 0;
		if(inst1_load_in && inst2_load_in)//*************************************
		begin
			if (is_thread1)
			begin
				rob1_internal_inst1_rob_load_in[t1_tail] = 1;
				rob1_internal_inst2_rob_load_in[t1_tail+4'b1] = 1;
				inst1_rs_rob_idx_in = {1'b0,t1_tail};
				inst2_rs_rob_idx_in = {1'b0,t1_tail + 4'b1};
				next_t1_tail = t1_tail + 4'h2;
			end
			else
			begin
				rob2_internal_inst1_rob_load_in[t2_tail] = 1;
				rob2_internal_inst2_rob_load_in[t2_tail+4'b1] = 1;
				inst1_rs_rob_idx_in = {1'b1,t2_tail};
				inst2_rs_rob_idx_in = {1'b1,t2_tail + 4'b1};
				next_t2_tail = t2_tail + 4'h2;
			end
		end
		else if(inst1_load_in && ~inst2_load_in)//*************************************
		begin
			if (is_thread1)
			begin
				rob1_internal_inst1_rob_load_in[t1_tail] = 1;
				inst1_rs_rob_idx_in = {1'b0,t1_tail};
				next_t1_tail = t1_tail + 4'h1;
			end
			else
			begin
				rob2_internal_inst1_rob_load_in[t2_tail] = 1;
				inst1_rs_rob_idx_in = {1'b1,t2_tail};
				next_t2_tail = t2_tail + 4'h1;
			end
		end
		if (commit1_is_thread1 && commit1_is_branch_out && commit1_mispredict_out)
		begin
			next_t1_tail = next_t1_head;
			for (int i = 0; i < `ROB_SIZE; i++) begin
				rob1_internal_if_committed[i] = 1;
			end
		end
		if (~commit1_is_thread1 && commit1_is_branch_out && commit1_mispredict_out)
		begin
			next_t2_tail = next_t2_head;
			for (int j = 0; j < `ROB_SIZE; j++) begin
				rob2_internal_if_committed[j] = 1;
			end
		end
		if (commit2_is_thread1 && commit2_is_branch_out && commit2_mispredict_out)
		begin
			next_t1_tail = next_t1_head;
			for (int k = 0; k < `ROB_SIZE; k++) begin
				rob1_internal_if_committed[k] = 1;
			end
		end
		if (~commit2_is_thread1 && commit2_is_branch_out && commit2_mispredict_out)
		begin
			next_t2_tail = next_t2_head;
			for (int m = 0; m < `ROB_SIZE; m++) begin
				rob2_internal_if_committed[m] = 1;
			end
		end
		if ((t1_tail + 4'b1 == t1_head) || (t1_tail == t1_head && !rob1_internal_available_out[t1_tail]))
		begin
			t1_is_full = 1;
		end
		if ((t2_tail + 4'b1 == t2_head) || (t2_tail == t2_head && !rob2_internal_available_out[t2_tail]))
		begin
			t2_is_full = 1;
		end
	end
	
	//the head move 
	always_ff @(posedge clock)
	begin
		if (reset)
		begin
			t1_head <= `SD 0;
			t2_head <= `SD 0;	
		end
		else
		begin
			t1_head <= `SD next_t1_head;
			t2_head <= `SD next_t2_head;
		end
	end
	//the tail move		
	always_ff @(posedge clock)
	begin
		if (reset)
		begin
			t1_tail <= `SD 0;
			t2_tail <= `SD 0;
		end
		else
		begin
			t1_tail <= `SD next_t1_tail;
			t2_tail <= `SD next_t2_tail;
		end
	end
endmodule
