//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  rs_one_entry.v                                       //
//                                                                      //
//   Description :                                                      //
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module rs_one_entry(

	input         							reset,          				// reset signal 
	input         							clock,          				// the clock 

	input  [$clog2(`PRF_SIZE)-1:0]  		inst1_rs1_dest_in,    			// The destination of this instruction
	input  [$clog2(`PRF_SIZE)-1:0]  		inst2_rs1_dest_in,    			// The destination of this instruction
 
	input  [63:0] 							rs1_cdb1_in,					// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  		rs1_cdb1_tag,    				// CDB tag bus from functional units 
	input  	      							rs1_cdb1_valid,					// The data on the CDB is valid 
	input  [63:0] 							rs1_cdb2_in,					// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  		rs1_cdb2_tag,    				// CDB tag bus from functional units 
	input  	      							rs1_cdb2_valid,					// The data on the CDB is valid 

	input  [63:0] 							inst1_rs1_opa_in,				// Operand a from Rename  
	input  [63:0] 							inst1_rs1_opb_in,				// Operand a from Rename 
	input  	     							inst1_rs1_opa_valid,			// Is Opa a Tag or immediate data (READ THIS COMMENT)
	input         							inst1_rs1_opb_valid,			// Is Opb a tag or immediate data (READ THIS COMMENT)
	
	input  [63:0]                                                         inst1_rs1_opc_in,
 	input         							inst1_rs1_opc_valid,

	input  ALU_FUNC							inst1_rs1_alu_func,
	input  FU_SELECT						inst1_rs1_fu_select,
	input  [5:0]							inst1_rs1_op_type_in,			// Instruction type of rs1
	input  [1:0]                          				inst1_rs_branch_in,

	input  [63:0] 							inst2_rs1_opa_in,				// Operand a from Rename  
	input  [63:0] 							inst2_rs1_opb_in,				// Operand a from Rename 
	input  	     							inst2_rs1_opa_valid,			// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         							inst2_rs1_opb_valid,			// Is Opb a tag or immediate data (READ THIS COMMENT) 

	input  [63:0]                                                         inst2_rs1_opc_in,
 	input         							inst2_rs1_opc_valid,

	input  ALU_FUNC							inst2_rs1_alu_func,
	input  FU_SELECT						inst2_rs1_fu_select,
	input  [5:0]							inst2_rs1_op_type_in,			// Instruction type of rs1
	input  [1:0]                          				inst2_rs_branch_in,

	input  		        					inst1_rs1_load_in,				// rs1 need two loads for each Signal from rename to flop opa/b/or signal to tell RS to load instruction in
	input  		        					inst2_rs1_load_in,

	input   	        					rs1_free_enable_fu,				// Signal to send data to Func units AND to free this RS
	input									rs1_free,						// when branch is taken, we need to free all RS entry

	input  [$clog2(`ROB_SIZE):0]       		inst1_rs1_rob_idx_in,   		// 
	input  [$clog2(`ROB_SIZE):0]       		inst2_rs1_rob_idx_in,  			// 
	


 	//output
	output logic							rs1_ready_out,    				// This RS is in use and ready to go to EX 
	output logic [63:0]						rs1_opa_out,       				// This RS' opa 
	output logic [63:0]						rs1_opb_out,       				// This RS' opb 

	output logic [63:0] 						rs1_opc_out,
	output logic [$clog2(`PRF_SIZE)-1:0]	rs1_dest_tag_out,  				// This RS' destination tag   
	output logic							rs1_available_out, 				// This RS' is available
	output ALU_FUNC							rs1_alu_func_out,
	output logic [$clog2(`ROB_SIZE):0]    	rs1_rob_idx_out,	 		  	// 
	output FU_SELECT						fu_select_reg_out,
	output [5:0]							rs1_op_type_out,
	output [1:0]  							rs1_branch_sig,
	
	// for debug
	input  [63:0]  							inst1_pc_in,
	input  [63:0]							inst2_pc_in,
	output logic [63:0]						rs1_inst_pc_out
);


	logic  [63:0] 							OPa;              				// Operand A 
	logic  [63:0] 							OPb;              				// Operand B 
	logic  									OPaValid;         				// Operand a Tag/Value 
	logic  									OPbValid;         				// Operand B Tag/Value
	logic  [63:0] 							OPa_reg;              			// Operand A 
	logic  [63:0] 							OPb_reg;              			// Operand B 
	logic  									OPaValid_reg;         			// Operand a Tag/Value 
	logic  									OPbValid_reg;         			// Operand B Tag/Value 

	logic  [63:0] 							OPc;
	logic  									OPcValid;
	logic  [63:0] 							OPc_reg;
	logic  									OPcValid_reg;

	logic  									InUse;            				// InUse bit 
	logic  [$clog2(`PRF_SIZE)-1:0]  		DestTag;   						// Destination Tag bit 
	logic  [$clog2(`ROB_SIZE):0] 			Rob_idx;
	logic  [$clog2(`PRF_SIZE)-1:0]  		DestTag_reg;   					// Destination Tag bit 
	logic  [$clog2(`ROB_SIZE):0] 			Rob_idx_reg;
 
	logic  									LoadAFromCDB1;  				// signal to load from the CDB1 
	logic  									LoadBFromCDB1;  				// signal to load from the CDB1
	logic  									LoadAFromCDB2;  				// signal to load from the CDB2 
	logic  									LoadBFromCDB2;  				// signal to load from the CDB2

	logic  									LoadCFromCDB1;
	logic  									LoadCFromCDB2;  
	logic									next_InUse;

	logic [5:0]								op_type;
	logic [5:0]								op_type_reg;
	ALU_FUNC								Alu_func;
	ALU_FUNC								Alu_func_reg;
	FU_SELECT								fu_select;
	FU_SELECT								fu_select_reg;

	logic [1:0]                           					branch_reg;
	logic [1:0] 								branch_sig;
	logic									OPcuse;
	
	//for debug
	logic [63:0]							inst_pc_reg;
	logic [63:0]							inst_pc;

	assign rs1_available_out= rs1_ready_out ? rs1_free_enable_fu : ~InUse;
 
	assign rs1_ready_out 	= InUse && OPaValid_reg && OPbValid_reg && OPcuse; 
 
	assign rs1_opa_out 		= rs1_free_enable_fu ? OPa_reg : 64'b0;

	assign fu_select_reg_out= fu_select_reg;
 
	assign rs1_opb_out 		= rs1_free_enable_fu ? OPb_reg : 64'b0;

	assign rs1_opc_out 		= rs1_free_enable_fu ? OPc_reg : 64'b0;
 
	assign rs1_dest_tag_out = rs1_free_enable_fu ? DestTag_reg : 0; 

	assign rs1_rob_idx_out	= Rob_idx_reg;
	
	assign rs1_alu_func_out = rs1_free_enable_fu ? Alu_func_reg : ALU_DEFAULT;
	
	assign rs1_op_type_out	= rs1_free_enable_fu ? op_type_reg : 0;
	
	assign rs1_inst_pc_out	= rs1_free_enable_fu ? inst_pc_reg : 0 ;

	assign rs1_branch_sig	= rs1_free_enable_fu ? branch_reg : 0 ;
	
	assign OPcuse = branch_reg[1] ? OPcValid_reg : 1'b1;

	assign LoadAFromCDB1 	= (rs1_cdb1_tag == OPa_reg[$clog2(`PRF_SIZE)-1:0]) && !OPaValid_reg && InUse && rs1_cdb1_valid; 

	assign LoadBFromCDB1 	= (rs1_cdb1_tag == OPb_reg[$clog2(`PRF_SIZE)-1:0]) && !OPbValid_reg && InUse && rs1_cdb1_valid; 

	assign LoadAFromCDB2 	= (rs1_cdb2_tag == OPa_reg[$clog2(`PRF_SIZE)-1:0]) && !OPaValid_reg && InUse && rs1_cdb2_valid; 

	assign LoadBFromCDB2 	= (rs1_cdb2_tag == OPb_reg[$clog2(`PRF_SIZE)-1:0]) && !OPbValid_reg && InUse && rs1_cdb2_valid;

	assign LoadCFromCDB1 	= (rs1_cdb1_tag == OPc_reg[$clog2(`PRF_SIZE)-1:0]) && !OPcValid_reg && InUse && rs1_cdb1_valid; 
	
	assign LoadCFromCDB2 	= (rs1_cdb2_tag == OPc_reg[$clog2(`PRF_SIZE)-1:0]) && !OPcValid_reg && InUse && rs1_cdb2_valid;

	always_comb begin

		if (rs1_free) begin
			OPa			= 0;
       		OPaValid	= 0;
       		OPb			= 0;
       		OPbValid	= 0;
			OPc			= 0;
			OPcValid	= 0;
			fu_select	= FU_DEFAULT;
			DestTag		= 0;
			Rob_idx		= 0;
			Alu_func	= ALU_DEFAULT;
			op_type		= 0;
			next_InUse	= 1'b0;
			inst_pc		= 0;
			branch_sig	= 0;
		end
		else if (rs1_free_enable_fu && inst1_rs1_load_in)
		begin
			OPa			= inst1_rs1_opa_in;
       		OPaValid	= inst1_rs1_opa_valid;
       		OPb			= inst1_rs1_opb_in;
       		OPbValid	= inst1_rs1_opb_valid;
		    OPc			= inst1_rs1_opc_in;
       		OPcValid	= inst1_rs1_opc_valid;
			fu_select	= inst1_rs1_fu_select;
			DestTag		= inst1_rs1_dest_in;
			Rob_idx		= inst1_rs1_rob_idx_in;
			Alu_func	= inst1_rs1_alu_func;
			op_type		= inst1_rs1_op_type_in;
			next_InUse	= 1'b1;
			inst_pc		= inst1_pc_in;
			branch_sig      = inst1_rs_branch_in;
		end
		else if (rs1_free_enable_fu && inst2_rs1_load_in)
		begin
			OPa			= inst2_rs1_opa_in;
       		OPaValid	= inst2_rs1_opa_valid;
       		OPb			= inst2_rs1_opb_in;
       		OPbValid	= inst2_rs1_opb_valid;
		    OPc			= inst2_rs1_opc_in;
       		OPcValid	= inst2_rs1_opc_valid;

			fu_select	= inst2_rs1_fu_select;
			DestTag		= inst2_rs1_dest_in;
			Rob_idx		= inst2_rs1_rob_idx_in;
			Alu_func	= inst2_rs1_alu_func;
			op_type		= inst2_rs1_op_type_in;
			next_InUse	= 1'b1;
			inst_pc		= inst2_pc_in;
			branch_sig      = inst2_rs_branch_in;
		end
		else if (rs1_free_enable_fu) begin
			OPa			= 0;
       		OPaValid	= 0;
       		OPb			= 0;
       		OPbValid	= 0;
			OPc			= 0;
       		OPcValid	= 0;
			fu_select	= FU_DEFAULT;
			DestTag		= 0;
			Rob_idx		= 0;
			Alu_func	= ALU_DEFAULT;
			op_type		= 0;
			next_InUse	= 1'b0;
			inst_pc		= 0;
			branch_sig  = 0;
		end
		else if (inst1_rs1_load_in) begin
			OPa			= inst1_rs1_opa_in;
       		OPaValid	= inst1_rs1_opa_valid;
       		OPb			= inst1_rs1_opb_in;
       		OPbValid	= inst1_rs1_opb_valid;
		   OPc			= inst1_rs1_opc_in;
       		OPcValid	= inst1_rs1_opc_valid;
			fu_select	= inst1_rs1_fu_select;
			DestTag		= inst1_rs1_dest_in;
			Rob_idx		= inst1_rs1_rob_idx_in;
			Alu_func	= inst1_rs1_alu_func;
			op_type		= inst1_rs1_op_type_in;
			next_InUse	= 1'b1;
			inst_pc		= inst1_pc_in;
			branch_sig      = inst1_rs_branch_in;
		end
		else if (inst2_rs1_load_in) begin
			OPa			= inst2_rs1_opa_in;
       		OPaValid	= inst2_rs1_opa_valid;
       		OPb			= inst2_rs1_opb_in;
       		OPbValid	= inst2_rs1_opb_valid;
			OPc			= inst2_rs1_opc_in;
       		OPcValid	= inst2_rs1_opc_valid;
			fu_select	= inst2_rs1_fu_select;
			DestTag		= inst2_rs1_dest_in;
			Rob_idx		= inst2_rs1_rob_idx_in;
			Alu_func	= inst2_rs1_alu_func;
			op_type		= inst2_rs1_op_type_in;
			next_InUse	= 1'b1;
			inst_pc		= inst2_pc_in;
			branch_sig	= inst2_rs_branch_in;
		end
		else begin
			OPa			= OPa_reg;
       		OPaValid	= OPaValid_reg;
       		OPb			= OPb_reg;
       		OPbValid	= OPbValid_reg;
			OPc			= OPc_reg;
       		OPcValid	= OPcValid_reg;
			fu_select	= fu_select_reg;
			DestTag		= DestTag_reg;
			Rob_idx		= Rob_idx_reg;
			Alu_func	= Alu_func_reg;
			op_type		= op_type_reg;
			next_InUse	= InUse;
			inst_pc		= inst_pc_reg;
			branch_sig	= branch_reg;
			if (LoadAFromCDB1)
			begin
    			OPa			= rs1_cdb1_in;
    			OPaValid	= 1'b1;
			end
			if (LoadBFromCDB1)
			begin
    			OPb			= rs1_cdb1_in;
    			OPbValid	= 1'b1;
			end
			if (LoadAFromCDB2)
			begin
    			OPa 		= rs1_cdb2_in;
    			OPaValid	= 1'b1;
			end
			if (LoadBFromCDB2)
			begin
    			OPb 		= rs1_cdb2_in;
    			OPbValid	= 1'b1;
			end
		
			if (LoadCFromCDB1)
			begin
    			OPc 		= rs1_cdb1_in;
    			OPcValid	= 1'b1;
			end
			if (LoadCFromCDB2)
			begin
    			OPc 		= rs1_cdb2_in;
    			OPcValid	= 1'b1;
			end
    		// Clear InUse bit once the FU has data
		end
	end

	always_ff @(posedge clock)
	begin
    	if (reset)
		begin
       		OPa_reg	 		<= `SD 0;
       		OPb_reg	 		<= `SD 0;
			OPc_reg	 		<= `SD 0;
      		OPaValid_reg 	<= `SD 0;
 	   		OPbValid_reg	<= `SD 0;
			OPcValid_reg	<= `SD 0;
       		InUse 	 		<= `SD 1'b0;
       		fu_select_reg	<= `SD FU_DEFAULT;
      		DestTag_reg		<= `SD 0;
			Rob_idx_reg		<= `SD 0;
			Alu_func_reg 	<= `SD ALU_DEFAULT;
			inst_pc_reg     <= `SD 0;
			branch_reg		<= `SD 0;
		end
		else
		begin
			OPa_reg			<= `SD OPa;
			OPaValid_reg	<= `SD OPaValid;
			OPb_reg			<= `SD OPb;
			OPbValid_reg	<= `SD OPbValid;
			OPc_reg			<= `SD OPc;
			OPcValid_reg	<= `SD OPcValid;
			fu_select_reg	<= `SD fu_select;
   			InUse 	 		<= `SD next_InUse;
   			DestTag_reg		<= `SD DestTag;
   			Rob_idx_reg		<= `SD Rob_idx;
   			Alu_func_reg 	<= `SD Alu_func;
   			op_type_reg		<= `SD op_type;
   			inst_pc_reg     <= `SD inst_pc;
			branch_reg      <= `SD branch_sig;
		end // else !reset
	end // always @
endmodule
