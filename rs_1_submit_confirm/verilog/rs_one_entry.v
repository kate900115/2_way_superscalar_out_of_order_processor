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

	input  [$clog2(`PRF_SIZE)-1:0]  	rs1_dest_in,    	// The destination of this instruction
 
	input  [63:0] 				rs1_cdb1_in,		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  	rs1_cdb1_tag,    	// CDB tag bus from functional units 
	input  	      				rs1_cdb1_valid,		// The data on the CDB is valid 
	input  [63:0] 				rs1_cdb2_in,		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  	rs1_cdb2_tag,    	// CDB tag bus from functional units 
	input  	      				rs1_cdb2_valid,		// The data on the CDB is valid 

	input  [63:0] 				rs1_opa_in,		// Operand a from Rename  
	input  [63:0] 				rs1_opb_in,		// Operand a from Rename 
	input  	     				rs1_opa_valid,		// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         				rs1_opb_valid,		// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [5:0]				rs1_op_type_in,		// Instruction type of rs1
	input  ALU_FUNC				rs1_alu_func,

	input  		        		rs1_load_in,		// Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	input   	        		rs1_use_enable,		// Signal to send data to Func units AND to free this RS

	input  [$clog2(`ROB_SIZE)-1:0]       	rs1_rob_idx_in,   	// 


	input					mult_available,
	input					adder_available,
	input					memory_available,
	input  FU_SELECT			fu_select,
  
 	//output
	output logic        			rs1_ready_out,    	// This RS is in use and ready to go to EX 
	output logic [63:0] 			rs1_opa_out,       	// This RS' opa 
	output logic [63:0] 			rs1_opb_out,       	// This RS' opb 
	output logic [$clog2(`PRF_SIZE)-1:0]	rs1_dest_tag_out,  	// This RS' destination tag   
	output logic        			rs1_available_out, 
	output logic [$clog2(`ROB_SIZE)-1:0]    rs1_rob_idx_out,   	// 
	output logic [5:0]		      	rs1_op_type_out,     	//
	output ALU_FUNC                         rs1_alu_func_out 
);  


	logic  [63:0] 				OPa;              	// Operand A 
	logic  [63:0] 				OPb;              	// Operand B 
	logic  					OPaValid;         	// Operand a Tag/Value 
	logic  					OPbValid;         	// Operand B Tag/Value 
	logic  					InUse;            	// InUse bit 
	logic  [$clog2(`PRF_SIZE)-1:0]  	DestTag;   		// Destination Tag bit 
	logic  [$clog2(`ROB_SIZE)-1:0] 		Rob_idx;   		//
	logic  [5:0]  				OP_type;  		//
 
	logic  					LoadAFromCDB1;  	// signal to load from the CDB1 
	logic  					LoadBFromCDB1;  	// signal to load from the CDB1
	logic  					LoadAFromCDB2;  	// signal to load from the CDB2 
	logic  					LoadBFromCDB2;  	// signal to load from the CDB2  

	logic					fu_ready;
	ALU_FUNC				Alu_func_reg;
	FU_SELECT				fu_select_reg;

	assign rs1_available_out= ~InUse;
 
	assign rs1_ready_out 	= InUse && OPaValid && OPbValid && fu_ready; 
 
	assign rs1_opa_out 	= rs1_use_enable ? OPa : 64'b0;
 
	assign rs1_opb_out 	= rs1_use_enable ? OPb : 64'b0; 
 
	assign rs1_dest_tag_out = rs1_use_enable ? DestTag : 0; 

	assign rs1_rob_idx_out	= rs1_use_enable ? Rob_idx : 0;

	assign rs1_op_type_out	= rs1_use_enable ? OP_type : 6'b0;

	assign rs1_alu_func_out = rs1_use_enable ? Alu_func_reg : ALU_DEFAULT;

	assign LoadAFromCDB1 	= (rs1_cdb1_tag == OPa[$clog2(`PRF_SIZE)-1:0]) && !OPaValid && InUse && rs1_cdb1_valid; 

	assign LoadBFromCDB1 	= (rs1_cdb1_tag == OPb[$clog2(`PRF_SIZE)-1:0]) && !OPbValid && InUse && rs1_cdb1_valid; 

	assign LoadAFromCDB2 	= (rs1_cdb2_tag == OPa[$clog2(`PRF_SIZE)-1:0]) && !OPaValid && InUse && rs1_cdb2_valid; 

	assign LoadBFromCDB2 	= (rs1_cdb2_tag == OPb[$clog2(`PRF_SIZE)-1:0]) && !OPbValid && InUse && rs1_cdb2_valid; 

	always_ff @(posedge clock) 
	begin
		/*case (fu_select)
		USE_MULTIPLIER:
			if (mult_available)
				fu_ready <= `SD 1;
			else
				fu_ready <= `SD 0;
		USE_ADDER:
			if (adder_available)
				fu_ready <= `SD 1;
			else
				fu_ready <= `SD 0;
		USE_MEMORY:
			if (memory_available)
				fu_ready <= `SD 1;
			else
				fu_ready <= `SD 0;
		default:
				fu_ready <= `SD 0;
		endcase*/
    		if (reset) 
    		begin 
            		OPa 	 	<= `SD 0;
            		OPb 	 	<= `SD 0;
            		OPaValid 	<= `SD 0;
            		OPbValid 	<= `SD 0;
			OP_type  	<= `SD 5'b0;
            		InUse 	 	<= `SD 1'b0; 
           		DestTag  	<= `SD 0;
			Rob_idx	 	<= `SD 0;
			Alu_func_reg 	<= `SD ALU_DEFAULT;
			fu_select_reg	<= `SD FU_DEFAULT;
    		end
    		else
    		begin
        		if (rs1_load_in) 
        		begin
           			OPa 	 	<= `SD rs1_opa_in;
            			OPb 	 	<= `SD rs1_opb_in;
            			OPaValid 	<= `SD rs1_opa_valid;
            			OPbValid 	<= `SD rs1_opb_valid;
				OP_type  	<= `SD rs1_op_type_in;
            			InUse 	 	<= `SD 1'b1;
            			DestTag  	<= `SD rs1_dest_in;
				Rob_idx	 	<= `SD rs1_rob_idx_in;
				Alu_func_reg 	<= `SD rs1_alu_func;
				fu_select_reg	<= `SD fu_select;

				case (fu_select)
				USE_MULTIPLIER:
					if (mult_available)
						fu_ready <= `SD 1;
					else
						fu_ready <= `SD 0;
				USE_ADDER:
					if (adder_available)
						fu_ready <= `SD 1;
					else
						fu_ready <= `SD 0;
				USE_MEMORY:
					if (memory_available)
						fu_ready <= `SD 1;
					else
						fu_ready <= `SD 0;
				default:
						fu_ready <= `SD 0;
				endcase
        		end 
        		else 
        		begin
            			if (LoadAFromCDB1)
            			begin
                			OPa 	 <= `SD rs1_cdb1_in;
                			OPaValid <= `SD 1'b1;
            			end
            			if (LoadBFromCDB1)
            			begin
                			OPb 	 <= `SD rs1_cdb1_in;
                			OPbValid <= `SD 1'b1;
            			end
				if (LoadAFromCDB2)
            			begin
                			OPa 	 <= `SD rs1_cdb2_in;
                			OPaValid <= `SD 1'b1;
            			end
            			if (LoadBFromCDB2)
            			begin
                			OPb 	 <= `SD rs1_cdb2_in;
                			OPbValid <= `SD 1'b1;
            			end
				if(fu_select_reg==fu_select)
					case (fu_select)
					USE_MULTIPLIER:
						if (mult_available)
							fu_ready <= `SD 1;
						else
							fu_ready <= `SD 0;
					USE_ADDER:
						if (adder_available)
							fu_ready <= `SD 1;
						else
							fu_ready <= `SD 0;
					USE_MEMORY:
						if (memory_available)
							fu_ready <= `SD 1;
						else
							fu_ready <= `SD 0;
					default:
							fu_ready <= `SD 0;
					endcase
            			// Clear InUse bit once the FU has data
            			if (rs1_use_enable)
            			begin
                			InUse 	 <= `SD 0;
            			end
        		end // else rs1_load_in 
    		end // else !reset 
	end // always @ 
endmodule  
