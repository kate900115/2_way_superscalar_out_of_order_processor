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

	input         				reset,          // reset signal 
	input         				clock,          // the clock 

	input  [$clog2(`PRF_SIZE)-1:0]  	rs_dest_in,     // The destination of this instruction
 
	input  [63:0] 				rs_cdb1_in,     // CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  	rs_cdb1_tag,    // CDB tag bus from functional units 
	input  	      				rs_cdb1_valid,  // The data on the CDB is valid 
	input  [63:0] 				rs_cdb2_in,     // CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  	rs_cdb2_tag,    // CDB tag bus from functional units 
	input  	      				rs_cdb2_valid,  // The data on the CDB is valid 

	input  [63:0] 				rs_opa_in,      // Operand a from Rename  
	input  [63:0] 				rs_opb_in,      // Operand a from Rename 
	input  	     				rs_opa_valid,   // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         				rs_opb_valid,   // Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [5:0]      			rs_op_type_in,  // Instruction type from decoder
	ALU_FUNC				rs_alu_func,	// ALU function type from decoder

	input  		        		rs_load_in,     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in

	input  [$clog2(`ROB_SIZE)-1:0]       	rs_rob_idx_in,  // 


	input					mult_available,
	input					adder_available,
	input					memory_available,
  
 	//output
	output logic [63:0] 			rs_opa_out,       	// This RS' opa 
	output logic [63:0] 			rs_opb_out,       	// This RS' opb 
	output logic [$clog2(`PRF_SIZE)-1:0]	rs_dest_tag_out,  	// This RS' destination tag  
	output logic [$clog2(`ROB_SIZE)-1:0]    rs_rob_idx_out,   	// This RS' corresponding ROB index
	output logic [5:0]		      	rs_op_type_out,     	// This RS' operation type
	output logic				rs_full,		// RS is full now
	output logic				rs_out_valid		// RS output is valid

);



	
	//input of one entry
	logic [`RS_SIZE-1:0] 				internal_rs_load_in;
	logic [`RS_SIZE-1:0] 				internal_rs_use_enable;
	
	//output of one entry
	logic [`RS_SIZE-1:0]				internal_rs_ready_out;
	logic [`RS_SIZE-1:0]				internal_rs_available_out;	
	logic [`RS_SIZE-1:0][63:0]			internal_rs_opa_out;
	logic [`RS_SIZE-1:0][63:0]			internal_rs_opb_out;
	logic [`RS_SIZE-1:0][5:0]			internal_rs_op_type_out;
	logic [`RS_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]	internal_rs_dest_tag_out;
	logic [`RS_SIZE-1:0][$clog2(`ROB_SIZE)-1:0] 	internal_rs_rob_idx_out;

	//internal registers
	FU_SELECT					fu_select;



	rs_one_entry rs1[`RS_SIZE-1:0](
	//input	
	.reset(reset),						
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
 	
	.rs1_op_type_in(rs_op_type_in),
	.rs1_alu_func(rs_alu_func),
	.rs1_load_in(internal_rs_load_in),   			//internal signal	
	.rs1_use_enable(internal_rs_use_enable),		//internal signal	
	.rs1_rob_idx_in(rs_rob_idx_in),   	

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


	//the instruction to be dispatched use this priority selector to choose an available rs_one_entry
	priority_selector #(.SIZE(`RS_SIZE)) rs_psl1( 
		.req(internal_rs_available_out),
	        .en(rs_load_in),
        	.gnt(internal_rs_load_in)
	);

	//this priority selector chooses which rs_one_entry to send its data to FU
	//Yuxuan: I think en will always be 1'b1 because this is comb logic. You can change the input of en.	
	priority_selector #(.SIZE(`RS_SIZE)) rs_psl2( 
		.req(internal_rs_ready_out),
        	.en(1'b1),		
        	.gnt(internal_rs_use_enable)
	);

	assign rs_full = (internal_rs_available_out == 0)? 1'b1 : 1'b0;

	always_comb begin
		if 	({rs_op_type_in[5:3],3'b0} == 6'h10 && rs_alu_func == ALU_MULQ)
			fu_select = USE_MULTIPLIER;
		else if (	({rs_op_type_in[5:3],3'b0} == 6'h08) || 
				({rs_op_type_in[5:3],3'b0} == 6'h20) || 
				({rs_op_type_in[5:3],3'b0} == 6'h28))
			fu_select = USE_MEMORY; 
		else 
			fu_select = USE_ADDER;
	end
	
	always_comb begin
		rs_out_valid    = 0;
		rs_opa_out      = 0;
		rs_opb_out      = 0;
		rs_dest_tag_out = 0; 
		rs_rob_idx_out  = 0;	 
		rs_op_type_out  = 0;
		for(int i=0;i<`RS_SIZE;i++)
		begin
			if(internal_rs_use_enable[i]==1'b1)
			begin
				rs_out_valid    = 1'b1;
				rs_opa_out      = internal_rs_opa_out[i];
			 	rs_opb_out      = internal_rs_opb_out[i];
				rs_dest_tag_out = internal_rs_dest_tag_out[i];
				rs_rob_idx_out  = internal_rs_rob_idx_out[i];
				rs_op_type_out  = internal_rs_op_type_out[i];
				break;
			end
		end
	end
endmodule
