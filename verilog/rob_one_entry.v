//******************************************************************************//
//      	modulename: rob_one_entry.v											//
//      																		//
//      		Description:					       							//
//      								       									//
//      								       									//
//      								       									//
//      								       									//
//									   								       		//
//      								       									//
//      								       									//
//////////////////////////////////////////////////////////////////////////////////


module rob_one_entry(

//input:
//basic
	input				reset,
	input				clock,

//after dispatch 
	input				is_thread1,
	input	[31:0]			inst1_pc_in,                    //pc in
	input	[4:0]			inst1_arn_dest_in,              //the architected register number of the destination of this instruction
	input	[$clog2(`PRF_SIZE)-1:0] inst1_prn_dest_in,              //the prf number assigned to the destination of this instruction
	input				inst1_is_branch_in,             //if this instruction is a branch
	input 				inst1_rob_load_in,				//tell this entry if we want to load this instruction

	input	[31:0]			inst2_pc_in,                    //pc in
	input	[4:0]			inst2_arn_dest_in,              //the architected register number of the destination of this instruction
	input	[$clog2(`PRF_SIZE)-1:0] inst2_prn_dest_in,              //the prf number assigned to the destination of this instruction
	input				inst2_is_branch_in,             //if this instruction is a branch
	input 				inst2_rob_load_in,				//tell this entry if we want to load this instruction

//after execution
	input				is_ex_in,                       //if this instruciont has been executed so that the value of the prf number assigned is valid
	input				mispredict_in,                  //after execution, if this instruction is a branch and it has been taken , this input should be "1"
	input				enable,					       	//if the input can be loaded to this entry
 	input				if_committed,					//if this ROB entry hit the head of the ROB and is about to be committed

//output:
//is this entry is about to be commmited, the output takes effect
	output				is_thread1_out,
	output				is_ex_out,
	output				is_branch_out,				       	//if this instruction is a branch
	output				available_out,				       	//if this rob entry is available
	output				mispredict_out,				       	//if this instrucion is mispredicted
	output	[4:0]			arn_dest_out,                       //the architected register number of the destination of this instruction
	output	[$clog2(`PRF_SIZE)-1:0]	prn_dest_out,                       //the prf number of the destination of this instruction
	output				if_rename_out				       	//if this entry is committed at this moment(tell RRAT)
);


//information of the instruction stored in this rob entry 
	logic				thread;
	logic	[31:0]			pc;							//pc stored in this entry
	logic	[4:0]			arn_dest;                   //the architected register number of the destination of this instruction stored in this entry
	logic	[$clog2(`PRF_SIZE)-1:0] prn_dest;                   //the prf number assigned to the destination of this instruction
	logic				is_branch;                  //if this instruction stored in this entry is a branch
	logic				is_executed;				//if this instruction stored in this entry has been executed
	logic				mispredict;                 //if this instrucion has was mispredicted
	logic				inuse;                      //if this entry is in use

	logic				next_thread;
	logic	[31:0]			next_pc;					//pc stored in this entry
	logic	[4:0]			next_arn_dest;              //the architected register number of the destination of this instruction stored in this entry
	logic	[$clog2(`PRF_SIZE)-1:0] next_prn_dest;              //the prf number assigned to the destination of this instruction
	logic				next_is_branch;             //if this instruction stored in this entry is a branch
	logic				next_is_executed;			//if this instruction stored in this entry has been executed
	logic				next_mispredict;            //if this instrucion has was mispredicted
	logic				next_inuse;                      //if this entry is in use

//describe the output function
	assign is_thread1_out = if_committed ? thread : 0;
	assign is_branch_out = if_committed ? is_branch : 0;
	assign mispredict_out = if_committed ? mispredict : 0;
	assign arn_dest_out = if_committed ? arn_dest : 0;
	assign prn_dest_out = if_committed ? prn_dest : 0;
	assign if_rename_out = if_committed;						//if this entry is committed the output information is important
	assign is_ex_out = is_executed;
	assign available_out = ~inuse;			//if this entry is not in use, it is available

	always_comb
	begin
		next_thread		= thread;
		next_pc			= pc;
		next_arn_dest		= arn_dest;
		next_prn_dest		= prn_dest;
		next_is_branch		= is_branch;
		next_is_executed	= is_executed;
		next_mispredict		= mispredict;
		next_inuse		= inuse;
		if (inst1_rob_load_in)
		begin
			next_thread		= is_thread1;
			next_pc			= inst1_pc_in;
			next_arn_dest		= inst1_arn_dest_in;
			next_prn_dest		= inst1_prn_dest_in;
			next_is_branch		= inst1_is_branch_in;
			next_is_executed	= 0;
			next_mispredict		= 0;
			next_inuse			= 1'b1;
		end
		else if (inst2_rob_load_in)
		begin
			next_thread		= is_thread1;
			next_pc			= inst2_pc_in;
			next_arn_dest		= inst2_arn_dest_in;
			next_prn_dest		= inst2_prn_dest_in;
			next_is_branch		= inst2_is_branch_in;
			next_is_executed	= 0;
			next_mispredict		= 0;
			next_inuse			= 1'b1;
		end
		else if (inuse && is_ex_in) begin
			next_is_executed 	= is_ex_in;
			next_mispredict		= mispredict_in;
		end
		else if (if_committed)
		begin
			next_inuse		= 1'b0;	//if committed, the next clock period we set inuse to be 0
		end
	end
	always_ff @(posedge clock)
	begin
		//if reset
		if (reset)
		begin
			thread		<=	`SD 0;
			pc		<=	`SD 0;
			arn_dest	<=	`SD 0;
			prn_dest	<=	`SD 0;
			is_branch	<= 	`SD 0;
			is_executed	<=	`SD 0;
			mispredict	<=	`SD 0;
			inuse		<=	`SD 0;
		end
		//if we want to load an instruction, the behavior is as follows:
		else if (enable)
		begin
			thread		<=	`SD next_thread;
			pc		<=	`SD next_pc;
			arn_dest	<=	`SD next_arn_dest;
			prn_dest	<=	`SD next_prn_dest;
			is_branch	<= 	`SD next_is_branch;
			is_executed	<=	`SD next_is_executed;
			mispredict	<=	`SD next_mispredict;
			inuse		<=	`SD next_inuse;
		end
	end//end always_ff                            
endmodule





