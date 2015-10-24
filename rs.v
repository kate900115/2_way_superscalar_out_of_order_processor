//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  rs.v                                       		//
//                                                                      //
//   Description :        						//
//                   							//
//                 							// 
//                  							//
//                                    					// 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module rs(

	input         				reset,          // reset signal 
	input         				clock,          // the clock 

	input  [$clog2(PRN_SIZE):0]  		rs_dest_in,    // The destination of this instruction
 
	input  [63:0] 				rs_cdb1_in,     // CDB bus from functional units 
	input  [$clog2(PRN_SIZE):0]  		rs_cdb1_tag,    // CDB tag bus from functional units 
	input  	      				rs_cdb1_valid,  // The data on the CDB is valid 
	input  [63:0] 				rs_cdb2_in,     // CDB bus from functional units 
	input  [$clog2(PRN_SIZE):0]  		rs_cdb2_tag,    // CDB tag bus from functional units 
	input  	      				rs_cdb2_valid,  // The data on the CDB is valid 

	input  [63:0] 				rs_opa_in,     // Operand a from Rename  
	input  [63:0] 				rs_opb_in,     // Operand a from Rename 
	input  	     				rs_opa_valid,  // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         				rs_opb_valid,  // Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [5:0]      			rs_op_type_in,     	// 
	input  ALU_FUNC				rs1_alu_func,

	input  		        		rs_load_in,    // Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	input   	        		rs_use_enable, // Signal to send data to Func units AND to free this RS

	input  [$clog2(ROB_SIZE):0]       	rs_rob_idx_in,   	// 


	input					mult_available,
	input					adder_available,
	input					memory_available,
  
 	//output
	output logic        			rs_ready,     		// This RS is in use and ready to go to EX 
	output logic [63:0] 			rs_opa_out,       	// This RS' opa 
	output logic [63:0] 			rs_opb_out,       	// This RS' opb 
	output logic [$clog2(PRN_SIZE):0]	rs_dest_tag_out,  	// This RS' destination tag  
	output logic        			rs_available_out, 
	output logic [$clog2(ROB_SIZE):0]      	rs_rob_idx_out,   	// 
	output logic [5:0]		      	rs_op_type_out,     	// 
	output logic				rs_full			//

		  );
	
	//input of one entry
	logic [RS_SIZE-1:0] 			internal_rs_load_in;
	logic [RS_SIZE-1:0] 			internal_rs_use_enable;
	
	//output of one entry
	logic [RS_SIZE-1:0]			internal_rs_ready_out;
	logic [RS_SIZE-1:0]			internal_rs_available_out;	
	logic [RS_SIZE-1:0][63:0]		internal_rs_opa_out;
	logic [RS_SIZE-1:0][63:0]		internal_rs_opb_out;
	logic [RS_SIZE-1:0][5:0]		internal_rs_op_type_out;
	logic [RS_SIZE-1:0][$clog2(PRN_SIZE):0]	internal_rs_dest_tag_out;
	logic [RS_SIZE-1:0][$clog2(PRN_SIZE):0] internal_rs_rob_idx_out;

	//internal registers
	logic FU_SELECT				fu_select;



	rs_one_entry rs1[RS_SIZE-1:0](
	//input	
	.reset(reset),					//internal signal
	.clock(clock),     
     	
	.rs1_dest_in(rs_dest_in),    
		
 	.rs1_cdb1_in(rs_cdb1_in), 
	.rs1_cdb1_tag(rs_cdb1_tag),
	.rs1_cdb1_valid(rs_cdb1_valid),  	
	.rs1_cdb2_in(rs_cdb2_in),
	.rs1_cdb2_tag(rs_cdb2_tag),    	
	.rs1_cdb2_valid(rs_cdb2_valid),
 
	.rs1_opa_in(rs_opa_in),
	.rs1_opb_in(rs_opb_in),     		
	.rs1_opa_valid(rs_opa_valid),  		
	.rs1_opb_valid(rs_opb_valid), 
 		 
	.rs1_load_in(internal_rs_load_in),   			//internal signal	
	.rs1_use_enable(internal_rs_use_enable),		//internal signal	
	.rs1_rob_idx_in(rs_rob_idx_in),   	
	.rs1_op_type_in(rs_op_type_in),     

	.mult_available(mult_available),
	.adder_available(adder_available),
	.memory_available(memory_available),	
	.fu_select(fu_select),
  
 	//output
	.rs1_ready_out(internal_rs_ready_out),
	.rs1_opa_out(internal_rs_opa_out),       
	.rs1_opb_out(internal_rs_opb_out),
	.rs1_dest_tag_out(internal_rs_dest_tag_out),  	 
	.rs1_available_out(internal_rs_available_out), 
	.rs1_rob_idx_out(internal_rs_rob_idx_out),   	
	.rs1_op_type_out(internal_rs_op_type_out)

		  );  

	always_comb begin
		if 	(({OP_type[5:3],3'b0} == 6'h10) && (alu_func == `ALU_MULQ))
			fu_select = USE_MULTIPLIER;
		else if (({OP_type[5:3],3'b0} == 6'h08) || ({OP_type[5:3],3'b0} == 6'h20) || ({OP_type[5:3],3'b0} == 6'h28))
			fu_select = USE_MEMORY; 
		else 
			fu_select = USE_ADDER;
	end
	





);
