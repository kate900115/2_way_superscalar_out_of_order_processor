module test_prf;
	logic				clock;
	logic				reset;

	logic				cdb1_valid;
	logic	[$clog2(`PRF_SIZE)-1:0]	cdb1_tag;
	logic   [63:0]			cdb1_out;
	logic				cdb2_valid;
	logic	[$clog2(`PRF_SIZE)-1:0]	cdb2_tag;
	logic   [63:0]			cdb2_out;

	logic	[$clog2(`PRF_SIZE)-1:0]	inst1_opa_prf_idx;			//opa prf index of instruction1
	logic	[$clog2(`PRF_SIZE)-1:0]	inst1_opb_prf_idx;			//opb prf index of instruction1
	logic	[$clog2(`PRF_SIZE)-1:0]	inst2_opa_prf_idx;			//opa prf index of instruction2
	logic	[$clog2(`PRF_SIZE)-1:0]	inst2_opb_prf_idx;			//opb prf index of instruction2

	logic				rat1_allocate_new_prf;			//the request from rat1 for allocating a new prf entry
	logic				rat2_allocate_new_prf;			//the request from rat2 for allocating a new prf entry

	logic	[`PRF_SIZE-1:0]		rrat1_prf_free_list;			//when a branch is mispredict, RRAT1 gives a freelist to PRF
	logic	[`PRF_SIZE-1:0]		rrat2_prf_free_list;			//when a branch is mispredict, RRAT2 gives a freelist to PRF
	logic	[`PRF_SIZE-1:0]		rat1_prf_free_list;			//when a branch is mispredict, RAT1 gives a freelist to PRF
	logic	[`PRF_SIZE-1:0]		rat2_prf_free_list;			//when a branch is mispredict, RAT2 gives a freelist to PRF
	logic				rrat1_branch_mistaken_free_valid;	//when a branch is mispredict, RRAT1 gives out a signal enable PRF to free its register files
	logic				rrat2_branch_mistaken_free_valid;	//when a branch is mispredict, RRAT2 gives out a signal enable PRF to free its register files

	logic				rrat1_prf_free_valid;			//when an instruction retires from RRAT1, RRAT1 gives out a signal enable PRF to free its register. 
	logic				rrat2_prf_free_valid;			//when an instruction retires from RRAT2, RRAT1 gives out a signal enable PRF to free its register.
	logic	[$clog2(`PRF_SIZE)-1:0] rrat1_prf_free_idx;			//when an instruction retires from RRAT1, RRAT1 will free a PRF, and this is its index. 
	logic	[$clog2(`PRF_SIZE)-1:0] rrat2_prf_free_idx;			//when an instruction retires from RRAT2, RRAT2 will free a PRF, and this is its index.

	logic				inst1_opa_valid;			//whether opa load from prf of instruction1 is valid
	logic				inst1_opb_valid;			//whether opb load from prf of instruction1 is valid
	logic				inst2_opa_valid;			//whether opa load from prf of instruction2 is valid
	logic				inst2_opb_valid;

	logic				rat1_prf_rename_valid_out;		//when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	logic				rat2_prf_rename_valid_out;		//when RAT2 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	logic	[$clog2(`PRF_SIZE)-1:0]	rat1_prf_rename_idx_out;		//when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	logic	[$clog2(`PRF_SIZE)-1:0]	rat2_prf_rename_idx_out;		//when RAT2 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.

	logic   [63:0]			inst1_opa_prf_value;			//opa prf value of instruction1
	logic	[63:0]			inst1_opb_prf_value;			//opb prf value of instruction1
	logic   [63:0]			inst2_opa_prf_value;			//opa prf value of instruction2
	logic	[63:0]			inst2_opb_prf_value;			//opb prf value of instruction2


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

		.rat1_allocate_new_prf(rat1_allocate_new_prf),			
		.rat2_allocate_new_prf(rat2_allocate_new_prf),			

		.rrat1_prf_free_list(rrat1_prf_free_list),			
		.rrat2_prf_free_list(rrat2_prf_free_list),			
		.rat1_prf_free_list(rat1_prf_free_list),			
		.rat2_prf_free_list(rat2_prf_free_list),			
		.rrat1_branch_mistaken_free_valid(rrat1_branch_mistaken_free_valid),	
		.rrat2_branch_mistaken_free_valid(rrat2_branch_mistaken_free_valid),	

		.rrat1_prf_free_valid(rrat1_prf_free_valid),		
		.rrat2_prf_free_valid(rrat2_prf_free_valid),		
		.rrat1_prf_free_idx(rrat1_prf_free_idx),			
		.rrat2_prf_free_idx(rrat2_prf_free_idx),			
		
		//output
		.rat1_prf_rename_valid_out(rat1_prf_rename_valid_out),		
		.rat2_prf_rename_valid_out(rat2_prf_rename_valid_out),		
		.rat1_prf_rename_idx_out(rat1_prf_rename_idx_out),		
		.rat2_prf_rename_idx_out(rat2_prf_rename_idx_out),

		.inst1_opa_valid(inst1_opa_valid),			
		.inst1_opb_valid(inst1_opb_valid),			
		.inst2_opa_valid(inst2_opa_valid),			
		.inst2_opb_valid(inst2_opb_valid),		

		.inst1_opa_prf_value(inst1_opa_prf_value),			
		.inst1_opb_prf_value(inst1_opb_prf_value),			
		.inst2_opa_prf_value(inst2_opa_prf_value),			
		.inst2_opb_prf_value(inst2_opb_prf_value)			

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
		$monitor("time:%d, clk:%b, inst1_opa_prf_value:%h, inst1_opb_prf_value:%h, inst2_opa_prf_value:%h, inst2_opb_prf_value:%h,\n\
					   rat1_prf_rename_idx_out:%b, rat1_prf_rename_valid_out:%b,rat2_prf_rename_idx_out :%b, rat2_prf_rename_valid_out:%b",
				$time, clock, inst1_opa_prf_value, inst1_opb_prf_value, inst2_opa_prf_value, inst2_opb_prf_value,  
					      rat1_prf_rename_idx_out, rat1_prf_rename_valid_out, rat2_prf_rename_idx_out, rat2_prf_rename_valid_out);

	


		clock = 0;
		//RESET
		reset = 1;
		#5;
		@(negedge clock);
		reset = 0;		

		//A new request from RAT1 to allocate a new PRF 
		//and return the index of this PRF entry.
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
		rat1_allocate_new_prf		 = 1;			
		rat2_allocate_new_prf		 = 0;			

		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	

		rrat1_prf_free_valid		 = 0;	
		rrat2_prf_free_valid		 = 0;	
		rrat1_prf_free_idx		 = 0;
		rrat2_prf_free_idx		 = 0;
		
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
		rat1_allocate_new_prf		 = 0;			
		rat2_allocate_new_prf		 = 0;			

		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	

		rrat1_prf_free_valid		 = 0;	
		rrat2_prf_free_valid		 = 0;	
		rrat1_prf_free_idx		 = 0;
		rrat2_prf_free_idx		 = 0;
		
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
		rat1_allocate_new_prf		 = 1;			
		rat2_allocate_new_prf		 = 0;			

		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	

		rrat1_prf_free_valid		 = 0;	
		rrat2_prf_free_valid		 = 0;	
		rrat1_prf_free_idx		 = 0;
		rrat2_prf_free_idx		 = 0;
		
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
		rat1_allocate_new_prf		 = 0;			
		rat2_allocate_new_prf		 = 0;			

		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	

		rrat1_prf_free_valid		 = 0;	
		rrat2_prf_free_valid		 = 0;	
		rrat1_prf_free_idx		 = 0;
		rrat2_prf_free_idx		 = 0;
		
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
		rat1_allocate_new_prf		 = 1;			
		rat2_allocate_new_prf		 = 0;			

		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	

		rrat1_prf_free_valid		 = 0;	
		rrat2_prf_free_valid		 = 0;	
		rrat1_prf_free_idx		 = 0;
		rrat2_prf_free_idx		 = 0;
		

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
		rat1_allocate_new_prf		 = 0;			
		rat2_allocate_new_prf		 = 0;			

		rrat1_prf_free_list		 = 0;			
		rrat2_prf_free_list		 = 0;			
		rat1_prf_free_list		 = 0;			
		rat2_prf_free_list		 = 0;
		rrat1_branch_mistaken_free_valid = 0;	
		rrat2_branch_mistaken_free_valid = 0;	

		rrat1_prf_free_valid		 = 0;	
		rrat2_prf_free_valid		 = 0;	
		rrat1_prf_free_idx		 = 0;
		rrat2_prf_free_idx		 = 0;
		@(negedge clock);
		$finish;





















	end




















endmodule
