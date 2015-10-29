module testbench_rs;
<<<<<<< HEAD
	logic clock,reset;
	logic [$clog2(`PRF_SIZE)-1:0]  	rs_dest_in;
 	logic [63:0] 						rs_cdb1_in;     // CDB bus from functional units 
	logic [$clog2(`PRF_SIZE)-1:0]  				rs_cdb1_tag;    // CDB tag bus from functional units 
	logic  	      						rs_cdb1_valid;  // The data on the CDB is valid 
	logic [63:0] 						rs_cdb2_in;     // CDB bus from functional units 
	logic [$clog2(`PRF_SIZE)-1:0]  				rs_cdb2_tag;    // CDB tag bus from functional units 
	logic  	      						rs_cdb2_valid;  // The data on the CDB is valid 
	logic  [63:0] 						rs_opa_in;      // Operand a from Rename  
	logic  [63:0] 						rs_opb_in;      // Operand a from Rename 
	logic  	     						rs_opa_valid;   // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	logic         						rs_opb_valid;   // Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [5:0]    		  			rs_op_type_in;  // 
	ALU_FUNC						rs_alu_func;
	logic  		    		    			rs_load_in;     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	logic  [$clog2(`ROB_SIZE)-1:0]  			rs_rob_idx_in;  // 
	logic							mult_available;
	logic							adder_available;
	logic							memory_available;
	//input signals
	logic [63:0] 						rs_opa_out;       	// This RS' opa 
	logic [63:0] 						rs_opb_out;       	// This RS' opb 
	logic [$clog2(`PRF_SIZE)-1:0] 				rs_dest_tag_out;  	// This RS' destination tag  
	logic [$clog2(`ROB_SIZE)-1:0] 	  			rs_rob_idx_out;   	
	logic [5:0]						rs_op_type_out;
	ALU_FUNC                                                rs_alu_func_out;    	 
	logic							rs_full;
	logic							rs_out_valid;			
	//output signals
=======
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
	logic  		        		inst2_rs_load_in;     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in

	logic  [$clog2(`ROB_SIZE)-1:0]       	inst1_rs_rob_idx_in;  // 
	logic  [$clog2(`ROB_SIZE)-1:0]       	inst2_rs_rob_idx_in;  //

	logic					fu1_mult_available;
	logic					fu1_adder_available;
	logic					fu1_memory_available;
	logic					fu2_mult_available;
	logic					fu2_adder_available;
	logic					fu2_memory_available;
  
 	//outputs
	logic [63:0]						fu1_rs_opa_out;       	// This RS' opa 
	logic [63:0]						fu1_rs_opb_out;       	// This RS' opb 
	logic [$clog2(`PRF_SIZE)-1:0]	fu1_rs_dest_tag_out;  	// This RS' destination tag  
	logic [$clog2(`ROB_SIZE)-1:0]    fu1_rs_rob_idx_out;   	// This RS' corresponding ROB index
	logic [5:0]						fu1_rs_op_type_out;     // This RS' operation type
	logic							fu1_rs_out_valid;		// RS output is valid
	ALU_FUNC                                                fu1_alu_func_out;

	logic [63:0]						fu2_rs_opa_out;       	// This RS' opa 
	logic [63:0]						fu2_rs_opb_out;       	// This RS' opb 
	logic [$clog2(`PRF_SIZE)-1:0]	fu2_rs_dest_tag_out;  	// This RS' destination tag  
	logic [$clog2(`ROB_SIZE)-1:0]    fu2_rs_rob_idx_out;   	// This RS' corresponding ROB index
	logic [5:0]					  	fu2_rs_op_type_out;    // This RS' operation type
	logic							fu2_rs_out_valid;		// RS output is valid
	ALU_FUNC                                                fu2_alu_func_out;
	logic							rs_full;				// RS is full now		
>>>>>>> 8e8466fccbfda37c925e4d1f07d77da4f9912f91
	
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
  
<<<<<<< HEAD
	   .rs_opa_out(rs_opa_out),       	// This RS' opa 
	   .rs_opb_out(rs_opb_out),       	// This RS' opb 
	   .rs_dest_tag_out(rs_dest_tag_out),  	// This RS' destination tag  
	   .rs_rob_idx_out(rs_rob_idx_out),   	// 
	   .rs_op_type_out(rs_op_type_out),     // 
	   .rs_alu_func_out(rs_alu_func_out),
	   .rs_full(rs_full),
	   .rs_out_valid(rs_out_valid)
