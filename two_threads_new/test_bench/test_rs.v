module testbench_rs;
	//inputs
	logic         				reset;          // reset signal 
	logic         				clock;          // the clock 

	logic  [$clog2(`ROB_SIZE):0]				inst1_rs_rob_idx_in;  	// The rob index of instruction 1
	FU_SELECT									inst1_rs_fu_select_in;

	logic  [$clog2(`ROB_SIZE):0]				inst2_rs_rob_idx_in;  	// The rob index of instruction 2
	FU_SELECT		        					inst2_rs_fu_select_in;

	logic  [5:0]								fu_is_available;		//0,3:mult1,2 1,4:ALU1,2 2,5:MEM1,2
	
	logic										thread1_branch_is_taken;// when a branch of thread1 is taken, we need to flush all the instructions of thread1 in RS
	logic										thread2_branch_is_taken;// when a branch of thread2 is taken, we need to flush all the instructions of thread2 in RS
	
	logic										inst1_is_halt;
	logic										inst2_is_halt;
  
 	
	logic  [$clog2(`PRF_SIZE)-1:0]  			inst1_rs_dest_in;     // The destination of this instruction
	logic  [$clog2(`PRF_SIZE)-1:0]  			inst2_rs_dest_in;     // The destination of this instruction
 
	logic  [63:0]								rs_cdb1_in;     		// CDB bus from functional units 
	logic  [$clog2(`PRF_SIZE)-1:0]  			rs_cdb1_tag;    		// CDB tag bus from functional units 
	logic										rs_cdb1_valid;  		// The data on the CDB is valid 
	logic  [63:0]								rs_cdb2_in;     		// CDB bus from functional units 
	logic  [$clog2(`PRF_SIZE)-1:0]  			rs_cdb2_tag;    		// CDB tag bus from functional units 
	logic										rs_cdb2_valid;  		// The data on the CDB is valid 
	// for instruction1
	logic  [63:0] 								inst1_rs_opa_in;      // Operand a from Rename  
	logic  [63:0] 								inst1_rs_opb_in;      // Operand a from Rename 
	logic  	     								inst1_rs_opa_valid;   // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	logic         								inst1_rs_opb_valid;   // Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [5:0]      							inst1_rs_op_type_in;  // Instruction type from decoder
	ALU_FUNC									inst1_rs_alu_func;	  // ALU function type from decoder
        
    // for instruction2
	logic  [63:0] 								inst2_rs_opa_in;      // Operand a from Rename  
	logic  [63:0] 								inst2_rs_opb_in;      // Operand a from Rename 
	logic  	     								inst2_rs_opa_valid;   // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	logic         								inst2_rs_opb_valid;   // Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [5:0]      							inst2_rs_op_type_in;  // Instruction type from decoder
	ALU_FUNC									inst2_rs_alu_func;	  // ALU function type from decoder

	logic  		        						inst1_rs_load_in;     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	logic 		        						inst2_rs_load_in;     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in

	logic  [$clog2(`ROB_SIZE)-1:0]      		inst1_rs_rob_idx_in;  // 
	logic  [$clog2(`ROB_SIZE)-1:0]      		inst2_rs_rob_idx_in;  //
	//output
	logic [5:0][63:0]							fu_rs_opa_out;       	// This RS' opa 
	logic [5:0][63:0]							fu_rs_opb_out;       	// This RS' opb 
	logic [5:0][$clog2(`PRF_SIZE)-1:0]			fu_rs_dest_tag_out;  	// This RS' destination tag  
	logic [5:0][$clog2(`ROB_SIZE)-1:0]  		fu_rs_rob_idx_out;   	// This RS' corresponding ROB index
	logic [5:0][5:0]							fu_rs_op_type_out;     // This RS' operation type
	logic [5:0]									fu_rs_out_valid;		// RS output is valid
	ALU_FUNC [5:0]								fu_alu_func_out;
	logic										rs_full;				// RS is full now
	
	// for debug
	logic [63:0]								inst1_rs_pc_in;
	logic [63:0]								inst2_rs_pc_in;
	logic [5:0][63:0]							fu_inst_pc_out;	

	rs DUT(.reset(reset),
	   .clock(clock),
	   .inst1_rs_dest_in(inst1_rs_dest_in),
	   .inst2_rs_dest_in(inst2_rs_dest_in),
	
		.inst1_rs_rob_idx_in(inst1_rs_rob_idx_in),
		.inst1_rs_fu_select_in(inst1_rs_fu_select_in),
		.inst2_rs_rob_idx_in(inst2_rs_rob_idx_in),
		.inst2_rs_fu_select_in(inst2_rs_fu_select_in),
		.fu_is_available(fu_is_available),
		.thread1_branch_is_taken(thread1_branch_is_taken),
		.thread2_branch_is_taken(thread2_branch_is_taken),
		.inst1_is_halt(inst1_is_halt),
		.inst2_is_halt(inst2_is_halt),
		
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

	   .fu_rs_opa_out(fu_rs_opa_out),
	   .fu_rs_opb_out(fu_rs_opb_out),
	   .fu_rs_dest_tag_out(fu_rs_dest_tag_out),
	   .fu_rs_rob_idx_out(fu_rs_rob_idx_out),
	   .fu_rs_op_type_out(fu_rs_op_type_out),
	   .fu_rs_out_valid(fu_rs_out_valid),
	   .fu_alu_func_out(fu_alu_func_out),

	   .rs_full(rs_full),
	   
	   //for debug
	   .inst1_rs_pc_in(inst1_rs_pc_in),
	   .inst2_rs_pc_in(inst2_rs_pc_in),
	   .fu_inst_pc_out(fu_inst_pc_out)
	   
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
		$monitor("time:%.0f, clk:%b, \n \
		fu1_rs_dest_tag_out:%d, fu1_rs_rob_idx_out:%d, fu1_rs_op_type_out:%d, fu1_alu_func_out:%d, fu1_rs_opa_out:%d, fu1_rs_opb_out:%d, fu1_rs_out_valid:%b, fu1_inst_pc_out:%h, \n \
	        fu2_rs_dest_tag_out:%d, fu2_rs_rob_idx_out:%d, fu2_rs_op_type_out:%d, fu2_alu_func_out:%d, fu2_rs_opa_out:%d, fu2_rs_opb_out:%d, fu2_rs_out_valid:%b, fu2_inst_pc_out:%h, \n \
	        fu3_rs_dest_tag_out:%d, fu3_rs_rob_idx_out:%d, fu3_rs_op_type_out:%d, fu3_alu_func_out:%d, fu3_rs_opa_out:%d, fu3_rs_opb_out:%d, fu3_rs_out_valid:%b, fu3_inst_pc_out:%h, \n \
	        fu4_rs_dest_tag_out:%d, fu4_rs_rob_idx_out:%d, fu4_rs_op_type_out:%d, fu4_alu_func_out:%d, fu4_rs_opa_out:%d, fu4_rs_opb_out:%d, fu4_rs_out_valid:%b, fu4_inst_pc_out:%h, \n \
	        fu5_rs_dest_tag_out:%d, fu5_rs_rob_idx_out:%d, fu5_rs_op_type_out:%d, fu5_alu_func_out:%d, fu5_rs_opa_out:%d, fu5_rs_opb_out:%d, fu5_rs_out_valid:%b, fu5_inst_pc_out:%h, \n \
	        fu6_rs_dest_tag_out:%d, fu6_rs_rob_idx_out:%d, fu6_rs_op_type_out:%d, fu6_alu_func_out:%d, fu6_rs_opa_out:%d, fu6_rs_opb_out:%d, fu6_rs_out_valid:%b, fu6_inst_pc_out:%h,rs_full: %b",
				$time, clock, fu_rs_dest_tag_out[0], fu_rs_rob_idx_out[0], fu_rs_op_type_out[0], fu_alu_func_out[0], fu_rs_opa_out[0], fu_rs_opb_out[0], fu_rs_out_valid[0], fu_inst_pc_out[0],
					      fu_rs_dest_tag_out[1], fu_rs_rob_idx_out[1], fu_rs_op_type_out[1], fu_alu_func_out[1], fu_rs_opa_out[1], fu_rs_opb_out[1], fu_rs_out_valid[1], fu_inst_pc_out[1],
					      fu_rs_dest_tag_out[2], fu_rs_rob_idx_out[2], fu_rs_op_type_out[2], fu_alu_func_out[2], fu_rs_opa_out[2], fu_rs_opb_out[2], fu_rs_out_valid[2], fu_inst_pc_out[2],
					      fu_rs_dest_tag_out[3], fu_rs_rob_idx_out[3], fu_rs_op_type_out[3], fu_alu_func_out[3], fu_rs_opa_out[3], fu_rs_opb_out[3], fu_rs_out_valid[3], fu_inst_pc_out[3],
					      fu_rs_dest_tag_out[4], fu_rs_rob_idx_out[4], fu_rs_op_type_out[4], fu_alu_func_out[4], fu_rs_opa_out[4], fu_rs_opb_out[4], fu_rs_out_valid[4], fu_inst_pc_out[4],
					      fu_rs_dest_tag_out[5], fu_rs_rob_idx_out[5], fu_rs_op_type_out[5], fu_alu_func_out[5], fu_rs_opa_out[5], fu_rs_opb_out[5], fu_rs_out_valid[5], fu_inst_pc_out[5], rs_full);
		clock = 0;
		$display("@@@ reset");
		//***RESET**
		reset = 1;
		#5;
		@(negedge clock);
		$display("@@@ 1 @@ LDA in, use ALU");
		$display("@@@ 1 @@ Dest reg=#1");
		$display("@@@ 1 @@ opa_in=0, opb=1");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#2");
		$display("@@@ 2 @@ opa_in=0, opb=64'h2734");
		$display("@@@ 2 @@ fu_available = 111111");
		reset = 0;
		thread1_branch_is_taken = 0;
		thread2_branch_is_taken = 0;
		inst1_is_halt    =0;
		inst2_is_halt    =0;
		inst1_rs_dest_in	= 1;
		inst1_rs_opa_in		= 0;
		inst1_rs_opb_in		= 8;
		inst1_rs_opa_valid	= 1;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `LDA_INST;
		inst1_rs_alu_func	= ALU_ADDQ;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 1;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 2;
		inst2_rs_opa_in		= 0;
		inst2_rs_opb_in		= 64'd2734;
		inst2_rs_opa_valid	= 1;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 2;
		
		rs_cdb1_in			= 0; 
		rs_cdb1_tag			= 0;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		
		inst1_rs_pc_in      = 64'h0101_0010_1234_5678;
		inst2_rs_pc_in		= 64'h0100_1235_1346_0534;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ SLL_INST in, use ALU");
		$display("@@@ 1 @@ Dest reg=#3");
		$display("@@@ 1 @@ opa_in=2, opb=16");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#4");
		$display("@@@ 2 @@ opa_in=1, opb=64'd2116");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 3;
		inst1_rs_opa_in		= 2;
		inst1_rs_opb_in		= 16;
		inst1_rs_opa_valid	= 1;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `SLL_INST;
		inst1_rs_alu_func	= ALU_SLL;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 4;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd2116;
		inst2_rs_opa_valid	= 1;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 0; 
		rs_cdb1_tag			= 0;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		inst1_rs_pc_in      = 64'h9123_8791_0000_1111;
		inst2_rs_pc_in		= 64'h8745_6431_0000_1112;
		#5

		@(negedge clock);
		$display("@@@ 1 @@ SLL_INST in, ###BUT LOAD IN =0 ####, use ALU");
		$display("@@@ 1 @@ Dest reg=#5");
		$display("@@@ 1 @@ opa_in=4, opb=3");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ BIS in, use ALU");
		$display("@@@ 2 @@ Dest reg=#6");
		$display("@@@ 2 @@ opa_in=1, opb=64'h876");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 5;
		inst1_rs_opa_in		= 4;
		inst1_rs_opb_in		= 3;
		inst1_rs_opa_valid	= 1;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 0;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 6;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd876;
		inst2_rs_opa_valid	= 1;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 0;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 0; 
		rs_cdb1_tag			= 0;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		inst1_rs_pc_in      = 0;
		inst2_rs_pc_in      = 0;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ SLL_INST in, ###I1 opa valid = 0 ####, use ALU");
		$display("@@@ 1 @@ Dest reg=#7");
		$display("@@@ 1 @@ opa_in=4, opb=3");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ BIS in, use ALU");
		$display("@@@ 2 @@ Dest reg=#8");
		$display("@@@ 2 @@ opa_in=1, opb=64'd876");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 7;
		inst1_rs_opa_in		= 4;
		inst1_rs_opb_in		= 3;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 8;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd876;
		inst2_rs_opa_valid	= 1;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 0; 
		rs_cdb1_tag			= 0;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ BIS in, use ALU###I1 I2opa valid = 0 ####");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd1324");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		inst1_rs_dest_in	= 9;
		inst1_rs_opa_in		= 7;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 10;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd1324;
		inst2_rs_opa_valid	= 0;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1776; 
		rs_cdb1_tag			= 4;		
		rs_cdb1_valid		= 1;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ BIS in, use ALU");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 000000");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd777");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		$display("@@@ 2 @@ fu_available = 000000");
		inst1_rs_dest_in	= 11;
		inst1_rs_opa_in		= 7;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 12;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd777;
		inst2_rs_opa_valid	= 0;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1776; 
		rs_cdb1_tag			= 4;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ BIS in, use ALU");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd777");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 11;
		inst1_rs_opa_in		= 7;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 12;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd777;
		inst2_rs_opa_valid	= 0;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1776; 
		rs_cdb1_tag			= 4;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ BIS in, use ALU");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd777");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 11;
		inst1_rs_opa_in		= 7;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 12;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd777;
		inst2_rs_opa_valid	= 0;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1776; 
		rs_cdb1_tag			= 4;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ BIS in, use ALU");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd777");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 11;
		inst1_rs_opa_in		= 7;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 12;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd777;
		inst2_rs_opa_valid	= 0;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1776; 
		rs_cdb1_tag			= 4;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ BIS in, use ALU");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd777");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 11;
		inst1_rs_opa_in		= 7;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 12;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd777;
		inst2_rs_opa_valid	= 0;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 0;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1006; 
		rs_cdb1_tag			= 7;		
		rs_cdb1_valid		= 1;
		rs_cdb2_in			= 1; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		#5
		@(negedge clock);
		$display("@@@ 1 @@ Branch is taken");
		$display("@@@ 1 @@ BIS in, use ALU");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd777");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 11;
		inst1_rs_opa_in		= 8;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 12;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd777;
		inst2_rs_opa_valid	= 0;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1006; 
		rs_cdb1_tag			= 7;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		thread1_branch_is_taken = 1;
		
		#5
		@(negedge clock);
		$display("@@@ 1 @@ Branch is taken");
		$display("@@@ 1 @@ BIS in, use ALU");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd777");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 11;
		inst1_rs_opa_in		= 8;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 0;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 12;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd777;
		inst2_rs_opa_valid	= 0;
		inst2_rs_opb_valid	= 1;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1006; 
		rs_cdb1_tag			= 7;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		thread1_branch_is_taken = 0;

		#5
		@(negedge clock);
		$display("@@@ 1 @@ HALT!!");
		$display("@@@ 1 @@ BIS in, use ALU");
		$display("@@@ 1 @@ Dest reg=#9");
		$display("@@@ 1 @@ opa_in=7, opb=9");
		$display("@@@ 1 @@ fu_available = 111111");
		$display("@@@ 2 @@ LDA in, use ALU");
		$display("@@@ 2 @@ Dest reg=#10");
		$display("@@@ 2 @@ opa_in=1, opb=64'd777");
		$display("@@@ 2 @@ fu_available = 111111");
		$display("@@@ 2 @@ CDB send data into Reg #4");
		$display("@@@ 2 @@ fu_available = 111111");
		inst1_rs_dest_in	= 11;
		inst1_rs_opa_in		= 8;
		inst1_rs_opb_in		= 9;
		inst1_rs_opa_valid	= 1;
		inst1_rs_opb_valid	= 1;
		inst1_rs_op_type_in	= `BIS_INST;
		inst1_rs_alu_func	= ALU_BIS;
		inst1_rs_load_in	= 1;
		inst1_rs_rob_idx_in	= 3;
		fu_is_available	= 6'b111111;
		
		inst2_rs_dest_in	= 12;
		inst2_rs_opa_in		= 1;
		inst2_rs_opb_in		= 64'd777;
		inst2_rs_opa_valid	= 1;
		inst2_rs_opb_valid	= 0;
		inst2_rs_op_type_in	= `LDA_INST;
		inst2_rs_alu_func	= ALU_ADDQ;
		inst2_rs_load_in	= 1;
		inst2_rs_rob_idx_in	= 1;
		rs_cdb1_in			= 64'd1006; 
		rs_cdb1_tag			= 7;		
		rs_cdb1_valid		= 0;
		rs_cdb2_in			= 0; 		 
		rs_cdb2_tag			= 0;
		rs_cdb2_valid		= 0; 
		inst1_rs_fu_select_in = 0;
		inst2_rs_fu_select_in = 0;
		thread1_branch_is_taken = 0;
		inst1_is_halt    =1;
		inst2_is_halt    =0;
		@(negedge clock);
		@(negedge clock);
		$display("@@@Passed");
		$finish;
	end
endmodule
