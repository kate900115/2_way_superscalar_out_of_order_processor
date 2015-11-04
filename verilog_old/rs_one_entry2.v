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
 
	input  [63:0] 				rs1_cdb1_in,		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  	rs1_cdb1_tag,    	// CDB tag bus from functional units 
	input  	      				rs1_cdb1_valid,		// The data on the CDB is valid 
	input  [63:0] 				rs1_cdb2_in,		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  	rs1_cdb2_tag,    	// CDB tag bus from functional units 
	input  	      				rs1_cdb2_valid,		// The data on the CDB is valid 

	input  [63:0] 				inst1_rs1_opa_in,		// Operand a from Rename  
	input  [63:0] 				inst1_rs1_opb_in,		// Operand a from Rename 
	input  	     				inst1_rs1_opa_valid,		// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         				inst1_rs1_opb_valid,		// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [5:0]				inst1_rs1_op_type_in,		// Instruction type of rs1
	input  ALU_FUNC				inst1_rs1_alu_func,
	input  FU_SELECT			inst1_fu_select,

	input  [63:0] 				inst2_rs1_opa_in,		// Operand a from Rename  
	input  [63:0] 				inst2_rs1_opb_in,		// Operand a from Rename 
	input  	     				inst2_rs1_opa_valid,		// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         				inst2_rs1_opb_valid,		// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [5:0]				inst2_rs1_op_type_in,		// Instruction type of rs1
	input  ALU_FUNC				inst2_rs1_alu_func,
	input  FU_SELECT			inst2_fu_select,

	input  		        		inst1_rs1_load_in,		// *****rs1 need two loads for each      Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	input  		        		inst2_rs1_load_in,

	input   	        		fu1_rs1_free,		// Signal to send data to Func units AND to free this RS
	input   	        		fu2_rs1_free,		// Signal to send data to Func units AND to free this RS

	input  [$clog2(`ROB_SIZE)-1:0]       	inst1_rs1_rob_idx_in,   	// 
	input  [$clog2(`ROB_SIZE)-1:0]       	inst2_rs1_rob_idx_in,   	// 


	input					fu1_mult_available,
	input					fu1_adder_available,
	input					fu1_memory_available,

	input					fu2_mult_available,
	input					fu2_adder_available,
	input					fu2_memory_available,

 	//output
	output logic							rs1_ready_out,    	// This RS is in use and ready to go to EX 
	output logic [63:0]						rs1_opa_out,       	// This RS' opa 
	output logic [63:0]						rs1_opb_out,       	// This RS' opb 
	output logic [$clog2(`PRF_SIZE)-1:0]				rs1_dest_tag_out,  	// This RS' destination tag   
	output logic							rs1_available_out, 	// This RS' is available
	output logic [$clog2(`ROB_SIZE)-1:0]    			rs1_rob_idx_out,   	// 
	output logic [5:0]					  	rs1_op_type_out,     	// 
	output FU_SELECT						fu_select_reg_out,
	output ALU_FUNC                         			rs1_alu_func_out 
);  


	logic  [63:0] 				OPa;              	// Operand A 
	logic  [63:0] 				OPb;              	// Operand B 
	logic  					OPaValid;         	// Operand a Tag/Value 
	logic  					OPbValid;         	// Operand B Tag/Value
	logic  [63:0] 				OPa_reg;              	// Operand A 
	logic  [63:0] 				OPb_reg;              	// Operand B 
	logic  					OPaValid_reg;         	// Operand a Tag/Value 
	logic  					OPbValid_reg;         	// Operand B Tag/Value 
	logic  					InUse;            	// InUse bit 
	logic  [$clog2(`PRF_SIZE)-1:0]  	DestTag;   		// Destination Tag bit 
	logic  [$clog2(`ROB_SIZE)-1:0] 		Rob_idx;   		//
	logic  [5:0]  				OP_type;  		//
 
	logic  					LoadAFromCDB1;  	// signal to load from the CDB1 
	logic  					LoadBFromCDB1;  	// signal to load from the CDB1
	logic  					LoadAFromCDB2;  	// signal to load from the CDB2 
	logic  					LoadBFromCDB2;  	// signal to load from the CDB2  

	logic					fu_ready;
	logic					fu_ready_reg;
	ALU_FUNC				Alu_func_reg;
	FU_SELECT				fu_select_reg;

	logic rs1_free;

	assign rs1_free   	= fu1_rs1_free || fu2_rs1_free;    //if we want to output this entry to fu1 or fu2

	assign rs1_available_out= ~InUse; //|| rs1_free;
 
	assign rs1_ready_out 	= InUse && OPaValid_reg && OPbValid_reg && fu_ready_reg; 
 
	assign rs1_opa_out 	= rs1_free ? OPa_reg : 64'b0;

	assign fu_select_reg_out= rs1_free ? fu_select_reg : FU_DEFAULT; 
 
	assign rs1_opb_out 	= rs1_free ? OPb_reg : 64'b0; 
 
	assign rs1_dest_tag_out = rs1_free ? DestTag : 0; 

	assign rs1_rob_idx_out	= rs1_free ? Rob_idx : 0;

	assign rs1_op_type_out	= rs1_free ? OP_type : 6'b0;
	
	assign rs1_alu_func_out = rs1_free ? Alu_func_reg : ALU_DEFAULT;

	assign LoadAFromCDB1 	= (rs1_cdb1_tag == OPa_reg[$clog2(`PRF_SIZE)-1:0]) && !OPaValid_reg && InUse && rs1_cdb1_valid; 

	assign LoadBFromCDB1 	= (rs1_cdb1_tag == OPb_reg[$clog2(`PRF_SIZE)-1:0]) && !OPbValid_reg && InUse && rs1_cdb1_valid; 

	assign LoadAFromCDB2 	= (rs1_cdb2_tag == OPa_reg[$clog2(`PRF_SIZE)-1:0]) && !OPaValid_reg && InUse && rs1_cdb2_valid; 

	assign LoadBFromCDB2 	= (rs1_cdb2_tag == OPb_reg[$clog2(`PRF_SIZE)-1:0]) && !OPbValid_reg && InUse && rs1_cdb2_valid;

	always_comb begin
		if (inst1_rs1_load_in) begin
			case (inst1_fu_select)
			USE_MULTIPLIER:
				if (fu1_mult_available || fu2_mult_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			USE_ADDER:
				if (fu1_adder_available || fu2_adder_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			USE_MEMORY:
				if (fu1_memory_available || fu1_memory_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			default:
					fu_ready = 0;
			endcase
			OPa	 = inst1_rs1_opa_in;
       			OPaValid = inst1_rs1_opa_valid;
       			OPb 	 = inst1_rs1_opb_in;
       			OPbValid = inst1_rs1_opb_valid;
		end
		else if (inst2_rs1_load_in) begin
			case (inst2_fu_select)
			USE_MULTIPLIER:
				if (fu1_mult_available || fu2_mult_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			USE_ADDER:
				if (fu1_adder_available || fu2_adder_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			USE_MEMORY:
				if (fu1_memory_available || fu1_memory_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			default:
					fu_ready = 0;
			endcase
			OPa	 = inst2_rs1_opa_in;
       			OPaValid = inst2_rs1_opa_valid;
       			OPb 	 = inst2_rs1_opb_in;
       			OPbValid = inst2_rs1_opb_valid;
		end
		else begin
			OPa	 = OPa_reg;
       			OPaValid = OPaValid_reg;
       			OPb 	 = OPb_reg;
       			OPbValid = OPbValid_reg;
			case (fu_select_reg)
			USE_MULTIPLIER:
				if (fu1_mult_available || fu2_mult_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			USE_ADDER:
				if (fu1_adder_available || fu2_adder_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			USE_MEMORY:
				if (fu1_memory_available || fu1_memory_available)
					fu_ready = 1;
				else
					fu_ready = 0;
			default:
					fu_ready = 0;
			endcase

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
	end

	always_ff @(posedge clock)
	begin
    		if (reset)
    		begin
            		OPa_reg	 	<= `SD 0;
            		OPb_reg	 	<= `SD 0;
            		OPaValid_reg 	<= `SD 0;
            		OPbValid_reg	<= `SD 0;
			OP_type  	<= `SD 5'b0;
            		InUse 	 	<= `SD 1'b0; 
           		DestTag  	<= `SD 0;
			Rob_idx	 	<= `SD 0;
			fu_ready_reg	<= `SD 0;
			Alu_func_reg 	<= `SD ALU_DEFAULT;
    		end
		else if (rs1_free)
			InUse 	 	<= `SD 0;
    		else
    		begin
			fu_ready_reg	<= `SD fu_ready;
			OPa_reg		<= `SD OPa;
			OPaValid_reg	<= `SD OPaValid;
			OPb_reg		<= `SD OPb;
			OPbValid_reg	<= `SD OPbValid;
			if (inst1_rs1_load_in)
        		begin
				OP_type  	<= `SD inst1_rs1_op_type_in;
            			InUse 	 	<= `SD 1'b1;
            			DestTag  	<= `SD inst1_rs1_dest_in;
				Rob_idx	 	<= `SD inst1_rs1_rob_idx_in;
				Alu_func_reg 	<= `SD inst1_rs1_alu_func;
        		end
			else if(inst2_rs1_load_in)
			begin
				OP_type  	<= `SD inst2_rs1_op_type_in;
            			InUse 	 	<= `SD 1'b1;
            			DestTag  	<= `SD inst2_rs1_dest_in;
				Rob_idx	 	<= `SD inst2_rs1_rob_idx_in;
				Alu_func_reg 	<= `SD inst2_rs1_alu_func;
			end
    		end // else !reset
	end // always @
endmodule