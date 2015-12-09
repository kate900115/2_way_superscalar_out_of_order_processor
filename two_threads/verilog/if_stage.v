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
	input 				thread1_branch_is_taken,///////////////////////////////////////////
	input 				thread2_branch_is_taken,
	input [63:0]		thread1_target_pc,
	input [63:0]		thread2_target_pc,
	input         		rs_stall,		 				// when RS is full, we need to stop PC
	input	  			rob1_stall,		 				// when RoB1 is full, we need to stop PC1
	input				rob2_stall,						// when RoB2 is full, we need to stop PC2
	input				rat_stall,						// when the freelist of PRF is empty, RAT generate a stall signal
	input				thread1_structure_hazard_stall,	// If data and instruction want to use memory at the same time
	input				thread2_structure_hazard_stall,	// If data and instruction want to use memory at the same time
	input [63:0]		Icache2proc_data,				// Data coming back from instruction-memory
	input [3:0]		    Icache2proc_tag,
	input [3:0]		    Icache2proc_response,
	input			    Icache_hit,
	input				is_two_threads,		


	output logic [63:0]	proc2Icache_addr,					// Address sent to Instruction memory
	output BUS_COMMAND	proc2Icache_command,
	output logic [63:0] next_PC_out,
	output logic [31:0] inst1_out,
	output logic [31:0] inst2_out,
	output logic	 	inst1_is_valid,
	output logic	 	inst2_is_valid,
	output logic		thread1_is_available,
	
	//for debug
	output logic [63:0]	proc2Imem_addr_previous,
	output logic 		is_next_thread1
	);
	
	logic [63:0]		PC_reg1;
	logic [63:0]		PC_reg2;
	logic [63:0]		next_PC1;
	logic [63:0]		next_PC2;

	logic [63:0]		current_inst1, next_current_inst1;
	logic [63:0]		current_inst2, next_current_inst2;
	logic				pc1_stall;
	logic				pc2_stall;
	logic				next_t1;
	logic				thread1_is_done, next_t1_done;
	logic				thread2_is_done, next_t2_done;
	BUS_COMMAND			next_command;
	logic				start;
	logic [3:0]			PC1_tag, next_PC1_tag;
	logic [3:0]			PC2_tag, next_PC2_tag;
	
	assign pc1_stall = rs_stall || rob1_stall || rat_stall || thread1_structure_hazard_stall || (Icache2proc_response == 0) || ((Icache2proc_response != 0) && (PC1_tag != Icache2proc_response));
	assign pc2_stall = rs_stall || rob2_stall || rat_stall || thread2_structure_hazard_stall || (Icache2proc_response == 0) || ((Icache2proc_response != 0) && (PC2_tag != Icache2proc_response));
  	assign proc2Imem_addr_previous = next_PC_out - 8;
  	always_ff @ (posedge clock) begin
  		if (reset) begin
			PC_reg1					<= `SD 0;
  			PC_reg2					<= `SD 0;
			thread1_is_available	<= `SD 0;
			thread1_is_done			<= `SD 0;
			thread2_is_done			<= `SD 0;
			proc2Icache_command		<= `SD BUS_NONE;
			current_inst1			<= `SD 0;
			current_inst2			<= `SD 0;
			start					<= `SD 0;
			PC1_tag					<= `SD 0;
			PC2_tag					<= `SD 0;
		end
  		else begin
	  		PC_reg1					<= `SD next_PC1;
  			PC_reg2					<= `SD next_PC2;
			thread1_is_available	<= `SD next_t1;
			thread1_is_done			<= `SD next_t1_done;
			thread2_is_done			<= `SD next_t2_done;
			proc2Icache_command		<= `SD next_command;
			current_inst1			<= `SD next_current_inst1;
			current_inst2			<= `SD next_current_inst2;
			start					<= `SD 1;
			PC1_tag					<= `SD next_PC1_tag;
			PC2_tag					<= `SD next_PC2_tag;
		end
  	end

	always_comb begin
		inst1_out = 0;
		inst2_out = 0;
		if (thread1_is_available) begin
			if (inst1_is_valid) begin
				inst1_out = current_inst1[31:0];
			end
			if (inst2_is_valid) begin
				inst2_out = current_inst1[63:32];
			end
		end
		else begin
			if (inst1_is_valid) begin
				inst1_out = current_inst2[31:0];
			end
			if (inst2_is_valid) begin
				inst2_out = current_inst2[63:32];
			end
		end
	end
	
	always_comb begin
		next_command		= BUS_NONE;
		if (start == 0) next_command = BUS_LOAD;
		next_current_inst1	= current_inst1;
		next_current_inst2	= current_inst2;
		proc2Icache_addr	= 0;
		next_PC1			= PC_reg1;
		next_PC2			= PC_reg2;
		next_PC1_tag		= PC1_tag;
		next_PC2_tag		= PC2_tag;
		if (thread1_is_done || thread2_is_done) begin
			if (thread2_is_done) begin
				next_PC_out		= PC_reg1;
				next_t1			= 1;
				if (Icache2proc_tag != 0 && PC1_tag == Icache2proc_tag) begin
					next_current_inst1	= Icache2proc_data;
					proc2Icache_addr	= PC_reg1;
					next_command		= BUS_LOAD;
					next_PC1			= PC_reg1 + 8;
				end
				if (proc2Icache_command == BUS_LOAD)
					next_PC1_tag		= Icache2proc_response;
				/*if (Icache2proc_response == 0 && proc2Icache_command == BUS_LOAD) begin
					next_command	 	= BUS_LOAD;
					next_PC_out			= PC_reg1;
				end*/
			end
			else if (thread1_is_done) begin
				next_PC_out		= PC_reg2;
				next_t1			= 0;
				if (Icache2proc_tag != 0 && PC2_tag == Icache2proc_tag) begin
					next_current_inst2	= Icache2proc_data;
					next_command		= BUS_LOAD;
					proc2Icache_addr	= PC_reg2;
					next_PC2			= PC_reg2 + 8;
				end
				if (proc2Icache_command == BUS_LOAD)
					next_PC2_tag		= Icache2proc_response;
				/*if (Icache2proc_response == 0 && proc2Icache_command == BUS_LOAD) begin
					next_command	 	= BUS_LOAD;
					next_PC_out			= PC_reg2;
				end*/
			end
		end
		else begin
			if (thread1_is_available) begin
				next_PC_out			= PC_reg1;
				next_t1				= 1;
				if (Icache2proc_tag != 0 && PC1_tag == Icache2proc_tag) begin
					next_current_inst1	= Icache2proc_data;
					proc2Icache_addr	= PC_reg1;
					next_command		= BUS_LOAD;
					next_PC1			= PC_reg1 + 8;
					next_t1				= 0;
				end
				if (proc2Icache_command == BUS_LOAD)
					next_PC1_tag		= Icache2proc_response;
				/*if (Icache2proc_response == 0 && proc2Icache_command == BUS_LOAD) begin
					next_command	 	= BUS_LOAD;
					next_PC_out			= PC_reg1;
				end*/
			end
			else begin
				next_PC_out			= PC_reg2;
				next_t1				= 0;
				if (Icache2proc_tag != 0 && PC2_tag == Icache2proc_tag) begin
					next_current_inst2	= Icache2proc_data;
					proc2Icache_addr	= PC_reg2;
					next_command	 	= BUS_LOAD;
					next_PC2			= PC_reg2 + 8;
					next_t1				= 1;
				end
				if (proc2Icache_command == BUS_LOAD)
					next_PC2_tag		= Icache2proc_response;
				/*if (Icache2proc_response == 0 && proc2Icache_command == BUS_LOAD) begin
					next_command	 	= BUS_LOAD;
					next_PC_out			= PC_reg2;
				end*/
			end
		end
		next_t1_done = thread1_is_done;
		next_t2_done = thread2_is_done;
		/*if (thread1_is_available) begin
			if (inst1_out == 32'h555 && inst1_is_valid) begin
				next_t1_done = 1;
			end
			else if (inst2_out == 32'h555 && inst2_is_valid) begin
				next_t1_done = 1;
			end
		end
		else begin	
			if (inst1_out == 32'h555 && inst1_is_valid) begin
				next_t2_done = 1;
			end
			else if (inst2_out == 32'h555 && inst2_is_valid) begin
				next_t2_done = 1;
			end
		end*/
		if (thread1_branch_is_taken) begin
			next_PC1	= thread1_target_pc - 4;
			next_t1_done= 0;
		end
		if (thread2_branch_is_taken) begin
			next_PC2	= thread2_target_pc - 4;
			next_t2_done= 0;
		end
	end

	//inst valid 
	always_comb begin
		if (thread1_is_available) begin
			if (pc1_stall) begin
				inst1_is_valid = 0;
				inst2_is_valid = 0;
			end
			else begin
				inst1_is_valid = 1;
				inst2_is_valid = 1;
			end
		end
		else begin
			if (pc2_stall) begin
				inst1_is_valid = 0;
				inst2_is_valid = 0;
			end
			else begin
				inst1_is_valid = 1;
				inst2_is_valid = 1;
			end
		end
	end
endmodule
