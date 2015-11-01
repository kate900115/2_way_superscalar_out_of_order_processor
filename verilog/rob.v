/******************************************************************************//
//      	modulename: rob.v				               //
//      								       //
//      		Description:					       //
//      								       //
//      								       //
//      								       //
//      								       //
//      								       //
//      								       //
//      								       //
/////////////////////////////////////////////////////////////////////////////////

module rob(
	
//normal input
	input						reset,
	input						clock,
	input						rs_rull,
//instruction1 input
	input	[31:0]					inst1_pc_in,						//the pc of the instruction
	input	[4:0]					inst1_arn_dest_in,					//the arf number of the destinaion of the instruction
	input	[`PRF_SIZE-1:0] 			inst1_prn_dest_in,                                   	//the prf number of the destination of this instruction
	input						inst1_is_branch_in,                                  	//if this instruction is a branch
	input 						inst1_load_in				       		//tell rob if instruction1 is valid
//instruction2 input
	input	[31:0]					inst2_pc_in,						//the pc of the instruction
	input	[4:0]					inst2_arn_dest_in,					//the arf number of the destinaion of the instruction
	input	[`PRF_SIZE-1:0] 			inst2_prn_dest_in,                                   	//the prf number of the destination of this instruction
	input						inst2_is_branch_in,                                  	//if this instruction is a branch
	input 						inst2_load_in				       		//tell rob if instruction2 is valid
//when executed,for each function unit,  the number of rob need to know so we can set the if_executed to of the entry to be 1
	input						if_mult1_executed,
	input						if_mult2_executed,
	input						if_add1_executed,
	input						if_add2_executed,
	input						if_memory1_executed,
	input						if_memory2_executed,
//after dispatching, we need to send rs the rob number we assigned to instruction1 and instruction2
	output	logic	[$clog2(`ROB_SIZE)-1:0]		inst1_rs_rob_idx_in,
	output	logic	[$clog2(`ROB_SIZE)-1:0]		inst2_rs_rob_idx_in
//when committed, the output of the first instrucion committed
	output	logic					commit1_is_branch_out,				       	//if this instruction is a branch
	output	logic					commit1_mispredict_out,				       	//if this instrucion is mispredicted
	output	logic	[4:0]				commit1_arn_dest_out,                                  	//the architected register number of the destination of this instruction
	output	logic	[`PRF_SIZE-1:0]			commit1_prn_dest_out,                                  	//the prf number of the destination of this instruction
	output	logic					commit1_if_rename_out				       	//if this entry is committed at this moment(tell RRAT)
//when committed, the output of the second instruction committed
	output	logic					commit2_is_branch_out,				       	//if this instruction is a branch
	output	logic					commit2_mispredict_out,				       	//if this instrucion is mispredicted
	output	logic	[4:0]				commit2_arn_dest_out,                                  	//the architected register number of the destination of this instruction
	output	logic	[`PRF_SIZE-1:0]			commit2_prn_dest_out,                                  	//the prf number of the destination of this instruction
	output	logic					commit2_if_rename_out				       	//if this entry is committed at this moment(tell RRAT)

);

//data logic variable needed

//function variable needed
	logic 	[$clog2(ROB_SEZE)-1:0]			head;
	logic 	[$clog2(ROB_SEZE)-1:0]			tail;
//internal logic variable needed
	logic	[`ROB_SIZE-1:0]				internal_is_branch_out;
	logic	[`ROB_SIZE-1:0]				internal_available_out;
	logic	[`ROB_SIZE-1:0]				internal_mispredict_out;
	logic	[`ROB_SIZE-1:0][4:0]			internal_arn_dest_out;
	logic	[`ROB_SIZE-1:0][[$clog2(`PRF_SIZE)-1:0]	internal_prn_dest_out;
	logic	[`ROB_SIZE-1:0]				internal_if_rename_out;
//internal_inst1_rob_load_in and internal_inst2_rob_load_in determine the number of entry we want to load instruction1 and instruction2
	logic	[`ROB_SIZE-1:0]				internal_inst1_rob_load_in;
	logic	[`ROB_SIZE-1:0]				internal_inst2_rob_load_in;  
//instantiate rob entries
	rob_one_entry rob1[`ROB_SIZE-1:0] (
	.reset(reset),
	.clock(clock),
	.rs_full(rs_full),
//
	.inst1_pc_in(inst1_pc_in),
	.inst1_arn_dest_in(inst1_arn_dest_in),
	.inst1_prn_dest_in(inst1_prn_dest_in),
	.inst1_is_branch_in(inst1_is_branch_in),
	.inst1_rob_load_in(internal_inst1_rob_load_in),

	.inst2_pc_in(inst2_pc_in),
	.inst2_arn_dest_in(inst2_arn_dest_in),
	.inst2_prn_dest_in(inst2_prn_dest_in),
	.inst2_is_branch_in(inst2_is_branch_in),
	.inst2_rob_load_in(internal_inst2_rob_load_in),
//
	.is_ex_in(),
	.mispredict_in(),
	.enable(1'b1),
	.if_committed(),
//
	.is_branch_out(internal_is_branch_out), 
	.available_out(internal_available_out),
	.mispredict_out(internal_mispredict_out),
	.arn_dest_out(internal_arn_dest_out),
	.prn_dest_out(internal_prn_dest_out),
	.if_rename_out(internal_if_rename_out)
	);
//when dispatching, we select two available rob entry from internal_available_out list
	two_stage_priority_selector	#(.p_SIZE(`ROB_SIZE))	tsps1(                                  
		.available(internal_rs_available_out),                                                 
		.enable1(inst1_load_in),							       
		.enable2(inst2_load_in),
		.output1(internal_inst1_rob_load_in),
		.output2(internal_inst2_rob_load_in)
	);
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

//instantiate the decoder, so we can output the number of rob assigned.
 	//decoder #(.SIZE(`RS_SIZE)) decoder1(.load(internal_inst1_rob_load_in),.idx(inst1_rs_rob_idx_in) );
	//decoder #(.SIZE(`RS_SIZE)) decoder2(.load(internal_inst2_rob_load_in),.idx(inst2_rs_rob_idx_in) );
	





endmodule
