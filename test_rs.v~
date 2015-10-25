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
	logic [$clog2(`ROB_SIZE)-1:0] rs_rob_idx_out,   	
	logic [5:0]		rs_op_type_out,     	 
	logic			rs_full			
	//output signals

	always #5 clock = ~clock;
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask
	
	initial begin
		$monitor("rs_dest_in: %h, rs_opa_valid: %b, rs_opb_valid: %b, rs_op_type_in: %h, rs_opa_in: %h, rs_opb_in: %h", rs_dest_in, rs_opa_valid, rs_opb_valid, rs_op_type_in, rs_opa_in, rs_opb_in );
		rs_dest_in={1'b1,($clog2(`PRN_SIZE)-1)1'b0};
		rs_opa_in=64'h4000_0000_0000_0000;
		rs_opb_in=64'h0040_0000_0000_0000;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_cdb2_valid=0;
		rs_op_type_in=6'h13;
		rs_alu_func=5'h0b;
		rs_load_in=1;
		rs_rob_idx_in={1'b1,($clog2(`ROB_SIZE)-1)1'b0};
		mult_available=1;
		adder_available=1;
		memory_available=1;
		
		//***RESET**		
		reset = 1;
		@(negedge clock);
		reset = 0;
		assert(rs_opa_out==64'h4000_0000_0000_0000 && rs_opb_out==64'h0040_0000_0000_0000 && rs_dest_tag_out=={1'b1,($clog2(`PRN_SIZE)-1)1'b0} && rs_rob_idx_out=={1'b1,($clog2(`ROB_SIZE)-1)1'b0} && rs_op_type_out==6'h13 && !rs_full) else #1 exit_on_error;
		
		$display("@@@Passed");
		$finish;
	end
endmodule


		
