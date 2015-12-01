
//////////////////////////////////
//								//
//		  SQ					//
//		work as a buffer		//
//								//
//////////////////////////////////

module sq(
	input	clock,
	input	reset,
	
	input	id_wr_mem_in1,
	input	id_wr_mem_in2,		//stq
	
	input	is_thread1;
	
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

	//we need rob age for store to commit
	input	[$clog2(`ROB_SIZE):0]		rob_commit_idx1,
	input	[$clog2(`ROB_SIZE):0]		rob_commit_idx2,
	
	//we need to know weather the instruction commited is a mispredict
	input	thread1_mispredict,
	input	thread2_mispredict,
	
	output	logic	[63:0]						instr_store_to_mem1,
	output	logic								instr_store_to_mem_valid1,
	output	logic	[4:0]						mem_store_idx,
	
	output	logic								rob1_excuted,
	output	logic								rob2_excuted,
	output	logic								t1_is_full,
	output	logic								t2_is_full
);

	//SQ
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_addr, n_sq_reg_addr;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_data, n_sq_reg_data;
	logic	[`SQ_SIZE-1:0][$clog2(`ROB_SIZE):0] sq_rob_idx, n_sq_rob_idx;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_opa, n_sq_reg_opa;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_opb, n_sq_reg_opb;
	logic	[`SQ_SIZE-1:0]			sq_reg_addr_valid, n_sq_reg_addr_valid;
	logic	[`SQ_SIZE-1:0]			sq_reg_inst_valid, n_sq_reg_inst_valid;
	
	logic 	[$clog2(`SQ_SIZE)-1:0]					sq_t1_head, n_sq_t1_head;
	logic 	[$clog2(`SQ_SIZE)-1:0]					sq_t2_head, n_sq_t2_head;
	logic	[$clog2(`SQ_SIZE)-1:0]					sq_t1_tail, n_sq_t1_tail;
	logic	[$clog2(`SQ_SIZE)-1:0]					sq_t2_tail, n_sq_t2_tail;
	logic	[$clog2(`SQ_SIZE)-1:0]					st_idx1, st_idx2;
	logic											st_in1, st_in2;
	logic											st_out1, st_out2;
	logic											sq_reg_data_valid, n_sq_reg_data_valid;

	logic	[$clog2(`SQ_SIZE)-1:0]					round_j;
		
	always_ff(@posedge clock) begin
		if(reset) begin


			sq_t1_head 			<= #1 0;
			sq_t1_tail 			<= #1 0;
			sq_t2_head 			<= #1 0;
			sq_t2_tail 			<= #1 0;
			sq_reg_addr 		<= #1 0;
			sq_rob_idx 			<= #1 0;
			sq_reg_opa 			<= #1 0;
			sq_reg_opb 			<= #1 0;
			sq_reg_data 		<= #1 0;
			sq_reg_addr_valid 	<= #1 0;
			sq_reg_inst_valid 	<= #1 0;
			sq_reg_data_valid	<= #1 0;

		end
		else begin
			sq_t1_head 			<= #1 n_sq_t1_head;
			sq_t1_tail 			<= #1 n_sq_t1_tail;
			sq_t2_head 			<= #1 n_sq_t2_head;
			sq_t2_tail 			<= #1 n_sq_t2_tail;
			sq_reg_addr 		<= #1 n_sq_reg_addr;
			sq_reg_data 		<= #1 n_sq_reg_data;
			sq_rob_idx 			<= #1 n_sq_rob_idx;
			sq_reg_opa 			<= #1 n_sq_reg_opa;
			sq_reg_opb 			<= #1 n_sq_reg_opb;
			sq_reg_inst_valid 	<= #1 n_sq_reg_inst_valid;
			sq_reg_addr_valid 	<= #1 n_sq_reg_addr_valid;
			sq_reg_data_valid	<= #1 n_sq_reg_data_valid;

		end
	end
	
	always_comb begin	
		st_in1 = 0;
		st_idx1 = 0;
		n_sq_t1_head 		= sq_t1_head;
		n_sq_t1_tail 		= sq_t1_tail;
		n_sq_t2_head 		= sq_t2_head;
		n_sq_t2_tail 		= sq_t2_tail;
		n_sq_reg_addr		= sq_reg_addr; 
		n_sq_reg_data 		= sq_reg_data;
		n_sq_rob_idx 		= sq_rob_idx;
		n_sq_reg_opa 		= sq_reg_opa;
		n_sq_reg_opb 		= sq_reg_opb;
		n_sq_reg_inst_valid	= sq_reg_inst_valid;
		n_sq_reg_addr_valid	= sq_reg_addr_valid;
		n_sq_reg_data_valid	= sq_reg_data_valid;
		
		if(id_wr_mem_in1)	begin //store
			for(round_j=sq_t1_head; round_j!=sq_t1_tail; round_j++) begin		//first find locations
				if(!sq_reg_addr_valid[round_j] && !st_in1) begin
					n_sq_reg_addr[round_j] 		= lsq_opa_in1 + lsq_opb_in1;
					n_sq_t1_tail 				= sq_t1_tail+1;
					n_sq_reg_data[round_j] 		= lsq_ra_data1;
					n_sq_rob_idx[round_j] 		= lsq_rob_idx_in1;
					n_sq_reg_opa[round_j] 		= lsq_opa_in1;
					n_sq_reg_opb[round_j] 		= lsq_opb_in1;
					n_sq_reg_inst_valid[round_j]= 1;
					n_sq_reg_addr_valid[round_j]= lsq_opb_in_valid1;
					n_sq_reg_data_valid[round_j]= lsq_ra_data_valid1;
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
		
		if(id_wr_mem_in2 && is_thread1) begin   //store
			for(round_j=sq_t1_head; round_j!=sq_t1_tail; round_j++) begin		//first find locations
				if(!sq_reg_addr_valid[round_j] && (!st_in1 || (st_in1 && round_j!=st_idx1))) begin
					n_sq_t1_tail 				= n_sq_t1_tail+1;
					n_sq_reg_addr[round_j] 		= lsq_opa_in2 + lsq_opb_in2; 
					n_sq_reg_data[round_j] 		= lsq_ra_data2;
					n_sq_rob_idx[round_j] 		= lsq_rob_idx_in2;
					n_sq_reg_opa[round_j] 		= lsq_opa_in2;
					n_sq_reg_opb[round_j] 		= lsq_opb_in2;
					n_sq_reg_inst_valid[round_j]= 1;
					n_sq_reg_addr_valid[round_j]= lsq_lsq_ra_data2;
					n_sq_reg_data_valid[round_j]= lsq_ra_data_valid2;
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
		
		if(id_wr_mem_in2 && !is_thread1) begin   //store
			for(round_j=sq_t2_head; round_j!=sq_t2_tail; round_j++) begin		//first find locations
				if(!sq_reg_addr_valid[round_j] && (!st_in1 || (st_in1 && round_j!=st_idx1))) begin
					n_sq_t2_tail 				= n_sq_t2_tail+1;
					n_sq_reg_addr[round_j] 		= lsq_opa_in2 + lsq_opb_in2; 
					n_sq_reg_data[round_j] 		= lsq_ra_data2;
					n_sq_rob_idx[round_j] 		= lsq_rob_idx_in2;
					n_sq_reg_opa[round_j] 		= lsq_opa_in2;
					n_sq_reg_opb[round_j] 		= lsq_opb_in2;
					n_sq_reg_inst_valid[round_j]= 1;
					n_sq_reg_addr_valid[round_j]= lsq_lsq_ra_data2;
					n_sq_reg_data_valid[round_j]= lsq_ra_data_valid2;
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
		
		//store to mem 
		rob1_excuted = 0;
		rob2_excuted = 0;
		if(sq_rob_idx[sq_t1_head]==(rob_commit_idx1 |rob_commit_idx2) begin
			instr_store_to_mem1 = sq_reg_data[sq_t1_head];
			n_sq_t1_head = sq_t1_head +1;
			instr_store_to_mem_valid1 = 1;
			mem_store_idx = sq_reg_addr[sq_t1_head];
			rob1_excuted = rob_commit_idx1;
			rob2_excuted = (rob_commit_idx1 && rob_commit_idx2) ? 0:rob_commit_idx2;
			n_sq_reg_inst_valid[sq_t1_head] = 0;
		end
		if(sq_rob_idx[sq_t2_head]==rob_commit_idx2 & !rob1_excuted)) begin
			instr_store_to_mem1 = sq_reg_data[sq_t2_head];
			n_sq_t2_head = sq_t2_head +1;
			instr_store_to_mem_valid1 = 1;
			mem_store_idx = sq_reg_addr[sq_t2_head];
			rob2_excuted = 1;
			n_sq_reg_inst_valid[sq_t2_head] = 0;
		end		
		
		//mispredict
		if(thread1_mispredict)begin
			n_sq_t1_tail = n_sq_t1_head;
		end
		if(thread2_mispredict)begin
			n_sq_t2_tail = n_sq_t2_head;
		end
		
		if ((sq_t1_tail + 2 == sq_t1_head)||(sq_t1_tail + 1 == sq_t1_head) || (sq_t1_tail == sq_t1_head))				//**************************** 
		begin
			t1_is_full = 1;
		end
		if ((sq_t2_tail + 2 == sq_t2_head)||(sq_t2_tail + 1 == sq_t2_head) || (sq_t2_tail == sq_t2_head))
		begin
			t2_is_full = 1;
		end
	end
