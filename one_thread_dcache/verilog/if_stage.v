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
	input 				mispredict,
	input [63:0]			target_pc,
	input         			rs_stall,		 				// when RS is full, we need to stop PC
	input	  			rob1_stall,		 				// when RoB1 is full, we need to stop PC1
	input				rat_stall,						// when the freelist of PRF is empty, RAT generate a stall signal
	input				structure_hazard_stall,// If data and instruction want to use memory at the same time
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
	output 			thread1_is_available,
	
	//for debug
	output logic [63:0]	PC_out
	
	);
	
	logic [63:0]		PC_reg;
	logic [63:0]		next_PC;


	logic [63:0]		current_inst1;
	logic [63:0]		current_inst2;
	logic			pc_stall;
	BUS_COMMAND		next_command;
	logic				reset_reg;

	assign thread1_is_available = ~is_two_threads;
	assign PC_out =  PC_reg;
	assign pc_stall = rs_stall || rob1_stall || rat_stall || structure_hazard_stall;
	//assign pc2_stall = rs_stall || rob2_stall || rat_stall || thread2_structure_hazard_stall || (Icache2proc_response == 0) || ((Icache2proc_response != 0) && (PC2_tag != Icache2proc_response));
 
	assign proc2Icache_addr		= {PC_reg[63:3],3'b0};
	assign current_inst1		= Icache2proc_data[31:0];
	assign current_inst2		= Icache2proc_data[63:32];
	
	always_ff @(posedge clock)
	begin
		if(reset)
		begin
			PC_reg	<=	`SD 0;
			proc2Icache_command <= `SD BUS_NONE;
			reset_reg <= `SD 1;
		end
		else
		begin
			proc2Icache_command <= `SD next_command;
			PC_reg		    <= `SD next_PC;
			reset_reg <= `SD 0;
		end
	end

	always_comb
	begin
			next_command	= BUS_NONE;
			next_PC		= PC_reg;
			inst1_is_valid 	= 0;
			inst2_is_valid 	= 0;
			inst1_out	= 0;
			inst2_out	= 0;
			if (mispredict)					// might not be right;
			begin
				next_PC		= target_pc +4 ;
				next_command	= BUS_LOAD;
				inst1_is_valid 	= 0;
				inst1_is_valid 	= 0;
				if(target_pc[3]==1)
				begin
				inst1_out	= 0;
				inst2_out	= current_inst2;
				end
				else
				begin
				inst1_out	= current_inst1;
				inst2_out	= current_inst2;
				end
			end
			else if(reset_reg)
			begin
				next_command	= BUS_LOAD;
				next_PC		= PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= current_inst1;
				inst2_out	= current_inst2;
			end
			else if(Icache_hit && ~pc_stall )
			begin
				next_command	= BUS_LOAD;
				next_PC		= PC_reg+8;
				inst1_is_valid 	= 1;
				inst2_is_valid 	= 1;
				inst1_out	= current_inst1;
				inst2_out	= current_inst2;
			end
			else if(Icache_hit && pc_stall )
			begin
				next_command	= BUS_LOAD;
				next_PC		= PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
			end
			else if(~Icache_hit && pc_stall )
			begin
				next_command	= BUS_NONE;
				next_PC		= PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
			end
			else if(~Icache_hit && ~pc_stall )
			begin
				next_command	= BUS_NONE;
				next_PC		= PC_reg;
				inst1_is_valid 	= 0;
				inst2_is_valid 	= 0;
				inst1_out	= 0;
				inst2_out	= 0;
			end
	end









  	
endmodule
