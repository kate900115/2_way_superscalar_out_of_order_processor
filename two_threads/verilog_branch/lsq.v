
//////////////////////////////////
//								//
//		  LSQ					//
//								//
//////////////////////////////////

//lsq works as a rs for the ldq/stq
//need to communicate with rob when it hits the head of the rob
//dispatch at the same time
//load queue works like a buffer and store queue works in order
`timescale 1ns/100ps

//QES: 1 which kind of instruction is comming to lsq: load/store
//QES: 5 when to update/ broadcast
//QES: 8 mispredict?
//clear all entries younger than the rob_commit_age in sq/lq
//QES: 9 what happens when sq enters/leaves
//sq enters: 1. compares and update lq dependency, 2. check violated lq 3. forward to lq and broadcast to rob 
//sq leaves: 1. commit to L1cache/prf? 2. update head and tial
//QES: 10 what happenes when lq enters/leaves

//lq leaves: 1.nothing leaves when corresponding rob_idx commit
//Is there any chance that opb has value when entering lsq

/*ldq:
 	ldq	$r3,0($r1)
          opa_select = ALU_OPA_IS_MEM_DISP;
          		opa_mux_out1 = mem_disp1;
				opa_mux_tag1 = `TRUE;
          opb_select = ALU_OPB_IS_REGB;
          		opb_mux_out1 = {{59{1'b0}},rb_idx1};
				opb_mux_tag1 = `FALSE; true means value,faulse means tag
          rd_mem = `TRUE;
          dest_reg = DEST_IS_REGA;
          		id_dest_reg_idx_out1 = ra_idx1;
          		
stq:
	stq     $r3,0x100($r1)
          opa_select = ALU_OPA_IS_MEM_DISP;
          opb_select = ALU_OPB_IS_REGB;
          wr_mem = `TRUE;
          dest_reg = DEST_NONE;
*/

module lsq(

	input	clock,
	input	reset,
	//sequential???? comb????
	input	id_rd_mem_in1,
	input	id_rd_mem_in2,    //ldq
	input	id_wr_mem_in1,
	input	id_wr_mem_in2,		//stq
	
	input  [63:0]								lsq_cdb1_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  			lsq_cdb1_tag,    		// CDB tag bus from functional units 
	input										lsq_cdb1_valid,  		// The data on the CDB is valid 
	input  [63:0]								lsq_cdb2_in,     		// CDB bus from functional units 
	input  [$clog2(`PRF_SIZE)-1:0]  			lsq_cdb2_tag,    		// CDB tag bus from functional units 
	input										lsq_cdb2_valid,  		// The data on the CDB is valid 
	
        //for instruction1
	input  [63:0] 								lsq_opa_in1,      	// Operand a from Rename  data
	input  [63:0] 								lsq_opb_in1,      	// Operand a from Rename  tag or data from prf
	input         								lsq_opb_valid1,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [$clog2(`ROB_SIZE):0]				lsq_rob_idx_in1,  	// The rob index of instruction 1
	input  [63:0]								lsq_ra_data1,	//comes from prf according to idx request, 0 if load
	input										lsq_ra_data_valid1, //weather data comes form prf is valid, if not, get from cdb
        
        //for instruction2
	input  [63:0] 								lsq_opa_in2,      	// Operand a from Rename  data
	input  [63:0] 								lsq_opb_in2,     	// Operand b from Rename  tag or data from prf
	input         								lsq_opb_valid2,   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	input  [$clog2(`ROB_SIZE)-1:0]				lsq_rob_idx_in2,  	// The rob index of instruction 2
	input  [63:0]								lsq_ra_data2, 	//comes from prf according to idx request, 0 if load
	input										lsq_ra_data_valid2,	//weather data comes form prf is valid, if not, get from cdb

	input	[4:0]								dest_reg_idx1, //`none_reg if store
	input	[4:0]								dest_reg_idx2,

	input	[63:0]						instr_load_from_mem1,	//when no forwarding possible, load from memory
	input								instr_load_mem_in_valid1,
	input	[4:0]						mem_load_tag_in,
	
	//we need rob age for store to commit
	input	[$clog2(`ROB_SIZE)-1:0]		rob_commit_idx1,
	input	[$clog2(`ROB_SIZE)-1:0]		rob_commit_idx2,

	//we need to know weather the instruction commited is a mispredict
	input	thread1_mispredict,
	input	thread2_mispredict,

	//load instruction is output when corresponding dest_tag get value from store_in
	//output to prf -- prf_tag		
	//store instructions are output when instruction retires and store write to memory
	//output to prf -- L1 cache (prf48)

	output logic [$clog2(`PRF_SIZE)-1:0]	lsq_CDB_dest_tag1;
	output logic [63:0]						lsq_CDB_result_out1;
	output logic 							lsq_CDB_result_is_valid1;

	output logic [$clog2(`PRF_SIZE)-1:0]	lsq_CDB_dest_tag2;
	output logic [63:0]						lsq_CDB_result_out2;
	output logic 							lsq_CDB_result_is_valid2;

	//sedn idx to prf to get value
	output	logic [$clog2(`PRF_SIZE)-1:0]	lsq_opb_idx1;
	output	logic							lsq_opb_request1;
	output	logic [$clog2(`PRF_SIZE)-1:0]	lsq_opb_idx2;
	output	logic							lsq_opb_request2;
	output	logic [$clog2(`PRF_SIZE)-1:0]	lsq_ra_dest_idx1;
	output	logic							lsq_ra_request1;	//request = 0 if load
	output	logic [$clog2(`PRF_SIZE)-1:0]	lsq_ra_dest_idx1;
	output	logic							lsq_ra_request1;


	//if sq has storeA @pc=0x100 if loadA @pc=0x120 will load from the sq
	//but later a storeA @pc=0x110 happens, we need to violate the forwarded data from rob
	//or the lsq is filled inorder, which means when store A @pc=0x110 mast happen before loadA @pc=0x120?
	//but lq/sq is independent...
	
	output	logic	[63:0]						instr_store_to_mem1,
	output	logic								instr_store_to_mem_valid1,
	output	logic	[4:0]						mem_store_idx,
	output	logic	[15:0]						load_from_mem_idx,//fifo
	output	logic								request_from_mem,
	output	logic	[4:0]						mem_load_tag_out,

	output	logic								rob1_excuted,
	output	logic								rob2_excuted
	
	//when new store came in and find a instr following him in program order has been excuted, the LSQ must report a violation
	//Here we only forward the independent loads!!!!!
	)
	
	//LQ
	//the relative ages of two instructions can be determined by examing the physical locations they occupied in LSQ
	//for example, instruction at slot 5 is older than instruction at slot 8
	//lq_reg stores address
	logic	[`LQ_SIZE-1:0][63:0]	lq_reg_addr, n_lq_reg_addr;
	//logic	[`LQ_SIZE-1:0][63:0]	lq_reg_data, n_lq_reg_data;
	logic	[`LQ_SIZE-1:0][$clog2(`ROB_SIZE)-1:0] lq_rob_idx, n_lq_rob_idx;
	logic	[`LQ_SIZE-1:0][63:0]	lq_reg_opa, n_lq_reg_opa;
	logic	[`LQ_SIZE-1:0][63:0]	lq_reg_opb, n_lq_reg_opb;
	logic	[`LQ_SIZE-1:0][4:0]		lq_reg_dest_tag, n_lq_reg_dest_tag;
	logic	[`LQ_SIZE-1:0]			lq_reg_addr_valid, n_lq_reg_addr_valid;
	logic	[`LQ_SIZE-1:0]			lq_reg_inst_valid, n_lq_reg_inst_valid;
	//logic							lq_reg_data_valid, n_lq_reg_data_valid;

	//SQ
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_addr, n_sq_reg_addr;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_data, n_sq_reg_data;
	logic	[`SQ_SIZE-1:0][$clog2(`ROB_SIZE)-1:0] sq_rob_idx, n_sq_rob_idx;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_opa, n_sq_reg_opa;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_opb, n_sq_reg_opb;
	logic	[`SQ_SIZE-1:0]			sq_reg_addr_valid, n_sq_reg_addr_valid;
	logic	[`SQ_SIZE-1:0]			sq_reg_inst_valid, n_sq_reg_inst_valid;

	logic	[`LQ_SIZE-1:0] [`SQ_SIZE-1:0] LSQ_DEP_CODE		lsq_reg_dep;

	logic 	[$clog2(`SQ_SIZE)-1:0]					sq_head, n_sq_head;
	logic	[$clog2(`SQ_SIZE)-1:0]					sq_tail, n_sq_tail;
	logic	[$clog2(`SQ_SIZE)-1:0]					ld_idx1, ld_idx2;
	logic	[$clog2(`SQ_SIZE)-1:0]					st_idx1, st_idx2;
	logic	[$clog2(`SQ_SIZE)-1:0]					ld_out_idx1, ld_out_idx2;
	logic											ld_in1, ld_in2;
	logic											st_in1, st_in2;
	logic											st_out1, st_out2;
	logic	[$clog2(`SQ_SIZE)-1:0]					round_j;
	logic	[$clog2(`SQ_SIZE)-1:0]					ysq_than_lq1, ysq_than_lq2;
	logic											sq_reg_data_valid, n_sq_reg_data_valid;
	
	//for cdb
	logic	[63:0]		lsq_ra_new1;
	logic	[63:0]		lsq_ra_new2;
	logic	[63:0]		lsq_opb_new1;
	logic	[63:0]		lsq_opb_new2;		
	logic				lsq_ra_new_valid1;
	logic				lsq_ra_new_valid2;		
	logic				lsq_opb_new_valid1;
	logic				lsq_opb_new_valid2;

	//for load from mem
	logic 				mem_res;
	logic	[`LQ_SIZE-1:0][4:0] wait_idx;
	logic	[4:0]		wait_int;
	
	always_ff(@posedge clock) begin
		if(reset) begin

			lq_reg_addr 		<= #1 0;
			lq_rob_idx 			<= #1 0;
			lq_reg_opa 			<= #1 0;
			lq_reg_opb 			<= #1 0;
			//lq_reg_data 		<= #1 0;
			lq_reg_dest_tag 	<= #1 0;
			lq_reg_addr_valid 	<= #1 0;
			lq_reg_inst_valid 	<= #1 0;
			//lq_reg_data_valid	<= #1 0;


			sq_head 			<= #1 0;
			sq_tail 			<= #1 0;
			sq_reg_addr 		<= #1 0;
			sq_rob_idx 			<= #1 0;
			sq_reg_opa 			<= #1 0;
			sq_reg_opb 			<= #1 0;
			sq_reg_data 		<= #1 0;
			sq_reg_addr_valid 	<= #1 0;
			sq_reg_inst_valid 	<= #1 0;
			sq_reg_data_valid	<= #1 0;
			
			wait_int			<= #1 0;
			wait_idx 			<= #1 0;

	end
		else begin

			lq_reg_addr 		<= #1 n_lq_reg_addr;
			lq_rob_idx 			<= #1 n_lq_rob_idx;
			lq_reg_opa 			<= #1 n_lq_reg_opa;
			lq_reg_opb 			<= #1 n_lq_reg_opb;
			//lq_reg_data 		<= #1 n_lq_reg_data;
			lq_reg_inst_valid 	<= #1 n_lq_reg_inst_valid;
			lq_reg_addr_valid 	<= #1 n_lq_reg_addr_valid;
			lq_reg_dest_tag		<= #1 n_lq_reg_dest_tag;
			//lq_reg_data_valid	<= #1 n_lq_reg_data_valid;

			sq_head 			<= #1 n_sq_head;
			sq_tail 			<= #1 n_sq_tail;
			sq_reg_addr 		<= #1 n_sq_reg_addr;
			sq_reg_data 		<= #1 n_sq_reg_data;
			sq_rob_idx 			<= #1 n_sq_rob_idx;
			sq_reg_opa 			<= #1 n_sq_reg_opa;
			sq_reg_opb 			<= #1 n_sq_reg_opb;
			sq_reg_inst_valid 	<= #1 n_sq_reg_inst_valid;
			sq_reg_addr_valid 	<= #1 n_sq_reg_addr_valid;
			sq_reg_data_valid	<= #1 n_sq_reg_data_valid;
			
			wait_int			<= #1 n_wait_int;
			wait_idx 			<= #1 n_wait_idx;
	end

		//if ((rs_cdb1_tag == inst1_rs_opa_in[$clog2(`PRF_SIZE)-1:0]) && !inst1_rs_opa_valid && rs_cdb1_valid)

	always_comb begin
		lsq_ra_new1	 = lsq_ra_data1;
		lsq_ra_new2	 = lsq_ra_data2;
		lsq_opb_new1 = lsq_opb_in1;
		lsq_opb_new2 = lsq_opb_in2;		
		lsq_ra_new_valid1 = lsq_ra_data_valid1;
		lsq_ra_new_valid2 = lsq_ra_data_valid2;		
		lsq_opb_new_valid1= lsq_opb_valid1;
		lsq_opb_new_valid2= lsq_opb_valid2;
		
		//get value from cdb
		if ((lsq_cdb1_tag == lsq_ra_data1[$clog2(`PRF_SIZE)-1:0]) && !lsq_ra_data_valid1 && lsq_cdb1_valid)
		begin
			lsq_ra_new1			= lsq_cdb1_in;
			lsq_ra_new_valid1	= 1'b1;
		end
		else if ((lsq_cdb2_tag == lsq_ra_data1[$clog2(`PRF_SIZE)-1:0]) && !lsq_ra_data_valid1 && lsq_cdb2_valid)
		begin
			lsq_ra_new1			= lsq_cdb2_in;
			lsq_ra_new_valid1	= 1'b1;
		end

		if ((lsq_cdb1_tag == lsq_opb_in1[$clog2(`PRF_SIZE)-1:0]) && !lsq_opb_valid1 && lsq_cdb1_valid)
		begin
			lsq_opb_new1		= lsq_cdb1_in;
			lsq_opb_new_valid1	= 1'b1;
		end   	
		else if ((lsq_cdb2_tag == lsq_opb_in1[$clog2(`PRF_SIZE)-1:0]) && !lsq_opb_valid1 && lsq_cdb2_valid)
		begin
			lsq_opb_new1		= lsq_cdb2_in;
			lsq_opb_new_valid1	= 1'b1;
		end

		if ((lsq_cdb1_tag == lsq_ra_data2[$clog2(`PRF_SIZE)-1:0]) && !lsq_ra_data_valid2 && lsq_cdb1_valid)
		begin
			lsq_ra_new2			= lsq_cdb1_in;
			lsq_ra_new_valid2	= 1'b1;
		end
		else if ((lsq_cdb2_tag == lsq_ra_data2[$clog2(`PRF_SIZE)-1:0]) && !lsq_ra_data_valid2 && lsq_cdb2_valid)
		begin
			lsq_ra_new2			= lsq_cdb2_in;
			lsq_ra_new_valid2	= 1'b1;
		end

		if ((lsq_cdb1_tag == lsq_opb_in2[$clog2(`PRF_SIZE)-1:0]) && !lsq_opb_valid1 && lsq_cdb1_valid)
		begin
			lsq_opb_new2		= lsq_cdb1_in;
			lsq_opb_new_valid2	= 1'b1;
		end   	
		else if ((lsq_cdb2_tag == lsq_opb_in2[$clog2(`PRF_SIZE)-1:0]) && !lsq_opb_valid1 && lsq_cdb2_valid)
		begin
			lsq_opb_new2		= lsq_cdb2_in;
			lsq_opb_new_valid2	= 1'b1;
		end  

	end
	
		
		//store the data from sq or mem
		//lq enters: 1. get the dependency from sq info 2.forward if they can
		ld_in1 = 0;
		ld_in2 = 0;
		st_in1 = 0;
		st_in2 = 0;
		ld_idx1 = 0;
		ld_idx2 = 0;
		st_indx1 = 0;
		st_idx2 = 0;

		n_lq_reg_addr 		= lq_reg_addr;
		n_lq_rob_idx 		= lq_rob_idx ;
		n_lq_reg_opa 		= lq_reg_opa;
		n_lq_reg_opb 		= lq_reg_opb;
		n_lq_reg_inst_valid = lq_reg_inst_valid;
		n_lq_reg_addr_valid	= lq_reg_addr_valid;
		n_lq_reg_dest_tag	= lq_reg_dest_tag;
		//n_lq_reg_data_valid = lq_reg_data_valid;
		//n_lq_reg_data 		= lq_reg_data;

		n_sq_head 			= sq_head;
		n_sq_tail 			= sq_tail;
		n_sq_reg_addr		= sq_reg_addr; 
		n_sq_reg_data 		= sq_reg_data;
		n_sq_rob_idx 		= sq_rob_idx;
		n_sq_reg_opa 		= sq_reg_opa;
		n_sq_reg_opb 		= sq_reg_opb;
		n_sq_reg_inst_valid	= sq_reg_inst_valid;
		n_sq_reg_addr_valid	= sq_reg_addr_valid;
		n_sq_reg_data_valid	= sq_reg_data_valid;

		if(id_rd_mem_in1)	begin 		//ldq allocate two entry for ld
			for(int i=0; i<`LQ_SIZE; i++) begin		//first find locations
				if(!lq_reg_addr_valid[i] && !ld_in1) begin
					n_lq_reg_opa[i] 		= lsq_opa_in1;
					n_lq_reg_opb[i] 		= lsq_opb_new1;
					n_lq_reg_addr[i] 		= lsq_opa_in1 + lsq_opb_new1;
					n_lq_rob_idx[i] 		= lsq_rob_idx_in1;
					n_lq_reg_inst_valid[i] 	= 1;
					n_lq_reg_addr_valid[i]	= lsq_opb_new_valid1;
					n_lq_reg_dest_tag[i]	= dest_reg_idx1;
					ld_idx1					= i; 
					ld_in1 					= 1;
					//load from mem
					//load from sq
					for(round_j=sq_head; round_j!=sq_tail; round_j++) begin
						if(sq_reg_inst_valid[round_j] && sq_reg_addr_valid[round_j] && sq_reg_addr[round_j] != (sq_opa_in1 + lsq_opb_new1) && lsq_opb_new_valid1)
							lsq_reg_dep[i][round_j] = NO_DEP_ADDR;
						else if(sq_reg_inst_valid[round_j] && sq_reg_addr_valid[round_j] && sq_reg_addr[round_j] == (sq_opa_in1 + lsq_opb_new1) && lsq_opb_new_valid1)
							lsq_reg_dep[i][round_j] = DEP;
						else if(!sq_reg_inst_valid[round_j])
							lsq_reg_dep[i][round_j] = NO_DEP_ORDER;
						else
							lsq_reg_dep[i][round_j] = NO_IDEA;
					end	//for
					break;
				end //if
			end 	//for

			if(id_rd_mem_in2) begin   //load+load
			for(int i=0; i<`LQ_SIZE; i++) begin		//first find locations
				if(!lq_reg_addr_valid[i] && i!=ld_idx1 && ld_in1 && !ld_in2) begin
					n_lq_reg_opa[i] 		= lsq_opa_in2;
					n_lq_reg_opb[i] 		= lsq_opb_new2;
					n_lq_reg_addr[i] 		= lsq_opa_in2 + lsq_opb_new2;
					n_lq_rob_idx[i] 		= lsq_rob_idx_in2;
					n_lq_reg_inst_valid[i] 	= 1;
					n_lq_reg_addr_valid[i]	= lsq_opb_new_valid2;
					n_lq_reg_dest_tag[i]	= dest_reg_idx2;
					ld_idx2					= i;
					ld_in2 					= 1;
					for(round_j=sq_head; round_j!=sq_tail; round_j++) begin
						if(sq_reg_inst_valid[round_j] && sq_reg_addr_valid[round_j] && sq_reg_addr[round_j] != (sq_opa_in2 + lsq_opb_new2) && lsq_opb_new_valid2)
							lsq_reg_dep[i][round_j] = NO_DEP_ADDR;
						else if(sq_reg_inst_valid[round_j] && sq_reg_addr_valid[round_j] && sq_reg_addr[round_j] == (sq_opa_in2 + lsq_opb_new2) && lsq_opb_new_valid2)
							lsq_reg_dep[i][round_j] = DEP;
						else if(!sq_reg_inst_valid[round_j])
							lsq_reg_dep[i][round_j] = NO_DEP_ORDER;
						else
							lsq_reg_dep[i][round_j] = NO_IDEA;
					end	//for
					break;
				end //if
			end 	//for
			end		//if

			//sq enters: 1. compares and update lq dependency, 3. forward to lq and broadcast to rob 
			else if(id_wr_mem_in2) begin   //load+store
			for(round_j=sq_head; round_j!=sq_tail; round_j++) begin		//first find locations
				if(!sq_reg_addr_valid[round_j] && !st_in1) begin
					n_sq_head 					= sq_head;
					n_sq_tail 					= sq_tail+1;
					n_sq_reg_addr[round_j] 		= lsq_opa_in2 + lsq_opb_new2; 
					n_sq_reg_data[round_j] 		= lsq_ra_new2;
					n_sq_rob_idx[round_j] 		= lsq_rob_idx_in2;
					n_sq_reg_opa[round_j] 		= lsq_opa_in2;
					n_sq_reg_opb[round_j] 		= lsq_opb_new2;
					n_sq_reg_inst_valid[round_j]= 1;
					n_sq_reg_addr_valid[round_j]= lsq_opb_new_valid2;
					n_sq_reg_data_valid[round_j]= lsq_ra_new_valid2;
					st_in1 						= 1;
					st_indx1					= round_j;
					for(int i=0; i<`LQ_SIZE; i++) begin
						if(lq_reg_inst_valid[i] || i== ld_idx1)
						lsq_reg_dep[i][round_j] = NO_DEP_ORDER;
						else
						lsq_reg_dep[i][round_j] = NO_IDEA;
					end //for
					
				end
			end 	//for
			end		//else if
		end 	//if

		if(id_wr_mem_in1)	begin ／／store 
			ld_in1 = 0;
			ld_in2 = 0;
			st_in1 = 0;
			st_in2 = 0;
			for(round_j=sq_head; round_j!=sq_tail; round_j++) begin		//first find locations
				if(!sq_reg_addr_valid[round_j] && !st_in1) begin
					n_sq_head 					= sq_head;
					n_sq_tail 					= sq_tail+1;
					n_sq_reg_addr[round_j] 		= lsq_opa_in1 + lsq_opb_new1; 
					n_sq_reg_data[round_j] 		= lsq_ra_new1;
					n_sq_rob_idx[round_j] 		= lsq_rob_idx_in1;
					n_sq_reg_opa[round_j] 		= lsq_opa_in1;
					n_sq_reg_opb[round_j] 		= lsq_opb_new1;
					n_sq_reg_inst_valid[round_j]= 1;
					n_sq_reg_addr_valid[round_j]= lsq_opb_new_valid1;
					n_sq_reg_data_valid[round_j]= lsq_ra_new_valid1;
					st_in1 						= 1;
					st_indx1					= round_j;
					for(int i=0; i<`LQ_SIZE; i++) begin
						if(lq_reg_inst_valid[i])
						lsq_reg_dep[i][round_j] = NO_DEP_ORDER;
						else
						lsq_reg_dep[i][round_j] = NO_IDEA;
					end //for
					
				end
			end //for

			if(id_rd_mem_in2) begin    ／／store+load
			for(int i=0; i<`LQ_SIZE; i++) begin		//first find locations
				if(!lq_reg_addr_valid[i] && !ld_in1) begin
					n_lq_reg_opa[i] 		= lsq_opa_in2;
					n_lq_reg_opb[i] 		= lsq_opb_new2;
					n_lq_reg_addr[i] 		= lsq_opa_in2 + lsq_opb_new2;
					n_lq_rob_idx[i] 		= lsq_rob_idx_in2;
					n_lq_reg_inst_valid[i] 	= 1;
					n_lq_reg_addr_valid[i]	= lsq_opb_new_valid2;
					n_lq_reg_dest_tag[i]	= dest_reg_idx2;
					ld_idx1					= i; 
					ld_in1 					= 1;
					for(round_j=sq_head; round_j!=sq_tail; round_j++) begin
						if((sq_reg_inst_valid[round_j] && sq_reg_addr_valid[round_j] && sq_reg_addr[round_j] != (sq_opa_in2 + lsq_opb_new2) && lsq_opb_new_valid2)
							| lsq_opb_new_valid1 && (lsq_opa_in1 + lsq_opb_new1)!= (sq_opa_in2 + lsq_opb_new2) && lsq_opb_new_valid2)
							lsq_reg_dep[i][round_j] = NO_DEP_ADDR;
						else if((sq_reg_inst_valid[round_j] && sq_reg_addr_valid[round_j] && sq_reg_addr[round_j] == (sq_opa_in1 + lsq_opb_new2) && lsq_opb_new_valid2)
							| lsq_opb_new_valid1 && (lsq_opa_in1 + lsq_opb_new1)== (sq_opa_in2 + lsq_opb_new2) && lsq_opb_new_valid2)
							lsq_reg_dep[i][round_j] = DEP;
						else if(!sq_reg_inst_valid[round_j] && lq_reg_inst_valid[i])
							lsq_reg_dep[i][round_j] = NO_DEP_ORDER;
						else
							lsq_reg_dep[i][round_j] = NO_IDEA;
					end	//for
					break;
				end //if
			end 	//for
			end		//if

			else if(id_wr_mem_in2) begin   //store + store
			for(round_j=sq_head +1 ; round_j!=sq_tail && round_j !=sq_tail+1; round_j++) begin		//first find locations
				if(!sq_reg_addr_valid[round_j] && st_in1 && round_j!=st_indx1 && !st_in2) begin
					n_sq_head 					= sq_head;
					n_sq_tail 					= sq_tail+2;
					n_sq_reg_addr[round_j] 		= lsq_opa_in2 + lsq_opb_new2; 
					n_sq_reg_data[round_j] 		= lsq_ra_new2;
					n_sq_rob_idx[round_j] 		= lsq_rob_idx_in2;
					n_sq_reg_opa[round_j] 		= lsq_opa_in2;
					n_sq_reg_opb[round_j] 		= lsq_opb_new2;
					n_sq_reg_inst_valid[round_j]= 1;
					n_sq_reg_addr_valid[round_j]= lsq_opb_new_valid2;
					n_sq_reg_data_valid[round_j]= lsq_ra_new_valid2;
					st_in1 						= 1;
					st_indx1					= round_j;
					for(int i=0; i<`LQ_SIZE; i++) begin
						if(lq_reg_inst_valid[i])
						lsq_reg_dep[i][round_j] = NO_DEP_ORDER;
						else
						lsq_reg_dep[i][round_j] = NO_IDEA;
					end //for
					
				end
			end //for
			end //if


			//forward data
			lsq_CDB_result_out1 = 0;
			lsq_CDB_result_out2 = 0;
			lsq_CDB_result_is_valid1 = 0;
			lsq_CDB_result_is_valid2 = 0;
			ld_out_idx1=0;
			ld_out_idx2=0;

			//if not able to forward from lq, then load from memory
			
			if(instr_load_mem_in_valid1) begin
			for(int i=0; i<`LQ_SIZE; i++)
				if(wait_idx[i]==mem_load_tag_in) begin
						lsq_CDB_dest_tag2 	= lq_reg_dest_tag[i];
						lsq_CDB_result_out2 = instr_load_from_mem1;
						lsq_CDB_result_is_valid2 = 1;
						n_wait_idx[i] = 0;
			end
			end
			
			for(int i=0; i<`LQ_SIZE; i++) begin		//forward
				if(lq_reg_addr_valid[i] && !lsq_CDB_result_out1) begin
					for(round_j = sq_head; round_j!=sq_tail; round_j++) begin
						mem_res = 0;
						if(lsq_reg_dep[i][round_j] == NO_IDEA) begin
							break;
							end
						else if(lsq_reg_dep[i][round_j] == NO_DEP_ORDER) begin
							if(!mem_res) begin
							load_from_mem_idx = lq_reg_addr[i];//fifo
							request_from_mem = 1;
							n_wait_int = wait_int+1;
							n_wait_idx[i] = wait_int;
							mem_load_tag_out = wait_int;
							end
							break;
							end
						else if(lsq_reg_dep[i][round_j] == NO_DEP_ADDR) begin
							if(round_j == sq_tail) break;
							end
						else if(lsq_reg_dep[i][round_j] == DEP) begin
							lsq_CDB_result_is_valid1 = 1;
							mem_res = 1;
							//n_lq_reg_data_valid[i]= 1;
							//n_lq_reg_data[i] = sq_reg_data[round_j];
							ysq_than_lq1 	= round_j;
							ld_out_idx1 = i;
							lsq_CDB_dest_tag1 	= lq_reg_dest_tag[i];
							lsq_CDB_result_out1 = sq_reg_data[round_j];
							end //else
					end //for
				end //if
			end //for
			
			if(!instr_load_mem_in_valid1) begin
			for(int i=0; i<`LQ_SIZE; i++) begin		//forward
				if(lq_reg_addr_valid[i] && lsq_CDB_result_is_valid1 && !lsq_CDB_result_is_valid2 && i!= ld_out_idx1) begin
					for(round_j = sq_head; round_j!=sq_tail; round_j++) begin
						if(lsq_reg_dep[i][round_j] == NO_IDEA) begin
							break;
							end
						else if(lsq_reg_dep[i][round_j] == NO_DEP_ORDER) begin
							break;
							end
						else if(lsq_reg_dep[i][round_j] == NO_DEP_ADDR) begin
							if(round_j == sq_tail) break;
							end
						else if(lsq_reg_dep[i][round_j] == DEP) begin
							lsq_CDB_result_is_valid2 = 1;
							//n_lq_reg_data_valid[i] = 1;
							//n_lq_reg_data[i] = sq_reg_data[round_j];
							ysq_than_lq2 = round_j;
							ld_out_idx2 = i;
							lsq_CDB_dest_tag2 	= lq_reg_dest_tag[i];
							lsq_CDB_result_out2 = sq_reg_data[ysq_than_lq2];
							end //else
					end //for
				end //if
			end //for
			end //if			

			//store to mem 
			if(sq_rob_idx[sq_head]==rob_commit_idx1 | rob_commit_idx2) begin
				instr_store_to_mem1 = sq_reg_data[sq_head];
				n_sq_head = sq_head +1;
				instr_store_to_mem_valid1 = 1;
				mem_store_idx = sq_reg_addr[sq_head];
				rob1_excuted = 1;
				n_sq_reg_inst_valid[sq_head] = 0;
			end
			if(sq_rob_idx[sq_head+1]==rob_commit_idx2) rob2_excuted = 0;

			//load retires
			for(int i=0; i<`LQ_SIZE; i++) begin	
				if(lq_rob_idx[i]==rob_commit_idx1)begin
					n_lq_reg_inst_valid[i] = 0;
					rob1_excuted = 1;
				end
				if(lq_rob_idx[i]==rob_commit_idx2) begin
					n_lq_reg_inst_valid[i] = 0;
					rob2_excuted = 1;
				end
			end

	end //comb
	
	
	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
