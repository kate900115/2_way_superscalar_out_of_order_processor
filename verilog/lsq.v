
//////////////////////////////////
//								//
//		  LSQ					//
//								//
//////////////////////////////////

//lsq works as a rs for the ldq/stq
//need to communicate with rob when it hits the head of the rob
//dispatch at the same time
//load queue works like a buffer and store queue works in order

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
	input  [$clog2(`ROB_SIZE):0]				lsq_rob_idx_in2,  	// The rob index of instruction 2
	input  [63:0]								lsq_ra_data2, 	//comes from prf according to idx request, 0 if load
	input										lsq_ra_data_valid2,	//weather data comes form prf is valid, if not, get from cdb

	input	[4:0]								dest_reg_idx1, //`none_reg if store
	input	[4:0]								dest_reg_idx2,

	input	[63:0]						instr_load_from_mem1,	//when no forwarding possible, load from memory
	input								instr_load_mem_in_valid1,
	input	[4:0]						mem_load_tag_in,
	
	//we need rob age for store to commit
	input	[$clog2(`ROB_SIZE):0]		rob_commit_idx1,
	input	[$clog2(`ROB_SIZE):0]		rob_commit_idx2,

	//we need to know weather the instruction commited is a mispredict
	input	thread1_mispredict,
	input	thread2_mispredict,

	//load instruction is output when corresponding dest_tag get value from store_in
	//output to prf -- prf_tag		
	//store instructions are output when instruction retires and store write to memory
	//output to prf -- L1 cache (prf48)

	output logic [$clog2(`PRF_SIZE)-1:0]	lsq_CDB_dest_tag1,
	output logic [63:0]						lsq_CDB_result_out1,
	output logic 							lsq_CDB_result_is_valid1,

	output logic [$clog2(`PRF_SIZE)-1:0]	lsq_CDB_dest_tag2,
	output logic [63:0]						lsq_CDB_result_out2,
	output logic 							lsq_CDB_result_is_valid2,

	//sedn idx to prf to get value
	output	logic [$clog2(`PRF_SIZE)-1:0]	lsq_opb_idx1,
	output	logic							lsq_opb_request1,
	output	logic [$clog2(`PRF_SIZE)-1:0]	lsq_opb_idx2,
	output	logic							lsq_opb_request2,
	output	logic [$clog2(`PRF_SIZE)-1:0]	lsq_ra_dest_idx1,
	output	logic							lsq_ra_request1,	//request = 0 if load
	output	logic [$clog2(`PRF_SIZE)-1:0]	lsq_ra_dest_idx2,
	output	logic							lsq_ra_request2,


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
	
	//when in store came in and find a instr following him in program order has been excuted, the LSQ must report a violation
	//Here we only forward the independent loads!!!!!
	);
	
	//LQ
	//the relative ages of two instructions can be determined by examing the physical locations they occupied in LSQ
	//for example, instruction at slot 5 is older than instruction at slot 8
	//lq_reg stores address
	logic	[`LQ_SIZE-1:0][63:0]	lq_reg_addr, n_lq_reg_addr;
	logic	[`LQ_SIZE-1:0][63:0]	lq_reg_data, n_lq_reg_data;
	logic	[`LQ_SIZE-1:0][$clog2(`ROB_SIZE):0] lq_rob_idx, n_lq_rob_idx;
	logic	[`LQ_SIZE-1:0][63:0]	lq_reg_opa, n_lq_reg_opa;
	logic	[`LQ_SIZE-1:0][63:0]	lq_reg_opb, n_lq_reg_opb;
	logic	[`LQ_SIZE-1:0][4:0]		lq_reg_dest_tag, n_lq_reg_dest_tag;
	logic	[`LQ_SIZE-1:0]			lq_reg_addr_valid, n_lq_reg_addr_valid;
	logic	[`LQ_SIZE-1:0]			lq_reg_inst_valid, n_lq_reg_inst_valid;
	logic							lq_reg_data_valid, n_lq_reg_data_valid;

	//SQ
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_addr, n_sq_reg_addr;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_data, n_sq_reg_data;
	logic	[`SQ_SIZE-1:0][$clog2(`ROB_SIZE):0] sq_rob_idx, n_sq_rob_idx;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_opa, n_sq_reg_opa;
	logic	[`SQ_SIZE-1:0][63:0]	sq_reg_opb, n_sq_reg_opb;
	logic	[`SQ_SIZE-1:0]			sq_reg_addr_valid, n_sq_reg_addr_valid;
	logic	[`SQ_SIZE-1:0]			sq_reg_inst_valid, n_sq_reg_inst_valid;

	LSQ_DEP_CODE [`LQ_SIZE-1:0][`SQ_SIZE-1:0]n_lsq_reg_dep;

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
	logic	[63:0]		lsq_ra_in1;
	logic	[63:0]		lsq_ra_in2;
	logic	[63:0]		lsq_opb_in1;
	logic	[63:0]		lsq_opb_in2;		
	logic				lsq_ra_in_valid1;
	logic				lsq_ra_in_valid2;		
	logic				lsq_opb_in_valid1;
	logic				lsq_opb_in_valid2;

	//for load from mem
	logic 	[`LQ_SIZE-1:0]		mem_res, mem_load, mem_load_req;
	logic	[`LQ_SIZE-1:0][4:0] wait_idx;
	logic	[`LQ_SIZE-1:0][4:0] n_wait_idx;
	logic	[`LQ_SIZE-1:0] wait_valid, n_wait_valid;
	logic	[4:0]		wait_int;
	logic	[4:0]		n_wait_int;
	
	//for priority selector
	logic	[`LQ_SIZE-1:0]							lq_cdb1;
	logic	[`LQ_SIZE-1:0]							lq_cdb2;

sq sq1(
	//logic
	.clock(clock),
	.reset(reset),
	.id_wr_mem_in1(id_wr_mem_in1),
	.id_wr_mem_in2(id_wr_mem_in2),		//stq
	.is_thread1(is_thread1),
	.lsq_opa_in1(lsq_opa_in1),      	// Operand a from Rename  data
	.lsq_opb_in1(lsq_opb_in1),      	// Operand a from Rename  tag or data from prf
	.lsq_opb_valid1(lsq_opb_valid1),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	.lsq_rob_idx_in1(lsq_rob_idx_in1),  	// The rob index of instruction 1
	.lsq_ra_data1(lsq_ra_data1),	//comes from prf according to idx request, 0 if load
	.lsq_ra_data_valid1(lsq_ra_data_valid1), //weather data comes form prf is valid, if not, get from cdb
	.lsq_opa_in2(lsq_opa_in2),      	// Operand a from Rename  data
	.lsq_opb_in2(lsq_opb_in2),     	// Operand b from Rename  tag or data from prf
	.lsq_opb_valid2(lsq_opb_valid2),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
	.lsq_rob_idx_in2(lsq_rob_idx_in2),  	// The rob index of instruction 2
	.lsq_ra_data2(lsq_ra_data2), 	//comes from prf according to idx request, 0 if load
	.lsq_ra_data_valid2(lsq_ra_data_valid2),	//weather data comes form prf is valid, if not, get from cdb
	
	//we need rob age for store to commit
	.rob_commit_idx1(rob_commit_idx1),
	.rob_commit_idx2(rob_commit_idx2),

	.lsq_cdb1_in(lsq_cdb1_in),     		// CDB bus from functional units 
	.lsq_cdb1_tag(lsq_cdb1_tag),    		// CDB tag bus from functional units 
	.lsq_cdb1_valid(lsq_cdb1_valid),  		// The data on the CDB is valid 
	.lsq_cdb2_in(lsq_cdb2_in),     		// CDB bus from functional units 
	.lsq_cdb2_tag(lsq_cdb2_tag),    		// CDB tag bus from functional units 
	.lsq_cdb2_valid(lsq_cdb2_valid),  		// The data on the CDB is valid 	
	//we need to know weather the instruction commited is a mispredict
	.thread1_mispredict(thread1_mispredict),
	.thread2_mispredict(thread2_mispredict),

	//output to lq
	.sq_reg_addr(sq_reg_addr),
	.sq_reg_data(sq_reg_data), 	
	.sq_rob_idx(sq_rob_idx),
	.sq_reg_addr_valid(sq_reg_addr_valid),
	.sq_reg_inst_valid(sq_reg_inst_valid),
	.sq_reg_data_valid(sq_reg_data_valid),
	.sq_t1_head(sq_t1_head), 
	.sq_t2_head(sq_t2_head),
	.sq_t1_tail(sq_t1_tail),
	.sq_t2_tail(sq_t2_tail),
		
	.mem_store_value(mem_store_value),
	.instr_store_to_mem_valid1(instr_store_to_mem_valid1),
	.mem_store_addr(mem_store_addr),
	.rob1_excuted(rob1_excuted),
	.rob2_excuted(rob2_excuted),
	.t1_sq_is_full(t1_is_full),
	.t2_sq_is_full(t2_is_full)
	);
		
	always_ff@(posedge clock) begin
		if(reset) begin

			lq_reg_addr 		<= #1 0;
			lq_rob_idx 			<= #1 0;
			lq_reg_opa 			<= #1 0;
			lq_reg_opb 			<= #1 0;
			lq_reg_data 		<= #1 0;
			lq_reg_dest_tag 	<= #1 0;
			lq_reg_addr_valid 	<= #1 0;
			lq_reg_inst_valid 	<= #1 0;
			lq_reg_data_valid	<= #1 0;
			
			wait_int			<= #1 0;
			wait_idx 			<= #1 0;
			wait_valid 			<= #1 0;
			lsq_reg_dep			<= #1 NO_IDEA;
		end
			else begin

				lq_reg_addr 		<= #1 n_lq_reg_addr;
				lq_rob_idx 			<= #1 n_lq_rob_idx;
				lq_reg_opa 			<= #1 n_lq_reg_opa;
				lq_reg_opb 			<= #1 n_lq_reg_opb;
				lq_reg_data 		<= #1 n_lq_reg_data;
				lq_reg_inst_valid 	<= #1 n_lq_reg_inst_valid;
				lq_reg_addr_valid 	<= #1 n_lq_reg_addr_valid;
				lq_reg_dest_tag		<= #1 n_lq_reg_dest_tag;
				lq_reg_data_valid	<= #1 n_lq_reg_data_valid;
			
				wait_int			<= #1 n_wait_int;
				wait_idx 			<= #1 n_wait_idx;
				wait_valid 			<= #1 n_wait_valid;
				lsq_reg_dep			<= #1 n_lsq_reg_dep;
		end
	end

		//if ((rs_cdb1_tag == inst1_rs_opa_in[$clog2(`PRF_SIZE)-1:0]) && !inst1_rs_opa_valid && rs_cdb1_valid)

	always_comb begin
	//get value from cdb
	for (int i = 0; i < `LQ_SIZE; i++) begin
		if (~lq_reg_addr_valid[i] && (lq_reg_opb[i][$clog2(`PRF_SIZE)-1:0] == cdb1_tag[i]) && lq_inst_valid[i] && lq_cdb1_valid[i]) begin
					n_lq_reg_opb[i]			= lq_cdb1_in[i];
					n_lq_reg_addr_valid[i]	= 1;
		end
		if (~lq_reg_addr_valid[i] && (lq_reg_opb[i][$clog2(`PRF_SIZE)-1:0] == cdb2_tag[i]) && lq_inst_valid[i] && lq_cdb2_valid[i]) begin
					n_lq_reg_opb[i]			= lq_cdb2_in[i];
					n_lq_reg_addr_valid[i]	= 1;
		end				
		if (~lq_reg_data_valid[i] && (lq_reg_dest_tag[i][$clog2(`PRF_SIZE)-1:0] == cdb1_tag[i]) && lq_inst_valid[i] && lq_cdb1_valid[i]) begin
					n_lq_reg_data[i]		= lq_cdb1_in[i];
					n_lq_reg_data_valid[i]	= 1;
		end
		if (~lq_reg_data_valid[i] && (lq_reg_dest_tag[i][$clog2(`PRF_SIZE)-1:0] == cdb2_tag[i]) && lq_inst_valid[i] && lq_cdb2_valid[i]) begin
					n_lq_reg_data[i]		= lq_cdb2_in[i];
					n_lq_reg_data_valid[i]	= 1;
		end
	end

	//store the data from sq or mem
		//lq enters: 1. get the dependency from sq info 2.forward if they can
		ld_in1 = 0;
		ld_in2 = 0;
		ld_idx1 = 0;
		ld_idx2 = 0;

		n_lq_reg_addr 		= lq_reg_addr;
		n_lq_rob_idx 		= lq_rob_idx ;
		n_lq_reg_opa 		= lq_reg_opa;
		n_lq_reg_opb 		= lq_reg_opb;
		n_lq_reg_inst_valid = lq_reg_inst_valid;
		n_lq_reg_addr_valid	= lq_reg_addr_valid;
		n_lq_reg_dest_tag	= lq_reg_dest_tag;
		n_lq_reg_data_valid = lq_reg_data_valid;
		n_lq_reg_data 		= lq_reg_data;
		
		n_wait_int = wait_int;
		n_wait_idx = wait_idx;
		n_wait_valid = wait_valid;

		if(id_rd_mem_in1)	begin 		//ldq allocate two entry for ld
			for(int i=0; i<`LQ_SIZE; i++) begin		//first find locations
				if(!lq_reg_addr_valid[i] && !ld_in1) begin
					n_lq_reg_opa[i] 		= lsq_opa_in1;
					n_lq_reg_opb[i] 		= lsq_opb_in1;
					n_lq_reg_addr[i] 		= lsq_opa_in1 + lsq_opb_in1;
					n_lq_rob_idx[i] 		= lsq_rob_idx_in1;
					n_lq_reg_inst_valid[i] 	= 1;
					n_lq_reg_addr_valid[i]	= lsq_opb_in_valid1;
					n_lq_reg_dest_tag[i]	= dest_reg_idx1;
					n_lq_reg_data[i]		= lsq_ra_data1;
					n_lq_reg_data_valid[i]	= lsq_ra_data_valid1;
					ld_idx1					= i; 
					ld_in1 					= 1;
					break;
				end //if
			end 	//for
		end //if

		if(id_rd_mem_in2) begin   //load+load
			for(int i=0; i<`LQ_SIZE; i++) begin		//first find locations
				if(!lq_reg_addr_valid[i] && ((i!=ld_idx1 && ld_in1)||!ld_in1) && !ld_in2) begin
					n_lq_reg_opa[i] 		= lsq_opa_in2;
					n_lq_reg_opb[i] 		= lsq_opb_in2;
					n_lq_reg_addr[i] 		= lsq_opa_in2 + lsq_opb_in2;
					n_lq_rob_idx[i] 		= lsq_rob_idx_in2;
					n_lq_reg_inst_valid[i] 	= 1;
					n_lq_reg_addr_valid[i]	= lsq_opb_in_valid2;
					n_lq_reg_dest_tag[i]	= dest_reg_idx2;
					n_lq_reg_data[i]		= lsq_ra_data2;
					n_lq_reg_data_valid[i]	= lsq_ra_data_valid2;
					ld_idx2					= i;
					ld_in2 					= 1;
					break;
				end //if
			end 	//for
		end		//if

		if(id_wr_mem_in1 && id_rd_mem_in2) begin    //store+load
			for(int i=0; i<`LQ_SIZE; i++) begin		//first find locations
				if(!lq_reg_addr_valid[i] && !ld_in1) begin
						if(lsq_opb_in_valid1 && lsq_opb_in_valid2 && (lsq_opa_in1 + lsq_opb_in1)!= (lsq_opa_in2 + lsq_opb_in2) && is_thread1)
							n_lsq_reg_dep[i][sq_t1_tail] = NO_DEP_ADDR;
							
						else if(lsq_opb_in_valid1 && lsq_opb_in_valid2 && (lsq_opa_in1 + lsq_opb_in1)!= (lsq_opa_in2 + lsq_opb_in2) && !is_thread1)
							n_lsq_reg_dep[i][sq_t2_tail] = NO_DEP_ADDR;
							
						else if(lsq_opb_in_valid1 && (lsq_opa_in1 + lsq_opb_in1)== (lsq_opa_in2 + lsq_opb_in2) && lsq_opb_in_valid2 && is_thread1) begin
							n_lsq_reg_dep[i][sq_t1_tail] = DEP;							
							n_lq_reg_data[i]		= lsq_ra_data1;
							n_lq_reg_data_valid[i]	= lsq_ra_data_valid1;
						end
							
						else if(lsq_opb_in_valid1 && (lsq_opa_in1 + lsq_opb_in1)== (lsq_opa_in2 + lsq_opb_in2) && lsq_opb_in_valid2 && is_thread1)
							n_lsq_reg_dep[i][sq_t2_tail] = DEP;
							
					break;
				end //if
			end 	//for
		end		//if
		
		//load from sq
		for (int i = 0; i < `LQ_SIZE; i++) begin
			for(int j=0;j <`SQ_SIZE;j++) begin
				//the addr can be figured out at every cycle
				if(sq_reg_inst_valid[j] && sq_reg_addr_valid[j] && sq_reg_addr[j] != (lsq_opa_in1 + lsq_opb_in1) && lsq_opb_in_valid1)
					n_lsq_reg_dep[i][j] = NO_DEP_ADDR;
				else if(sq_reg_inst_valid[j] && sq_reg_addr_valid[j] && sq_reg_addr[j] == (lsq_opa_in1 + lsq_opb_in1) && lsq_opb_in_valid1) begin
					n_lsq_reg_dep[i][j] 	= DEP;
					n_lq_reg_data[i]		=sq_reg_data[j];
					n_lq_reg_data_valid[i]	=sq_reg_data_valid[j];
				end
				else if(!sq_reg_inst_valid[j])
					n_lsq_reg_dep[i][j] = NO_DEP_ORDER;
					
			end	//for
		end //for

		//the data can be figured out at every cycle
		for (int i = 0; i < `LQ_SIZE; i++) begin
		 if (lq_rob_idx[i][$clog2(`ROB_SIZE)] == 0) begin
		 	for(round_j = sq_t1_head; round_j!=sq_t1_tail; round_j++) begin
				if(lsq_reg_dep[i][round_j]==DEP) begin
					n_lq_reg_data[i]		=sq_reg_data[round_j];
					n_lq_reg_data_valid[i]	=sq_reg_data_valid[round_j];				
				end
			end
		 end
		 else begin
		 	for(round_j = sq_t2_head;round_j!=sq_t2_tail; round_j++) begin
				if(lsq_reg_dep[i][round_j]==DEP) begin
					n_lq_reg_data[i]		=sq_reg_data[round_j];
					n_lq_reg_data_valid[i]	=sq_reg_data_valid[round_j];				
				end
			end
		 end
		end		
				
		//get value from mem
		if(instr_load_mem_in_valid1) begin
			for(int i=0; i<`LQ_SIZE; i++)
				if(wait_idx[i]==mem_load_tag_in && wait_valid[i]) begin
						n_lq_reg_data[i] 	= instr_load_from_mem1;
						n_lq_reg_data_valid[i] = 1;
						n_wait_idx[i] = 0;
						n_wait_valid[i] = 0;
			end
		end
			
		//ask for mem to load data
		mem_res = 0;
		mem_load_req = 0;
		load_from_mem_idx=0;
		request_from_mem = 0;
		mem_load_tag_out=0;
		priority_selector #(1,`LQ_SIZE)load(
			req(mem_res!),
			en(1'b1),
    		// Outputs
			gnt_bus({mem_load}),
		);
		for(int i=0; i<`LQ_SIZE; i++) begin		//mem load???
				if(lq_reg_addr_valid[i] && !lq_reg_data_valid[i] && (lq_rob_idx[i][$clog2(`ROB_SIZE)] == 0)) begin
					for(round_j = sq_t1_head; round_j!=sq_t1_tail; round_j++) begin
						if(n_lsq_reg_dep[i][j] == NO_IDEA) begin
							break;
							end
						else if(n_lsq_reg_dep[i][j] == NO_DEP_ORDER) begin
							if(!mem_res[i]) begin
							mem_load_req[i] = 1;
							end
							break;
							end
						else if(n_lsq_reg_dep[i][j] == NO_DEP_ADDR) begin
							if(round_j == sq_t1_tail) break;
							end
						else if(n_lsq_reg_dep[i][j] == DEP) begin
							mem_res[i] = 1;
							end //else
					end //for
				end //if
		end //for
			
		for(int i=0; i<`LQ_SIZE; i++) begin		//mem load???
				if(lq_reg_addr_valid[i] && !lq_reg_data_valid[i] && (lq_rob_idx[i][$clog2(`ROB_SIZE)] == 1)) begin
					for(round_j = sq_t2_head; round_j!=sq_t2_tail; round_j++) begin
						if(n_lsq_reg_dep[i][j] == NO_IDEA) begin
							break;
							end
						else if(n_lsq_reg_dep[i][j] == NO_DEP_ORDER) begin
							if(!mem_res[i]) begin
							mem_load_req[i] = 1;
							end
							break;
							end
						else if(n_lsq_reg_dep[i][j] == NO_DEP_ADDR) begin
							if(round_j == sq_t2_tail) break;
							end
						else if(n_lsq_reg_dep[i][j] == DEP) begin
							mem_res[i] = 1;
							end //else
					end //for
				end //if
		end //for
			
		for(int i=0; i<`LQ_SIZE; i++) begin		//send request to load from mem
				if(mem_load[i]) begin
						load_from_mem_idx = lq_reg_addr[i];//fifo
						request_from_mem = 1;
						n_wait_int = wait_int+1;
						n_wait_idx[i] = wait_int;
						mem_load_tag_out = wait_int;
				end
		end			

			
		//forward data
		lsq_CDB_result_out1 = 0;
		lsq_CDB_result_out2 = 0;
		lsq_CDB_result_is_valid1 = 0;
		lsq_CDB_result_is_valid2 = 0;
		lsq_CDB_dest_tag1 = 0;
		lsq_CDB_dest_tag2 = 0;
		ld_out_idx1=0;
		ld_out_idx2=0;

		priority_selector #(2,`LQ_SIZE)load(
			req(lq_reg_data_valid),
			en(1'b1),
    		// Outputs
			gnt_bus({lq_cdb1,lq_cdb2}),
		);
	

		for(int i=0; i<`LQ_SIZE; i++) begin		//forward
				if(lq_cdb1[i]) begin
					lsq_CDB_result_is_valid1 = 1;
					n_lq_reg_addr_valid[i] = 0;
					n_lq_reg_inst_valid[i] = 0;
					n_lq_reg_data_valid[i] = 0;
					lsq_CDB_dest_tag1 	= sq_reg_dest_tag[i];
					lsq_CDB_result_out1 = lq_reg_data[i];
				end //if
				if(lq_cdb2[i]) begin
					lsq_CDB_result_is_valid2 = 1;
					n_lq_reg_addr_valid[i] = 0;
					n_lq_reg_inst_valid[i] = 0;
					n_lq_reg_data_valid[i] = 0;
					lsq_CDB_dest_tag2 	= sq_reg_dest_tag[i];
					lsq_CDB_result_out2 = lq_reg_data[i];
				end //if
		end //for	


		//load retires
		rob2_excuted = 1;
		for(int i=0; i<`LQ_SIZE; i++) begin	
				if(lq_rob_idx[i]==rob_commit_idx1 && lq_reg_inst_valid[i])begin
					rob1_excuted = 0;
				end
				if(lq_rob_idx[i]==rob_commit_idx2 && lq_reg_inst_valid[i]) begin
					rob2_excuted = 0;
				end
			end
		end
	end //comb
	
	
	always_comb begin
		if (thread1_mispredict) begin
			for (int i = 0; i < `LQ_SIZE; i++) begin
				if (lq_rob_idx[i][$clog2(`ROB_SIZE)] == 0) begin
					lq_reg_addr_valid[i] 	<= #1 0;
					lq_reg_inst_valid[i] 	<= #1 0;
					lq_reg_data_valid[i]	<= #1 0;
				end
			end
		end
		if (thread2_mispredict) begin
			for (int i = 0; i < `LQ_SIZE; i++) begin
				if (lq_rob_idx[i][$clog2(`ROB_SIZE)] == 1) begin
					lq_reg_addr_valid[i] 	<= #1 0;
					lq_reg_inst_valid[i] 	<= #1 0;
					lq_reg_data_valid[i]	<= #1 0;
				end
			end
		end
	end
	
endmodule 

