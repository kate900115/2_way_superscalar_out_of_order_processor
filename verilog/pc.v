/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  pc.v                                                //
//                                                                     //
//  Description :  PC of the two way Out		               		   // 
//                 of Order Machine; fetch instruction,     	       //
//                 compute next PC location, and send them             //
//                 down the pipeline.                                  //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

//`timescale 1ns/100ps

module pc(
	input         			clock,                   		// system clock
	input         			reset,                   		// system reset

	input         			branch_is_taken,         		// taken-branch signal
	input  [63:0] 			fu_target_pc,            		// target pc: use if take_branch is TRUE

	input  [63:0] 			Imem2proc_data,          		// Data coming back from instruction-memory
	input			    	Imem2proc_valid,				//
	input         			rs_stall,		 				// when RS is full, we need to stop PC
	input	  				rob_stall,		 				// when RoB is full, we need to stop PC
	input					rat_stall,						// when the freelist of PRF is empty, RAT generate a stall signal
	input					memory_structure_hazard_stall,  // If data and instruction want to use memory at the same time
	input					pc_enable,						// 
 
	output logic [63:0] 	proc2Imem_addr,    	 			// Address sent to Instruction memory
	output logic [63:0] 	next_PC_out,        	 		// PC of instruction after fetched (PC+8). for debug
	output logic [31:0] 	inst1_out,        	 			// fetched instruction out
	output logic [31:0]		inst2_out, 
	output logic        	inst1_is_valid,  		 		// when low, instruction is garbage
	output logic        	inst2_is_valid  		 		// when low, instruction is garbage
  );


	logic  [63:0] 			PC_reg;             	 		// PC we are currently fetching
	logic  [63:0]	 		next_PC;
	logic  [31:0]	 		current_inst1;
	logic  [31:0]	 		current_inst2;
		
	logic      				PC_stall; 
	logic 					inst1_is_valid_reg;
	logic					inst2_is_valid_reg;
	logic [31:0]			inst1_out_reg;
	logic [31:0]			inst2_out_reg;



	assign proc2Imem_addr = {PC_reg[63:3], 3'b0};
	assign current_inst1  = Imem2proc_data[63:32];
	assign current_inst2  = Imem2proc_data[31:0];

	assign PC_stall	      = rs_stall || rob_stall || rat_stall || memory_structure_hazard_stall;
	assign next_PC_out    = next_PC;

  	// next PC is target_pc if there is a taken branch or
  	// the next sequential PC (PC+8) if no branch
  	// halting is handled with the enable PC_enable;

  	// The take-branch signal must override stalling (otherwise it may be lost)


  	// Pass PC+8 down pipeline w/instruction

  	// This register holds the PC value
  	
 
  	always_ff @(posedge clock) 
	begin
			// synopsys sync_set_reset "reset"
    		if(reset)			
    		begin
	      		PC_reg 		  	  <= `SD 0;  
      			inst1_is_valid 	  <= `SD 0;
      			inst2_is_valid 	  <= `SD 0;
				inst1_out	  	  <= `SD 0;
				inst2_out	 	  <= `SD 0;
    		end
    		else
    		begin
    			PC_reg 		  	  <= `SD next_PC;  
      			inst1_is_valid 	  <= `SD inst1_is_valid_reg;
      			inst2_is_valid 	  <= `SD inst2_is_valid_reg;
				inst1_out	  	  <= `SD inst1_out_reg;
				inst2_out	 	  <= `SD inst2_out_reg;
    		end
  	end  // always

	always_comb
	begin
		if (branch_is_taken)
		begin
			next_PC 			= fu_target_pc;
			inst1_is_valid_reg  = 1'b1;
			inst2_is_valid_reg  = 1'b1;
			inst1_out_reg 		= current_inst1;
			inst2_out_reg 		= current_inst2;
		end
		else
		begin
			if (PC_stall || (!pc_enable) || (!Imem2proc_valid))
			begin
				next_PC = PC_reg; 
				inst1_is_valid_reg  = 1'b0;
				inst2_is_valid_reg  = 1'b0;
				inst1_out_reg 		= 0;
				inst2_out_reg 		= 0;
			end
			else
			begin
				next_PC = PC_reg + 8;
				inst1_is_valid_reg  = 1'b1;
				inst2_is_valid_reg  = 1'b1;
				inst1_out_reg 		= current_inst1;
				inst2_out_reg 		= current_inst2;
			end
		end
			//$display("next_PC:%h", next_PC);
			//$display("Imem2proc_data:%h", Imem2proc_data);
	end

endmodule

/* //this one is the old verson and it is wrong
module pc(
	input         			clock,                   		// system clock
	input         			reset,                   		// system reset

	input         			branch_is_taken,         		// taken-branch signal
	input  [63:0] 			fu_target_pc,            		// target pc: use if take_branch is TRUE

	input  [63:0] 			Imem2proc_data,          		// Data coming back from instruction-memory
	input			    	Imem2proc_valid,				//
	input         			rs_stall,		 				// when RS is full, we need to stop PC
	input	  				rob_stall,		 				// when RoB is full, we need to stop PC
	input					memory_structure_hazard_stall,  // If data and instruction want to use memory at the same time
	input					pc_enable,						// 	
	input					is_two_threads,					//
 
	
	output logic [63:0] 	proc2Imem_addr,    	 			// Address sent to Instruction memory
	output logic [63:0] 	next_PC_out,        	 		// PC of instruction after fetched (PC+8). for debug
	output logic [31:0] 	inst1_out,        	 			// fetched instruction out
	output logic [31:0]		inst2_out, 
	output logic        	inst1_is_valid,  		 		// when low, instruction is garbage
	output logic        	inst2_is_valid  		 		// when low, instruction is garbage
  );


	logic  [63:0] 			PC_reg;             	 		// PC we are currently fetching
	logic  [63:0]	 		next_PC;
	logic  [31:0]	 		current_inst1;
	logic  [31:0]	 		current_inst2;
		
	logic      				PC_stall;    	


	assign proc2Imem_addr = {PC_reg[63:3], 3'b0};
	assign current_inst1  = Imem2proc_data[63:32];
	assign current_inst2  = Imem2proc_data[31:0];

	assign PC_stall	      = rs_stall || rob_stall || memory_structure_hazard_stall;
	assign next_PC_out    = next_PC;

  	// next PC is target_pc if there is a taken branch or
  	// the next sequential PC (PC+8) if no branch
  	// halting is handled with the enable PC_enable;

  	// The take-branch signal must override stalling (otherwise it may be lost)


  	// Pass PC+8 down pipeline w/instruction

  	// This register holds the PC value
  	
 
  	always_ff @(posedge clock) 
	begin
			// synopsys sync_set_reset "reset"
    		if(reset)			
    		begin
	      		PC_reg 		  	  <= `SD 0;  
      			inst1_is_valid 	  <= `SD 1;
      			inst2_is_valid 	  <= `SD 1;
				inst1_out	  	  <= `SD 0;
				inst2_out	 	  <= `SD 0;
    		end
    		else
    		begin
    			if (is_two_threads)
				begin
					if(PC_stall || (pc_enable) || (!Imem2proc_valid))
					begin
						PC_reg		 	  <= `SD next_PC;
						inst1_is_valid	  <= `SD 0;
						inst2_is_valid	  <= `SD 0;
						inst1_out	 	  <= `SD 0;
						inst2_out		  <= `SD 0;
					end
					else
					begin
						PC_reg			  <= `SD next_PC;
						inst1_is_valid	  <= `SD 1;
						inst2_is_valid	  <= `SD 1;
						inst1_out		  <= `SD current_inst1;
						inst2_out		  <= `SD current_inst2;
					end
				end
				else
				begin
					if(PC_stall || (!pc_enable) || (!Imem2proc_valid))
					begin
						PC_reg		 	  <= `SD next_PC;
						inst1_is_valid	  <= `SD 0;
						inst2_is_valid	  <= `SD 0;
						inst1_out	 	  <= `SD 0;
						inst2_out		  <= `SD 0;
					end
					else
					begin
						PC_reg			  <= `SD next_PC;
						inst1_is_valid	  <= `SD 1;
						inst2_is_valid	  <= `SD 1;
						inst1_out		  <= `SD current_inst1;
						inst2_out		  <= `SD current_inst2;
					end
				end
    		end
  	end  // always

	always_comb
	begin
		if (branch_is_taken)
		begin
			next_PC = fu_target_pc;
		end
		else
		begin
			if (PC_stall || (!pc_enable) || (!Imem2proc_valid))
			begin
				next_PC = PC_reg; 
			end
			else
			begin
				next_PC = PC_reg + 8;
			end
		end
	end
endmodule*/
