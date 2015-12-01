module test_if_stage;
	//input
	logic 				clock;							// system clock
	logic 				reset; 							// system reset
	logic 				thread1_branch_is_taken;
	logic 				thread2_branch_is_taken;
	logic [63:0]		thread1_target_pc;
	logic [63:0]		thread2_target_pc;
	logic         		rs_stall;		 				// when RS is full, we need to stop PC
	logic	  			rob1_stall;		 				// when RoB1 is full, we need to stop PC1
	logic	  			rob2_stall;		 				// when RoB2 is full, we need to stop PC2
	logic				rat_stall;
	logic				thread1_structure_hazard_stall;	// If data and instruction want to use memory at the same time
	logic				thread2_structure_hazard_stall;	// If data and instruction want to use memory at the same time
	logic [63:0]		Imem2proc_data;					// Data coming back from instruction-memory
	logic			    Imem2proc_valid;				// 
	logic				is_two_threads;		

	//output
	logic [63:0]		proc2Imem_addr;					// Address sent to Instruction memory
	logic [63:0] 		next_PC_out;
	logic [31:0] 		thread1_inst_out;
	logic [31:0] 		thread2_inst_out;
	logic	 			thread1_inst_is_valid;
	logic	 			thread2_inst_is_valid;
	
	// for debug
	logic [63:0]		proc2Imem_addr_previous;

	if_stage(
		//input
		.clock(clock),							
		.reset(reset), 							
		.thread1_branch_is_taken(thread1_branch_is_taken),
		.thread2_branch_is_taken(thread2_branch_is_taken),
		.thread1_target_pc(thread1_target_pc),
		.thread2_target_pc(thread2_target_pc),
		.rs_stall(rs_stall),		 				
		.rob1_stall(rob1_stall),
		.rob2_stall(rob2_stall),	
		.rat_stall(rat_stall),		 				
		.thread1_structure_hazard_stall(thread1_structure_hazard_stall),	
		.thread2_structure_hazard_stall(thread2_structure_hazard_stall),	
		.Imem2proc_data(Imem2proc_data),					
	    .Imem2proc_valid(Imem2proc_valid),				
		.is_two_threads(is_two_threads),		

		//output
		.proc2Imem_addr(proc2Imem_addr),					
		.next_PC_out(next_PC_out),
		.thread1_inst_out(thread1_inst_out),
		.thread2_inst_out(thread2_inst_out),
		.thread1_inst_is_valid(thread1_inst_is_valid),
	 	.thread2_inst_is_valid(thread2_inst_is_valid),
	 	
	 	// for debug
	 	.proc2Imem_addr_previous(proc2Imem_addr_previous)
	);
	
	always #5 clock = ~clock;
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask
	
	initial 
	begin
		$monitor(" @@@  time:%d, clk:%b, \n\
						proc2Imem_addr:%d, \n\
						next_PC_out:%d, \n\
						thread1_inst_out:%h, \n\
						thread1_inst_is_valid:%b,\n\
						thread2_inst_out:%h, \n\
						thread2_inst_is_valid:%b.\n\
						proc2Imem_addr_previous:%d",//for debug
				$time, clock, 
				proc2Imem_addr,next_PC_out,thread1_inst_out,thread1_inst_is_valid,thread2_inst_out,thread2_inst_is_valid,proc2Imem_addr_previous);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");
		$display("@@@ next instruction(Imem2proc_valid=0)!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 0;					
		Imem2proc_valid					= 0;				
		is_two_threads					= 0;
		@(negedge clock);
		$display("@@@ next instruction!!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h0100_5601_1253_9787;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 0;	
		@(negedge clock);
		$display("@@@ next instruction!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h0100_8901_1093_9707;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 0;		
		@(negedge clock);
		$display("@@@ next instruction!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h1001_8901_1093_9707;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 0;
		@(negedge clock);
		$display("@@@ RS_STALL@!!!!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 1;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h1001_8901_1093_9707;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 0;
		@(negedge clock);
		$display("@@@ branch is mispredict!!");
		reset = 0;						
		thread1_branch_is_taken 		= 1;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 64'h0000_0000_0000_0100;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h0010_0000_1212_9707;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 0;		
		@(negedge clock);
		$display("@@@ next_inst!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h1001_8901_1093_9707;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 0;		
		@(negedge clock);
		$display("@@@ reset!!");
		reset = 1;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 0;					
		Imem2proc_valid					= 0;				
		is_two_threads					= 0;			
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h2111_8801_3593_9780;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;		
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h1010_0000_3573_9180;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;	
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h3563_0000_2153_9180;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ RoB1 stall!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 1;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		@(negedge clock);
		@(negedge clock);		
		@(negedge clock);
		$display("@@@ RS stall!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 1;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ next instruction!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ thread1 branch is taken!!");
		reset = 0;						
		thread1_branch_is_taken 		= 1;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 64'h0000_0000_0001_0000;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h8988_7475_1230_9532;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h4325_7400_1040_9592;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ thread1 brench is taken!!");
		reset = 0;						
		thread1_branch_is_taken 		= 1;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 64'h0000_0000_0000_1000;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(negedge clock);
		$display("@@@ next instruction(two threads)!!");
		reset = 0;						
		thread1_branch_is_taken 		= 0;
		thread2_branch_is_taken 		= 0;
		thread1_target_pc 				= 0;
		thread2_target_pc				= 0;	
		rs_stall 						= 0;		 			
		rob1_stall 						= 0;
		rob2_stall 						= 0;
		rat_stall						= 0;	
		thread1_structure_hazard_stall	= 0;	
		thread2_structure_hazard_stall	= 0;	
		Imem2proc_data					= 64'h7713_8080_3410_8980;					
		Imem2proc_valid					= 1;				
		is_two_threads					= 1;
		@(posedge clock);
		#1;
		$finish;		
	end
endmodule
