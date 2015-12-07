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
	input         					clock,                   		// system clock
	input         					reset,                   		// system reset

	input         					branch_is_taken,         		// taken-branch signal
	input  [63:0] 					fu_target_pc,            		// target pc: use if take_branch is TRUE

	input  [63:0] 					Imem2proc_data,          		// Data coming back from instruction-memory
	input			    			Imem2proc_valid,				//
	input         					rs_stall,		 				// when RS is full, we need to stop PC
	input	  						rob_stall,		 				// when RoB is full, we need to stop PC
	input							rat_stall,						// when the freelist of PRF is empty, RAT generate a stall signal
	input							memory_structure_hazard_stall,  // If data and instruction want to use memory at the same time
	input							pc_enable,						// when PC_enable = 1, PC can calculate the next address.
	input	CURRENT_THREAD_STATE 	current_thread_state,
	input							is_thread1pc,
	input							is_two_threads, 
 
	output logic [63:0] 			proc2Imem_addr_mem,    	 			// Address sent to Instruction memory
	output BUS_COMMAND				proc2Icache_command,
										        	 		// PC of instruction after fetched (PC+8). for debug
	output logic [31:0] 			inst1_out,        	 			// fetched instruction out
	output logic [31:0]				inst2_out, 
	output logic        			inst1_is_valid_current,  		 		// when low, instruction is garbage
	output logic        			inst2_is_valid_current,  		 		// when low, instruction is garbage
	
	// for debug
	output logic [63:0] 			next_PC_out,
	output logic [63:0]				proc2Imem_addr_previous
  );


	logic  [63:0] 					PC_reg;             	 		// PC we are currently fetching
	logic  [63:0]	 				next_PC;
	logic  [31:0]	 				current_inst1;
	logic  [31:0]	 				current_inst2;
		
	logic      						PC_stall; 
	logic 							inst1_is_valid_reg;
	logic							inst2_is_valid_reg;
	logic 							inst1_is_valid_two;
	logic							inst2_is_valid_two;
	logic 							inst1_is_valid_one;
	logic							inst2_is_valid_one;

	logic 	[63:0]					PC_current;
	logic 	[63:0]					proc2Imem_addr;
	logic							if_address_minused;
	logic PC_change, next_PC_change;
	assign inst1_is_valid_current  = PC_stall? 0 : (~is_two_threads) ? inst1_is_valid_one : inst1_is_valid_two;
	assign inst2_is_valid_current  = PC_stall? 0 : (~is_two_threads) ? inst2_is_valid_one : inst2_is_valid_two;
	assign PC_current			   = PC_reg;


	assign proc2Imem_addr 		   = {PC_current[63:3], 3'b0};

	assign PC_stall	      		   = rs_stall || rat_stall || memory_structure_hazard_stall;	//not including rob_stall 

	// for debug
	assign next_PC_out    		   = next_PC;
	assign proc2Imem_addr_previous = (proc2Imem_addr==0)? 0 : proc2Imem_addr - 8;

	assign proc2Imem_addr_mem = PC_change ? proc2Imem_addr:0;
	assign proc2Icache_command = PC_change ?BUS_LOAD:BUS_NONE;
	
	assign next_PC_change = (!PC_stall&& !rob_stall && pc_enable && Imem2proc_valid);
	
  	// next PC is target_pc if there is a taken branch or
  	// the next sequential PC (PC+8) if no branch
  	// halting is handled with the enable PC_enable;

  	// The take-branch signal must override stalling (otherwise it may be lost)
	always_ff @(posedge clock) begin
		if(reset||branch_is_taken)
			PC_change <= `SD 1;
		else
			PC_change <= `SD next_PC_change;
	end


  	// Pass PC+8 down pipeline instruction

  	// This register holds the PC value
	
  	always_ff @(posedge clock) begin

			// synopsys sync_set_reset "reset"
    		if(reset)
    		begin
	      		PC_reg 		  	 	<= `SD 0;  
				inst1_is_valid_two	<= `SD 1'b0;
				inst2_is_valid_two	<= `SD 1'b0;
  				inst1_out	 	 	<= `SD 0;
				inst2_out	 	 	<= `SD 0;
    		end
    		else
    		begin
    			PC_reg				<= `SD next_PC;  
				inst1_is_valid_two	<= `SD inst1_is_valid_reg;
				inst2_is_valid_two	<= `SD inst2_is_valid_reg;
  				inst1_out			<= `SD current_inst1;
				inst2_out			<= `SD current_inst2;
    		end
  	end  // always


	always_ff@(posedge clock)
	begin
		if(reset)
			if_address_minused <= `SD 0;
		else if(inst1_is_valid_current || inst2_is_valid_current ||if_address_minused )	//if send success, then reset minused
		begin
			if_address_minused <= `SD 0;
		end
		else
		begin
			if( ((is_thread1pc && current_thread_state==THREAD1_IS_EX) || (~is_thread1pc && current_thread_state==THREAD2_IS_EX))&& is_two_threads )
			begin	
				if(PC_stall)
					if_address_minused <= `SD 1;
				else
					if_address_minused <= `SD 0;
			end	
		end
	end

	always_comb
	begin
		current_inst1	= Imem2proc_data[31:0];
		current_inst2	= Imem2proc_data[63:32];
		if (branch_is_taken)
		begin
			next_PC = fu_target_pc + 4;
			inst1_is_valid_one	= 1'b1;
			inst2_is_valid_one	= 1'b1;
		end
		else
		begin
			if(is_two_threads)
			begin
				if( ((is_thread1pc && current_thread_state==THREAD1_IS_EX) || (~is_thread1pc && current_thread_state==THREAD2_IS_EX)) &&(PC_stall || !Imem2proc_valid) && ~if_address_minused)
				begin
					next_PC	= PC_reg - 8; 
				end
				else if (rob_stall || (!pc_enable) )
				begin
					next_PC	= PC_reg; 
				end
				else
				begin
					next_PC = PC_reg + 8;
				end
			end
			else	// one thread				
			begin
				if (PC_stall || rob_stall || (!pc_enable) || (!Imem2proc_valid))
				begin
					next_PC			= PC_reg; 
					inst1_is_valid_one  = 1'b0;
					inst2_is_valid_one  = 1'b0;
					current_inst1 	= inst1_out;
					current_inst2 	= inst2_out;
				end
				else
				begin
					next_PC 		= PC_reg + 8;
					inst1_is_valid_one	= 1'b1;
					inst2_is_valid_one	= 1'b1;
				end
			end
		end
	end

	always_comb
	begin
		if (branch_is_taken)
		begin
			inst1_is_valid_reg		= 1'b1;
			inst2_is_valid_reg		= 1'b1;
		end
		else
		begin
			if (PC_stall||rob_stall || (!pc_enable) || (!Imem2proc_valid))
			begin
				if(rob_stall)
				begin
					inst1_is_valid_reg  = 1'b0;
					inst2_is_valid_reg  = 1'b0;
				end
				else
				begin
					inst1_is_valid_reg  = 1'b1;
					inst2_is_valid_reg  = 1'b1;
				end
			end
			else
			begin	
				inst1_is_valid_reg  = 1'b1;
				//inst2_is_valid_reg  = 1'b1;
			end
		end
	end
endmodule
