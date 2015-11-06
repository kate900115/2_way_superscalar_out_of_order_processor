module testbench_rs;
	//inputs
	logic         				reset;          // reset signal 
	logic         				clock;          // the clock 

	logic  [$clog2(`PRF_SIZE)-1:0]  	inst1_rs_dest_in;     // The destination of this instruction
	logic  [$clog2(`PRF_SIZE)-1:0]  	inst2_rs_dest_in;     // The destination of this instruction
 
	logic  [63:0]						rs_cdb1_in;     // CDB bus from functional units 
	logic  [$clog2(`PRF_SIZE)-1:0]  	rs_cdb1_tag;    // CDB tag bus from functional units 
	logic								rs_cdb1_valid;  // The data on the CDB is valid 
	logic  [63:0]						rs_cdb2_in;     // CDB bus from functional units 
	logic  [$clog2(`PRF_SIZE)-1:0]  	rs_cdb2_tag;    // CDB tag bus from functional units 
	logic								rs_cdb2_valid;  // The data on the CDB is valid 

                                                                 //*** for instruction1
	logic  [63:0] 				inst1_rs_opa_in;      // Operand a from Rename  
	logic  [63:0] 				inst1_rs_opb_in;      // Operand a from Rename 
	logic  	     				inst1_rs_opa_valid;   // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	logic         				inst1_rs_opb_valid;   // Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [5:0]      			inst1_rs_op_type_in;  // Instruction type from decoder
	ALU_FUNC				inst1_rs_alu_func;	// ALU function type from decoder
        
                                                                //*** for instruction2
	logic  [63:0] 				inst2_rs_opa_in;      // Operand a from Rename  
	logic  [63:0] 				inst2_rs_opb_in;      // Operand a from Rename 
	logic  	     				inst2_rs_opa_valid;   // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	logic         				inst2_rs_opb_valid;   // Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [5:0]      			inst2_rs_op_type_in;  // Instruction type from decoder
	ALU_FUNC				inst2_rs_alu_func;	// ALU function type from decoder

	logic  		        		inst1_rs_load_in;     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	logic 		        		inst2_rs_load_in;     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in

	logic  [$clog2(`ROB_SIZE)-1:0]       	inst1_rs_rob_idx_in;  // 
	logic  [$clog2(`ROB_SIZE)-1:0]       	inst2_rs_rob_idx_in;  //

	logic					fu1_mult_available;
	logic					fu1_adder_available;
	logic					fu1_memory_available;
	logic					fu2_mult_available;
	logic					fu2_adder_available;
	logic					fu2_memory_available;
  
 	//outputs
	logic [5:0][63:0]					fu_rs_opa_out;       	// This RS' opa 
	logic [5:0][63:0]					fu_rs_opb_out;       	// This RS' opb 
	logic [5:0][$clog2(`PRF_SIZE)-1:0]			fu_rs_dest_tag_out;  	// This RS' destination tag  
	logic [5:0][$clog2(`ROB_SIZE)-1:0]    			fu_rs_rob_idx_out;   	// This RS' corresponding ROB index
	logic [5:0][5:0]					fu_rs_op_type_out;     // This RS' operation type
	logic [5:0]						fu_rs_out_valid;		// RS output is valid
	ALU_FUNC [5:0]						fu_alu_func_out;

	rs DUT(.reset(reset),
	   .clock(clock),
	   .inst1_rs_dest_in(inst1_rs_dest_in),
	   .inst2_rs_dest_in(inst2_rs_dest_in),

	   .rs_cdb1_in(rs_cdb1_in),
	   .rs_cdb1_tag(rs_cdb1_tag),
	   .rs_cdb1_valid(rs_cdb1_valid),
	   .rs_cdb2_in(rs_cdb2_in),
	   .rs_cdb2_tag(rs_cdb2_tag),
	   .rs_cdb2_valid(rs_cdb2_valid),
   
	   .inst1_rs_opa_in(inst1_rs_opa_in),
	   .inst1_rs_opb_in(inst1_rs_opb_in),
	   .inst1_rs_opa_valid(inst1_rs_opa_valid),
	   .inst1_rs_opb_valid(inst1_rs_opb_valid),
	   .inst1_rs_op_type_in(inst1_rs_op_type_in),
	   .inst1_rs_alu_func(inst1_rs_alu_func),

	   .inst2_rs_opa_in(inst2_rs_opa_in),
	   .inst2_rs_opb_in(inst2_rs_opb_in),
	   .inst2_rs_opa_valid(inst2_rs_opa_valid),
	   .inst2_rs_opb_valid(inst2_rs_opb_valid),
	   .inst2_rs_op_type_in(inst2_rs_op_type_in),
	   .inst2_rs_alu_func(inst2_rs_alu_func),

 	   .inst1_rs_load_in(inst1_rs_load_in),
	   .inst2_rs_load_in(inst2_rs_load_in),
	   .inst1_rs_rob_idx_in(inst1_rs_rob_idx_in),
	   .inst2_rs_rob_idx_in(inst2_rs_rob_idx_in),

	   .fu1_mult_available(fu1_mult_available),
	   .fu1_adder_available(fu1_adder_available),
	   .fu1_memory_available(fu1_memory_available),
	   .fu2_mult_available(fu2_mult_available),
	   .fu2_adder_available(fu2_adder_available),
	   .fu2_memory_available(fu2_memory_available),
  

	   .fu_rs_opa_out(fu_rs_opa_out),
	   .fu_rs_opb_out(fu_rs_opb_out),
	   .fu_rs_dest_tag_out(fu_rs_dest_tag_out),
	   .fu_rs_rob_idx_out(fu_rs_rob_idx_out),
	   .fu_rs_op_type_out(fu_rs_op_type_out),
	   .fu_rs_out_valid(fu_rs_out_valid),
	   .fu_alu_func_out(fu_alu_func_out),

	   .rs_full(rs_full)
	);

	always #5 clock = ~clock;
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	initial begin
		$monitor("time:%.0f, clk:%b, fu1_rs_dest_tag_out:%d, fu1_rs_rob_idx_out:%d, fu1_rs_op_type_out:%d, fu1_alu_func_out:%d, fu1_rs_opa_out:%d, fu1_rs_opb_out:%d, fu1_rs_out_valid:%b,\n \
	        fu2_rs_dest_tag_out:%d, fu2_rs_rob_idx_out:%d, fu2_rs_op_type_out:%d, fu2_alu_func_out:%d, fu2_rs_opa_out:%d, fu2_rs_opb_out:%d, fu2_rs_out_valid:%b, \n \
	        fu3_rs_dest_tag_out:%d, fu3_rs_rob_idx_out:%d, fu3_rs_op_type_out:%d, fu3_alu_func_out:%d, fu3_rs_opa_out:%d, fu3_rs_opb_out:%d, fu3_rs_out_valid:%b, \n \
	        fu4_rs_dest_tag_out:%d, fu4_rs_rob_idx_out:%d, fu4_rs_op_type_out:%d, fu4_alu_func_out:%d, fu4_rs_opa_out:%d, fu4_rs_opb_out:%d, fu4_rs_out_valid:%b, \n \
	        fu5_rs_dest_tag_out:%d, fu5_rs_rob_idx_out:%d, fu5_rs_op_type_out:%d, fu5_alu_func_out:%d, fu5_rs_opa_out:%d, fu5_rs_opb_out:%d, fu5_rs_out_valid:%b, \n \
	        fu6_rs_dest_tag_out:%d, fu6_rs_rob_idx_out:%d, fu6_rs_op_type_out:%d, fu6_alu_func_out:%d, fu6_rs_opa_out:%d, fu6_rs_opb_out:%d, fu6_rs_out_valid:%b, rs_full: %b",
				$time, clock, fu_rs_dest_tag_out[0], fu_rs_rob_idx_out[0], fu_rs_op_type_out[0], fu_alu_func_out[0], fu_rs_opa_out[0], fu_rs_opb_out[0], fu_rs_out_valid[0], 
					      fu_rs_dest_tag_out[1], fu_rs_rob_idx_out[1], fu_rs_op_type_out[1], fu_alu_func_out[1], fu_rs_opa_out[1], fu_rs_opb_out[1], fu_rs_out_valid[1], 
					      fu_rs_dest_tag_out[2], fu_rs_rob_idx_out[2], fu_rs_op_type_out[2], fu_alu_func_out[2], fu_rs_opa_out[2], fu_rs_opb_out[2], fu_rs_out_valid[2],
					      fu_rs_dest_tag_out[3], fu_rs_rob_idx_out[3], fu_rs_op_type_out[3], fu_alu_func_out[3], fu_rs_opa_out[3], fu_rs_opb_out[3], fu_rs_out_valid[3],
					      fu_rs_dest_tag_out[4], fu_rs_rob_idx_out[4], fu_rs_op_type_out[4], fu_alu_func_out[4], fu_rs_opa_out[4], fu_rs_opb_out[4], fu_rs_out_valid[4],
					      fu_rs_dest_tag_out[5], fu_rs_rob_idx_out[5], fu_rs_op_type_out[5], fu_alu_func_out[5], fu_rs_opa_out[5], fu_rs_opb_out[5], fu_rs_out_valid[5],rs_full);
		clock = 0;
		//***RESET**
		reset = 1;
		#5;
		@(negedge clock);
		reset = 0;
		inst1_rs_dest_in	= 1;
		inst1_rs_opa_in		= 0;
		inst1_rs_opb_in		= 8;
		inst1_rs_opa_valid	= 1;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `LDA_INST;
		inst1_rs_alu_func	= ALU_ADDQ;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 1;
		fu1_mult_available	= 1;
		fu1_adder_available	= 1;
		fu1_memory_available	= 1;
		
		inst2_rs_dest_in	= 2;
		inst2_rs_opa_in		= 0;
		inst2_rs_opb_in		= 64'h27bb;
		inst2_rs_opa_valid	= 1;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 2;
		fu2_mult_available	= 1;
		fu2_adder_available	= 1;
		fu2_memory_available	= 1;
		#5

		@(negedge clock);
		inst1_rs_dest_in	= 3;
		inst1_rs_opa_in		= 2;
		inst1_rs_opb_in		= 16;
		inst1_rs_opa_valid	= 1;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `SLL_INST;
		inst1_rs_alu_func	= ALU_SLL;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu1_mult_available	= 1;
		fu1_adder_available	= 1;
		fu1_memory_available	= 1;
		
		inst2_rs_dest_in	= 4;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'h2ee6;
		inst2_rs_opa_valid	= 1;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		fu2_mult_available	= 1;
		fu2_adder_available	= 1;
		fu2_memory_available	= 1;
		#5

		@(negedge clock);
		inst1_rs_dest_in	= 5;
		inst1_rs_opa_in		= 4;
		inst1_rs_opb_in		= 3;
		inst1_rs_opa_valid	= 1;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu1_mult_available	= 1;
		fu1_adder_available	= 1;
		fu1_memory_available	= 1;
		
		inst2_rs_dest_in	= 6;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'h876;
		inst2_rs_opa_valid	= 1;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		fu2_mult_available	= 1;
		fu2_adder_available	= 1;
		fu2_memory_available	= 1;
		#5
		@(negedge clock);
		$display("@@@Passed");
		$finish;
	end
endmodule
