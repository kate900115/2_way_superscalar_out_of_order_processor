module test_pc;
	
	logic         		clock;                   	// system clock
	logic         		reset;                   	// system reset

	logic         		branch_is_taken;         	// taken-branch signal
	logic  [63:0] 		fu_target_pc;            	// target pc: use if take_branch is TRUE

	logic  [63:0] 		Imem2proc_data;         	// Data coming back from instruction-memory
	logic         		rs_stall;		 	// when RS is full, we need to stop PC
	logic	  		rob_stall;		 	// when RoB is full, we need to stop PC
	logic			memory_structure_hazard_stall;  // If data and instruction want to use memory at the same time
	logic			pc_enable;			//	

	
	logic [63:0] 	proc2Imem_addr;   	 	
	logic [63:0] 	next_PC_out;        	 	
	logic [31:0] 	inst1_out;        	 		// fetched instruction out
	logic [31:0]	inst2_out; 
	logic        	inst1_is_valid;  		 	// when low, instruction is garbage
	logic        	inst2_is_valid;  		 	// when low, instruction is garbage		 	

pc pc1(
	// input
	.clock(clock),                   				
	.reset(reset),                   				

	.branch_is_taken(branch_is_taken),         			
	.fu_target_pc(fu_target_pc),            			

	.Imem2proc_data(Imem2proc_data),          			
	.rs_stall(rs_stall),		 				
	.rob_stall(rob_stall),		 				
	.memory_structure_hazard_stall(memory_structure_hazard_stall),  
	.pc_enable(pc_enable),

	// output 		
	.proc2Imem_addr(proc2Imem_addr),    	 			
	.next_PC_out(next_PC_out),        	 			
	.inst1_out(inst1_out),       
	.inst2_out(inst2_out),   	 				
	.inst1_is_valid(inst1_is_valid),
	.inst2_is_valid(inst2_is_valid)  		 			
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
						inst1_out:%h, \n\
						inst1_is_valid:%b,\n\
						inst2_out:%h, \n\
						inst2_is_valid:%b",//for debug
				$time, clock, 
				proc2Imem_addr,next_PC_out,inst1_out,inst1_is_valid,inst2_out,inst2_is_valid);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");

		$display("@@@ next instruction!");
		reset = 0;
		branch_is_taken 	      = 0;        			
		fu_target_pc		      = 0;           			
		Imem2proc_data  	      = 64'h1234_4567_5678_3456;         			
		rs_stall		      = 0;		 				
		rob_stall		      = 0;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		@(negedge clock);
		$display("@@@ next instruction!");
		branch_is_taken 	      = 0;        			
		fu_target_pc		      = 0;           			
		Imem2proc_data  	      = 64'h0000_4567_5008_3416;         			
		rs_stall		      = 0;		 				
		rob_stall		      = 0;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		@(negedge clock);
		$display("@@@ next instruction!");
		branch_is_taken 	      = 0;        			
		fu_target_pc		      = 0;           			
		Imem2proc_data  	      = 64'h0000_0000_5008_3416;         			
		rs_stall		      = 0;		 				
		rob_stall		      = 0;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		@(negedge clock);
		$display("@@@ branch is taken!");
		branch_is_taken 	      = 1;        			
		fu_target_pc		      = 64'h0000_0000_0000_0100;           			
		Imem2proc_data  	      = 64'h0000_0000_5008_1016;         			
		rs_stall		      = 0;		 				
		rob_stall		      = 0;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		@(negedge clock);
		$display("@@@ next instruction!!");
		branch_is_taken 	      = 0;        			
		fu_target_pc		      = 0;           			
		Imem2proc_data  	      = 64'h0000_0010_9008_1406;         			
		rs_stall		      = 0;		 				
		rob_stall		      = 0;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		@(negedge clock);
		$display("@@@ rs_stall!");
		branch_is_taken 	      = 0;        			
		fu_target_pc		      = 0;           			
		Imem2proc_data  	      = 64'h0000_1110_5018_0016;         			
		rs_stall		      = 1;		 				
		rob_stall		      = 0;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		@(negedge clock);
		$display("@@@ next instruction!!");
		branch_is_taken 	      = 0;        			
		fu_target_pc		      = 0;           			
		Imem2proc_data  	      = 64'h5610_0310_9198_1425;         			
		rs_stall		      = 0;		 				
		rob_stall		      = 0;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		@(negedge clock);
		$display("@@@ rob_stall!!");
		branch_is_taken 	      = 0;        			
		fu_target_pc		      = 0;           			
		Imem2proc_data  	      = 64'h5610_7777_6467_1425;         			
		rs_stall		      = 0;		 				
		rob_stall		      = 1;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		@(negedge clock);
		$display("@@@ rob_stall!!");
		branch_is_taken 	      = 0;        			
		fu_target_pc		      = 0;           			
		Imem2proc_data  	      = 64'h5610_7777_6467_1425;         			
		rs_stall		      = 0;		 				
		rob_stall		      = 1;	 				
		memory_structure_hazard_stall = 0;  
		pc_enable 		      = 1;
		$finish;
	end

endmodule
