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
	input 				thread1_mispredict,
	input				thread2_mispredict,
	input [63:0]			thread1_target_pc,
	input [63:0]			thread2_target_pc,
	input         			rs_stall,		 				// when RS is full, we need to stop PC
	input	  			rob1_stall,		 				// when RoB1 is full, we need to stop PC1
	input				rob2_stall,
	input				rat_stall,						// when the freelist of PRF is empty, RAT generate a stall signal
	input				structure_hazard_stall,// If data and instruction want to use memory at the same time

	input				thread1_halt,
	input				thread2_halt,
//from i cache
	input [63:0]		Icache2proc_data,				// Data coming back from instruction-memory
	input			    Icache_hit,


	input				is_two_threads,		

//to i cache
	output logic [63:0]	proc2Icache_addr,					// Address sent to Instruction memory
	output BUS_COMMAND	proc2Icache_command,

	output logic [31:0] 	inst1_out,
	output logic [31:0] 	inst2_out,
	output logic	 	inst1_is_valid,
	output logic	 	inst2_is_valid,
	output logic		thread1_is_available,
	
	//for debug
	output logic [63:0]	PC_out
	
	);
	
	logic [63:0]		thread1_PC_reg;
	logic [63:0]		thread2_PC_reg;
	logic [63:0]		thread1_next_PC;
	logic [63:0]		thread2_next_PC;


	logic [63:0]		current_inst1;
	logic [63:0]		current_inst2;
	logic			pc1_stall;
	logic			pc2_stall;
	BUS_COMMAND		next_command;
	logic				reset_reg;
	logic			current_thread;
	logic			next_thread;
	logic			no_thread1;
	logic			no_thread2;
	logic			next_no_thread1;
	logic			next_no_thread2;
	logic			pc_stall;

	assign thread1_is_available = current_thread;							//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	assign PC_out =  current_thread? thread1_PC_reg : thread2_PC_reg;
	assign pc1_stall = rs_stall || rob1_stall || rat_stall || structure_hazard_stall;
	assign pc2_stall = rs_stall || rob2_stall || rat_stall || structure_hazard_stall;
	//assign pc2_stall = rs_stall || rob2_stall || rat_stall || thread2_structure_hazard_stall || (Icache2proc_response == 0) || ((Icache2proc_response != 0) && (PC2_tag != Icache2proc_response));
 
	assign proc2Icache_addr		= {PC_out[63:3],3'b0};
	assign current_inst1		= Icache2proc_data[31:0];
	assign current_inst2		= Icache2proc_data[63:32];
	assign pc_stall 		= pc1_stall || pc2_stall;
	
	always_ff @(posedge clock)
	begin
		if(reset)
		begin
			thread1_PC_reg	<=	`SD 0;
			thread2_PC_reg	<=	`SD 0;
			proc2Icache_command <= `SD BUS_NONE;
			reset_reg <= `SD 1;
			no_thread1 <= `SD 0;
			no_thread2 <= `SD 0;
			current_thread <= `SD 0;
		end
		else
		begin
			thread1_PC_reg	<=	`SD thread1_next_PC;
			thread2_PC_reg	<=	`SD thread2_next_PC;
			proc2Icache_command <= `SD next_command;
			reset_reg <= `SD 0;
			no_thread1 <= `SD next_no_thread1;
			no_thread2 <= `SD next_no_thread2;
			current_thread <= `SD next_thread;
		end
	end

	always_comb
	begin	

		if(reset_reg)						//if reset, firstly deal with thread1
		begin
			next_no_thread1=0;
			next_no_thread2=0;
		end
		else if (thread1_mispredict && thread2_mispredict)
		begin
			next_no_thread1=0;
			next_no_thread2=0;
		end
		else if(thread1_mispredict)
		begin
			next_no_thread1=0;
			next_no_thread2=no_thread2;
		end
		else if (thread2_mispredict)
		begin
			next_no_thread1=no_thread1;
			next_no_thread2=0;
		end
		else if(thread1_halt )
		begin
			next_no_thread1=1;
			next_no_thread2=no_thread2;
		end
		else if(thread2_halt)
		begin
			next_no_thread1=no_thread1;
			next_no_thread2=1;
		end
		else
		begin
			next_no_thread1=no_thread1;
			next_no_thread2=no_thread2;
		end

	end

	always_comb
	begin

			next_thread	= 0;
			next_command	= BUS_NONE;
			thread1_next_PC =0;
			thread2_next_PC =0;

			inst1_is_valid 	= 0;
			inst2_is_valid 	= 0;
			inst1_out	= 0;
			inst2_out	= 0;
			if(reset_reg)						//if reset, firstly deal with thread1
			begin
				next_thread	= 1;
				next_command	= BUS_LOAD;
				thread1_next_PC	= thread1_PC_reg;
				thread2_next_PC = thread2_PC_reg;

				inst1_is_valid 	= 0;				//the instructions are invalid
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
			end
			else if (thread1_mispredict && thread2_mispredict)
			begin
				next_thread	= 1;
				next_command	= BUS_LOAD;
				thread1_next_PC	= thread1_target_pc + 4;
				thread2_next_PC = thread2_target_pc + 4;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
			end
			else if (thread1_mispredict)					// might not be right;
			begin
				//next_thread	= 1;
				//next_command	= BUS_LOAD;
				if(Icache_hit && ~pc_stall &&current_thread)
				begin
				next_thread	= 1;
				next_command	= BUS_LOAD;
				thread1_next_PC	= thread1_target_pc + 4;
				thread2_next_PC = thread2_PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
				end
				else if(Icache_hit && ~pc_stall &&~current_thread)
				begin
				next_thread	= 1;
				next_command	= BUS_LOAD;
				thread1_next_PC	= thread1_target_pc + 4;
				thread2_next_PC = thread2_PC_reg + 8;
				inst1_is_valid 	= 1;
				inst2_is_valid 	= 1;
				inst1_out	= current_inst1;
				inst2_out	= current_inst2;
				end
				else
				begin
					if(~current_thread)
					begin
						next_thread	= current_thread;
						next_command	= BUS_NONE;
						thread1_next_PC	= thread1_target_pc + 4;
						thread2_next_PC = thread2_PC_reg;
						inst1_is_valid 	= 0;
						inst2_is_valid 	= 0;
						inst1_out	= 0;
						inst2_out	= 0;
					end
					else
					begin
						next_thread	= 1;
						next_command	= BUS_LOAD;
						thread1_next_PC	= thread1_target_pc + 4;
						thread2_next_PC = thread2_PC_reg;
						inst1_is_valid 	= 0;
						inst2_is_valid 	= 0;
						inst1_out	= 0;
						inst2_out	= 0;
					end

				end

			end
			else if (thread2_mispredict )					// might not be right;
			begin
				if(Icache_hit && ~pc_stall &&~current_thread)
				begin
				next_thread	= 0;
				next_command	= BUS_LOAD;
				thread2_next_PC	= thread2_target_pc + 4;
				thread1_next_PC = thread1_PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
				end
				else if(Icache_hit && ~pc_stall &&current_thread)
				begin
				next_thread	= 0;
				next_command	= BUS_LOAD;
				thread2_next_PC	= thread2_target_pc + 4;
				thread1_next_PC = thread1_PC_reg +8;
				inst1_is_valid 	= 1;
				inst2_is_valid 	= 1;
				inst1_out	= current_inst1;
				inst2_out	= current_inst2;
				end
				else
				begin
					if(current_thread)
					begin
						next_thread	= current_thread;
						next_command	= BUS_NONE;
						thread1_next_PC	= thread1_PC_reg;
						thread2_next_PC = thread2_target_pc + 4;
						inst1_is_valid 	= 0;
						inst2_is_valid 	= 0;
						inst1_out	= 0;
						inst2_out	= 0;
					end
					else
					begin
						next_thread	= 0;
						next_command	= BUS_LOAD;
						thread1_next_PC	= thread1_PC_reg;
						thread2_next_PC = thread2_target_pc + 4;
						inst1_is_valid 	= 0;
						inst2_is_valid 	= 0;
						inst1_out	= 0;
						inst2_out	= 0;
					end
				end
			end
			else if(Icache_hit && ~pc_stall )
			begin
				if(current_thread && no_thread2)
				begin
					next_thread	= 1;
					next_command	= BUS_LOAD;
					thread1_next_PC = thread1_PC_reg +8;
					thread2_next_PC = thread2_PC_reg;
					inst1_is_valid 	= 1;
					inst2_is_valid 	= 1;
					inst1_out	= current_inst1;
					inst2_out	= current_inst2;
					if(thread1_PC_reg[2]==1)
					begin
						thread1_next_PC = thread1_PC_reg +4;
						inst1_is_valid 	= 1;
						inst2_is_valid 	= 0;
						inst1_out	= current_inst2;
						inst2_out	= 0;						
					end
					
				end
				else if(~current_thread && no_thread1)
				begin
					next_thread	= 0;
					next_command	= BUS_LOAD;
					thread1_next_PC = thread1_PC_reg;
					thread2_next_PC = thread2_PC_reg +8;
					inst1_is_valid 	= 1;
					inst2_is_valid 	= 1;
					inst1_out	= current_inst1;
					inst2_out	= current_inst2;
					if(thread2_PC_reg[2]==1)
					begin
						thread2_next_PC = thread2_PC_reg +4;
						inst1_is_valid 	= 1;
						inst2_is_valid 	= 0;
						inst1_out	= current_inst2;
						inst2_out	= 0;						
					end
				end
				else
				begin
					if(current_thread)
					begin
					next_thread	= 0;
					next_command	= BUS_LOAD;
					thread1_next_PC = thread1_PC_reg+8;
					thread2_next_PC = thread2_PC_reg ;
					inst1_is_valid 	= 1;
					inst2_is_valid 	= 1;
					inst1_out	= current_inst1;
					inst2_out	= current_inst2;
						if(thread1_PC_reg[2]==1)
						begin
							thread1_next_PC = thread1_PC_reg +4;
							inst1_is_valid 	= 1;
							inst2_is_valid 	= 0;
							inst1_out	= current_inst2;
							inst2_out	= 0;						
						end
					end
					else //so it is thread2
					begin
					next_thread	= 1;
					next_command	= BUS_LOAD;
					thread1_next_PC = thread1_PC_reg;
					thread2_next_PC = thread2_PC_reg +8;
					inst1_is_valid 	= 1;
					inst2_is_valid 	= 1;
					inst1_out	= current_inst1;
					inst2_out	= current_inst2;
						if(thread2_PC_reg[2]==1)
						begin
							thread2_next_PC = thread2_PC_reg +4;
							inst1_is_valid 	= 1;
							inst2_is_valid 	= 0;
							inst1_out	= current_inst2;
							inst2_out	= 0;						
						end
					end
				end


				
			end
			else if(Icache_hit && pc_stall )
			begin
				next_thread	= current_thread;
				next_command	= BUS_LOAD;
				thread1_next_PC = thread1_PC_reg;
				thread2_next_PC = thread2_PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
			end
			else if(~Icache_hit && pc_stall )
			begin
				next_thread	= current_thread;
				next_command	= BUS_NONE;
				thread1_next_PC = thread1_PC_reg;
				thread2_next_PC = thread2_PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
			end
			else if(~Icache_hit && ~pc_stall )
			begin
				next_thread	= current_thread;
				next_command	= BUS_NONE;
				thread1_next_PC = thread1_PC_reg;
				thread2_next_PC = thread2_PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
			end
	end
endmodule
