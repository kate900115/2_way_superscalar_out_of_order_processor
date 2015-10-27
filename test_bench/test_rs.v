module testbench_rs;
	logic clock,reset;
	logic [$clog2(`PRF_SIZE)-1:0]  	rs_dest_in;
 	logic [63:0] 					rs_cdb1_in;     // CDB bus from functional units 
	logic [$clog2(`PRF_SIZE)-1:0]  	rs_cdb1_tag;    // CDB tag bus from functional units 
	logic  	      					rs_cdb1_valid;  // The data on the CDB is valid 
	logic [63:0] 					rs_cdb2_in;     // CDB bus from functional units 
	logic [$clog2(`PRF_SIZE)-1:0]  	rs_cdb2_tag;    // CDB tag bus from functional units 
	logic  	      					rs_cdb2_valid;  // The data on the CDB is valid 
	logic  [63:0] 					rs_opa_in;      // Operand a from Rename  
	logic  [63:0] 					rs_opb_in;      // Operand a from Rename 
	logic  	     					rs_opa_valid;   // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	logic         					rs_opb_valid;   // Is Opb a tag or immediate data (READ THIS COMMENT) 
	logic  [5:0]      				rs_op_type_in;  // 
	ALU_FUNC						rs_alu_func;
	logic  		        			rs_load_in;     // Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	logic  [$clog2(`ROB_SIZE)-1:0]  rs_rob_idx_in;  // 
	logic							mult_available;
	logic							adder_available;
	logic							memory_available;
	//input signals
	logic [63:0] 					rs_opa_out;       	// This RS' opa 
	logic [63:0] 					rs_opb_out;       	// This RS' opb 
	logic [$clog2(`PRF_SIZE)-1:0] 	rs_dest_tag_out;  	// This RS' destination tag  
	logic [$clog2(`ROB_SIZE)-1:0] 	rs_rob_idx_out;   	
	logic [5:0]						rs_op_type_out;     	 
	logic							rs_full;
	logic							rs_out_valid;			
	//output signals
	
	rs DUT(.reset(reset),
	   .clock(clock),           
	   .rs_dest_in(rs_dest_in),   
	   .rs_cdb1_in(rs_cdb1_in),      
	   .rs_cdb1_tag(rs_cdb1_tag),    
	   .rs_cdb1_valid(rs_cdb1_valid),  
	   .rs_cdb2_in(rs_cdb2_in),     
	   .rs_cdb2_tag(rs_cdb2_tag),   
	   .rs_cdb2_valid(rs_cdb2_valid),   
	   .rs_opa_in(rs_opa_in),        
	   .rs_opb_in(rs_opb_in),     
	   .rs_opa_valid(rs_opa_valid),   
	   .rs_opb_valid(rs_opb_valid),    
	   .rs_op_type_in(rs_op_type_in),  
	   .rs_alu_func(rs_alu_func),
	   .rs_load_in(rs_load_in),    
	   .rs_rob_idx_in(rs_rob_idx_in), 
	   .mult_available(mult_available),
	   .adder_available(adder_available),
	   .memory_available(memory_available),
  
	   .rs_opa_out(rs_opa_out),       	// This RS' opa 
	   .rs_opb_out(rs_opb_out),       	// This RS' opb 
	   .rs_dest_tag_out(rs_dest_tag_out),  	// This RS' destination tag  
	   .rs_rob_idx_out(rs_rob_idx_out),   	// 
	   .rs_op_type_out(rs_op_type_out),     // 
	   .rs_full(rs_full),
	   .rs_out_valid(rs_out_valid)
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
		$monitor("time:%d, clk:%b, rs_dest_tag_out:%h, rs_rob_idx_out:%h, rs_op_type_out:%h, rs_opa_out:%h, rs_opb_out:%h, rs_out_valid:%b", $time, clock, rs_dest_tag_out, rs_rob_idx_out, rs_op_type_out, rs_opa_out, rs_opb_out, rs_out_valid);
		clock = 0;
		//***RESET**
		reset = 1;
		#5;
		@(negedge clock);
		reset = 0;
		rs_load_in=0;
		#5;
		@(negedge clock);
		rs_dest_in= {{$clog2(`PRF_SIZE)-1{1'b0}},1'b1};
		rs_opa_in= 32;
		rs_opb_in= 26;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_cdb2_valid=0;
		rs_op_type_in=6'h13;    //instruction is mulq
		rs_alu_func=ALU_DEFAULT;
		rs_load_in=1;
		rs_rob_idx_in={$clog2(`ROB_SIZE){1'b0}};
		mult_available=1;
		adder_available=1;
		memory_available=1;
		#5;
		@(negedge clock);
		while(!rs_out_valid);
		assert(	rs_opa_out==32 && 
			rs_opb_out==26 && 
			rs_dest_tag_out == {{$clog2(`PRF_SIZE)-1{1'b0}},1'b1} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE){1'b0}}} && 
			rs_op_type_out == 6'h13 && !rs_full && rs_out_valid)  $display("@@@mulq issue Passed");
			else #1 exit_on_error;
		rs_dest_in= {3'b111,{$clog2(`PRF_SIZE)-3{1'b0}}};
		rs_opa_in= {{64-$clog2(`PRF_SIZE){1'b0}},{$clog2(`PRF_SIZE)-1{1'b0}},1'b1};
		rs_opb_in= 46;
		rs_opa_valid=0;
		rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_cdb2_valid=0;
		rs_op_type_in=6'h10;   //instruction is addq
		rs_alu_func=ALU_DEFAULT;
		rs_load_in=1;
		rs_rob_idx_in={{$clog2(`ROB_SIZE)-1{1'b0}},1'b1};
		mult_available=0;
		adder_available=1;
		memory_available=1;
		#5;
		@(negedge clock);
		while(rs_out_valid);
		assert(	rs_opa_out==64'h0 && 
			rs_opb_out==64'h0 && 
			rs_dest_tag_out == {$clog2(`PRF_SIZE){1'b0}} && 
			rs_rob_idx_out == {$clog2(`ROB_SIZE){1'b0}} && 
			rs_op_type_out == 6'h00 && !rs_full && !rs_out_valid)  $display("@@@addq wait to issue Passed");
			else #1 exit_on_error;
		rs_dest_in= {3'b100,{$clog2(`PRF_SIZE)-3{1'b0}}};
		rs_opa_in= 64'h0000_0000_0003_0000;
		rs_opb_in= 64'h0000_0000_0000_4000;
		rs_opa_valid=0;
		rs_opb_valid=0;
		#5;
		@(negedge clock);
		rs_cdb1_valid=1;
		rs_cdb1_tag={{$clog2(`PRF_SIZE)-1{1'b0}},1'b1};
		rs_cdb1_in=832;
		rs_cdb2_valid=1;
		rs_cdb2_tag={{$clog2(`PRF_SIZE)-1{1'b0}},1'b1};
		rs_cdb2_in=46;
		rs_op_type_in=6'h28;    //instruction is LDQ
		rs_alu_func=ALU_DEFAULT;
		rs_load_in=1;
		rs_rob_idx_in={{($clog2(`ROB_SIZE)-2){1'b0}},2'b10};
		mult_available=1;
		adder_available=1;
		memory_available=1;
		#5;
		@(negedge clock);
		while(!rs_out_valid);
		assert(	rs_opa_out==832 && 
			rs_opb_out==46 && 
			rs_dest_tag_out == {3'b111,{$clog2(`PRF_SIZE)-3{1'b0}}} && 
			rs_rob_idx_out == {{$clog2(`ROB_SIZE)-1{1'b0}},1'b1} && 
			rs_op_type_out == 6'h10 && !rs_full && rs_out_valid)  $display("@@@addq issue Passed");
			else #1 exit_on_error;
		rs_dest_in= {3'b010,{$clog2(`PRF_SIZE)-3{1'b0}}};
		rs_opa_in= 64'h0000_0000_0045_0000;
		rs_opb_in= 64'h0000_0000_0000_2400;
		rs_opa_valid=1;
		rs_opb_valid=1;
		rs_cdb1_valid=0;
		rs_cdb2_valid=0;
		rs_op_type_in=6'h10;    //instruction is addq
		rs_alu_func=ALU_DEFAULT;
		rs_load_in=1;
		rs_rob_idx_in={{($clog2(`ROB_SIZE)-2){1'b0}},2'b11};
		mult_available=1;
		adder_available=0;
		memory_available=1;
		#5;
		@(negedge clock);
		while(rs_out_valid);
		assert(	rs_opa_out==64'h0 && 
			rs_opb_out==64'h0 && 
			rs_dest_tag_out == {$clog2(`PRF_SIZE){1'b0}} && 
			rs_rob_idx_out == {$clog2(`ROB_SIZE){1'b0}} && 
			rs_op_type_out == 6'h00 && !rs_full && !rs_out_valid)  $display("@@@ldq wait to issue Passed");
			else #1 exit_on_error;
		$display("@@@Passed");
		$finish;
	end
endmodule


		
