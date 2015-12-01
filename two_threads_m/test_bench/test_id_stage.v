module test_id_stage;
//inputs
	logic         clock;                // system clock
	logic         reset;                // system reset
	logic  [31:0] if_id_IR1;             // incoming instruction1
	logic  [31:0] if_id_IR2;             // incoming instruction2
	logic         if_id_valid_inst1;
	logic         if_id_valid_inst2;
	logic  [63:0] if_id_NPC_inst1;           // incoming instruction1 PC+4
	logic  [63:0] if_id_NPC_inst2;           // incoming instruction2 PC+4
//outputs		
	logic [63:0] opa_mux_out1;               //instr1 opa and opb value or tag
	logic [63:0] opb_mux_out1;
	logic  opa_mux_tag1;               //signal to indicate whether it is value or tag,true means value,faulse means tag
	logic  opb_mux_tag1;
	logic  [4:0] id_dest_reg_idx_out1;  // destination (writeback) register index
													        // (ZERO_REG if no writeback)				 
	logic [63:0] opa_mux_out2;               //instr2 opa and opb value or tag
	logic [63:0] opb_mux_out2;
	logic  opa_mux_tag2;               //signal to indicate whether it is value or tag
	logic  opb_mux_tag2;
	logic  [4:0] id_dest_reg_idx_out2;  // destination (writeback) register index

	logic  [4:0] id_alu_func_out1;      // ALU function select (ALU_xxx *)
	logic  [4:0] id_alu_func_out2;      // ALU function select (ALU_xxx *)
	logic  [5:0] id_op_type_inst1;		// op type
	logic  [5:0] id_op_type_inst2;

	logic        id_rd_mem_out1;        // does inst read memory?
	logic        id_wr_mem_out1;        // does inst write memory?
	//logic        id_ldl_mem_out1;       // load-lock inst?
	//logic        id_stc_mem_out1;       // store-conditional inst?
	logic        id_cond_branch_out1;   // is inst a conditional branch?
	logic        id_uncond_branch_out1; // is inst an unconditional branch 
													        // or jump?
	logic        id_halt_out1;
	//logic        id_cpuid_out1;         // get CPUID inst?
	logic        id_illegal_out1;
	logic        id_valid_inst_out1;     // is inst a valid instruction to be 
									        // counted for CPI calculations?
	logic        id_rd_mem_out2;        // does inst read memory?
	logic        id_wr_mem_out2;        // does inst write memory?
	//logic        id_ldl_mem_out2;       // load-lock inst?
	//logic        id_stc_mem_out2;       // store-conditional inst?
	logic        id_cond_branch_out2;   // is inst a conditional branch?
	logic        id_uncond_branch_out2; // is inst an unconditional branch 
											        		// or jump?
	logic        id_halt_out2;
	//logic        id_cpuid_out2;         // get CPUID inst?
	logic        id_illegal_out2;
	logic        id_valid_inst_out2;     // is inst a valid instruction to be 

	id_stage DUT(//inputs
			.clock(clock),
			.reset(reset),
			.if_id_IR1(if_id_IR1),
			.if_id_IR2(if_id_IR2),
			.if_id_valid_inst1(if_id_valid_inst1),
			.if_id_valid_inst2(if_id_valid_inst2),
			.if_id_NPC_inst1(if_id_NPC_inst1),
			.if_id_NPC_inst2(if_id_NPC_inst2),
		    //outputs
			.opa_mux_out1(opa_mux_out1),
			.opb_mux_out1(opb_mux_out1),
			.opa_mux_tag1(opa_mux_tag1),
			.opb_mux_tag1(opb_mux_tag1),
			.id_dest_reg_idx_out1(id_dest_reg_idx_out1),
	
			.opa_mux_out2(opa_mux_out2),               //instr2 opa and opb value or tag
			.opb_mux_out2(opb_mux_out2),
			.opa_mux_tag2(opa_mux_tag2),               //signal to indicate whether it is value or tag
			.opb_mux_tag2(opb_mux_tag2),
			.id_dest_reg_idx_out2(id_dest_reg_idx_out2),  // destination (writeback) register index

			.id_alu_func_out1(id_alu_func_out1),      // ALU function select (ALU_xxx *)
			.id_alu_func_out2(id_alu_func_out2),      // ALU function select (ALU_xxx *)
			.id_op_type_inst1(id_op_type_inst1),		// op type
			.id_op_type_inst2(id_op_type_inst2),

			.id_rd_mem_out1(id_rd_mem_out1),        // does inst read memory?
			.id_wr_mem_out1(id_wr_mem_out1),        // does inst write memory?
			//.id_ldl_mem_out1(id_ldl_mem_out1),       // load-lock inst?
			//.id_stc_mem_out1(id_stc_mem_out1),       // store-conditional inst?
			.id_cond_branch_out1(id_cond_branch_out1),   // is inst a conditional branch?
			.id_uncond_branch_out1(id_uncond_branch_out1), // is inst an unconditional branch 
													        // or jump?
			.id_halt_out1(id_halt_out1),
			//.id_cpuid_out1(id_cpuid_out1),         // get CPUID inst?
			.id_illegal_out1(id_illegal_out1),
			.id_valid_inst_out1(id_valid_inst_out1),     // is inst a valid instruction to be 
									        // counted for CPI calculations?
			.id_rd_mem_out2(id_rd_mem_out2),        // does inst read memory?
			.id_wr_mem_out2(id_wr_mem_out2),        // does inst write memory?
			//.id_ldl_mem_out2(id_ldl_mem_out2),       // load-lock inst?
			//.id_stc_mem_out2(id_stc_mem_out2),       // store-conditional inst?
			.id_cond_branch_out2(id_cond_branch_out2),   // is inst a conditional branch?
			.id_uncond_branch_out2(id_uncond_branch_out2), // is inst an unconditional branch 
											        		// or jump?
			.id_halt_out2(id_halt_out2),
			//.id_cpuid_out2(id_cpuid_out2),         // get CPUID inst?
			.id_illegal_out2(id_illegal_out2),
			.id_valid_inst_out2(id_valid_inst_out2)     // is inst a valid instruction to be
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
		$monitor("@@@time:%.0f, clk:%b, opa_mux_out1:%h, opb_mux_out1:%h, opa_mux_tag1:%b, opb_mux_tag1:%b, id_dest_reg_idx_out1:%b, \
			     id_alu_func_out1:%b, id_op_type_inst1:%b, id_rd_mem_out1:%b, id_wr_mem_out1:%b, \
			     id_cond_branch_out1:%b, id_uncond_branch_out1:%b, id_halt_out1:%b, id_illegal_out1:%b, id_valid_inst_out1:%b, \
			     opa_mux_out2:%h, opb_mux_out2:%h, opa_mux_tag2:%b, opb_mux_tag2:%b, id_dest_reg_idx_out2:%b,  id_alu_func_out2:%b, \
			     id_op_type_inst2:%b, id_rd_mem_out2:%b, id_wr_mem_out2:%b, id_cond_branch_out2:%b, \
			     id_uncond_branch_out2:%b, id_halt_out2:%b, id_illegal_out2:%b, id_valid_inst_out2:%b", 
			   $time, clock, opa_mux_out1, opb_mux_out1, opa_mux_tag1, opb_mux_tag1, id_dest_reg_idx_out1,
			     id_alu_func_out1, id_op_type_inst1, id_rd_mem_out1, id_wr_mem_out1,
			     id_cond_branch_out1, id_uncond_branch_out1, id_halt_out1, id_illegal_out1, id_valid_inst_out1, 
			     opa_mux_out2, opb_mux_out2, opa_mux_tag2, opb_mux_tag2, id_dest_reg_idx_out2,  id_alu_func_out2,
			     id_op_type_inst2, id_rd_mem_out2, id_wr_mem_out2, id_cond_branch_out2, 
			     id_uncond_branch_out2, id_halt_out2, id_illegal_out2, id_valid_inst_out2 );
			
		clock = 0;
		//***RESET**
		reset = 1;
		@(negedge clock);
		reset = 0;
		@(negedge clock);
		
		if_id_IR1=32'h207f1000;             
		if_id_IR2=32'h205f0000;             
		if_id_valid_inst1=1;
		if_id_valid_inst2=1;
		if_id_NPC_inst1=4;           
		if_id_NPC_inst2=8;
		
		$display("@@@passed");
		$finish;
	end
endmodule

		














 

