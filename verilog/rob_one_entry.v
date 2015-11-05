/******************************************************************************//
//      	modulename: rob_one_entry.v				       //
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


module rob_one_entry(

//input:
//basic
	input				reset,
	input				clock,
	input				rs_full,                                       	//if rs is full

//after dispatch 
	input	[31:0]			inst1_pc_in,                                    //pc in
	input	[4:0]			inst1_arn_dest_in,                              //the architected register number of the destination of this instruction
	input	[$clog2(`PRF_SIZE)-1:0] inst1_prn_dest_in,                              //the prf number assigned to the destination of this instruction
	input				inst1_is_branch_in,                             //if this instruction is a branch
	input 				inst1_rob_load_in				//tell this entry if we want to load this instruction
	input				inst1_if_thread1				//the it is for thread1, else it is for thread2

	input	[31:0]			inst2_pc_in,                                    //pc in
	input	[4:0]			inst2_arn_dest_in,                              //the architected register number of the destination of this instruction
	input	[$clog2(`PRF_SIZE)-1:0] inst2_prn_dest_in,                              //the prf number assigned to the destination of this instruction
	input				inst2_is_branch_in,                             //if this instruction is a branch
	input 				inst2_rob_load_in				//tell this entry if we want to load this instruction
	input				inst2_if_thread1				//the it is for thread1, else it is for thread2



//after execution
	input				is_ex_in,                                      	//if this instruciont has been executed so that the value of the prf number assigned is valid
	input				mispredict_in,                                 	//after execution, if this instruction is a branch and it has been taken , this input should be "1"
	input				enable,					       	//if the input can be loaded to this entry
 	input				if_committed,		                       	//if this ROB entry hit the head of the ROB and is about to be committed

//output:
//is this entry is about to be commmited, the output takes effect
	output				is_ex_out
	output				is_branch_out,				       	//if this instruction is a branch
	output				available_out,				       	//if this rob entry is available
	output				mispredict_out,				       	//if this instrucion is mispredicted
	output	[4:0]			arn_dest_out,                                  	//the architected register number of the destination of this instruction
	output	[$clog2(`PRF_SIZE)-1:0]	prn_dest_out,                                  	//the prf number of the destination of this instruction
	output				if_rename_out				       	//if this entry is committed at this moment(tell RRAT)
);


//information of the instruction stored in this rob entry 
	logic	[31:0]			pc,                                            	//pc stored in this entry
	logic	[4:0]			arn_dest,                                      	//the architected register number of the destination of this instruction stored in this entry
	logic	[$clog2(`PRF_SIZE)-1:0] prn_dest,                                      	//the prf number assigned to the destination of this instruction
	logic				is_branch,                                     	//if this instruction stored in this entry is a branch
	logic				is_executed				       	//if this instruction stored in this entry has been executed
	logic				mispredict                                     	//if this instrucion has was mispredicted
	logic				inuse                                          	//if this entry is in use

//describe the output function
	assign is_branch_out = if_committed ? is_branch : 0;
	assign mispredict_out = if_committed ? mispredict : 0;
	assign arn_dest_out = if_committed ? arn_dest : 0;
	assign prn_dest_out = if_committed ? prn_dest : 0;
	assign rename_out = if_committed;                                      		//if this entry is committed the output information is important
	assign is_ex_out = is_executed;

	assign available_out = ~inuse;                                         		//if this entry is not in use, it is available

	always_ff @(posedge clock)
	begin
		//if reset
		if (reset)
		begin
			pc		<=	`SD 0;
			arn_dest	<=	`SD 0;
			prn_dest	<=	`SD 0;
			is_branch	<= 	`SD 0;
			is_executed	<=	`SD 0;
			mispredict	<=	`SD 0;
			inuse		<=	`SD 0;
		end
		//if we want to load an instruction, the behavior is as follows:
		else
		begin
			if (inst1_rob_load_in)
			begin
				pc		<=	`SD inst1_pc_in;
				arn_dest	<=	`SD inst1_arn_dest_in;
				prn_dest	<=	`SD inst1_prn_dest_in;
				is_branch	<= 	`SD inst1_is_branch_in;
				is_executed	<=	`SD inst1_is_ex_in;
				mispredict	<=	`SD inst1_mispredict_in;
				inuse		<=	`SD 1'b1;
			end
			else if (inst2_rob_load_in)
			begin
				pc		<=	`SD inst2_pc_in;
				arn_dest	<=	`SD inst2_arn_dest_in;
				prn_dest	<=	`SD inst2_prn_dest_in;
				is_branch	<= 	`SD inst2_is_branch_in;
				is_executed	<=	`SD inst2_is_ex_in;
				mispredict	<=	`SD inst2_mispredict_in;
				inuse		<=	`SD 1'b1;
			end
			else if (if_committed)
			begin
				inuse		<=	`SD 0;				//if committed, the next clock period we set inuse to be 0
			end
		end
	end//end always_ff                            
endmodule
