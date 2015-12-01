//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  rs.v                                       	        //
//                                                                      //
//   Description :                                                      //
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module rs(

	input         								reset,          		// reset signal 
	input         								clock,          		// the clock 

	input  [$clog2(`PRF_SIZE)-1:0]  			inst1_rs_dest_in,     	// The destination of this instruction
	input  [$clog2(`PRF_SIZE)-1:0] 	 			inst2_rs_dest_in,     	// The destination of this instruction
 
	input  [63:0]								rs_cdb1_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  			rs_cdb1_tag,    		// CDB tag bus from functional units 
	input										rs_cdb1_valid,  		// The data on the CDB is valid 
	input  [63:0]								rs_cdb2_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  			rs_cdb2_tag,    		// CDB tag bus from functional units 
	input										rs_cdb2_valid,  		// The data on the CDB is valid 

        //for instruction1
	input  [63:0] 								inst1_rs_opa_in,      	// Operand a from Rename  
	input  [63:0] 								inst1_rs_opb_in,      	// Operand a from Rename 
	input  	     								inst1_rs_opa_valid,   	// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         								inst1_rs_opb_valid,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [$clog2(`ROB_SIZE):0]				inst1_rs_rob_idx_in,  	// The rob index of instruction 1
	input  ALU_FUNC								inst1_rs_alu_func,    	// ALU function type from decoder
	input  [5:0]	      						inst1_rs_op_type_in,  	// Instruction type from decoder
	input  FU_SELECT							inst1_rs_fu_select_in,
	input  		        						inst1_rs_load_in,     	// Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	input  [1:0]                                                            inst1_rs_branch_in,
        
        //for instruction2
	input  [63:0] 								inst2_rs_opa_in,      	// Operand a from Rename  
	input  [63:0] 								inst2_rs_opb_in,      	// Operand a from Rename 
	input  	     								inst2_rs_opa_valid,   	// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         								inst2_rs_opb_valid,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [$clog2(`ROB_SIZE):0]				inst2_rs_rob_idx_in,  	// The rob index of instruction 2
	input  ALU_FUNC								inst2_rs_alu_func,    	// ALU function type from decoder
	input  [5:0]	      						inst2_rs_op_type_in,  	// Instruction type from decoder
	input  FU_SELECT        					inst2_rs_fu_select_in,
	input  		        						inst2_rs_load_in,     	// Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	input  [1:0]                                                            inst2_rs_branch_in,

	input  [5:0]								fu_is_available,		//0,3:mult1,2 1,4:ALU1,2 2,5:MEM1,2
	
	input										thread1_branch_is_taken,// when a branch of thread1 is taken, we need to flush all the instructions of thread1 in RS
	input										thread2_branch_is_taken,// when a branch of thread2 is taken, we need to flush all the instructions of thread2 in RS
	
	input										inst1_is_halt,
	input										inst2_is_halt,
	

  
 	//output
	output logic [5:0][63:0]					fu_rs_opa_out,       	// This RS' opa 
	output logic [5:0][63:0]					fu_rs_opb_out,       	// This RS' opb 
	output logic [5:0][$clog2(`PRF_SIZE)-1:0]	fu_rs_dest_tag_out,  	// This RS' destination tag
	output logic [5:0][$clog2(`ROB_SIZE):0]		fu_rs_rob_idx_out,   	// This RS' corresponding ROB index
	output logic [5:0][5:0]						fu_rs_op_type_out,     	// This RS' operation type
	output ALU_FUNC [5:0]						fu_alu_func_out,
	
	output logic [5:0]							fu_rs_out_valid,			// RS output is valid
	output logic [5:0] [1:0]                                                fu_rs_branch_out, 

	output										rs_full,					// RS is full now
	
	// for debug
	input  [63:0]								inst1_rs_pc_in,
	input  [63:0]								inst2_rs_pc_in,
	output logic [5:0][63:0]					fu_inst_pc_out								
);

	
	//input of one entry
	//logic [2*`RS_SIZE-1:0]						internal_rs_load_in;			//instruction1 go to the entries according to this,
	logic [`RS_SIZE-1:0] 						inst1_internal_rs_load_in;		//when dispatching two instructions it tell us the address of entries to load each instructions
	logic [`RS_SIZE-1:0] 						inst2_internal_rs_load_in;		//instruction2 go to the entries according to this

	logic [`RS_SIZE-1:0]	 					internal_rs_free_enable_fu;			//tell rs which entry we want to send to FU1
	
	//output of one entry
	logic [`RS_SIZE-1:0]						internal_rs_ready_out;
	logic [`RS_SIZE-1:0]						internal_rs_available_out;	
	logic [`RS_SIZE-1:0][63:0]					internal_rs_opa_out;
	logic [`RS_SIZE-1:0][63:0]					internal_rs_opb_out;
	logic [`RS_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]	internal_rs_dest_tag_out;
	logic [`RS_SIZE-1:0][$clog2(`ROB_SIZE):0] 	internal_rs_rob_idx_out;
	logic [`RS_SIZE-1:0][5:0]					internal_rs_op_type_out;
	ALU_FUNC  [`RS_SIZE-1:0]					internal_rs_alu_func_out;
	FU_SELECT [`RS_SIZE-1:0]					internal_rs_fu_select_reg_out;  
	logic [`RS_SIZE-1:0]						internal_rs_free;
	logic [`RS_SIZE-1:0] [1:0] 					internal_rs_branch_sig;                          


	//internal registers
	

	logic	[`RS_SIZE-1:0]						ready_out_for_second_rs;
	logic	[`RS_SIZE-1:0]						second_rs_use_available;
	logic	[`RS_SIZE-1:0]  					temp_internal_rs_available_out;

	logic 										inst1_use_mult;
	logic										inst1_use_adder;
	logic										inst1_use_memory;

	logic	[63:0]								inst1_OPa;
	logic										inst1_OPaValid;
	logic	[63:0]								inst1_OPb;
	logic										inst1_OPbValid;
	logic	[63:0]								inst2_OPa;
	logic										inst2_OPaValid;
	logic	[63:0]								inst2_OPb;
	logic										inst2_OPbValid;

	logic	[`RS_SIZE-1:0]						is_full1, is_full2;
	
	logic 	[`RS_SIZE-1:0]						inst1_internal_rs_load_in_temp;
	logic   [`RS_SIZE-1:0]						inst2_internal_rs_load_in_temp;
	
	// for debug
	logic	[`RS_SIZE-1:0][63:0]				internal_rs_inst_pc_out;
	

	//instruction input selection
	always_comb begin
		inst1_OPa		= inst1_rs_opa_in;
		inst1_OPaValid	= inst1_rs_opa_valid;
		inst1_OPb		= inst1_rs_opb_in;
		inst1_OPbValid	= inst1_rs_opb_valid;
		inst2_OPa		= inst2_rs_opa_in;
		inst2_OPaValid	= inst2_rs_opa_valid;
		inst2_OPb		= inst2_rs_opb_in;
		inst2_OPbValid	= inst2_rs_opb_valid;

		if ((rs_cdb1_tag == inst1_rs_opa_in[$clog2(`PRF_SIZE)-1:0]) && !inst1_rs_opa_valid && rs_cdb1_valid)
		begin
			inst1_OPa		= rs_cdb1_in;
			inst1_OPaValid	= 1'b1;
		end
		else if ((rs_cdb2_tag == inst1_rs_opa_in[$clog2(`PRF_SIZE)-1:0]) && !inst1_rs_opa_valid && rs_cdb2_valid)
		begin
			inst1_OPa		= rs_cdb2_in;
			inst1_OPaValid	= 1'b1;
		end

		if ((rs_cdb1_tag == inst1_rs_opb_in[$clog2(`PRF_SIZE)-1:0]) && !inst1_rs_opb_valid && rs_cdb1_valid)
		begin
			inst1_OPb		= rs_cdb1_in;
			inst1_OPbValid	= 1'b1;
		end   	
		else if ((rs_cdb2_tag == inst1_rs_opb_in[$clog2(`PRF_SIZE)-1:0]) && !inst1_rs_opb_valid && rs_cdb2_valid)
		begin
			inst1_OPb		= rs_cdb2_in;
			inst1_OPbValid	= 1'b1;
		end

		if ((rs_cdb1_tag == inst2_rs_opa_in[$clog2(`PRF_SIZE)-1:0]) && !inst2_rs_opa_valid && rs_cdb1_valid)
		begin
			inst2_OPa		= rs_cdb1_in;
			inst2_OPaValid	= 1'b1;
		end
		else if ((rs_cdb2_tag == inst2_rs_opa_in[$clog2(`PRF_SIZE)-1:0]) && !inst2_rs_opa_valid && rs_cdb2_valid)
		begin
			inst2_OPa		= rs_cdb2_in;
			inst2_OPaValid	= 1'b1;
		end

		if ((rs_cdb1_tag == inst2_rs_opb_in[$clog2(`PRF_SIZE)-1:0]) && !inst2_rs_opb_valid && rs_cdb1_valid)
		begin
			inst2_OPb		= rs_cdb1_in;
			inst2_OPbValid	= 1'b1;
		end   	
		else if ((rs_cdb2_tag == inst2_rs_opb_in[$clog2(`PRF_SIZE)-1:0]) && !inst2_rs_opb_valid && rs_cdb2_valid)
		begin
			inst2_OPb		= rs_cdb2_in;
			inst2_OPbValid	= 1'b1;
		end  

	end

	rs_one_entry rs1[`RS_SIZE-1:0](
	//input	
	.reset(reset),					                    
	.clock(clock),     
     	
	.inst1_rs1_dest_in(inst1_rs_dest_in),
	.inst2_rs1_dest_in(inst2_rs_dest_in),   

 	.rs1_cdb1_in(rs_cdb1_in),
	.rs1_cdb1_tag(rs_cdb1_tag),
	.rs1_cdb1_valid(rs_cdb1_valid),  	
	.rs1_cdb2_in(rs_cdb2_in),
	.rs1_cdb2_tag(rs_cdb2_tag),    	
	.rs1_cdb2_valid(rs_cdb2_valid),
 
	.inst1_rs1_opa_in(inst1_OPa),
	.inst1_rs1_opb_in(inst1_OPb),		
	.inst1_rs1_opa_valid(inst1_OPaValid),
	.inst1_rs1_opb_valid(inst1_OPbValid),
	.inst1_rs1_alu_func(inst1_rs_alu_func),
	.inst1_rs1_op_type_in(inst1_rs_op_type_in),
	.inst1_rs1_fu_select(inst1_rs_fu_select_in),
	.inst1_rs_branch_in(inst1_rs_branch_in), 
	.inst2_rs1_opa_in(inst2_OPa),
	.inst2_rs1_opb_in(inst2_OPb),		
	.inst2_rs1_opa_valid(inst2_OPaValid),
	.inst2_rs1_opb_valid(inst2_OPbValid),
	.inst2_rs1_alu_func(inst2_rs_alu_func),
	.inst2_rs1_op_type_in(inst2_rs_op_type_in),
	.inst2_rs1_fu_select(inst2_rs_fu_select_in),
	.inst2_rs_branch_in(inst2_rs_branch_in), 	

	.inst1_rs1_load_in(inst1_internal_rs_load_in),   				
	.inst2_rs1_load_in(inst2_internal_rs_load_in),   					
	.inst1_rs1_rob_idx_in(inst1_rs_rob_idx_in),   
	.inst2_rs1_rob_idx_in(inst2_rs_rob_idx_in),   	

	.rs1_free_enable_fu(internal_rs_free_enable_fu),
	.rs1_free(internal_rs_free),
  
 	//output
	.rs1_ready_out(internal_rs_ready_out),
	.rs1_opa_out(internal_rs_opa_out),       
	.rs1_opb_out(internal_rs_opb_out),
	.rs1_dest_tag_out(internal_rs_dest_tag_out),  	 
	.rs1_available_out(internal_rs_available_out),
	.rs1_alu_func_out(internal_rs_alu_func_out),
	.rs1_op_type_out(internal_rs_op_type_out),
	.rs1_rob_idx_out(internal_rs_rob_idx_out),
	.fu_select_reg_out(internal_rs_fu_select_reg_out),
	.rs1_branch_sig(internal_rs_branch_sig),
	
	// for debug
	.inst1_pc_in(inst1_rs_pc_in),
	.inst2_pc_in(inst2_rs_pc_in),
	.rs1_inst_pc_out(internal_rs_inst_pc_out)

	  );  

	//when dispatching, two instruction comes in, 
	//this selector can help us to find two available entries in rs, 
	//then make the load of the two entries to be 1
	priority_selector #(.REQS(2),.WIDTH(`RS_SIZE)) tsps1(                                  
		.req(internal_rs_available_out),                                                 
		.en(inst1_rs_load_in && inst2_rs_load_in),
		.gnt_bus({inst1_internal_rs_load_in_temp, inst2_internal_rs_load_in_temp})
	);
	
	assign 	inst1_internal_rs_load_in = inst1_is_halt? 0 : inst1_internal_rs_load_in_temp;
	assign 	inst2_internal_rs_load_in = inst2_is_halt? 0 : inst2_internal_rs_load_in_temp;

	//during the wake-up rs entries , we want to select two to the two FU. 
	//but for example: only one adder is available, 
	//we want to make sure that only one instruction using adder is sent to FU, 
	//so the logic is quite complicated. 
	//if this condition happans, 
	//we have to forbid selecting two instructions both using adder.
	always_comb begin
	$display("internal_rs_available_out:%b", internal_rs_available_out);
		for (int i = 0; i < `RS_SIZE; i++) begin
			internal_rs_free_enable_fu[i]		= 0;
		end
		
		for (int i = 0; i < 6; i++) begin
			fu_rs_out_valid[i]		= 0;
			fu_rs_opa_out[i]		= 0;
			fu_rs_opb_out[i]		= 0;
			fu_rs_dest_tag_out[i]	= 0;
			fu_rs_rob_idx_out[i]	= 0;
			fu_rs_op_type_out[i]	= 0;
			fu_alu_func_out[i]		= ALU_DEFAULT;
			fu_rs_branch_out[i]        =0;
			fu_inst_pc_out[i]          =0;
		end

		if (fu_is_available[0]) begin
			for (int i = 0; i < `RS_SIZE; i++) begin
				if (internal_rs_ready_out[i] && internal_rs_fu_select_reg_out[i] == USE_MULTIPLIER) begin
					if (!internal_rs_free_enable_fu[i]) begin
						internal_rs_free_enable_fu[i] 	= 1;
						fu_rs_opa_out[0]		= internal_rs_opa_out[i];
						fu_rs_opb_out[0]		= internal_rs_opb_out[i];
						fu_rs_dest_tag_out[0]	= internal_rs_dest_tag_out[i];
						fu_rs_rob_idx_out[0]	= internal_rs_rob_idx_out[i];
						fu_rs_op_type_out[0]	= internal_rs_op_type_out[i];
						fu_rs_out_valid[0]		= 1'b1;
						fu_alu_func_out[0]		= internal_rs_alu_func_out[i];
						fu_rs_branch_out[0]             = internal_rs_branch_sig[i];
						fu_inst_pc_out[0]		= internal_rs_inst_pc_out[i];
						break;
					end
				end
			end
		end

		if (fu_is_available[1]) begin
			for (int i = 0; i < `RS_SIZE; i++) begin
				if (internal_rs_ready_out[i] && internal_rs_fu_select_reg_out[i] == USE_ADDER) begin
					if (!internal_rs_free_enable_fu[i]) begin
						internal_rs_free_enable_fu[i]		= 1;
						fu_rs_opa_out[1]		= internal_rs_opa_out[i];
						fu_rs_opb_out[1]		= internal_rs_opb_out[i];
						fu_rs_dest_tag_out[1]	= internal_rs_dest_tag_out[i];
						fu_rs_rob_idx_out[1]	= internal_rs_rob_idx_out[i];
						fu_rs_op_type_out[1]	= internal_rs_op_type_out[i];
						fu_rs_out_valid[1]		= 1'b1;
						fu_alu_func_out[1]		= internal_rs_alu_func_out[i];
						fu_rs_branch_out[1]             = internal_rs_branch_sig[i];
						fu_inst_pc_out[1]		= internal_rs_inst_pc_out[i];
						break;
					end
				end
			end
		end

		if (fu_is_available[2]) begin
			for (int i = 0; i < `RS_SIZE; i++) begin
				if (internal_rs_ready_out[i] && internal_rs_fu_select_reg_out[i] == USE_MULTIPLIER) begin
					if (!internal_rs_free_enable_fu[i]) begin
						internal_rs_free_enable_fu[i]	= 1;
						fu_rs_opa_out[2]	= internal_rs_opa_out[i];
						fu_rs_opb_out[2]	= internal_rs_opb_out[i];
						fu_rs_dest_tag_out[2]	= internal_rs_dest_tag_out[i];
						fu_rs_rob_idx_out[2]	= internal_rs_rob_idx_out[i];
						fu_rs_op_type_out[2]	= internal_rs_op_type_out[i];
						fu_rs_out_valid[2]	= 1'b1;
						fu_alu_func_out[2]		= internal_rs_alu_func_out[i];
						fu_rs_branch_out[2]             = internal_rs_branch_sig[i];
						fu_inst_pc_out[2]		= internal_rs_inst_pc_out[i];
						break;
					end
				end
			end
		end

		if (fu_is_available[3]) begin
			for (int i = 0; i < `RS_SIZE; i++) begin
				if (internal_rs_ready_out[i] && internal_rs_fu_select_reg_out[i] == USE_ADDER) begin
					if (!internal_rs_free_enable_fu[i]) begin
						internal_rs_free_enable_fu[i]	= 1;
						fu_rs_opa_out[3]	= internal_rs_opa_out[i];
						fu_rs_opb_out[3]	= internal_rs_opb_out[i];
						fu_rs_dest_tag_out[3]	= internal_rs_dest_tag_out[i];
						fu_rs_rob_idx_out[3]	= internal_rs_rob_idx_out[i];
						fu_rs_op_type_out[3]	= internal_rs_op_type_out[i];
						fu_rs_out_valid[3]	= 1'b1;
						fu_alu_func_out[3]		= internal_rs_alu_func_out[i];
						fu_rs_branch_out[3]             = internal_rs_branch_sig[i];
						fu_inst_pc_out[3]		= internal_rs_inst_pc_out[i];
						break;
					end
				end
			end
		end

		if (fu_is_available[4]) begin
			for (int i = 0; i < `RS_SIZE; i++) begin
				if (internal_rs_ready_out[i] && internal_rs_fu_select_reg_out[i] == USE_MEMORY) begin
					if (!internal_rs_free_enable_fu[i]) begin
						internal_rs_free_enable_fu[i]	= 1;
						fu_rs_opa_out[4]	= internal_rs_opa_out[i];
						fu_rs_opb_out[4]	= internal_rs_opb_out[i];
						fu_rs_dest_tag_out[4]	= internal_rs_dest_tag_out[i];
						fu_rs_rob_idx_out[4]	= internal_rs_rob_idx_out[i];
						fu_rs_op_type_out[4]	= internal_rs_op_type_out[i];
						fu_rs_out_valid[4]	= 1'b1;
						fu_alu_func_out[4]		= internal_rs_alu_func_out[i];
						fu_rs_branch_out[4]             = internal_rs_branch_sig[i];
						fu_inst_pc_out[4]		= internal_rs_inst_pc_out[i];
						break;
					end
				end
			end
		end

		if (fu_is_available[5]) begin
			for (int i = 0; i < `RS_SIZE; i++) begin
				if (internal_rs_ready_out[i] && internal_rs_fu_select_reg_out[i] == USE_MEMORY) begin
					if (!internal_rs_free_enable_fu[i]) begin
						internal_rs_free_enable_fu[i]	= 1;
						fu_rs_opa_out[5]	= internal_rs_opa_out[i];
						fu_rs_opb_out[5]	= internal_rs_opb_out[i];
						fu_rs_dest_tag_out[5]	= internal_rs_dest_tag_out[i];
						fu_rs_rob_idx_out[5]	= internal_rs_rob_idx_out[i];
						fu_rs_op_type_out[5]	= internal_rs_op_type_out[i];
						fu_rs_out_valid[5]	= 1'b1;
						fu_alu_func_out[5]		= internal_rs_alu_func_out[i];
						fu_rs_branch_out[5]             = internal_rs_branch_sig[i];
						fu_inst_pc_out[5]		= internal_rs_inst_pc_out[i];
						break;
					end
				end
			end
		end
					//	$display("fu_rs_dest_tag_out:%h", fu_rs_dest_tag_out);
	end

	//to test how many RS_one_entry(s) are available
	//if there isn't any entry availble, rs_full = RS_NO_ENTRY_EMPTY
	//if there is one entry available, rs_full = RS_ONE_ENTRY_EMPTY
	//if there is two or more entry available, rs_full = RS_TWO_OR_MORE_ENTRY_EMPTY

	priority_selector #(.REQS(2),.WIDTH(`RS_SIZE)) rs_is_full(                                  
		.req(internal_rs_available_out),
		.en(1'b1),
		.gnt_bus({is_full1, is_full2})
	);
	assign rs_full = (is_full1 == 0);
	
	always_comb
	begin
	    if (thread1_branch_is_taken && thread2_branch_is_taken)
	    begin
	    	for (int i = 0; i < `RS_SIZE; i++)
	    	begin
	    		internal_rs_free[i] = 1'b1;
	    	end
	    end
		else if (thread1_branch_is_taken)
		begin
			for (int i = 0; i < `RS_SIZE; i++)
			begin
				if (internal_rs_rob_idx_out[i][$clog2(`ROB_SIZE)]==1'b0)
				begin
					internal_rs_free[i] = 1'b1;
				end
				else
				begin
					internal_rs_free[i] = 1'b0;
				end
			end
		end
		else if (thread2_branch_is_taken)
		begin
			for (int i = 0; i < `RS_SIZE; i++)
			begin
				if (internal_rs_rob_idx_out[i][$clog2(`ROB_SIZE)]==1'b1)
				begin
					internal_rs_free[i] = 1'b1;
				end
				else
				begin
					internal_rs_free[i] = 1'b0;
				end
			end
		end
		else
		begin
			internal_rs_free = 0;
		end
	end
	
endmodule
