module testbench_rs;
	logic clock,reset;
	logic [$clog2(`PRN_SIZE)-1:0]  	rs_dest_in;
 	logic [63:0] 			rs_cdb1_in,     // CDB bus from functional units 
	logic [$clog2(`PRN_SIZE)-1:0]  	rs_cdb1_tag,    // CDB tag bus from functional units 
	logic  	      			rs_cdb1_valid,  // The data on the CDB is valid 
	logic [63:0] 			rs_cdb2_in,     // CDB bus from functional units 
	logic [$clog2(`PRN_SIZE)-1:0]  	rs_cdb2_tag,    // CDB tag bus from functional units 
	logic  	      			rs_cdb2_valid,  // The data on the CDB is valid 
	logic  [63:0] 			rs_opa_in,      // Operand a from Rename  
	logic  [63:0] 			rs_opb_in,      // Operand a from Rename 
	logic  	     			rs_opa_valid,   // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	logic         			rs_opb_valid,   // Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [5:0]      		rs_op_type_in,  // 
	logic  ALU_FUNC			rs_alu_func,
	logic  		        	rs_load_in,     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	logic  [$clog2(`ROB_SIZE)-1:0]  rs_rob_idx_in,  // 
	logic				mult_available,
	logic				adder_available,
	logic				memory_available,
//input signals
	logic [63:0] 		rs_opa_out,       	// This RS' opa 
	logic [63:0] 		rs_opb_out,       	// This RS' opb 
	logic [$clog2(`PRN_SIZE)-1:0] rs_dest_tag_out,  	// This RS' destination tag  
	logic [$clog2(`ROB_SIZE)-1:0] rs_rob_idx_out,   	// 
	logic [5:0]		rs_op_type_out,     	// 
	logic			rs_full			//

	always #5 clock = ~clock;
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask
	
	initial begin
		$monitor("rs_dest_in: %s, rs_opa_valid: %b, rs_opb_valid: %h, rs_op_type_: %h, read_idx: %h, hit: %b", );
