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

	input         				reset,          	// reset signal 
	input         				clock,          	// the clock 

	input  [$clog2(`PRF_SIZE)-1:0]  	inst1_rs1_dest_in,    	// The destination of this instruction
	input  [$clog2(`PRF_SIZE)-1:0]  	inst2_rs1_dest_in,    	// The destination of this instruction
 
	input  [63:0] 						rs1_cdb1_in,		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  	rs1_cdb1_tag,    	// CDB tag bus from functional units 
	input  	      						rs1_cdb1_valid,		// The data on the CDB is valid 
	input  [63:0] 						rs1_cdb2_in,		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  	rs1_cdb2_tag,    	// CDB tag bus from functional units 
	input  	      						rs1_cdb2_valid,		// The data on the CDB is valid 

	input  [63:0] 				inst1_rs1_opa_in,		// Operand a from Rename  
	input  [63:0] 				inst1_rs1_opb_in,		// Operand a from Rename 
	input  	     				inst1_rs1_opa_valid,		// Is Opa a Tag or immediate data (READ THIS COMMENT)
	input         				inst1_rs1_opb_valid,		// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  ALU_FUNC				inst1_rs1_alu_func,
	input  FU_SELECT			inst1_rs1_fu_select,
	input  [5:0]				inst1_rs1_op_type_in,		// Instruction type of rs1

	input  [63:0] 				inst2_rs1_opa_in,		// Operand a from Rename  
	input  [63:0] 				inst2_rs1_opb_in,		// Operand a from Rename 
	input  	     				inst2_rs1_opa_valid,		// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         				inst2_rs1_opb_valid,		// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  ALU_FUNC				inst2_rs1_alu_func,
	input  FU_SELECT			inst2_rs1_fu_select,
	input  [5:0]				inst2_rs1_op_type_in,		// Instruction type of rs1

	input  		        		inst1_rs1_load_in,		// *****rs1 need two loads for each      Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	input  		        		inst2_rs1_load_in,

	input   	        		rs1_free,		// Signal to send data to Func units AND to free this RS

	input  [$clog2(`ROB_SIZE):0]       	inst1_rs1_rob_idx_in,   	// 
	input  [$clog2(`ROB_SIZE):0]       	inst2_rs1_rob_idx_in,   	// 

 	//output
	output logic							rs1_ready_out,    	// This RS is in use and ready to go to EX 
	output logic [63:0]						rs1_opa_out,       	// This RS' opa 
	output logic [63:0]						rs1_opb_out,       	// This RS' opb 
	output logic [$clog2(`PRF_SIZE)-1:0]	rs1_dest_tag_out,  	// This RS' destination tag   
	output logic							rs1_available_out, 	// This RS' is available
	output ALU_FUNC							rs1_alu_func_out,
	output logic [$clog2(`ROB_SIZE):0]    	rs1_rob_idx_out,   	// 
	output FU_SELECT						fu_select_reg_out,
);


	logic  [63:0] 			OPa;              	// Operand A 
	logic  [63:0] 			OPb;              	// Operand B 
	logic  					OPaValid;         	// Operand a Tag/Value 
	logic  					OPbValid;         	// Operand B Tag/Value
	logic  [63:0] 			OPa_reg;              	// Operand A 
	logic  [63:0] 			OPb_reg;              	// Operand B 
	logic  					OPaValid_reg;         	// Operand a Tag/Value 
	logic  					OPbValid_reg;         	// Operand B Tag/Value 
	logic  					InUse;            	// InUse bit 
	logic  [$clog2(`PRF_SIZE)-1:0]  	DestTag;   		// Destination Tag bit 
	logic  [$clog2(`ROB_SIZE):0] 		Rob_idx;
	logic  [$clog2(`PRF_SIZE)-1:0]  	DestTag_reg;   		// Destination Tag bit 
	logic  [$clog2(`ROB_SIZE):0] 		Rob_idx_reg;
 
	logic  					LoadAFromCDB1;  	// signal to load from the CDB1 
	logic  					LoadBFromCDB1;  	// signal to load from the CDB1
	logic  					LoadAFromCDB2;  	// signal to load from the CDB2 
	logic  					LoadBFromCDB2;  	// signal to load from the CDB2  
	logic					next_InUse;

	logic [5:0]				op_type;
	logic [5:0]				op_type_reg;
	ALU_FUNC				Alu_func;
	ALU_FUNC				Alu_func_reg;
	FU_SELECT				fu_select;
	FU_SELECT				fu_select_reg;

	assign rs1_available_out= rs1_ready_out ? rs1_free : ~InUse;
 
	assign rs1_ready_out 	= InUse && OPaValid_reg && OPbValid_reg; 
 
	assign rs1_opa_out 		= rs1_free ? OPa_reg : 64'b0;

	assign fu_select_reg_out= fu_select_reg;
 
	assign rs1_opb_out 		= rs1_free ? OPb_reg : 64'b0; 
 
	assign rs1_dest_tag_out = rs1_free ? DestTag : 0; 

	assign rs1_rob_idx_out	= rs1_free ? Rob_idx : 0;
	
	assign rs1_alu_func_out = rs1_free ? Alu_func_reg : ALU_DEFAULT;

	assign LoadAFromCDB1 	= (rs1_cdb1_tag == OPa_reg[$clog2(`PRF_SIZE)-1:0]) && !OPaValid_reg && InUse && rs1_cdb1_valid; 

	assign LoadBFromCDB1 	= (rs1_cdb1_tag == OPb_reg[$clog2(`PRF_SIZE)-1:0]) && !OPbValid_reg && InUse && rs1_cdb1_valid; 

	assign LoadAFromCDB2 	= (rs1_cdb2_tag == OPa_reg[$clog2(`PRF_SIZE)-1:0]) && !OPaValid_reg && InUse && rs1_cdb2_valid; 

	assign LoadBFromCDB2 	= (rs1_cdb2_tag == OPb_reg[$clog2(`PRF_SIZE)-1:0]) && !OPbValid_reg && InUse && rs1_cdb2_valid;

	always_comb begin
		if (inst1_rs1_load_in) begin
			OPa			= inst1_rs1_opa_in;
       		OPaValid	= inst1_rs1_opa_valid;
       		OPb			= inst1_rs1_opb_in;
       		OPbValid	= inst1_rs1_opb_valid;
			fu_select	= inst1_rs1_fu_select;
			DestTag		= inst1_rs1_dest_in;
			Rob_idx		= inst1_rs1_rob_idx_in;
			Alu_func	= inst1_rs1_alu_func;
			op_type		= inst1_rs1_op_type_in;
			next_InUse	= 1'b1;
		end
		else if (inst2_rs1_load_in) begin
			OPa			= inst2_rs1_opa_in;
       		OPaValid	= inst2_rs1_opa_valid;
       		OPb			= inst2_rs1_opb_in;
       		OPbValid	= inst2_rs1_opb_valid;
			fu_select	= inst2_rs1_fu_select;
			DestTag		= inst2_rs1_dest_in;
			Rob_idx		= inst2_rs1_rob_idx_in;
			Alu_func	= inst2_rs1_alu_func;
			op_type		= inst2_rs1_op_type_in;
			next_InUse	= 1'b1;
		end
		else begin
			OPa			= OPa_reg;
       		OPaValid	= OPaValid_reg;
       		OPb			= OPb_reg;
       		OPbValid	= OPbValid_reg;
			fu_select	= fu_select_reg;
			DestTag		= DestTag_reg;
			Rob_idx		= Rob_idx_reg;
			Alu_func	= Alu_func_reg;
			op_type		= op_type_reg;
			next_InUse	= InUse;
    			if (LoadAFromCDB1)
    			begin
        			OPa	 = rs1_cdb1_in;
        			OPaValid = 1'b1;
    			end
    			if (LoadBFromCDB1)
    			begin
        			OPb 	 = rs1_cdb1_in;
        			OPbValid = 1'b1;
    			end
			if (LoadAFromCDB2)
    			begin
        			OPa 	 = rs1_cdb2_in;
        			OPaValid = 1'b1;
    			end
    			if (LoadBFromCDB2)
    			begin
        			OPb 	 = rs1_cdb2_in;
        			OPbValid = 1'b1;
    			end
    			// Clear InUse bit once the FU has data
		end
		if (rs1_free)
			next_InUse	= 1'b0;
	end

	always_ff @(posedge clock)
	begin
    		if (reset)
    		begin
           		OPa_reg	 		<= `SD 0;
           		OPb_reg	 		<= `SD 0;
          		OPaValid_reg 	<= `SD 0;
     	   		OPbValid_reg	<= `SD 0;
           		InUse 	 		<= `SD 1'b0;
           		fu_select_reg	<= `SD FU_DEFAULT;
          		DestTag  		<= `SD 0;
				Rob_idx	 		<= `SD 0;
				Alu_func_reg 	<= `SD ALU_DEFAULT;
    		end
		else
    		begin
				OPa_reg			<= `SD OPa;
				OPaValid_reg	<= `SD OPaValid;
				OPb_reg			<= `SD OPb;
				OPbValid_reg	<= `SD OPbValid;
				fu_select_reg	<= `SD fu_select;
       			InUse 	 		<= `SD next_InUse;
       			DestTag_reg		<= `SD DestTag;
       			Rob_idx_reg		<= `SD Rob_idx;
       			Alu_func_reg 	<= `SD Alu_func;
       			op_type_reg		<= `SD op_type;
    		end // else !reset
	end // always @
endmodule
