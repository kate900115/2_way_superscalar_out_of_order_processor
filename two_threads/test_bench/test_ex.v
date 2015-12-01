module test_ex;

	//input
	logic clock;			// system clock
	logic reset;			// system reset

	logic [3:0][63:0]			fu_rs_opa_in;		// register A value from reg file
	logic [3:0][63:0]			fu_rs_opb_in;		// register B value from reg file
	logic [3:0][$clog2(`PRF_SIZE)-1:0]	fu_rs_dest_tag_in;
	logic [3:0][$clog2(`ROB_SIZE)-1:0]	fu_rs_rob_idx_in;
	logic [3:0][5:0]  			fu_rs_op_type_in;	// incoming instruction
	logic [3:0]				fu_rs_valid_in;
	ALU_FUNC [5:0]     			fu_alu_func_in;	// ALU function select from decoder

	logic 	adder1_send_in_success;
	logic 	adder2_send_in_success;
	logic 	mult1_send_in_success;
	logic 	mult2_send_in_success;

	// output
	logic [3:0][$clog2(`PRF_SIZE)-1:0]	fu_rs_dest_tag_out;
	logic [3:0][$clog2(`ROB_SIZE)-1:0]	fu_rs_rob_idx_out;
	logic [3:0][5:0]  			fu_rs_op_type_out;	// incoming instruction
	ALU_FUNC [3:0]				fu_alu_func_out;	// ALU function select from decoder
	logic [3:0][63:0]			fu_result_out;
	logic [3:0]				fu_result_is_valid;	// 0,2: mult1,2; 1,3: adder1,2
	logic [3:0]				fu_is_available;

	ex_stage DUT(
	    clock,			// system clock
	    reset,			// system reset

	    fu_rs_opa_in,		// register A value from reg file
	    fu_rs_opb_in,		// register B value from reg file
	    fu_rs_dest_tag_in,
	    fu_rs_rob_idx_in,
	    fu_rs_op_type_in,	// incoming instruction
	    fu_rs_valid_in,
	    fu_alu_func_in,	// ALU function select from decoder

	    //logic           id_ex_cond_branch,   // is this a cond br? from decoder
	    //logic           id_ex_uncond_branch, // is this an uncond br? from decoder

	    adder1_send_in_success,
	    adder2_send_in_success,
	    mult1_send_in_success,
	    mult2_send_in_success,

	    fu_rs_dest_tag_out,
	    fu_rs_rob_idx_out,
	    fu_rs_op_type_out,	// incoming instruction
	    fu_alu_func_out,	// ALU function select from decoder
	    fu_result_out,
	    fu_result_is_valid,	// 0,2: mult1,2; 1,3: adder1,2
	    fu_is_available
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
		$monitor("@@@time:%.0f, clk:%b adder1_send_in_success:%b, adder2_send_in_success:%b, mult1_send_in_success:%b, mult2_send_in_success:%b\n \
		fu_rs_opa_in:%h, fu_rs_opb_in:%h, fu_rs_dest_tag_in:%h, fu_rs_rob_idx_in:%h, fu_rs_op_type_in:%h, fu_rs_valid_in:%h, fu_alu_func_in:%b,\n \
	        fu_rs_dest_tag_out:%h, fu_rs_rob_idx_out:%h, fu_rs_op_type_out:%h, fu_alu_func_out:%h, fu_result_out:%h, fu_result_is_valid:%h, fu_is_available:%b\n\
		fu_rs_opa_in:%h, fu_rs_opb_in:%h, fu_rs_dest_tag_in:%h, fu_rs_rob_idx_in:%h, fu_rs_op_type_in:%h, fu_rs_valid_in:%h, fu_alu_func_in:%b,\n \
	        fu_rs_dest_tag_out:%h, fu_rs_rob_idx_out:%h, fu_rs_op_type_out:%h, fu_alu_func_out:%h, fu_result_out:%h, fu_result_is_valid:%h, fu_is_available:%b\n\
		fu_rs_opa_in:%h, fu_rs_opb_in:%h, fu_rs_dest_tag_in:%h, fu_rs_rob_idx_in:%h, fu_rs_op_type_in:%h, fu_rs_valid_in:%h, fu_alu_func_in:%b,\n \
	        fu_rs_dest_tag_out:%h, fu_rs_rob_idx_out:%h, fu_rs_op_type_out:%h, fu_alu_func_out:%h, fu_result_out:%h, fu_result_is_valid:%h, fu_is_available:%b\n\
		fu_rs_opa_in:%h, fu_rs_opb_in:%h, fu_rs_dest_tag_in:%h, fu_rs_rob_idx_in:%h, fu_rs_op_type_in:%h, fu_rs_valid_in:%h, fu_alu_func_in:%b,\n \
	        fu_rs_dest_tag_out:%h, fu_rs_rob_idx_out:%h, fu_rs_op_type_out:%h, fu_alu_func_out:%h, fu_result_out:%h, fu_result_is_valid:%h, fu_is_available:%b",
				$time, clock, adder1_send_in_success, adder2_send_in_success, mult1_send_in_success, mult2_send_in_success,
					fu_rs_opa_in[0], fu_rs_opb_in[0], fu_rs_dest_tag_in[0], fu_rs_rob_idx_in[0], fu_rs_op_type_in[0], fu_rs_valid_in[0], fu_alu_func_in[0],
					fu_rs_dest_tag_out[0], fu_rs_rob_idx_out[0], fu_rs_op_type_out[0], fu_alu_func_out[0], fu_result_out[0], fu_result_is_valid[0], fu_is_available[0],
					fu_rs_opa_in[1], fu_rs_opb_in[1], fu_rs_dest_tag_in[1], fu_rs_rob_idx_in[1], fu_rs_op_type_in[1], fu_rs_valid_in[1], fu_alu_func_in[1],
					fu_rs_dest_tag_out[1], fu_rs_rob_idx_out[1], fu_rs_op_type_out[1], fu_alu_func_out[1], fu_result_out[1], fu_result_is_valid[1], fu_is_available[1],
					fu_rs_opa_in[2], fu_rs_opb_in[2], fu_rs_dest_tag_in[2], fu_rs_rob_idx_in[2], fu_rs_op_type_in[2], fu_rs_valid_in[2], fu_alu_func_in[2],
					fu_rs_dest_tag_out[2], fu_rs_rob_idx_out[2], fu_rs_op_type_out[2], fu_alu_func_out[2], fu_result_out[2], fu_result_is_valid[2], fu_is_available[2],
					fu_rs_opa_in[3], fu_rs_opb_in[3], fu_rs_dest_tag_in[3], fu_rs_rob_idx_in[3], fu_rs_op_type_in[3], fu_rs_valid_in[3], fu_alu_func_in[3],
					fu_rs_dest_tag_out[3], fu_rs_rob_idx_out[3], fu_rs_op_type_out[3], fu_alu_func_out[3], fu_result_out[3], fu_result_is_valid[3], fu_is_available[3]);
		clock = 0;
		//***RESET**
		reset = 1;
		@(negedge clock);
		reset = 0;
		fu_rs_opa_in[0]		= 4;
		fu_rs_opb_in[0] 	= 5;
		fu_rs_dest_tag_in[0]	= 0;
		fu_rs_rob_idx_in[0]	= 0;
		fu_rs_op_type_in[0]	= `MULQ_INST;
		fu_rs_valid_in[0]	= 1;
		fu_alu_func_in[0]	= ALU_MULQ;

		fu_rs_opa_in[1]		= 2;
		fu_rs_opb_in[1] 	= 3;
		fu_rs_dest_tag_in[1]	= 1;
		fu_rs_rob_idx_in[1]	= 1;
		fu_rs_op_type_in[1]	= `ADDQ_INST;
		fu_rs_valid_in[1]	= 1;
		fu_alu_func_in[1]	= ALU_ADDQ;

		fu_rs_opa_in[2]		= 4;
		fu_rs_opb_in[2] 	= 5;
		fu_rs_dest_tag_in[2]	= 0;
		fu_rs_rob_idx_in[2]	= 0;
		fu_rs_op_type_in[2]	= `MULQ_INST;
		fu_rs_valid_in[2]	= 0;
		fu_alu_func_in[2]	= ALU_MULQ;

		fu_rs_opa_in[3]		= 4;
		fu_rs_opb_in[3] 	= 5;
		fu_rs_dest_tag_in[3]	= 0;
		fu_rs_rob_idx_in[3]	= 0;
		fu_rs_op_type_in[3]	= `MULQ_INST;
		fu_rs_valid_in[3]	= 0;
		fu_alu_func_in[3]	= ALU_MULQ;

		adder1_send_in_success	= 0;
		adder2_send_in_success	= 0;
		mult1_send_in_success	= 0;
		mult2_send_in_success	= 0;
		#5
		@(negedge clock);
		fu_rs_valid_in[0]	= 0;
		fu_rs_valid_in[1]	= 0;
		#5
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);
		adder1_send_in_success	= 1;
		@(negedge clock);
		mult1_send_in_success	= 1;
		@(negedge clock);
		@(negedge clock);
		$display("@@@Passed");
		$finish;
	end
endmodule
