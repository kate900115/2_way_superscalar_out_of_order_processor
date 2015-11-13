//`define DEBUG_OUT
module test_prf;
	logic							clock;
	logic							reset;

	logic							cdb1_valid;
	logic	[$clog2(`PRF_SIZE)-1:0]	cdb1_tag;
	logic   [63:0]					cdb1_out;
	logic							cdb2_valid;
	logic	[$clog2(`PRF_SIZE)-1:0]	cdb2_tag;
	logic   [63:0]					cdb2_out;

	logic	[$clog2(`PRF_SIZE)-1:0]	inst1_opa_prf_idx;					//opa prf index of instruction1
	logic	[$clog2(`PRF_SIZE)-1:0]	inst1_opb_prf_idx;					//opb prf index of instruction1
	logic	[$clog2(`PRF_SIZE)-1:0]	inst2_opa_prf_idx;					//opa prf index of instruction2
	logic	[$clog2(`PRF_SIZE)-1:0]	inst2_opb_prf_idx;					//opb prf index of instruction2

	logic							rat1_allocate_new_prf1;				//the request from rat1 for allocating a new prf entry
	logic							rat1_allocate_new_prf2;				//the request from rat2 for allocating a new prf entry
	logic							rat2_allocate_new_prf1;				//the request from rat1 for allocating a new prf entry
	logic							rat2_allocate_new_prf2;				//the request from rat2 for allocating a new prf entry

	logic	[`PRF_SIZE-1:0]			rrat1_prf_free_list;				//when a branch is mispredict, RRAT1 gives a freelist to PRF
	logic	[`PRF_SIZE-1:0]			rrat2_prf_free_list;				//when a branch is mispredict, RRAT2 gives a freelist to PRF
	logic	[`PRF_SIZE-1:0]			rat1_prf_free_list;					//when a branch is mispredict, RAT1 gives a freelist to PRF
	logic	[`PRF_SIZE-1:0]			rat2_prf_free_list;					//when a branch is mispredict, RAT2 gives a freelist to PRF
	logic							rrat1_branch_mistaken_free_valid;	//when a branch is mispredict, RRAT1 gives out a signal enable PRF to free its register files
	logic							rrat2_branch_mistaken_free_valid;	//when a branch is mispredict, RRAT2 gives out a signal enable PRF to free its register files
	
	logic							rrat1_prf1_free_valid;				// when an instruction retires from RRAT1, RRAT1 gives out a signal enable PRF to free its register. 
	logic							rrat2_prf1_free_valid;				// when an instruction retires from RRAT2, RRAT1 gives out a signal enable PRF to free its register.
	logic	[$clog2(`PRF_SIZE)-1:0] rrat1_prf1_free_idx;				// when an instruction retires from RRAT1, RRAT1 will free a PRF, and this is its index. 
	logic	[$clog2(`PRF_SIZE)-1:0] rrat2_prf1_free_idx;				// when an instruction retires from RRAT2, RRAT2 will free a PRF, and this is its index.
	logic							rrat1_prf2_free_valid;				// when an instruction retires from RRAT1, RRAT1 gives out a signal enable PRF to free its register. 
	logic							rrat2_prf2_free_valid;				// when an instruction retires from RRAT2, RRAT1 gives out a signal enable PRF to free its register.
	logic	[$clog2(`PRF_SIZE)-1:0] rrat1_prf2_free_idx;				// when an instruction retires from RRAT1, RRAT1 will free a PRF, and this is its index. 
	logic	[$clog2(`PRF_SIZE)-1:0] rrat2_prf2_free_idx;				// when an instruction retires from RRAT2, RRAT2 will free a PRF, and this is its index.

	logic							inst1_opa_valid;					//whether opa load from prf of instruction1 is valid
	logic							inst1_opb_valid;					//whether opb load from prf of instruction1 is valid
	logic							inst2_opa_valid;					//whether opa load from prf of instruction2 is valid
	logic							inst2_opb_valid;					//whether opa load from prf of instruction2 is valid

	logic							rat1_prf1_rename_valid_out;			//when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	logic							rat1_prf2_rename_valid_out;			//when RAT2 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	logic							rat2_prf1_rename_valid_out;			//when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	logic							rat2_prf2_rename_valid_out;			//when RAT2 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.

	logic	[$clog2(`PRF_SIZE)-1:0]	rat1_prf1_rename_idx_out;			//when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	logic	[$clog2(`PRF_SIZE)-1:0]	rat1_prf2_rename_idx_out;			//when RAT2 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	logic	[$clog2(`PRF_SIZE)-1:0]	rat2_prf1_rename_idx_out;			//when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	logic	[$clog2(`PRF_SIZE)-1:0]	rat2_prf2_rename_idx_out;			//when RAT2 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.

	logic   [63:0]					inst1_opa_prf_value;				//opa prf value of instruction1
	logic	[63:0]					inst1_opb_prf_value;				//opb prf value of instruction1
	logic   [63:0]					inst2_opa_prf_value;				//opa prf value of instruction2
	logic	[63:0]					inst2_opb_prf_value;				//opb prf value of instruction2
	logic							prf_is_full;	

	// for debug
	logic 	[`PRF_SIZE-1:0]			internal_assign_a_free_reg1;
	logic 	[`PRF_SIZE-1:0]			internal_prf_available;
	logic 	[`PRF_SIZE-1:0]			internal_assign_a_free_reg2;
	logic 	[`PRF_SIZE-1:0]			internal_prf_available2;
	logic 	[`PRF_SIZE-1:0]			internal_free_this_entry;
	
	// for writeback
	logic   [63:0]					writeback_value1;
	logic   [63:0]					writeback_value2;

	prf prf1(
		//input
		.clock(clock),
		.reset(reset),

		.cdb1_valid(cdb1_valid),
		.cdb1_tag(cdb1_tag),
		.cdb1_out(cdb1_out),
		.cdb2_valid(cdb2_valid),
		.cdb2_tag(cdb2_tag),
		.cdb2_out(cdb2_out),
		.inst1_opa_prf_idx(inst1_opa_prf_idx),				
		.inst1_opb_prf_idx(inst1_opb_prf_idx),				
		.inst2_opa_prf_idx(inst2_opa_prf_idx),				
		.inst2_opb_prf_idx(inst2_opb_prf_idx),				

		.rat1_allocate_new_prf1(rat1_allocate_new_prf1),			
		.rat1_allocate_new_prf2(rat1_allocate_new_prf2),
		.rat2_allocate_new_prf1(rat2_allocate_new_prf1),			
		.rat2_allocate_new_prf2(rat2_allocate_new_prf2),			

		.rrat1_prf_free_list(rrat1_prf_free_list),			
		.rrat2_prf_free_list(rrat2_prf_free_list),			
		.rat1_prf_free_list(rat1_prf_free_list),			
		.rat2_prf_free_list(rat2_prf_free_list),			
		.rrat1_branch_mistaken_free_valid(rrat1_branch_mistaken_free_valid),	
		.rrat2_branch_mistaken_free_valid(rrat2_branch_mistaken_free_valid),	
		
		.rrat1_prf1_free_valid(rrat1_prf1_free_valid),				
		.rrat2_prf1_free_valid(rrat2_prf1_free_valid),				
		.rrat1_prf1_free_idx(rrat1_prf1_free_idx),			
		.rrat2_prf1_free_idx(rrat2_prf1_free_idx),				
		.rrat1_prf2_free_valid(rrat1_prf2_free_valid),			
		.rrat2_prf2_free_valid(rrat2_prf2_free_valid),			
		.rrat1_prf2_free_idx(rrat1_prf2_free_idx),			
		.rrat2_prf2_free_idx(rrat2_prf2_free_idx),					
		
		//output
		.rat1_prf1_rename_valid_out(rat1_prf1_rename_valid_out),		
		.rat1_prf2_rename_valid_out(rat1_prf2_rename_valid_out),	
		.rat2_prf1_rename_valid_out(rat2_prf1_rename_valid_out),		
		.rat2_prf2_rename_valid_out(rat2_prf2_rename_valid_out),		
		.rat1_prf1_rename_idx_out(rat1_prf1_rename_idx_out),		
		.rat1_prf2_rename_idx_out(rat1_prf2_rename_idx_out),
		.rat2_prf1_rename_idx_out(rat2_prf1_rename_idx_out),		
		.rat2_prf2_rename_idx_out(rat2_prf2_rename_idx_out),

		.inst1_opa_valid(inst1_opa_valid),			
		.inst1_opb_valid(inst1_opb_valid),			
		.inst2_opa_valid(inst2_opa_valid),			
		.inst2_opb_valid(inst2_opb_valid),		

		.inst1_opa_prf_value(inst1_opa_prf_value),			
		.inst1_opb_prf_value(inst1_opb_prf_value),			
		.inst2_opa_prf_value(inst2_opa_prf_value),			
		.inst2_opb_prf_value(inst2_opb_prf_value),
		
		.prf_is_full(prf_is_full),
		
		//for writebakc
		.writeback_value1(writeback_value1),
		.writeback_value2(writeback_value2),
		
		//for debug
		.internal_assign_a_free_reg1(internal_assign_a_free_reg1),
		.internal_prf_available(internal_prf_available),
		.internal_assign_a_free_reg2(internal_assign_a_free_reg2),
		.internal_prf_available2(internal_prf_available2),	
		.internal_free_this_entry(internal_free_this_entry)	

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
		$monitor(" @@@  time:%d, clk:%b, \n\
						inst1_opa_prf_value:%h, \n\
						inst1_opb_prf_value:%h, \n\
						inst2_opa_prf_value:%h, \n\
						inst2_opb_prf_value:%h, \n\
						inst1_opa_valid:%h,\n\
						inst1_opb_valid:%h,\n\
						inst2_opa_valid:%h,\n\
						inst2_opb_valid:%h,\n\
						rat1_prf1_rename_idx_out:%b, \n\
						rat1_prf1_rename_valid_out:%b\n\
						rat1_prf2_rename_idx_out :%b,\n\
						rat1_prf2_rename_valid_out:%b\n\
						rat2_prf1_rename_idx_out:%b, \n\
						rat2_prf1_rename_valid_out:%b\n\
						rat2_prf2_rename_idx_out :%b,\n\
						rat2_prf2_rename_valid_out:%b\n\
						internal_assign_a_free_reg1=%b,\n\
						internal_prf_available=%b\n\
						internal_assign_a_free_reg2=%b\n\
						internal_prf_available2=%b\n\
						prf_is_full=%b\n\
						internal_free_this_entry=%b\n\
						writeback_value1=%h\n\
						writeback_value2=%h",
				$time, clock, 
				inst1_opa_prf_value, inst1_opb_prf_value, inst2_opa_prf_value,inst2_opb_prf_value,
				inst1_opa_valid,     inst1_opb_valid,     inst2_opa_valid,    inst2_opb_valid,
				rat1_prf1_rename_idx_out, rat1_prf1_rename_valid_out, rat1_prf2_rename_idx_out,rat1_prf2_rename_valid_out,
				rat2_prf1_rename_idx_out, rat2_prf1_rename_valid_out, rat2_prf2_rename_idx_out,rat2_prf2_rename_valid_out,
				internal_assign_a_free_reg1, internal_prf_available, internal_assign_a_free_reg2, internal_prf_available2, prf_is_full,
				internal_free_this_entry, writeback_value1, writeback_value2);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");
		reset = 0;
		

		//A new request from RAT1 to allocate a new PRF 
		//and return the index of this PRF entry.
		$display("@@@ RAT1 allocate prf1 and RAT2 allocate prf2!!");
		reset = 0;	
		cdb1_valid			 			= 0;
		cdb1_tag			 			= 0;
		cdb1_out			 			= 0;
		cdb2_valid			 			= 0;
		cdb2_tag			 			= 0;
		cdb2_out			 			= 0;
		inst1_opa_prf_idx				= 0;				
		inst1_opb_prf_idx				= 0;				
		inst2_opa_prf_idx				= 0;			
		inst2_opb_prf_idx				= 0;				
		rat1_allocate_new_prf1			= 1;			
		rat1_allocate_new_prf2  		= 0;
		rat2_allocate_new_prf1  		= 1;			
		rat2_allocate_new_prf2		 	= 0;			
		rrat1_prf_free_list		 		= 0;			
		rrat2_prf_free_list		 		= 0;			
		rat1_prf_free_list		 		= 0;			
		rat2_prf_free_list		 		= 0;
		rrat1_branch_mistaken_free_valid= 0;	
		rrat2_branch_mistaken_free_valid= 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;		

		@(posedge clock);
		$display("@@@ RAT1 and RAT2 stop sending allocate_a_new_register_signal!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		
		@(negedge clock);
		$display("@@@ RAT1 allocate two new registers!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 1;			
		rat1_allocate_new_prf2		 = 1;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;		
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;


		@(posedge clock);
		$display("@@@ RAT1 stop sending allocate_new_register_signal!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 1;			
		rat2_allocate_new_prf2		 = 1;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		
		@(negedge clock);  
		$display("@@@ RAT2 allocate two new registers!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 1;			
		rat2_allocate_new_prf2		 = 1;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;

		@(posedge clock);
		$display("@@@ RAT2 stop sending allocate_a_new_register_signal!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;				
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;

		@(negedge clock);  
		$display("@@@ RAT1 and RAT2 allocate new registers!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 1;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 1;			
		rat2_allocate_new_prf2		 = 0;
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;


		@(posedge clock);
		$display("@@@ RAT2 stop sending allocate_a_new_register_signal!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;	
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		//at this time, we allocate 3 PRF entries (101111,101110,101101)
		//after this, we want to store data from CDB.
		//from CDB2, we store 5 into #reg 101111.
			
		@(negedge clock);
		$display("@@@ Store data from CDB2!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 1;
		cdb2_tag			 = 6'b101111;
		cdb2_out			 = 5;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;		
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;  
		@(negedge clock); 
		//then we want to load data from #reg 101110;
		$display("@@@ Load data from reg#101111!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 6'b101111;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;		
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		
		@(negedge clock);
		$display("@@@ Doing nothing at all!!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;	

		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	

		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);
		@(negedge clock);

		@(negedge clock);
		$display("@@@ RAT1 and RAT2 allocate new registers\n@@@ at the same time!!!");  
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 1;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 1;			
		rat2_allocate_new_prf2		 = 0;
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;

		@(negedge clock);
		$display("@@@ Load data from a wrong register which is not allocated!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 6'b000011;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;	
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;	


		@(negedge clock);

		$display("@@@ Store data from CDB1!!");
		cdb1_valid			 = 1;
		cdb1_tag			 = 6'b101101;
		cdb1_out			 = 9;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;		
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;

		@(negedge clock); 
		//then we want to load data from #reg 101110;
		$display("@@@ Load data from reg#101101!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 6'b101101;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;	
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		
		@(negedge clock);
		$display("@@@ RRAT wants to free reg#101101!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;	
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;		
		rrat1_prf1_free_valid 			= 1;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 6'b101101;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;	
		
		@(negedge clock);
		$display("@@@ RAT1 and RAT2 want to allocate new entries!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 1;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 1;			
		rat2_allocate_new_prf2		 = 0;	
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;

		@(negedge clock);
		$display("@@@ Store data from CDB2!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 1;
		cdb2_tag			 = 6'b101010;
		cdb2_out			 = 17;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;

		@(negedge clock);
		$display("@@@ RRAT1 send the freelist in");
		$display("@@@ RRAT1 because of the freelist!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;		
		rrat1_prf_free_list		 = 48'b001100100000000000000000000000000000000000000000;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 48'b011101000000000000000111100000001111000000010111;
		rrat1_branch_mistaken_free_valid = 1;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;		
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;

		@(negedge clock);
		$display("@@@ RRAT1 send the freelist in");
		$display("@@@ RRAT1 because of the freelist!!");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;		
		rrat1_prf_free_list		 = 48'b001100100000000000000000000000000000000000000000;			
		rrat2_prf_free_list		 = 48'b000000100000000000000000000000000000000000000000;			
		rat1_prf_free_list		 = 48'b010101100000000000000111100000001111000000010111;			
		rat2_prf_free_list		 = 48'b000101100000000000000111100000001111000000010111;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 1;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		
		@(negedge clock);
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;


		@(negedge clock);
		$display("@@@ this time we want to (1)free one entry");
		$display("@@@ (2)store a value from CDB (3)load inst1 opb");
		cdb1_valid			 = 1;
		cdb1_tag			 = 6'b101110;
		cdb1_out			 = 19;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 6'b101111;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;		
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 1;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 6'b101011;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);

		$display("@@@ this time we want to (1)allocate a new entry");
		$display("@@@ (2)load value from Reg#6'b101110");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 6'b101110;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 1;			
		rat2_allocate_new_prf2		 = 1;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);


		$display("@@@ store a value to a register which is not allocated");
		cdb1_valid			 = 1;
		cdb1_tag			 = 6'b000001;
		cdb1_out			 = 11;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 0;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);
		$display("@@@ load value from this wrong register");
		cdb1_valid			 = 0;
		cdb1_tag			 = 0;
		cdb1_out			 = 0;
		cdb2_valid			 = 0;
		cdb2_tag			 = 0;
		cdb2_out			 = 0;
		inst1_opa_prf_idx		 = 6'b000001;				
		inst1_opb_prf_idx		 = 0;				
		inst2_opa_prf_idx		 = 0;			
		inst2_opb_prf_idx		 = 0;				
		rat1_allocate_new_prf1		 = 0;			
		rat1_allocate_new_prf2		 = 0;
		rat2_allocate_new_prf1		 = 0;			
		rat2_allocate_new_prf2		 = 0;			
		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	
		rrat1_prf1_free_valid 			= 0;				
		rrat2_prf1_free_valid 			= 0;				
		rrat1_prf1_free_idx				= 0;			
		rrat2_prf1_free_idx				= 0;				
		rrat1_prf2_free_valid			= 0;		
		rrat2_prf2_free_valid			= 0;			
		rrat1_prf2_free_idx				= 0;			
		rrat2_prf2_free_idx				= 0;
		@(negedge clock);
		$finish;

	end


endmodule
