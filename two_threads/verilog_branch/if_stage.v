/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  if_stage.v                                          //
//                                                                     //
//  Description :  PC of the two way Out		               		   // 
//                 of Order Machine; fetch instruction,     	       //
//                 compute next PC location, and send them             //
//                 down the pipeline.                                  //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

module if_stage(
	input 				clock,							// system clock
	input 				reset, 							// system reset
	input 				thread1_branch_is_taken,
	input 				thread2_branch_is_taken,
	input [63:0]		thread1_target_pc,
	input [63:0]		thread2_target_pc,
	input         		rs_stall,		 				// when RS is full, we need to stop PC
	input	  			rob1_stall,		 				// when RoB1 is full, we need to stop PC1
	input				rob2_stall,						// when RoB2 is full, we need to stop PC2
	input				rat_stall,						// when the freelist of PRF is empty, RAT generate a stall signal
	input				thread1_structure_hazard_stall,	// If data and instruction want to use memory at the same time
	input				thread2_structure_hazard_stall,	// If data and instruction want to use memory at the same time
	input [63:0]		Imem2proc_data,					// Data coming back from instruction-memory
	input			    Imem2proc_valid,				// 
	input				is_two_threads,		


	output logic [63:0]	proc2Imem_addr,					// Address sent to Instruction memory
	output logic [63:0] next_PC_out,
	output logic [31:0] thread1_inst_out,
	output logic [31:0] thread2_inst_out,
	output logic	 	thread1_inst_is_valid,
	output logic	 	thread2_inst_is_valid,
	output logic		thread1_is_available,
	
	//for debug
	output logic [63:0]	proc2Imem_addr_previous
	);
	
	
	logic 				pc_enable1;
	logic 				pc_enable2;
	logic [63:0]		next_PC_out1;
	logic [63:0]		next_PC_out2;
	logic [63:0]		proc2Imem_addr1;
	logic [63:0]		proc2Imem_addr2;

 	logic [31:0] 		thread1_inst1_out;
	logic [31:0] 		thread1_inst2_out;
	logic [31:0] 		thread2_inst1_out;
	logic [31:0] 		thread2_inst2_out;
	logic	 	 		thread1_inst1_is_valid;
	logic	 	 		thread1_inst2_is_valid;
	logic	 	 		thread2_inst1_is_valid;
	logic	 	 		thread2_inst2_is_valid;
	logic [63:0]		proc2Imem_addr_previous1;
	logic [63:0]		proc2Imem_addr_previous2;
	
	CURRENT_THREAD_STATE current_thread_state;
	CURRENT_THREAD_STATE next_thread_state;
	
	assign thread1_is_available = current_thread_state[0];

	pc pc1(
		//input
		.clock(clock),                   	
		.reset(reset),                   	

		.branch_is_taken(thread1_branch_is_taken),      
		.fu_target_pc(thread1_target_pc),        
		.Imem2proc_data(Imem2proc_data),  
		.Imem2proc_valid(Imem2proc_valid),        	
		.rs_stall(rs_stall),		 	
		.rob_stall(rob1_stall),	
		.rat_stall(rat_stall),	 	
		.memory_structure_hazard_stall(thread1_structure_hazard_stall),  
		.pc_enable(pc_enable1),			 		

		//output
		.proc2Imem_addr(proc2Imem_addr1),    	 	
		.inst1_out(thread1_inst1_out),        	 			// fetched instruction out
		.inst2_out(thread1_inst2_out), 
		.inst1_is_valid(thread1_inst1_is_valid),  		 	// when low, instruction is garbage
		.inst2_is_valid(thread1_inst2_is_valid),  
		
		// for debug
		.proc2Imem_addr_previous(proc2Imem_addr_previous1),	
		.next_PC_out(next_PC_out1)        	 				// PC of instruction after fetched (PC+8).	 	
  		);


	pc pc2(
		//input
		.clock(clock),                   	
		.reset(reset),                   	
	
		.branch_is_taken(thread2_branch_is_taken),      
		.fu_target_pc(thread2_target_pc),        
		.Imem2proc_data(Imem2proc_data), 
		.Imem2proc_valid(Imem2proc_valid),         	
		.rs_stall(rs_stall),		 	
		.rob_stall(rob2_stall),	
		.rat_stall(rat_stall),	 	
		.memory_structure_hazard_stall(thread2_structure_hazard_stall),  
		.pc_enable(pc_enable2),			 		
	
		//output
		.proc2Imem_addr(proc2Imem_addr2),    	 	      	 	
		.inst1_out(thread2_inst1_out),        	 	
		.inst2_out(thread2_inst2_out), 
		.inst1_is_valid(thread2_inst1_is_valid),  		 	
		.inst2_is_valid(thread2_inst2_is_valid),
		
		// for debug
		.proc2Imem_addr_previous(proc2Imem_addr_previous2),	
		.next_PC_out(next_PC_out2)        	 				 	  		 	
  		);	
  	
  	always_ff@(posedge clock)
  	begin
  		if (reset)
  		begin
			current_thread_state <= `SD PROGRAM_START;		
  		end
  		else
		begin
  			current_thread_state <= `SD next_thread_state;
		end
  	end

	always_comb
	begin
		if (!is_two_threads)
		begin
			pc_enable1			  		    = 1'b1;
			pc_enable2			  		    = 1'b0;
			proc2Imem_addr				    = proc2Imem_addr1;
			next_PC_out 		 		    = next_PC_out1;
			thread1_inst_out 	 		    = thread1_inst1_out;
			thread2_inst_out 	 		    = thread1_inst2_out;
			thread1_inst_is_valid		    = thread1_inst1_is_valid;
			thread2_inst_is_valid		    = thread1_inst2_is_valid;
			proc2Imem_addr_previous		    = proc2Imem_addr_previous1;
			next_thread_state			    = THREAD1_IS_EX;
		end
		else
		begin
			case (current_thread_state)
				PROGRAM_START:
				begin
					pc_enable1			    = 1'b0;
					pc_enable2			    = 1'b0;
					proc2Imem_addr		    = proc2Imem_addr1;
					next_PC_out 		    = next_PC_out2;
					thread1_inst_out 	    = thread1_inst1_out;
					thread2_inst_out 	    = thread1_inst2_out;
					thread1_inst_is_valid   = thread1_inst1_is_valid;
					thread2_inst_is_valid   = thread1_inst2_is_valid;
					proc2Imem_addr_previous = proc2Imem_addr_previous1;
					next_thread_state       = THREAD2_IS_EX;
				end
				THREAD1_IS_EX:
				begin
					pc_enable1			    = 1'b0;
					pc_enable2			    = 1'b1;
					proc2Imem_addr		    = proc2Imem_addr1;
					next_PC_out 		    = next_PC_out2;
					thread1_inst_out 	    = thread1_inst1_out;
					thread2_inst_out 	    = thread1_inst2_out;
					thread1_inst_is_valid   = thread1_inst1_is_valid;
					thread2_inst_is_valid   = thread1_inst2_is_valid;
					proc2Imem_addr_previous	= proc2Imem_addr_previous1;
					next_thread_state       = THREAD2_IS_EX;
				end
				THREAD2_IS_EX:
				begin
					pc_enable1			    = 1'b1;
					pc_enable2			    = 1'b0;
					proc2Imem_addr		    = proc2Imem_addr2;
					next_PC_out 		    = next_PC_out1;
					thread1_inst_out 	    = thread2_inst1_out;
					thread2_inst_out 	    = thread2_inst2_out;
					thread1_inst_is_valid   = thread2_inst1_is_valid;
					thread2_inst_is_valid   = thread2_inst2_is_valid;
					proc2Imem_addr_previous = proc2Imem_addr_previous2;
					next_thread_state 	    = THREAD1_IS_EX;
				end
				default:
				begin
					pc_enable1			    = 1'b0;
					pc_enable2			    = 1'b0;
					proc2Imem_addr		    = 0;
					next_PC_out 		    = 0;
					thread1_inst_out 	    = 0;
					thread2_inst_out 	    = 0;
					thread1_inst_is_valid   = 0;
					thread2_inst_is_valid   = 0;
					proc2Imem_addr_previous = 0;
					next_thread_state       = NO_ONE_IS_EX;
				end
			endcase
		end
			//$display("Imem2proc_data:%h", Imem2proc_data);
	end	
endmodule