=======

	   .fu1_rs_opa_out(fu1_rs_opa_out),       	// This RS' opa 
	   .fu1_rs_opb_out(fu1_rs_opb_out),       	// This RS' opb 
	   .fu1_rs_dest_tag_out(fu1_rs_dest_tag_out),  	// This RS' destination tag  
	   .fu1_rs_rob_idx_out(fu1_rs_rob_idx_out),   	// 
	   .fu1_rs_op_type_out(fu1_rs_op_type_out),     //
	   .fu1_rs_out_valid(fu1_rs_out_valid),
	   .fu1_alu_func_out(fu1_alu_func_out),
	   .fu2_rs_opa_out(fu2_rs_opa_out),       	// This RS' opa 
	   .fu2_rs_opb_out(fu2_rs_opb_out),       	// This RS' opb 
	   .fu2_rs_dest_tag_out(fu2_rs_dest_tag_out),  	// This RS' destination tag  
	   .fu2_rs_rob_idx_out(fu2_rs_rob_idx_out),   	// 
	   .fu2_rs_op_type_out(fu2_rs_op_type_out),     //
	   .fu2_rs_out_valid(fu2_rs_out_valid),
	   .fu2_alu_func_out(fu2_alu_func_out),

	   .rs_full(rs_full)
>>>>>>> 8e8466fccbfda37c925e4d1f07d77da4f9912f91
	);

	always #5 clock = ~clock;

	task wait_until_done;
		rs_load_in=0;
		forever begin : wait_loop
			@(posedge rs_out_valid);
			@(negedge clock);
			if(rs_out_valid) disable wait_until_done;
		end
	endtask
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	initial begin
		$monitor("time:%d, clk:%b, fu1_rs_dest_tag_out:%h, fu1_rs_rob_idx_out:%h, fu1_rs_op_type_out:%h, fu1_alu_func_out:%h, fu1_rs_opa_out:%h, fu1_rs_opb_out:%h, fu1_rs_out_valid:%b, \
					   fu2_rs_dest_tag_out:%h, fu2_rs_rob_idx_out:%h, fu2_rs_op_type_out:%h, fu2_alu_func_out:%h, fu2_rs_opa_out:%h, fu2_rs_opb_out:%h, fu2_rs_out_valid:%b,",
				$time, clock, fu1_rs_dest_tag_out, fu1_rs_rob_idx_out, fu1_rs_op_type_out, fu1_alu_func_out, fu1_rs_opa_out, fu1_rs_opb_out, fu1_rs_out_valid, 
					      fu2_rs_dest_tag_out, fu2_rs_rob_idx_out, fu2_rs_op_type_out, fu2_alu_func_out, fu2_rs_opa_out, fu2_rs_opb_out, fu2_rs_out_valid);
		clock = 0;
		//***RESET**
		reset = 1;
		#5;
		@(negedge clock);
		reset = 0;
<<<<<<< HEAD
		rs_load_in=0;
		rs_cdb2_valid=0;
		//#5;
=======
		inst1_rs_load_in=0;
		inst2_rs_load_in=0;
		#5;
