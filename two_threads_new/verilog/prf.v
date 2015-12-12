//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  prf.v                                       	        //
//                                                                      //
//   Description :                                                      //
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module prf(
	input									clock,
	input									reset,

	input									cdb1_valid,
	input	[$clog2(`PRF_SIZE)-1:0]			cdb1_tag,
	input   [63:0]							cdb1_out,
	input									cdb2_valid,
	input	[$clog2(`PRF_SIZE)-1:0]			cdb2_tag,
	input   [63:0]							cdb2_out,

	input	[$clog2(`PRF_SIZE)-1:0]			rat1_inst1_opa_prf_idx,				// opa prf index of instruction1
	input	[$clog2(`PRF_SIZE)-1:0]			rat1_inst1_opb_prf_idx,				// opb prf index of instruction1
	input	[$clog2(`PRF_SIZE)-1:0]			rat1_inst1_opc_prf_idx,				// branch prf index of instruction1
	input	[$clog2(`PRF_SIZE)-1:0]			rat1_inst2_opa_prf_idx,				// opa prf index of instruction2
	input	[$clog2(`PRF_SIZE)-1:0]			rat1_inst2_opb_prf_idx,				// opb prf index of instruction2
	input	[$clog2(`PRF_SIZE)-1:0]			rat1_inst2_opc_prf_idx,				// branch prf index of instruction2
	
	input	[$clog2(`PRF_SIZE)-1:0]			rat2_inst1_opa_prf_idx,				// opa prf index of instruction1
	input	[$clog2(`PRF_SIZE)-1:0]			rat2_inst1_opb_prf_idx,				// opb prf index of instruction1
	input	[$clog2(`PRF_SIZE)-1:0]			rat2_inst1_opc_prf_idx,				// branch prf index of instruction1
	input	[$clog2(`PRF_SIZE)-1:0]			rat2_inst2_opa_prf_idx,				// opa prf index of instruction2
	input	[$clog2(`PRF_SIZE)-1:0]			rat2_inst2_opb_prf_idx,				// opb prf index of instruction2
	input	[$clog2(`PRF_SIZE)-1:0]			rat2_inst2_opc_prf_idx,				// branch prf index of instruction2
	
	input 									rat1_read_enable,					// if rat1 read_enable=1, rat1 idx is valid, else rat2 idx is valid
 	input									is_one_thread,						// if is_one_thread =1, there is one thread running, if is_one_thread = 0, there is two thread running

	input									rat1_allocate_new_prf1,				// the request from rat1 for allocating a new prf entry
	input									rat1_allocate_new_prf2,				// the request from rat1 for allocating a new prf entry
	input									rat2_allocate_new_prf1,				// the request from rat2 for allocating a new prf entry
	input									rat2_allocate_new_prf2,				// the request from rat2 for allocating a new prf entry

	input	[`PRF_SIZE-1:0]					rrat1_prf_free_list,				// when a branch is mispredict, RRAT1 gives a freelist to PRF
	input	[`PRF_SIZE-1:0]					rrat2_prf_free_list,				// when a branch is mispredict, RRAT2 gives a freelist to PRF
	input	[`PRF_SIZE-1:0]					rat1_prf_free_list,					// when a branch is mispredict, RAT1 gives a freelist to PRF
	input	[`PRF_SIZE-1:0]					rat2_prf_free_list,					// when a branch is mispredict, RAT2 gives a freelist to PRF
	input									rrat1_branch_mistaken_free_valid,	// when a branch is mispredict, RRAT1 gives out a signal enable PRF to free its register files
	input									rrat2_branch_mistaken_free_valid,	// when a branch is mispredict, RRAT2 gives out a signal enable PRF to free its register files

	input									rrat1_prf1_free_valid,				// when an instruction retires from RRAT1, RRAT1 gives out a signal enable PRF to free its register. 
	input									rrat2_prf1_free_valid,				// when an instruction retires from RRAT2, RRAT1 gives out a signal enable PRF to free its register.
	input	[$clog2(`PRF_SIZE)-1:0] 		rrat1_prf1_free_idx,				// when an instruction retires from RRAT1, RRAT1 will free a PRF, and this is its index. 
	input	[$clog2(`PRF_SIZE)-1:0] 		rrat2_prf1_free_idx,				// when an instruction retires from RRAT2, RRAT2 will free a PRF, and this is its index.
	input									rrat1_prf2_free_valid,				// when an instruction retires from RRAT1, RRAT1 gives out a signal enable PRF to free its register. 
	input									rrat2_prf2_free_valid,				// when an instruction retires from RRAT2, RRAT1 gives out a signal enable PRF to free its register.
	input	[$clog2(`PRF_SIZE)-1:0] 		rrat1_prf2_free_idx,				// when an instruction retires from RRAT1, RRAT1 will free a PRF, and this is its index. 
	input	[$clog2(`PRF_SIZE)-1:0] 		rrat2_prf2_free_idx,				// when an instruction retires from RRAT2, RRAT2 will free a PRF, and this is its index.
	
	//for writeback
	input	[$clog2(`PRF_SIZE)-1:0]			rob1_retire_idx,					// when rob1 retires an instruction, prf gives out the corresponding value.
	input	[$clog2(`PRF_SIZE)-1:0]			rob2_retire_idx,					// when rob2 retires an instruction, prf gives out the corresponding value.
	

	
	//output
	output	logic							rat1_prf1_rename_valid_out,			// when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	output	logic							rat1_prf2_rename_valid_out,			// when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	output	logic							rat2_prf1_rename_valid_out,			// when RAT2 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	output	logic							rat2_prf2_rename_valid_out,			// when RAT2 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	output	logic [$clog2(`PRF_SIZE)-1:0]	rat1_prf1_rename_idx_out,			// when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	output	logic [$clog2(`PRF_SIZE)-1:0]	rat1_prf2_rename_idx_out,			// when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	output	logic [$clog2(`PRF_SIZE)-1:0]	rat2_prf1_rename_idx_out,			// when RAT2 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	output	logic [$clog2(`PRF_SIZE)-1:0]	rat2_prf2_rename_idx_out,			// when RAT2 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.

	output  logic	[63:0]					inst1_opa_prf_value,				// opa prf value of instruction1
	output	logic	[63:0]					inst1_opb_prf_value,				// opb prf value of instruction1
	output	logic	[63:0]					inst1_opc_prf_value,				// branch operand prf value of instruction1
	output  logic	[63:0]					inst2_opa_prf_value,				// opa prf value of instruction2
	output	logic	[63:0]					inst2_opb_prf_value,				// opb prf value of instruction2
	output	logic	[63:0]					inst2_opc_prf_value,				// branch operand prf value of instruction2
	
	output  logic							inst1_opa_valid,					// whether opa load from prf of instruction1 is valid
	output	logic							inst1_opb_valid,					// whether opb load from prf of instruction1 is valid
	output  logic                                                   inst1_opc_valid,						//whether branch load1 is valid 
	output  logic							inst2_opa_valid,					// whether opa load from prf of instruction2 is valid
	output	logic							inst2_opb_valid,					// whether opa load from prf of instruction2 is valid
	output  logic                                                   inst2_opc_valid,						//whether branch load2 is valid
	output  logic							prf_is_full,						// if the freelist of prf is empty, prf should give out this signal
	
	// for writeback
	output  logic   [63:0]					writeback_value1,					
	output  logic	[63:0]					writeback_value2,

	// for debug
	//`ifdef DEBUG_OUT
	output [`PRF_SIZE-1:0]					internal_assign_a_free_reg1,
	output [`PRF_SIZE-1:0]         			internal_prf_available,
	output [`PRF_SIZE-1:0]					internal_assign_a_free_reg2,
	output [`PRF_SIZE-1:0]					internal_prf_available2,
	output [`PRF_SIZE-1:0]					internal_free_this_entry
	//`endif		
	
);
	// internal signal for input
	
	logic	[`PRF_SIZE-1:0]					internal_free_this_entry;
	logic	[`PRF_SIZE-1:0]					internal_assign_a_free_reg1;
	logic	[`PRF_SIZE-1:0]					internal_assign_a_free_reg2;
	logic   [`PRF_SIZE-1:0][63:0]			internal_data_in;
	logic	[`PRF_SIZE-1:0]					internal_write_prf_enable;
	logic	[3:0]							allocate_new_prf;

	// internal signal for output	
	logic   [`PRF_SIZE-1:0]					internal_prf_available;
	logic   [`PRF_SIZE-1:0]					internal_prf_ready;
	logic   [`PRF_SIZE-1:0][63:0]			internal_data_out;
	logic	[`PRF_SIZE-1:0]					internal_prf_available2;

	// other registers to store value
	logic									priority_selector1_en;
	logic									priority_selector2_en;
	
	
	
	
	// when all the internal_prf_available=0, the freelist of prf is zero.
   	assign prf_is_full = (internal_prf_available == 0)? 1'b1 : 1'b0;
    
	// when RAT wants to allocate new PRF entries.
	assign allocate_new_prf = {rat1_allocate_new_prf1,rat1_allocate_new_prf2,rat2_allocate_new_prf1,rat2_allocate_new_prf2};	

	always_comb
	begin
		case(allocate_new_prf)
		4'b1000:
			begin
				priority_selector1_en      = 1'b1;
				priority_selector2_en      = 1'b0;
				rat2_prf1_rename_valid_out = 0;
				rat2_prf2_rename_valid_out = 0;
				rat1_prf2_rename_valid_out = 0;		
				rat2_prf1_rename_idx_out   = 0;
				rat2_prf2_rename_idx_out   = 0;
				rat1_prf2_rename_idx_out   = 0;

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg1[i]==1'b1)
					begin
						rat1_prf1_rename_valid_out = 1'b1;
						rat1_prf1_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat1_prf1_rename_valid_out = 1'b0;
						rat1_prf1_rename_idx_out   = 0;
					end
				end
			end
			
		4'b0100:
			begin
				priority_selector1_en      = 1'b1;
				priority_selector2_en      = 1'b0;
				rat2_prf1_rename_valid_out = 0;
				rat2_prf2_rename_valid_out = 0;
				rat1_prf1_rename_valid_out = 0;
				rat2_prf1_rename_idx_out   = 0;
				rat2_prf2_rename_idx_out   = 0;
				rat1_prf1_rename_idx_out   = 0;

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg1[i]==1'b1)
					begin
						rat1_prf2_rename_valid_out = 1'b1;
						rat1_prf2_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat1_prf2_rename_valid_out = 1'b0;
						rat1_prf2_rename_idx_out   = 0;
					end
				end
			end
		
		4'b0010:
			begin
				priority_selector1_en      = 1'b1;
				priority_selector2_en      = 1'b0;
				rat2_prf2_rename_valid_out = 0;
				rat1_prf2_rename_valid_out = 0;
				rat1_prf1_rename_valid_out = 0;
				rat2_prf2_rename_idx_out   = 0;
				rat1_prf2_rename_idx_out   = 0;
				rat1_prf1_rename_idx_out   = 0;

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg1[i]==1'b1)
					begin
						rat2_prf1_rename_valid_out = 1'b1;
						rat2_prf1_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat2_prf1_rename_valid_out = 1'b0;
						rat2_prf1_rename_idx_out   = 0;
					end
				end
			end
		4'b0001:
			begin
				priority_selector1_en      = 1'b1;
				priority_selector2_en      = 1'b0;
				rat2_prf1_rename_valid_out = 0;
				rat1_prf2_rename_valid_out = 0;
				rat1_prf1_rename_valid_out = 0;
				rat2_prf1_rename_idx_out   = 0;
				rat1_prf2_rename_idx_out   = 0;
				rat1_prf1_rename_idx_out   = 0;

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg1[i]==1'b1)
					begin
						rat2_prf2_rename_valid_out = 1'b1;
						rat2_prf2_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat2_prf2_rename_valid_out = 1'b0;
						rat2_prf2_rename_idx_out   = 0;
					end
				end
			end
		4'b1100:
			begin
				priority_selector1_en      = 1'b1;
				priority_selector2_en      = 1'b1;
				rat2_prf1_rename_valid_out = 0;
				rat2_prf2_rename_valid_out = 0;
				rat2_prf1_rename_idx_out   = 0;
				rat2_prf2_rename_idx_out   = 0;

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg1[i]==1'b1)
					begin
						rat1_prf1_rename_valid_out = 1'b1;
						rat1_prf1_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat1_prf1_rename_valid_out = 1'b0;
						rat1_prf1_rename_idx_out   = 0;
					end
				end
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg2[i]==1'b1)
					begin
						rat1_prf2_rename_valid_out = 1'b1;
						rat1_prf2_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat1_prf2_rename_valid_out = 1'b0;
						rat1_prf2_rename_idx_out   = 0;
					end
				end
			end
		
		4'b0011:
			begin
				priority_selector1_en      = 1'b1;
				priority_selector2_en      = 1'b1;

				rat1_prf1_rename_valid_out = 0;
				rat1_prf2_rename_valid_out = 0;
				rat1_prf1_rename_idx_out   = 0;
				rat1_prf2_rename_idx_out   = 0;

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg1[i]==1'b1)
					begin
						rat2_prf1_rename_valid_out = 1'b1;
						rat2_prf1_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat2_prf1_rename_valid_out = 1'b0;
						rat2_prf1_rename_idx_out   = 0;
					end
				end

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg2[i]==1'b1)
					begin
						rat2_prf2_rename_valid_out = 1'b1;
						rat2_prf2_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat2_prf2_rename_valid_out = 1'b0;
						rat2_prf2_rename_idx_out   = 0;
					end
				end
			end
		
		/*4'b1010:
			begin
				priority_selector1_en      = 1'b1;
				priority_selector2_en      = 1'b1;
				rat1_prf2_rename_valid_out = 0;
				rat2_prf2_rename_valid_out = 0;
				rat1_prf2_rename_idx_out   = 0;
				rat2_prf2_rename_idx_out   = 0;

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg1[i]==1'b1)
					begin
						rat1_prf1_rename_valid_out = 1'b1;
						rat1_prf1_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat1_prf1_rename_valid_out = 1'b0;
						rat1_prf1_rename_idx_out   = 0;
					end
				end

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if (internal_assign_a_free_reg2[i]==1'b1)
					begin
						rat2_prf1_rename_valid_out = 1'b1;
						rat2_prf1_rename_idx_out   = i;
						break;
					end
					else
					begin
						rat2_prf1_rename_valid_out = 1'b0;
						rat2_prf1_rename_idx_out   = 0;
					end
				end
			end */
		
		default:
			begin
				priority_selector1_en 	   = 1'b0;
				priority_selector2_en      = 1'b0;
				rat1_prf1_rename_valid_out = 0;
				rat1_prf2_rename_valid_out = 0;
				rat2_prf1_rename_valid_out = 0;
				rat2_prf2_rename_valid_out = 0;
				rat1_prf1_rename_idx_out   = 0;
				rat1_prf2_rename_idx_out   = 0;
				rat2_prf1_rename_idx_out   = 0;
				rat2_prf2_rename_idx_out   = 0;

			end
		endcase
	end


	prf_one_entry prf2[`PRF_SIZE-1:0](
		//input
		.clock(clock),
		.reset(reset),
		.free_this_entry(internal_free_this_entry),
    	.data_in(internal_data_in),
		.write_prf_enable(internal_write_prf_enable),
		.assign_a_free_reg(internal_assign_a_free_reg1 | internal_assign_a_free_reg2),

		//output
		.prf_available(internal_prf_available),
		.prf_ready(internal_prf_ready),
		.data_out(internal_data_out)
		    );

	//this priority selector choose a register from free lists for RAT1
	//and return the index of this newly allocated register
	priority_selector #(.WIDTH(`PRF_SIZE)) prf_psl1( 
		.req(internal_prf_available),
	    .en( priority_selector1_en),
        .gnt(internal_assign_a_free_reg1)
	);

	
	
	//#######ATTENTION########
	//internal_assign_a_free_reg1 and internal_assign_a_free_reg2 the highest bit might be X when 
	//so RAT and RRAT should not give out signals like "xxx". 
	
	//this priority selector choose a second register from free lists for RAT2
	//and return the index of this newly allocated register

	assign internal_prf_available2 = (~internal_assign_a_free_reg1)&internal_prf_available;
	
	priority_selector #(.WIDTH(`PRF_SIZE)) prf_psl2( 
		.req(internal_prf_available2),
	    .en(priority_selector2_en),
        .gnt(internal_assign_a_free_reg2)
	);


	//store the data from CDB
	always_comb
	begin
		for(int i=0;i<`PRF_SIZE;i++)
		begin
				internal_data_in[i] 	     = 0;
				internal_write_prf_enable[i] = 1'b0;

			if  ((cdb1_tag == i) && (cdb1_valid))

			begin
				internal_data_in[i] 	     = cdb1_out;
				internal_write_prf_enable[i] = 1'b1;
			end
			if 	((cdb2_tag == i) && (cdb2_valid)) 
			begin
				internal_data_in[i] 	     = cdb2_out;
				internal_write_prf_enable[i] = 1'b1;
			end

		end
	end

	//load data to the opa and opb of RS
	always_comb
	begin	
			inst1_opa_prf_value = 0;
			inst1_opb_prf_value = 0;
			inst2_opa_prf_value = 0;
			inst2_opb_prf_value = 0;
			inst1_opa_valid		= 0;
			inst1_opb_valid	    = 0;
			inst2_opa_valid		= 0;
			inst2_opb_valid		= 0;
	
			//rat1
			if (rat1_read_enable)
			begin
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat1_inst1_opa_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst1_opa_prf_value = internal_data_out[i];
						inst1_opa_valid	    = 1'b1;
						break;
					end
					else
					begin
						// if the value in prf is invalid, we need to return the index of this entry
						inst1_opa_prf_value = {58'b0,rat1_inst1_opa_prf_idx};
						inst1_opa_valid	    = 1'b0;
					end
				end

				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat1_inst1_opb_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst1_opb_prf_value = internal_data_out[i];
						inst1_opb_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst1_opb_prf_value = {58'b0,rat1_inst1_opb_prf_idx};
						inst1_opb_valid	    = 1'b0;
					end
				end
				
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat1_inst1_opc_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst1_opc_prf_value = internal_data_out[i];
						inst1_opc_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst1_opc_prf_value = {58'b0,rat1_inst1_opc_prf_idx};
						inst1_opc_valid	    = 1'b0;
					end
				end
	
	
				for(int i=0;i<`PRF_SIZE;i++)
				begin			
					if ((rat1_inst2_opa_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst2_opa_prf_value = internal_data_out[i];
						inst2_opa_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst2_opa_prf_value = {58'b0,rat1_inst2_opa_prf_idx};
						inst2_opa_valid	    = 1'b0;
					end
				end
			
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat1_inst2_opb_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst2_opb_prf_value = internal_data_out[i];
						inst2_opb_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst2_opb_prf_value = {58'b0,rat1_inst2_opb_prf_idx};
						inst2_opb_valid	    = 1'b0;
					end
				end
				
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat1_inst2_opc_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst2_opc_prf_value = internal_data_out[i];
						inst2_opc_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst2_opc_prf_value = {58'b0,rat1_inst2_opc_prf_idx};
						inst2_opc_valid	    = 1'b0;
					end
				end
			end //if

			else
			begin
			//rat2
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat2_inst1_opa_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst1_opa_prf_value = internal_data_out[i];
						inst1_opa_valid	    = 1'b1;
						break;
					end
					else
					begin
					// if the value in prf is invalid, we need to return the index of this entry
						inst1_opa_prf_value = {58'b0,rat2_inst1_opa_prf_idx};
						inst1_opa_valid	    = 1'b0;
					end
				end
			
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat2_inst1_opb_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst1_opb_prf_value = internal_data_out[i];
						inst1_opb_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst1_opb_prf_value = {58'b0,rat2_inst1_opb_prf_idx};
						inst1_opb_valid	    = 1'b0;
					end
				end
				
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat2_inst1_opc_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst1_opc_prf_value = internal_data_out[i];
						inst1_opc_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst1_opc_prf_value = {58'b0,rat2_inst1_opc_prf_idx};
						inst1_opc_valid	    = 1'b0;
					end
				end
				
		
				for(int i=0;i<`PRF_SIZE;i++)
				begin			
					if ((rat2_inst2_opa_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst2_opa_prf_value = internal_data_out[i];
						inst2_opa_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst2_opa_prf_value = {58'b0,rat2_inst2_opa_prf_idx};
						inst2_opa_valid	    = 1'b0;
					end
				end
		
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat2_inst2_opb_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst2_opb_prf_value = internal_data_out[i];
						inst2_opb_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst2_opb_prf_value = {58'b0,rat2_inst2_opb_prf_idx};
						inst2_opb_valid	    = 1'b0;
					end
				end
				
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if ((rat2_inst2_opc_prf_idx==i) && internal_prf_ready[i] && (!internal_prf_available[i]))
					begin
						inst2_opc_prf_value = internal_data_out[i];
						inst2_opc_valid	    = 1'b1;
						break;
					end
					else
					begin
						inst2_opc_prf_value = {58'b0,rat2_inst2_opc_prf_idx};
						inst2_opc_valid	    = 1'b0;
					end
				end
			end	//if
			
			// for writeback
			for(int i=0;i<`PRF_SIZE;i++)
			begin
				if ((rob1_retire_idx == i) && internal_prf_ready[i] && (!internal_prf_available[i]))
				begin
					writeback_value1 = internal_data_out[i];
					break;
				end
				else
				begin
					writeback_value1 = 0;
				end
			end
			
			for(int i=0;i<`PRF_SIZE;i++)
			begin
				if ((rob2_retire_idx == i) && internal_prf_ready[i] && (!internal_prf_available[i]))
				begin
					writeback_value2 = internal_data_out[i];
					break;
				end
				else
				begin
					writeback_value2 = 0;
				end
			end
			if ((rat1_inst1_opa_prf_idx==`PRF_SIZE)||(rat2_inst1_opa_prf_idx==`PRF_SIZE))
			begin	
				inst1_opa_prf_value = 0;
				inst1_opa_valid	    = 1'b1;
			end	

		if((rat1_inst1_opb_prf_idx==`PRF_SIZE)||(rat2_inst1_opb_prf_idx==`PRF_SIZE))
		begin
			inst1_opb_prf_value = 0;
			inst1_opb_valid	    = 1'b1;
		end
		if((rat1_inst2_opa_prf_idx==`PRF_SIZE)||(rat2_inst2_opa_prf_idx==`PRF_SIZE))
		begin
			inst2_opa_prf_value = 0;
			inst2_opa_valid	    = 1'b1;
		end
		if((rat1_inst2_opb_prf_idx==`PRF_SIZE)||(rat2_inst2_opb_prf_idx==`PRF_SIZE))
		begin
			inst2_opb_prf_value = 0;
			inst2_opb_valid	    = 1'b1;
		end	

			
		if((rat1_inst1_opc_prf_idx==`PRF_SIZE)||(rat2_inst1_opc_prf_idx==`PRF_SIZE))
		begin
			inst1_opc_prf_value = 0;
			inst1_opc_valid	    = 1'b1;
		end
		if((rat1_inst2_opc_prf_idx==`PRF_SIZE)||(rat2_inst2_opc_prf_idx==`PRF_SIZE))
		begin
			inst2_opc_prf_value = 0;
			inst2_opc_valid	    = 1'b1;
		end

	end

	//free prf	
	always_comb
	begin
		internal_free_this_entry = 0;
		//free one entry of PRF 
		//this happens when RoB retires an intruction
		//RRAT will give out the physical register index to tell which entry of PRF should be free
		for(int i=0;i<`PRF_SIZE;i++)
		begin
			if 	(((rrat1_prf1_free_idx==i)&&(rrat1_prf1_free_valid))||
				 ((rrat1_prf2_free_idx==i)&&(rrat1_prf2_free_valid))||
				 ((rrat2_prf1_free_idx==i)&&(rrat2_prf1_free_valid))||
				 ((rrat2_prf2_free_idx==i)&&(rrat2_prf2_free_valid)))
			begin
				internal_free_this_entry[i] = 1'b1;
			end
			else
			begin
				internal_free_this_entry[i] = 1'b0;
			end
		end

		//when there is a branch mispredict, 
		//we need to free all the registers that are not in the RRAT
		//because we have two RRAT updating the PRF, 
		//when RRAT1 frees the registers, we must check RAT2
		//when RRAT2 frees the registers, we must check RAT1
		if (!is_one_thread)
		begin
			if (rrat1_branch_mistaken_free_valid)
			begin
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if(rrat1_prf_free_list[i]&&rat2_prf_free_list[i])
					begin
						internal_free_this_entry[i] = 1'b1;
					end
					else
					begin
						internal_free_this_entry[i] = 1'b0;
					end
				end
			end
			if (rrat2_branch_mistaken_free_valid)
			begin
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if(rrat2_prf_free_list[i]&&rat1_prf_free_list[i])
					begin
						internal_free_this_entry[i] = 1'b1;
					end
					else
					begin
						internal_free_this_entry[i] = 1'b0;
					end
				end
			end		
		end
		else
		begin
			if(rrat1_branch_mistaken_free_valid)
			begin
				for(int i=0;i<`PRF_SIZE;i++)
				begin
					if(rrat1_prf_free_list[i])
					begin
						internal_free_this_entry[i] = 1'b1;
					end
					else
					begin
						internal_free_this_entry[i] = 1'b0;
					end
				end
			end
		end
			//$display("inst1_opa_prf_value:%h", inst1_opa_prf_value);	
			//$display("inst2_opa_prf_value:%h", inst2_opa_prf_value);	
	end
endmodule