>>>>>>> 8e8466fccbfda37c925e4d1f07d77da4f9912f91
		@(negedge clock);
		inst1_rs_dest_in= {{$clog2(`PRF_SIZE)-1{1'b0}},1'b1};
		inst1_rs_opa_in= 32;
		inst1_rs_opb_in= 26;
		inst1_rs_opa_valid=1;
		inst1_rs_opb_valid=1;
		rs_cdb1_valid=0;
<<<<<<< HEAD
		rs_op_type_in=`INTM_GRP;    //instruction is mulq
		rs_alu_func=ALU_MULQ;
		rs_load_in=1;
		rs_rob_idx_in={{$clog2(`ROB_SIZE){1'b0}}};
		@(negedge clock);
		rs_load_in=0;
		mult_available=1;
		adder_available=1;
		memory_available=1;
		@(negedge clock);
		assert(	rs_opa_out==32 && 
			rs_opb_out==26 && 
			rs_dest_tag_out == {{$clog2(`PRF_SIZE)-1{1'b0}},1'b1} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE){1'b0}}} && 
			rs_op_type_out == `INTM_GRP && rs_alu_func_out==ALU_MULQ && !rs_full && rs_out_valid)  $display("@@@mulq issue Passed");
			else #1 exit_on_error;

		rs_dest_in= {3'b111,{$clog2(`PRF_SIZE)-3{1'b0}}};
		rs_opa_in= {{64-$clog2(`PRF_SIZE){1'b0}},{$clog2(`PRF_SIZE)-1{1'b0}},1'b1};
		rs_opb_in= 46;
		rs_opa_valid=0;
		rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_op_type_in=`INTA_GRP;   //instruction is addq,dependent on mulq
		rs_alu_func=ALU_ADDQ;
		rs_load_in=1;
		rs_rob_idx_in={{$clog2(`ROB_SIZE)-1{1'b0}},1'b1};
		@(negedge clock);
		rs_load_in=0;
		mult_available=0;
		adder_available=1;
		memory_available=1;
		@(negedge clock);
		assert(	rs_opa_out==64'h0 && 
			rs_opb_out==64'h0 && 
			rs_dest_tag_out == {$clog2(`PRF_SIZE){1'b0}} && 
			rs_rob_idx_out == {$clog2(`ROB_SIZE){1'b0}} && 
			rs_op_type_out == 6'h00 && rs_alu_func_out== ALU_DEFAULT && !rs_full && !rs_out_valid)  $display("@@@addq wait to issue Passed");
			else #1 exit_on_error;

		rs_dest_in= {3'b100,{$clog2(`PRF_SIZE)-3{1'b0}}};
		rs_opa_in= 64'h0000_0000_0003_0000;
		rs_opb_in= 64'h0000_0000_0000_4000;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_op_type_in=`LDQ_INST;    //instruction is LDQ,independent on previous instrs
		rs_alu_func=ALU_ADDQ;
		rs_load_in=1;
		rs_rob_idx_in={{$clog2(`ROB_SIZE)-2{1'b0}},2'b10};
		@(negedge clock);
		rs_load_in=0;
		mult_available=0;
		adder_available=1;
		memory_available=1;
		@(negedge clock);
		assert(	rs_opa_out==64'h0000_0000_0003_0000 && 
			rs_opb_out==64'h0000_0000_0000_4000 && 
			rs_dest_tag_out == {3'b100,{$clog2(`PRF_SIZE)-3{1'b0}}} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE)-2{1'b0}},2'b10} && 
			rs_op_type_out == `LDQ_INST && rs_alu_func_out==ALU_ADDQ && !rs_full && rs_out_valid)  $display("@@@ldq issue Passed");
			else #1 exit_on_error;
	
		
		rs_dest_in= {3'b010,{$clog2(`PRF_SIZE)-3{1'b0}}};
		rs_opa_in= 64'h0000_0000_0045_0000;
		rs_opb_in= 64'h0000_0000_0000_2400;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_op_type_in=`INTA_GRP;    //instruction is addq,independent on previous instrs
		rs_alu_func=ALU_ADDQ;
		rs_load_in=1;
		rs_rob_idx_in={{$clog2(`ROB_SIZE)-2{1'b0}},2'b11};
		@(negedge clock);
		rs_load_in=0;
		mult_available=0;
		adder_available=1;
		memory_available=0;
		@(negedge clock);
		assert(	rs_opa_out==64'h0000_0000_0045_0000 && 
			rs_opb_out==64'h0000_0000_0000_2400 && 
			rs_dest_tag_out == {3'b010,{$clog2(`PRF_SIZE)-3{1'b0}}} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE)-2{1'b0}},2'b11} && 
			rs_op_type_out == `INTA_GRP && rs_alu_func_out==ALU_ADDQ && !rs_full && rs_out_valid)  $display("@@@current independent addq issue Passed");
			else #1 exit_on_error;

		rs_dest_in= {3'b101,{$clog2(`PRF_SIZE)-3{1'b0}}};
		rs_opa_in= 828;
		rs_opb_in= 255;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=1;
		rs_cdb1_tag={{$clog2(`PRF_SIZE)-1{1'b0}},1'b1};//multq execution completed,CDB broadcast,dependent addq operand available
		rs_cdb1_in=832;
		rs_op_type_in=`INTM_GRP;    //instruction is independent mulq on preceding addq
		rs_alu_func=ALU_MULQ;
		rs_load_in=1;
		rs_rob_idx_in={{$clog2(`ROB_SIZE)-3{1'b0}},3'b100};
		@(negedge clock);
		rs_load_in=0;
		mult_available=1;
		adder_available=0;  //ex alu unit unavailable,cannot dispatch addq
		memory_available=0;
		assert(	rs_opa_out==832 && 
			rs_opb_out==46 && 
			rs_dest_tag_out == {3'b111,{$clog2(`PRF_SIZE)-3{1'b0}}} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE)-1{1'b0}},1'b1} && 
			rs_op_type_out == `INTA_GRP && rs_alu_func_out==ALU_ADDQ && !rs_full && rs_out_valid)  $display("@@@dependent addq issue Passed");
			else #1 exit_on_error;
		@(negedge clock);
		assert(	rs_opa_out==828 && 
			rs_opb_out==255 && 
			rs_dest_tag_out == {3'b101,{$clog2(`PRF_SIZE)-3{1'b0}}} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE)-3{1'b0}},3'b100} && 
			rs_op_type_out == `INTM_GRP && rs_alu_func_out==ALU_MULQ && !rs_full && rs_out_valid)  $display("@@@independent mulq issue Passed");
			else #1 exit_on_error;


		//different independent instrs test
		rs_dest_in= {4'b1010,{$clog2(`PRF_SIZE)-4{1'b0}}};
		rs_opa_in= 64'h0000_3234_0000_0000;
		rs_opb_in= 64'h0000_0000_2000_8300;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=1;
		rs_cdb1_tag={3'b100,{$clog2(`PRF_SIZE)-3{1'b0}}};//ldq execution completed,CDB broadcast
		rs_cdb1_in=300;
		rs_op_type_in=`INTA_GRP;    //instruction is independent subq on preceding addq
		rs_alu_func=ALU_SUBQ;
		rs_load_in=1;
		rs_rob_idx_in={{$clog2(`ROB_SIZE)-3{1'b0}},3'b101};
		@(negedge clock);
		rs_load_in=0;
		mult_available=0;
		adder_available=0;  //although finished,only 1 cdb,stay in adder
		memory_available=1;
		@(negedge clock);
		assert(	rs_opa_out==64'h0 && 
			rs_opb_out==64'h0 && 
			rs_dest_tag_out == {$clog2(`PRF_SIZE){1'b0}} && 
			rs_rob_idx_out == {$clog2(`ROB_SIZE){1'b0}} && 
			rs_op_type_out == 6'h00 && rs_alu_func_out== ALU_DEFAULT && !rs_full && !rs_out_valid)  $display("@@@nothing can be issued Passed");
			else #1 exit_on_error;

		
		rs_load_in=1;
		rs_dest_in= {4'b1000,{$clog2(`PRF_SIZE)-4{1'b0}}};
		rs_opa_in= 64'h0000_3234_0000_0000;
		rs_opb_in= 64'h0000_1882_1000_8300;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=1;
		rs_cdb1_tag={3'b010,{$clog2(`PRF_SIZE)-3{1'b0}}};//independent addq execution completed,CDB broadcast
		rs_cdb1_in=64'h0000_0000_0045_2400;
		rs_op_type_in=`INTA_GRP;    //instruction is independent CMPULT on preceding addq
		rs_alu_func=ALU_CMPULT;
		rs_rob_idx_in={{$clog2(`ROB_SIZE)-3{1'b0}},3'b110};
		@(negedge clock);
		rs_load_in=0;
		mult_available=0;
		adder_available=1;     //finished,can sent dependent addq to ex unit
		memory_available=1;
		@(negedge clock);
		rs_load_in=1;
		rs_dest_in= {4'b1001,{$clog2(`PRF_SIZE)-4{1'b0}}};
		rs_opa_in= 64'h1111_0000_0000_0000;
		rs_opb_in= 64'h0000_0000_0000_1111;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_op_type_in=`INTA_GRP;    //instruction is independent CMPEQ on preceding addq
		rs_alu_func=ALU_CMPEQ;
		rs_rob_idx_in={{$clog2(`ROB_SIZE)-3{1'b0}},3'b111};
		assert(	rs_opa_out==64'h0000_3234_0000_0000 && 
			rs_opb_out==64'h0000_1882_1000_8300 &&
			rs_dest_tag_out == {4'b1000,{$clog2(`PRF_SIZE)-4{1'b0}}} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE)-3{1'b0}},3'b110} && 
			rs_op_type_out == `INTA_GRP && rs_alu_func_out== ALU_CMPULT && !rs_full && rs_out_valid)  $display("@@@CMPULT issue Passed");
			else #1 exit_on_error;
		@(negedge clock);
		rs_load_in=0;
		mult_available=0;
		adder_available=0;     
		memory_available=1;
		assert(	rs_opa_out==64'h0000_3234_0000_0000 && 
			rs_opb_out==64'h0000_0000_2000_8300 && 
			rs_dest_tag_out == {4'b1010,{$clog2(`PRF_SIZE)-4{1'b0}}} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE)-3{1'b0}},3'b101} && 
			rs_op_type_out == `INTA_GRP && rs_alu_func_out==ALU_SUBQ && !rs_full && rs_out_valid)  $display("@@@independent subq issue Passed");
			else #1 exit_on_error;
		@(negedge clock);
		assert(	rs_opa_out==64'h0 && 
			rs_opb_out==64'h0 && 
			rs_dest_tag_out == {$clog2(`PRF_SIZE){1'b0}} && 
			rs_rob_idx_out == {$clog2(`ROB_SIZE){1'b0}} && 
			rs_op_type_out == 6'h00 && rs_alu_func_out== ALU_DEFAULT && !rs_full && !rs_out_valid)  $display("@@@nothing can be issued Passed");
			else #1 exit_on_error;
		rs_load_in=0;
		rs_cdb1_valid=1;
		rs_cdb1_tag={3'b111,{$clog2(`PRF_SIZE)-3{1'b0}}};      //dependent addq execution completed,CDB broadcast
		rs_cdb1_in=878;
		@(negedge clock);
		mult_available=0;            // only 1 cdb 
		adder_available=1;
		memory_available=1;
		wait_until_done;
		assert(	rs_opa_out==64'h1111_0000_0000_0000 && 
			rs_opb_out==64'h0000_0000_0000_1111 && 
			rs_dest_tag_out == {4'b1001,{$clog2(`PRF_SIZE)-4{1'b0}}} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE)-3{1'b0}},3'b111} && 
			rs_op_type_out == `INTA_GRP && rs_alu_func_out== ALU_CMPEQ && !rs_full && rs_out_valid)  $display("@@@CMPULT issue Passed");
			else #1 exit_on_error;
		rs_load_in=0;
		rs_cdb1_valid=1;
		rs_cdb1_tag={3'b101,{$clog2(`PRF_SIZE)-3{1'b0}}};      //mulq execution completed,CDB broadcast
		rs_cdb1_in=211140;
		@(negedge clock);
		rs_load_in=0;
		mult_available=1;
		adder_available=0;
		memory_available=1;
		@(negedge clock);
		assert(	rs_opa_out==64'h0 && 
			rs_opb_out==64'h0 && 
			rs_dest_tag_out == {$clog2(`PRF_SIZE){1'b0}} && 
			rs_rob_idx_out == {$clog2(`ROB_SIZE){1'b0}} && 
			rs_op_type_out == 6'h00 && rs_alu_func_out== ALU_DEFAULT && !rs_full && !rs_out_valid)  $display("@@@nothing can be issued Passed");
=======
		rs_cdb2_valid=0;
		inst1_rs_op_type_in=`INTM_GRP;    //instruction is mulq
		inst1_rs_alu_func=ALU_MULQ;
		inst1_rs_load_in=1;
		inst1_rs_rob_idx_in={{$clog2(`ROB_SIZE){1'b0}}};
		fu1_mult_available=1;
		fu1_adder_available=1;
		fu1_memory_available=1;
		
		inst2_rs_dest_in= {3'b111,{$clog2(`PRF_SIZE)-3{1'b0}}};
		inst2_rs_opa_in= {{64-$clog2(`PRF_SIZE){1'b0}},{$clog2(`PRF_SIZE)-1{1'b0}},1'b1};
		inst2_rs_opb_in= 46;
		inst2_rs_opa_valid=0;
		inst2_rs_opb_valid=1;
		inst2_rs_op_type_in=`INTA_GRP;   //instruction is addq
		inst2_rs_alu_func=ALU_ADDQ;
		inst2_rs_load_in=1;
		inst2_rs_rob_idx_in={{$clog2(`ROB_SIZE)-1{1'b0}},1'b1};
		fu2_mult_available=1;
		fu2_adder_available=1;
		fu2_memory_available=1;
		#5;
		@(negedge clock);
		while((!fu1_rs_out_valid) || fu2_rs_out_valid);
		assert(	fu1_rs_opa_out==32 && 
			fu1_rs_opb_out==26 && 
			fu1_rs_dest_tag_out == {{$clog2(`PRF_SIZE)-1{1'b0}},1'b1} && 
			fu1_rs_rob_idx_out == {{$clog2(`ROB_SIZE){1'b0}}} && 
			fu1_rs_op_type_out == `INTM_GRP && fu1_alu_func_out == ALU_MULQ && fu1_rs_out_valid
  			&& !rs_full &&
			fu2_rs_opa_out==64'h0 && 
			fu2_rs_opb_out==64'h0 && 
			fu2_rs_dest_tag_out == {$clog2(`PRF_SIZE){1'b0}} && 
			fu2_rs_rob_idx_out == {$clog2(`ROB_SIZE){1'b0}} && 
			fu2_rs_op_type_out == 6'h00 && fu2_alu_func_out == ALU_DEFAULT && !fu2_rs_out_valid)  $display("@@@addq wait to issue and mulq issue Passed");
			else #1 exit_on_error;

		inst1_rs_dest_in= {3'b100,{$clog2(`PRF_SIZE)-3{1'b0}}};
		inst1_rs_opa_in= 64'h0000_0000_0003_0000;
		inst1_rs_opb_in= 64'h0000_0000_0000_4000;
		inst1_rs_opa_valid=1;
		inst1_rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_cdb2_valid=0;
		inst1_rs_op_type_in=`LDQ_INST;    //instruction is LDQ
		inst1_rs_alu_func=ALU_ADDQ;
		inst1_rs_load_in=1;
		inst1_rs_rob_idx_in={{$clog2(`ROB_SIZE)-2{1'b0}},2'b10};
		fu1_mult_available=0;
		fu1_adder_available=1;
		fu1_memory_available=1;
		
		inst2_rs_dest_in= {3'b010,{$clog2(`PRF_SIZE)-3{1'b0}}};
		inst2_rs_opa_in= 64'h0000_0000_0045_0000;
		inst2_rs_opb_in= 64'h0000_0000_0000_2400;
		inst2_rs_opa_valid=1;
		inst2_rs_opb_valid=1;
		inst2_rs_op_type_in=`INTA_GRP;    //instruction is independent addq
		inst2_rs_alu_func=ALU_ADDQ;
		inst2_rs_load_in=1;
		inst2_rs_rob_idx_in={{$clog2(`ROB_SIZE)-2{1'b0}},2'b11};
		fu2_mult_available=1;
		fu2_adder_available=1;
		fu2_memory_available=1;
		#5;
		@(negedge clock);
		while(!fu1_rs_out_valid && !fu2_rs_out_valid);
		$display("%b", fu2_rs_dest_tag_out == {3'b010,{$clog2(`PRF_SIZE)-3{1'b0}}});
		$display("%b", fu2_rs_rob_idx_out == {{$clog2(`ROB_SIZE)-2{1'b0}},2'b11});
		$display("%b", fu2_rs_op_type_out == `INTA_GRP && fu2_alu_func_out == ALU_ADDQ);
		$display("enter");
		assert( fu1_rs_opa_out==64'h0 && 
			fu1_rs_opb_out==64'h0 && 
			fu1_rs_dest_tag_out == {$clog2(`PRF_SIZE){1'b0}} && 
			fu1_rs_rob_idx_out == {$clog2(`ROB_SIZE){1'b0}} && 
			fu1_rs_op_type_out == 6'h00 && fu1_alu_func_out == ALU_DEFAULT && !fu1_rs_out_valid
			&& !rs_full &&
			fu2_rs_opa_out==64'h0000_0000_0045_0000 && 
			fu2_rs_opb_out==64'h0000_0000_0000_2400 && 
			fu2_rs_dest_tag_out == {3'b010,{$clog2(`PRF_SIZE)-3{1'b0}}} && 
			fu2_rs_rob_idx_out == {{$clog2(`ROB_SIZE)-2{1'b0}},2'b11} && 
			fu2_rs_op_type_out == `INTA_GRP && fu2_alu_func_out == ALU_ADDQ && fu2_rs_out_valid)  $display("@@@ldq and independent addq issue Passed");
>>>>>>> 8e8466fccbfda37c925e4d1f07d77da4f9912f91
			else #1 exit_on_error;
		rs_load_in=0;
		rs_cdb1_valid=1;
		rs_cdb1_tag={4'b1000,{$clog2(`PRF_SIZE)-4{1'b0}}};      //CMPULT execution completed,CDB broadcast
		rs_cdb1_in=0;                  //opa<opb is wrong
		mult_available=1;
		adder_available=1;
		memory_available=1;
		#5;
		@(negedge clock);
		$display("@@@Passed");
		$finish;
	end
endmodule
