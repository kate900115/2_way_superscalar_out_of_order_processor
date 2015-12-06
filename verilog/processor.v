//////////////////////////////////////////////////////////////////////////
//																		//
//   Modulename :  processor.v                                          //
//                                                                      //
//  Description :  														//
//                                                        				//
//                                                       				//
//////////////////////////////////////////////////////////////////////////

module processor(
//input
    input         clock,                    // System clock
    input         reset,                    // System reset
    input [3:0]   mem2proc_response,        // Tag from memory about current request
    input [63:0]  mem2proc_data,            // Data coming back from memory
    input [3:0]   mem2proc_tag,              // Tag from memory about current reply

    output BUS_COMMAND  proc2mem_command,    // command sent to memory
    output logic [63:0] proc2mem_addr,      // Address sent to memory
    output logic [63:0] proc2mem_data,      // Data sent to memory

    output logic [3:0]  pipeline_completed_insts,
    //output ERROR_CODE   pipeline_error_status,

    // testing hooks (these must be exported so we can test
    // the synthesized version) data is tested by looking at
    // the final values in memory

//output
    //Output from rob
    output logic							ROB_commit1_valid,
	output logic [$clog2(`ARF_SIZE)-1:0]	ROB_commit1_arn_dest,
	output logic 							ROB_commit1_wr_en,
    output logic [63:0]						PRF_writeback_value1,
    output logic							ROB_commit2_valid,
    output logic [$clog2(`ARF_SIZE)-1:0]	ROB_commit2_arn_dest,
	output logic 							ROB_commit2_wr_en,
    output logic [63:0]						PRF_writeback_value2,
    output ERROR_CODE   pipeline_error_status,
    
    // Outputs from IF-Stage 
    output logic [63:0]						PC_proc2Imem_addr,
    output logic [63:0]						PC_proc2Imem_addr_previous,
    output logic [31:0]						PC_inst1,
    output logic [31:0]						PC_inst2,
    output logic							PC_inst1_valid,
    output logic							PC_inst2_valid,
    
    // Outputs from RS
	output logic [5:0][63:0]				fu_next_inst_pc_out,
	output logic [5:0][5:0]					RS_EX_op_type,
	output ALU_FUNC [5:0]					RS_EX_alu_func,
	
	// Outputs from EX-stage
	output logic [5:0][63:0]				fu_inst_pc_out,	
	output ALU_FUNC [5:0]					EX_alu_func_out,
    output logic [5:0][5:0]					EX_rs_op_type_out,
    output logic [5:0]						EX_RS_fu_is_available,
    output logic [5:0]						EX_CDB_fu_result_is_valid,
	
	// Outputs from ROB
	output logic [63:0]						ROB_commit1_pc,
	output logic [63:0]						ROB_commit2_pc,
	output logic [31:0]						ROB_commit1_inst_out,
	output logic [31:0]						ROB_commit2_inst_out

);

logic	thread1_branch_is_taken_pc;  //for pc to change addr
logic	thread2_branch_is_taken_pc;

logic	thread1_branch_is_taken;  //for flush
logic	thread2_branch_is_taken;
//pc output
logic			PC_thread1_is_available;
//decoder
logic [63:0]	ID_inst1_opa;
logic [63:0]	ID_inst1_opb;
logic			ID_inst1_opa_valid;
logic			ID_inst1_opb_valid;
logic [63:0]	ID_inst2_opa;
logic [63:0]	ID_inst2_opb;
logic			ID_inst2_opa_valid;
logic			ID_inst2_opb_valid;
logic [4:0]		ID_dest_ARF_idx1;
logic [4:0]		ID_dest_ARF_idx2;
ALU_FUNC		ID_alu_func1;
ALU_FUNC		ID_alu_func2;
FU_SELECT		ID_fu_select1;
FU_SELECT		ID_fu_select2;
logic [5:0]		ID_op_type1;
logic [5:0]		ID_op_type2;
logic			ID_inst1_is_cond_branch;
logic			ID_inst2_is_cond_branch;
logic			ID_inst1_is_uncond_branch;
logic			ID_inst2_is_uncond_branch;
logic			ID_inst1_is_valid;
logic			ID_inst2_is_valid;
logic			ID_inst1_is_halt;
logic			ID_inst2_is_halt;
logic			ID_inst1_is_illegal;
logic			ID_inst2_is_illegal;
logic [4:0]			ID_rega_inst1;
logic [4:0]			ID_rega_inst2;

//rat output
logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_opa_idx1;
logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_opb_idx1;
logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_opa_idx2;
logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_opb_idx2;

logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_opa_idx1;
logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_opb_idx1;
logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_opa_idx2;
logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_opb_idx2;

logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_rega_idx1;
logic [$clog2(`PRF_SIZE)-1:0]	RAT1_PRF_rega_idx2;
logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_rega_idx1;
logic [$clog2(`PRF_SIZE)-1:0]	RAT2_PRF_rega_idx2;

logic	RAT1_PRF_allocate_req1;
logic	RAT1_PRF_allocate_req2;
logic	RAT2_PRF_allocate_req1;
logic	RAT2_PRF_allocate_req2;

logic	[`PRF_SIZE-1:0]		RAT1_PRF_free_list;
logic	[`PRF_SIZE-1:0]		RAT2_PRF_free_list;
logic				rat1_prf_free_valid;
logic				rat2_prf_free_valid;


//prf output
logic	PRF_RAT1_rename_valid1;
logic	PRF_RAT1_rename_valid2;
logic	PRF_RAT2_rename_valid1;
logic	PRF_RAT2_rename_valid2;

logic [$clog2(`PRF_SIZE)-1:0]	PRF_RAT1_rename_idx1;
logic [$clog2(`PRF_SIZE)-1:0]	PRF_RAT1_rename_idx2;
logic [$clog2(`PRF_SIZE)-1:0]	PRF_RAT2_rename_idx1;
logic [$clog2(`PRF_SIZE)-1:0]	PRF_RAT2_rename_idx2;

logic [63:0]	PRF_RS_inst1_opa;
logic [63:0]	PRF_RS_inst1_opb;
logic [63:0]	PRF_RS_inst2_opa;
logic [63:0]	PRF_RS_inst2_opb;
logic			PRF_RS_inst1_opa_valid;
logic			PRF_RS_inst1_opb_valid;
logic			PRF_RS_inst2_opa_valid;
logic			PRF_RS_inst2_opb_valid;

logic [63:0]    PRF_RS_inst1_opc;
logic [63:0] 	PRF_RS_inst2_opc;	
logic			PRF_RS_inst1_opc_valid;
logic			PRF_RS_inst2_opc_valid;	

logic			PRF_is_full;

//rrat output
logic [`ARF_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]		RRAT_RAT_mispredict_up_idx1;
logic [`ARF_SIZE-1:0][$clog2(`PRF_SIZE)-1:0]		RRAT_RAT_mispredict_up_idx2;
logic							RRAT1_PRF_free_valid1;
logic [$clog2(`PRF_SIZE)-1:0]	RRAT1_PRF_free_idx1;
logic 							RRAT1_PRF_free_valid2;
logic [$clog2(`PRF_SIZE)-1:0]	RRAT1_PRF_free_idx2;
logic							RRAT2_PRF_free_valid1;
logic [$clog2(`PRF_SIZE)-1:0]	RRAT2_PRF_free_idx1;
logic 							RRAT2_PRF_free_valid2;
logic [$clog2(`PRF_SIZE)-1:0]	RRAT2_PRF_free_idx2;
logic [`PRF_SIZE-1:0]			RRAT1_PRF_free_enable_list;
logic [`PRF_SIZE-1:0]			RRAT2_PRF_free_enable_list;

//rob output
logic ROB_t1_is_full;
logic ROB_t2_is_full;
logic [$clog2(`ROB_SIZE):0]		ROB_inst1_rob_idx;
//logic							ROB_commit1_if_rename_out;
logic 					ROB_commit1_is_valid;	
logic [$clog2(`ROB_SIZE):0]		ROB_inst2_rob_idx;
//logic							ROB_commit2_if_rename_out;
logic 					ROB_commit2_is_valid;
logic							cdb1_branch_taken;
logic							cdb2_branch_taken;
logic [63:0]					ROB_commit1_target_pc;
logic [63:0]					ROB_commit2_target_pc;
logic [$clog2(`PRF_SIZE)-1:0]	ROB_commit1_prn_dest;
logic [$clog2(`PRF_SIZE)-1:0]	ROB_commit2_prn_dest;
logic 							ROB_commit1_is_thread1;
logic 							ROB_commit1_is_branch;
logic 							ROB_commit2_is_thread1;
logic							ROB_commit2_is_branch;
logic							ROB_commit1_is_halt;
logic							ROB_commit1_is_illegal;
logic							ROB_commit2_is_halt;
logic							ROB_commit2_is_illegal;
logic							ROB_commit1_branch_taken;
logic 							ROB_commit2_branch_taken;
//rs output
logic [5:0][63:0]		RS_EX_opa;
logic [5:0][63:0]		RS_EX_opb;

logic [5:0][63:0]		RS_EX_opc;
logic [5:0][$clog2(`PRF_SIZE)-1:0]	RS_EX_dest_tag;
logic [5:0][$clog2(`ROB_SIZE):0]	RS_EX_rob_idx;
logic [5:0]					RS_EX_out_valid;
logic [5:0] [1:0]			RS_EX_branch_out;
logic						RS_full;

//ex output
//logic [5:0]							EX_RS_fu_is_available;
logic [5:0][$clog2(`PRF_SIZE)-1:0]	EX_CDB_dest_tag;
logic [5:0][63:0]					EX_CDB_fu_result_out;
//logic [5:0]							EX_CDB_fu_result_is_valid;
logic [5:0][$clog2(`ROB_SIZE):0]	EX_CDB_rob_idx;
logic [1:0]							EX_CDB_mispredict_sig;
//ex success send to cdb
logic					adder1_send_in_success;
logic					adder2_send_in_success;
logic					mult1_send_in_success;
logic					mult2_send_in_success;
logic					memory1_send_in_success;
logic					memory2_send_in_success;

//cdb output
logic							cdb1_valid;
logic [63:0]					cdb1_value;
logic [$clog2(`PRF_SIZE)-1:0]	cdb1_tag;
logic [$clog2(`ROB_SIZE):0]		cdb1_rob_idx;
logic							cdb2_valid;
logic [63:0]					cdb2_value;
logic [$clog2(`PRF_SIZE)-1:0]	cdb2_tag;
logic [$clog2(`ROB_SIZE):0]		cdb2_rob_idx;

logic [63:0]	thread1_target_pc;
logic [63:0]	thread2_target_pc;

//BTB output
logic [63:0]	BTB_target_inst1_pc;
logic [63:0]	BTB_target_inst2_pc;
logic			BTB_target_inst1_valid;
logic			BTB_target_inst2_valid;



//predictor output
logic 	inst1_mispredict;
logic 	inst2_mispredict;
logic 	inst1_mispredict_valid;
logic 	inst2_mispredict_valid;
logic inst1_predict;             //inst predict signal
logic inst1_predict_valid;
logic inst2_predict;
logic inst2_predict_valid;

// Icache output
logic 									Icache_valid_out;
logic [`ICACHE_BLOCK_SIZE-1:0]			Icache_data_out;
logic [3:0]								Icache2proc_response;
logic [3:0]								Icache2proc_tag;
logic [63:0]							Icache2proc_addr;
BUS_COMMAND  							Icache2proc_command;

logic Imem2proc_valid;
BUS_COMMAND	LSQ2Dcache_command;
logic [63:0]		LSQ_address_out;
assign proc2mem_command	= (LSQ2Dcache_command == BUS_NONE) ? Icache2proc_command : LSQ2Dcache_command;
assign proc2mem_addr 	= (LSQ2Dcache_command == BUS_NONE) ? Icache2proc_addr : LSQ_address_out;
							
always_comb begin
   	if((ROB_commit1_is_thread1 && ROB_commit1_is_branch && inst1_mispredict && inst1_mispredict_valid)) begin
		if(ROB_commit1_branch_taken)
			thread1_target_pc = ROB_commit1_target_pc;
		else
   			thread1_target_pc = ROB_commit1_pc;
	end
   	else if(ROB_commit2_is_thread1 && ROB_commit2_is_branch && inst2_mispredict && inst2_mispredict_valid) begin
		if(ROB_commit2_branch_taken)
			thread1_target_pc = ROB_commit2_target_pc;
		else
   			thread1_target_pc = ROB_commit2_pc;
	end
   	else if(BTB_target_inst1_valid)
   		thread1_target_pc = BTB_target_inst1_pc;
  	else if (BTB_target_inst2_valid)
 		thread1_target_pc = BTB_target_inst2_pc;
 	else 
		thread1_target_pc =0;
end

always_comb begin
   	if((~ROB_commit1_is_thread1 && ROB_commit1_is_branch && inst1_mispredict && inst1_mispredict_valid)) begin
		if(ROB_commit1_branch_taken)
			thread2_target_pc = ROB_commit1_target_pc;
		else
   			thread2_target_pc = ROB_commit1_pc;
	end
   	else if(~ROB_commit2_is_thread1 && ROB_commit2_is_branch && inst2_mispredict && inst2_mispredict_valid) begin
		if(ROB_commit2_branch_taken)
			thread2_target_pc = ROB_commit2_target_pc;
		else
   			thread2_target_pc = ROB_commit2_pc;
	end
   	else if (BTB_target_inst1_valid)
   		thread2_target_pc = BTB_target_inst1_pc;
  	else if (BTB_target_inst2_valid)
 		thread2_target_pc = BTB_target_inst2_pc;
 	else 
		thread2_target_pc =0;
end
/*assign thread2_target_pc = 	(~ROB_commit1_is_thread1 && ROB_commit1_is_branch && inst1_mispredict&& inst1_mispredict_valid) ? (ROB_commit1_target_pc) : 
							(~ROB_commit2_is_thread1 && ROB_commit2_is_branch && inst2_mispredict&&inst2_mispredict_valid) ? (ROB_commit2_target_pc) : 
							(BTB_target_inst2_valid)?BTB_target_inst2_pc:BTB_target_inst1_pc;*/
							
assign ROB_commit1_wr_en = ROB_commit1_arn_dest != `ZERO_REG;
assign ROB_commit2_wr_en = ROB_commit2_arn_dest != `ZERO_REG;
assign pipeline_error_status =  ROB_commit1_is_illegal            ? HALTED_ON_ILLEGAL_I1 :
                                ROB_commit1_is_halt               ? HALTED_ON_HALT_I1 :
                                ROB_commit2_is_illegal            ? HALTED_ON_ILLEGAL_I2 :
                                ROB_commit2_is_halt               ? HALTED_ON_HALT_I2 :
                                //(mem2proc_response==4'h0)  ? HALTED_ON_MEMORY_ERROR :
                                NO_ERROR;
 
//HERE THE BRANCH TAKEN SIGNAL IS THE MISPREDICT SIGNAL                              
assign thread1_branch_is_taken_pc = (inst1_mispredict&&inst1_mispredict_valid && ROB_commit1_is_thread1) || (inst2_mispredict&&inst2_mispredict_valid && ROB_commit2_is_thread1) ||(BTB_target_inst2_valid || BTB_target_inst1_valid); //predict taken 
assign thread2_branch_is_taken_pc = (inst1_mispredict&&inst1_mispredict_valid && ~ROB_commit1_is_thread1) || (inst2_mispredict&&inst2_mispredict_valid && ~ROB_commit2_is_thread1) ||(BTB_target_inst2_valid || BTB_target_inst1_valid);
assign thread1_branch_is_taken = (inst1_mispredict&&inst1_mispredict_valid && ROB_commit1_is_thread1) || (inst2_mispredict&&inst2_mispredict_valid && ROB_commit2_is_thread1);
assign thread2_branch_is_taken = (inst1_mispredict&&inst1_mispredict_valid && ~ROB_commit1_is_thread1) || (inst2_mispredict&&inst2_mispredict_valid && ~ROB_commit2_is_thread1);
//assign Imem2proc_valid = !(mem2proc_tag == 0);
assign Icache2proc_valid = !(Icache2proc_tag == 0)|| Icache_valid_out; //Imem 
assign pipeline_completed_insts = {3'b0,ROB_commit1_valid || ROB_commit2_valid};
//////////////////////////////////
//								//
//			  PC				//
//								//
//////////////////////////////////
if_stage pc(
//input
	.clock(clock),							// system clock
	.reset(reset), 							// system reset
	.thread1_branch_is_taken(thread1_branch_is_taken_pc),
	.thread2_branch_is_taken(thread2_branch_is_taken_pc),
	.thread1_target_pc(thread1_target_pc),
	.thread2_target_pc(thread2_target_pc),
	.rs_stall(RS_full),		 				// when RS is full, we need to stop PC
	.rob1_stall(ROB_t1_is_full),		 				// when RoB1 is full, we need to stop PC1
	.rob2_stall(ROB_t2_is_full),						// when RoB2 is full, we need to stop PC2
	.rat_stall(PRF_is_full),						// when the freelist of PRF is empty, RAT generate a stall signal
	.thread1_structure_hazard_stall(1'b0),	// If data and instruction want to use memory at the same time
	.thread2_structure_hazard_stall(1'b0),	// If data and instruction want to use memory at the same time
	.Imem2proc_data(Icache_data_out),					// Data coming back from instruction-memory
	.Imem2proc_valid(Icache2proc_valid),				// 
	.is_two_threads(1'b0),
//output
	.proc2Imem_addr(PC_proc2Imem_addr),
	//.next_PC_out(,
	.thread1_inst_out(PC_inst1),
	.thread2_inst_out(PC_inst2),
	.thread1_inst_is_valid(PC_inst1_valid),
	.thread2_inst_is_valid(PC_inst2_valid),
	.thread1_is_available(PC_thread1_is_available),
	//for debug
	.proc2Imem_addr_previous(PC_proc2Imem_addr_previous)
	);

//////////////////////////////////
//								//
//			 ICACHE				//
//								//
//////////////////////////////////
icache ica(
	.clock(clock),
	.reset(reset),
	
	// input from processor.v
	.proc2Icache_addr(PC_proc2Imem_addr),	
	.proc2Icache_command(BUS_LOAD),
	
	// input from memory
	.Imem2proc_response(mem2proc_response),
	.Imem2proc_tag(mem2proc_tag),
	.Imem2proc_data(mem2proc_data),
	
	// output to mem.v
	.proc2Imem_command(Icache2proc_command),
	.proc2Imem_addr(Icache2proc_addr),
	
	// output to processor.v
	.Icache_data_out(Icache_data_out),
	.Icache_valid_out(Icache_valid_out),
	.Icache2proc_tag(Icache2proc_tag),	 	
	.Icache2proc_response(Icache2proc_response)
	);

//////////////////////////////////
//								//
//			Decoder				//
//								//
//////////////////////////////////
id_stage id(
//input
	.clock(clock),							// system clock
	.reset(reset), 							// system reset
	.if_id_IR1(PC_inst1),             		// incoming instruction1
	.if_id_IR2(PC_inst2),             		// incoming instruction2

	.if_id_valid_inst1(PC_inst1_valid),
	.if_id_valid_inst2(PC_inst2_valid),
	.if_id_NPC_inst1(PC_proc2Imem_addr_previous),           // incoming instruction1 PC
	.if_id_NPC_inst2(PC_proc2Imem_addr_previous+4),           // incoming instruction PC+4
//output

	.id_rega_inst1(ID_rega_inst1),
	.id_rega_inst2(ID_rega_inst2),            //branch rega

	.opa_mux_out1(ID_inst1_opa),               //instr1 opa and opb value or tag
	.opb_mux_out1(ID_inst1_opb),
	.opa_mux_tag1(ID_inst1_opa_valid),               //signal to indicate whether it is value or tag,true means value,faulse means tag
	.opb_mux_tag1(ID_inst1_opb_valid),
	.id_dest_reg_idx_out1(ID_dest_ARF_idx1),  // destination (writeback) register index
													        // (ZERO_REG if no writeback)
				 
	.opa_mux_out2(ID_inst2_opa),               //instr2 opa and opb value or tag
	.opb_mux_out2(ID_inst2_opb),
	.opa_mux_tag2(ID_inst2_opa_valid),               //signal to indicate whether it is value or tag
	.opb_mux_tag2(ID_inst2_opb_valid),
	.id_dest_reg_idx_out2(ID_dest_ARF_idx2),  // destination (writeback) register index


	.id_alu_func_out1(ID_alu_func1),      // ALU function select (ALU_xxx *)
	.id_alu_func_out2(ID_alu_func2),      // ALU function select (ALU_xxx *)
	.id_op_type_inst1(ID_op_type1),
	.id_op_type_inst2(ID_op_type2),
	
	.id_op_select1(ID_fu_select1),		// op type
	.id_op_select2(ID_fu_select2),


	//.id_rd_mem_out1,        // does inst read memory?
	//.id_wr_mem_out1,        // does inst write memory?
	//.id_ldl_mem_out1,       // load-lock inst?
	//.id_stc_mem_out1,       // store-conditional inst?
	.id_cond_branch_out1(ID_inst1_is_cond_branch),   // is inst a conditional branch?
	.id_uncond_branch_out1(ID_inst1_is_uncond_branch), // is inst an unconditional branch 
													        // or jump?
	.id_halt_out1(ID_inst1_is_halt),
	//.id_cpuid_out1,         // get CPUID inst?
	.id_illegal_out1(ID_inst1_is_illegal),
	.id_valid_inst_out1(ID_inst1_is_valid),     // is inst a valid instruction to be 
													        // counted for CPI calculations?
	//.id_rd_mem_out2,        // does inst read memory?
	//.id_wr_mem_out2,        // does inst write memory?
	//.id_ldl_mem_out2,       // load-lock inst?
	//.id_stc_mem_out2,       // store-conditional inst?
	.id_cond_branch_out2(ID_inst2_is_cond_branch),   // is inst a conditional branch?
	.id_uncond_branch_out2(ID_inst2_is_uncond_branch), // is inst an unconditional branch 
													        // or jump?
	.id_halt_out2(ID_inst2_is_halt),
	//.id_cpuid_out2,         // get CPUID inst?
	.id_illegal_out2(ID_inst2_is_illegal),
	.id_valid_inst_out2(ID_inst2_is_valid)     // is inst a valid instruction to be 
);
//////////////////////////////////
//								//
//			 RAT				//
//								//
//////////////////////////////////
rat rat1(
//input
	.clock(clock),				// system clock
	.reset(reset),          	// system reset
	
	.inst1_enable(PC_thread1_is_available && PC_inst1_valid),	//high if inst can run
	.inst2_enable(PC_thread1_is_available && PC_inst2_valid),
	.opa_ARF_idx1(ID_inst1_opa[4:0]),	//we will use opa_ARF_idx to find PRF_idx
	.opb_ARF_idx1(ID_inst1_opb[4:0]),	//to find PRF_idx
	.dest_ARF_idx1(ID_dest_ARF_idx1),	//the ARF index of dest reg
	.dest_rename_sig1(ID_dest_ARF_idx1 != `ZERO_REG),	//if high, dest_reg need rename

	.opa_ARF_idx2(ID_inst2_opa[4:0]),	//we will use opa_ARF_idx to find PRF_idx
	.opb_ARF_idx2(ID_inst2_opb[4:0]),	//to find PRF_idx
	.dest_ARF_idx2(ID_dest_ARF_idx2),	//the ARF index of dest reg
	.dest_rename_sig2(ID_dest_ARF_idx2 != `ZERO_REG),	//if high, dest_reg need rename

	.rega_arf_inst1(ID_rega_inst1),
	.rega_arf_inst2(ID_rega_inst2),


	.opa_valid_in1(ID_inst1_opa_valid),	//if high opa_valid is immediate
	.opb_valid_in1(ID_inst1_opb_valid),
	.opa_valid_in2(ID_inst2_opa_valid),	//if high opa_valid is immediate
	.opb_valid_in2(ID_inst2_opb_valid),

	.mispredict_sig1(inst1_mispredict&&inst1_mispredict_valid && ROB_commit1_is_thread1),	//indicate whether mispredict happened
	.mispredict_sig2(inst2_mispredict&&inst2_mispredict_valid && ROB_commit2_is_thread1),	//indicate whether mispredict happened
	.mispredict_up_idx(RRAT_RAT_mispredict_up_idx1),

	//Notion: valid1 and idx is the first PRF to use!!!!!!
	//Not for inst1!!!!!!!!!!
	.PRF_rename_valid1(PRF_RAT1_rename_valid1),							//we get valid signal from prf if the dest address has been request
	.PRF_rename_idx1(PRF_RAT1_rename_idx1),								//the PRF alocated for dest
	.PRF_rename_valid2(PRF_RAT1_rename_valid2),							//we get valid signal from prf if the dest address has been request
	.PRF_rename_idx2(PRF_RAT1_rename_idx2),								//the PRF alocated for dest

	//output
	.opa_PRF_idx1(RAT1_PRF_opa_idx1),
	.opb_PRF_idx1(RAT1_PRF_opb_idx1),
	.request1(RAT1_PRF_allocate_req1),  //send to PRF indicate whether it need data
	//.RAT_allo_halt1(),



	//output 2
	.opa_PRF_idx2(RAT1_PRF_opa_idx2),
	.opb_PRF_idx2(RAT1_PRF_opb_idx2),
	.request2(RAT1_PRF_allocate_req2),  //send to PRF indicate whether it need data
	//.RAT_allo_halt2(),

	.rega_prf_inst1(RAT1_PRF_rega_idx1),
	.rega_prf_inst2(RAT1_PRF_rega_idx2),

	//output together
	.PRF_free_list_out(RAT1_PRF_free_list),
	.PRF_free_valid(rat1_prf_free_valid)
	);
	
rat rat2(
//input
	.clock(clock),				// system clock
	.reset(reset),          	// system reset
	
	.inst1_enable(~PC_thread1_is_available && PC_inst1_valid),	//high if inst can run
	.inst2_enable(~PC_thread1_is_available && PC_inst2_valid),
	
	.opa_ARF_idx1(ID_inst1_opa[4:0]),	//we will use opa_ARF_idx to find PRF_idx
	.opb_ARF_idx1(ID_inst1_opb[4:0]),	//to find PRF_idx
	.dest_ARF_idx1(ID_dest_ARF_idx1),	//the ARF index of dest reg
	.dest_rename_sig1(ID_dest_ARF_idx1 != `ZERO_REG),	//if high, dest_reg need rename

	.opa_ARF_idx2(ID_inst2_opa[4:0]),	//we will use opa_ARF_idx to find PRF_idx
	.opb_ARF_idx2(ID_inst2_opb[4:0]),	//to find PRF_idx
	.dest_ARF_idx2(ID_dest_ARF_idx2),	//the ARF index of dest reg
	.dest_rename_sig2(ID_dest_ARF_idx2 != `ZERO_REG),	//if high, dest_reg need rename

	.rega_arf_inst1(ID_rega_inst1),
	.rega_arf_inst2(ID_rega_inst2),


	.opa_valid_in1(ID_inst1_opa_valid),	//if high opa_valid is immediate
	.opb_valid_in1(ID_inst1_opb_valid),
	.opa_valid_in2(ID_inst2_opa_valid),	//if high opb_valid is immediate
	.opb_valid_in2(ID_inst2_opb_valid),

	.mispredict_sig1(inst1_mispredict&&inst1_mispredict_valid && ~ROB_commit1_is_thread1),	//indicate whether mispredict happened
	.mispredict_sig2(inst2_mispredict&&inst2_mispredict_valid && ~ROB_commit2_is_thread1),	//indicate whether mispredict happened
	.mispredict_up_idx(RRAT_RAT_mispredict_up_idx2),	//if mispredict happens, need to copy from rrat

	//Notion: valid1 and idx is the first PRF to use!!!!!!
	//Not for inst1!!!!!!!!!!
	.PRF_rename_valid1(PRF_RAT2_rename_valid1),							//we get valid signal from prf if the dest address has been request
	.PRF_rename_idx1(PRF_RAT2_rename_idx1),	//the PRF alocated for dest
	.PRF_rename_valid2(PRF_RAT2_rename_valid2),							//we get valid signal from prf if the dest address has been request
	.PRF_rename_idx2(PRF_RAT2_rename_idx2),	//the PRF alocated for dest
//output
	.opa_PRF_idx1(RAT2_PRF_opa_idx1),
	.opb_PRF_idx1(RAT2_PRF_opb_idx1),
	.request1(RAT2_PRF_allocate_req1),  //send to PRF indicate whether it need data
	//.RAT_allo_halt1(RAT2_PRF_allocate_req1),

	//output 2
	.opa_PRF_idx2(RAT2_PRF_opa_idx2),
	.opb_PRF_idx2(RAT2_PRF_opb_idx2),
	.request2(RAT2_PRF_allocate_req2),  //send to PRF indicate whether it need data
	//.RAT_allo_halt2(RAT2_PRF_allocate_req2),

	.rega_prf_inst1(RAT2_PRF_rega_idx1),
	.rega_prf_inst2(RAT2_PRF_rega_idx2),

	//output together
	.PRF_free_list_out(RAT2_PRF_free_list),
	.PRF_free_valid(rat2_prf_free_valid)//high when mispredict
	);

//////////////////////////////////
//								//
//			 RRAT				//
//								//
//////////////////////////////////
rrat rrat1(
	//input
	.clock(clock),				// system clock
	.reset(reset),          	// system reset 

	.inst1_enable(ROB_commit1_valid && ROB_commit1_is_thread1),						//*************
	.inst2_enable(ROB_commit2_valid && ROB_commit2_is_thread1),						//**********

	.RoB_PRF_idx1(ROB_commit1_prn_dest),									
	.RoB_ARF_idx1(ROB_commit1_arn_dest),
	.RoB_retire_in1(ROB_commit1_valid && ROB_commit1_is_thread1),	//high when instruction retires
	.mispredict_sig1(inst1_mispredict&&inst1_mispredict_valid),

	.RoB_PRF_idx2(ROB_commit2_prn_dest),
	.RoB_ARF_idx2(ROB_commit2_arn_dest),
	.RoB_retire_in2(ROB_commit2_valid && ROB_commit2_is_thread1),	//high when instruction retires
	.mispredict_sig2(inst2_mispredict&&inst2_mispredict_valid),

	//output
	.PRF_free_valid1(RRAT1_PRF_free_valid1),
	.PRF_free_idx1(RRAT1_PRF_free_idx1),
	.PRF_free_valid2(RRAT1_PRF_free_valid2),
	.PRF_free_idx2(RRAT1_PRF_free_idx2),
	.mispredict_up_idx(RRAT_RAT_mispredict_up_idx1),
	.PRF_free_enable_list(RRAT1_PRF_free_enable_list)
);

rrat rrat2(
	//input
	.clock(clock),				// system clock
	.reset(reset),          	// system reset 

	.inst1_enable(ROB_commit1_valid && ~ROB_commit1_is_thread1),							//******************
	.inst2_enable(ROB_commit2_valid && ~ROB_commit2_is_thread1),							//****************

	.RoB_PRF_idx1(ROB_commit1_prn_dest),
	.RoB_ARF_idx1(ROB_commit1_arn_dest),
	.RoB_retire_in1(ROB_commit1_valid && ~ROB_commit1_is_thread1),	//high when instruction retires
	.mispredict_sig1(inst1_mispredict&&inst1_mispredict_valid),

	.RoB_PRF_idx2(ROB_commit2_prn_dest),
	.RoB_ARF_idx2(ROB_commit2_arn_dest),
	.RoB_retire_in2(ROB_commit2_valid && ~ROB_commit2_is_thread1),	//high when instruction retires
	.mispredict_sig2(inst2_mispredict&&inst2_mispredict_valid),
//output
	.PRF_free_valid1(RRAT2_PRF_free_valid1),
	.PRF_free_idx1(RRAT2_PRF_free_idx1),
	.PRF_free_valid2(RRAT2_PRF_free_valid2),
	.PRF_free_idx2(RRAT2_PRF_free_idx2),
	.mispredict_up_idx(RRAT_RAT_mispredict_up_idx2),
	.PRF_free_enable_list(RRAT2_PRF_free_enable_list)
);

//////////////////////////////////
//								//
//			 PRF				//
//								//
//////////////////////////////////
prf prf1(
//input
	.clock(clock),				// system clock
	.reset(reset),          	// system reset
	//cdb
	.cdb1_valid(cdb1_valid),
	.cdb1_tag(cdb1_tag),
	.cdb1_out(cdb1_value),
	.cdb2_valid(cdb2_valid),
	.cdb2_tag(cdb2_tag),
	.cdb2_out(cdb2_value),
	//rat
	.rat1_inst1_opa_prf_idx(RAT1_PRF_opa_idx1),			// opa prf index of instruction1			***********not
	.rat1_inst1_opb_prf_idx(RAT1_PRF_opb_idx1),			// opb prf index of instruction1
	.rat1_inst2_opa_prf_idx(RAT1_PRF_opa_idx2),			// opa prf index of instruction2
	.rat1_inst2_opb_prf_idx(RAT1_PRF_opb_idx2),			// opb prf index of instruction2
	.rat2_inst1_opa_prf_idx(RAT2_PRF_opa_idx1),			// opa prf index of instruction1
	.rat2_inst1_opb_prf_idx(RAT2_PRF_opb_idx1),			// opb prf index of instruction1
	.rat2_inst2_opa_prf_idx(RAT2_PRF_opa_idx2),			// opa prf index of instruction2
	.rat2_inst2_opb_prf_idx(RAT2_PRF_opb_idx2),			// opb prf index of instruction2

	.rat1_inst1_opc_prf_idx(RAT1_PRF_rega_idx1),
	.rat1_inst2_opc_prf_idx(RAT1_PRF_rega_idx2),				//for branch operand 
	.rat2_inst1_opc_prf_idx(RAT2_PRF_rega_idx1),
	.rat2_inst2_opc_prf_idx(RAT2_PRF_rega_idx2),

	.rat1_allocate_new_prf1(RAT1_PRF_allocate_req1),			// the request from rat1 for allocating a new prf entry
	.rat1_allocate_new_prf2(RAT1_PRF_allocate_req2),			// the request from rat1 for allocating a new prf entry
	.rat2_allocate_new_prf1(RAT2_PRF_allocate_req1),			// the request from rat2 for allocating a new prf entry
	.rat2_allocate_new_prf2(RAT2_PRF_allocate_req2),			// the request from rat2 for allocating a new prf entry

	.rrat1_prf_free_list(RRAT1_PRF_free_enable_list),				// when a branch is mispredict, RRAT1 gives a freelist to PRF
	.rrat2_prf_free_list(RRAT2_PRF_free_enable_list),				// when a branch is mispredict, RRAT2 gives a freelist to PRF
	.rrat1_branch_mistaken_free_valid(inst1_mispredict&&inst1_mispredict_valid),			// when a branch is mispredict, RRAT1 gives a freelist to PRF
	.rrat2_branch_mistaken_free_valid(inst2_mispredict&&inst2_mispredict_valid),			// when a branch is mispredict, RRAT2 gives a freelist to PRF
	.rat1_prf_free_list(RAT1_PRF_free_list),			// when a branch is mispredict, RAT1 gives a freelist to PRF
	.rat2_prf_free_list(RAT2_PRF_free_list),			// when a branch is mispredict, RAT2 gives a freelist to PRF

	.rrat1_prf1_free_valid(RRAT1_PRF_free_valid1),				// when an instruction retires from RRAT1, RRAT1 gives out a signal enable PRF to free its register. 
	.rrat2_prf1_free_valid(RRAT2_PRF_free_valid1),				// when an instruction retires from RRAT2, RRAT1 gives out a signal enable PRF to free its register.
	.rrat1_prf1_free_idx(RRAT1_PRF_free_idx1),				// when an instruction retires from RRAT1, RRAT1 will free a PRF, and this is its index. 
	.rrat2_prf1_free_idx(RRAT2_PRF_free_idx1),				// when an instruction retires from RRAT2, RRAT2 will free a PRF, and this is its index.
	.rrat1_prf2_free_valid(RRAT1_PRF_free_valid2),				// when an instruction retires from RRAT1, RRAT1 gives out a signal enable PRF to free its register. 
	.rrat2_prf2_free_valid(RRAT2_PRF_free_valid2),				// when an instruction retires from RRAT2, RRAT1 gives out a signal enable PRF to free its register.
	.rrat1_prf2_free_idx(RRAT1_PRF_free_idx2),				// when an instruction retires from RRAT1, RRAT1 will free a PRF, and this is its index. 
	.rrat2_prf2_free_idx(RRAT2_PRF_free_idx2),				// when an instruction retires from RRAT2, RRAT2 will free a PRF, and this is its index.
	
	.rob1_retire_idx(ROB_commit1_prn_dest),					// when rob1 retires an instruction, prf gives out the corresponding value.
	.rob2_retire_idx(ROB_commit2_prn_dest),					// when rob2 retires an instruction, prf gives out the corresponding value.
	.rat1_read_enable(PC_thread1_is_available),
	.is_one_thread(1'b1),


	//output
	.rat1_prf1_rename_valid_out(PRF_RAT1_rename_valid1),		// when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	.rat1_prf2_rename_valid_out(PRF_RAT1_rename_valid2),		// when RAT1 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	.rat2_prf1_rename_valid_out(PRF_RAT2_rename_valid1),		// when RAT2 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	.rat2_prf2_rename_valid_out(PRF_RAT2_rename_valid2),		// when RAT2 asks the PRF to allocate a new entry, PRF should make sure the returned index is valid.
	
	.rat1_prf1_rename_idx_out(PRF_RAT1_rename_idx1),		// when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	.rat1_prf2_rename_idx_out(PRF_RAT1_rename_idx2),		// when RAT1 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	.rat2_prf1_rename_idx_out(PRF_RAT2_rename_idx1),		// when RAT2 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.
	.rat2_prf2_rename_idx_out(PRF_RAT2_rename_idx2),		// when RAT2 asks the PRF to allocate a new entry, PRF should return the index of this newly allocated entry.

	.inst1_opa_prf_value(PRF_RS_inst1_opa),			// opa prf value of instruction1
	.inst1_opb_prf_value(PRF_RS_inst1_opb),			// opb prf value of instruction1
	.inst2_opa_prf_value(PRF_RS_inst2_opa),			// opa prf value of instruction2
	.inst2_opb_prf_value(PRF_RS_inst2_opb),			// opb prf value of instruction2

	.inst1_opc_prf_value(PRF_RS_inst1_opc),
	.inst2_opc_prf_value(PRF_RS_inst2_opc),
	.inst1_opc_valid(PRF_RS_inst1_opc_valid),
	.inst2_opc_valid(PRF_RS_inst2_opc_valid),

	.inst1_opa_valid(PRF_RS_inst1_opa_valid),			// whether opa load from prf of instruction1 is valid
	.inst1_opb_valid(PRF_RS_inst1_opb_valid),			// whether opb load from prf of instruction1 is valid
	.inst2_opa_valid(PRF_RS_inst2_opa_valid),			// whether opa load from prf of instruction2 is valid
	.inst2_opb_valid(PRF_RS_inst2_opb_valid),			// whether opa load from prf of instruction2 is valid

	.prf_is_full(PRF_is_full),						// if the freelist of prf is empty, prf should give out this signal
	// for write back
	.writeback_value1(PRF_writeback_value1),
	.writeback_value2(PRF_writeback_value2)
);

//////////////////////////////////
//								//
//			 ROB				//
//								//
//////////////////////////////////
rob rob1(
//input
	.clock(clock),				// system clock
	.reset(reset),          	// system reset
	
	.is_thread1(PC_thread1_is_available),					//if it ==1, it is for thread1, else it is for thread 2
//instruction1 input
	.inst1_pc_in(PC_proc2Imem_addr_previous),				//the pc of the instruction
	.inst1_arn_dest_in(ID_dest_ARF_idx1),			//the arf number of the destinaion of the instruction
	.inst1_prn_dest_in(PC_thread1_is_available ? PRF_RAT1_rename_idx1 : PRF_RAT2_rename_idx1),			//the prf number of the destination of this instruction
	.inst1_is_branch_in(ID_inst1_is_cond_branch || ID_inst1_is_uncond_branch),			//if this instruction is a branch
	.inst1_is_halt_in(ID_inst1_is_halt),
	.inst1_is_illegal_in(ID_inst1_is_illegal),
	.inst1_load_in(ID_inst1_is_valid),				//tell rob if instruction1 is valid

//instruction2 input
	.inst2_pc_in(PC_proc2Imem_addr_previous+4),				//the pc of the instruction
	.inst2_arn_dest_in(ID_dest_ARF_idx2),			//the arf number of the destinaion of the instruction
	.inst2_prn_dest_in(PC_thread1_is_available ? PRF_RAT1_rename_idx2 : PRF_RAT2_rename_idx2),          //the prf number of the destination of this instruction
	.inst2_is_branch_in(ID_inst2_is_cond_branch || ID_inst2_is_uncond_branch),			//if this instruction is a branch
	.inst2_is_halt_in(ID_inst2_is_halt),
	.inst2_is_illegal_in(ID_inst2_is_illegal),
	.inst2_load_in(ID_inst2_is_valid),		       	//tell rob if instruction2 is valid
//when executed,for each function unit,  the number of rob need to know so we can set the if_executed to of the entry to be 1
	.if_fu_executed1(cdb1_valid),		//if the instruction in the first multiplyer has been executed ************************************
	.fu_rob_idx1(cdb1_rob_idx),			//the rob number of the instruction in the first multiplyer************************************
	.mispredict_in1(cdb1_branch_taken),
	.target_pc_in1(cdb1_value),
	.if_fu_executed2(cdb2_valid),		//if the instruction in the first multiplyer has been executed ************************************
	.fu_rob_idx2(cdb2_rob_idx),			//the rob number of the instruction in the first multiplyer************************************
	.mispredict_in2(cdb2_branch_taken),
	.target_pc_in2(cdb2_value),

	//.inst1_mispredict_sig(inst1_mispredict && inst1_mispredict_valid),
	//.inst2_mispredict_sig(inst2_mispredict && inst2_mispredict_valid),
//output
//after dispatching, we need to send rs the rob number we assigned to instruction1 and instruction2
	.inst1_rs_rob_idx_in(ROB_inst1_rob_idx),					//it is combinational logic so that the output is dealt with right after a
	.inst2_rs_rob_idx_in(ROB_inst2_rob_idx),					//instruction comes in, and then this signal is immediately sent to rs to
																						//store in rs
//when committed, the output of the first instrucion committed
	.commit1_pc_out(ROB_commit1_pc),
	.commit1_target_pc_out(ROB_commit1_target_pc),
	.commit1_is_branch_out(ROB_commit1_is_branch),				       	//if this instruction is a branch
	.commit1_mispredict_out(ROB_commit1_branch_taken),				       	//if this instrucion is taken branch
	.commit1_arn_dest_out(ROB_commit1_arn_dest),                       //the architected register number of the destination of this instruction
	.commit1_prn_dest_out(ROB_commit1_prn_dest),						//the prf number of the destination of this instruction
	.commit1_if_rename_out(ROB_commit1_valid),				       	//if this entry is committed at this moment(tell RRAT)
	.commit1_valid(ROB_commit1_is_valid),
	.commit1_is_halt_out(ROB_commit1_is_halt),
	.commit1_is_illegal_out(ROB_commit1_is_illegal),
	.commit1_is_thread1(ROB_commit1_is_thread1),
//when committed, the output of the second instruction committed
	.commit2_pc_out(ROB_commit2_pc),
	.commit2_target_pc_out(ROB_commit2_target_pc),
	.commit2_is_branch_out(ROB_commit2_is_branch),						//if this instruction is a branch
	.commit2_mispredict_out(ROB_commit2_branch_taken),				       	//if this instrucion is mispredicted
	.commit2_arn_dest_out(ROB_commit2_arn_dest),						//the architected register number of the destination of this instruction
	.commit2_prn_dest_out(ROB_commit2_prn_dest),						//the prf number of the destination of this instruction
	.commit2_if_rename_out(ROB_commit2_valid),				       	//if this entry is committed at this moment(tell RRAT)
	.commit2_valid(ROB_commit2_is_valid),
	.commit2_is_halt_out(ROB_commit2_is_halt),
	.commit2_is_illegal_out(ROB_commit2_is_illegal),
	.commit2_is_thread1(ROB_commit2_is_thread1),
	.t1_is_full(ROB_t1_is_full),
	.t2_is_full(ROB_t2_is_full),
	//for debug
	.rob_inst1_in(PC_inst1),
	.rob_inst2_in(PC_inst2),
	.commit1_inst_out(ROB_commit1_inst_out),
	.commit2_inst_out(ROB_commit2_inst_out)
);


//////////////////////////////////
//								//
//			  RS				//
//								//
//////////////////////////////////
rs rs1(
//input
	.clock(clock),				// system clock
	.reset(reset),          	// system reset 

	.inst1_rs_dest_in(PC_thread1_is_available ? PRF_RAT1_rename_idx1 : PRF_RAT2_rename_idx1),     	// The destination of this instruction
	.inst2_rs_dest_in(PC_thread1_is_available ? PRF_RAT1_rename_idx2 : PRF_RAT2_rename_idx2),     	// The destination of this instruction
	//cdb input
	.rs_cdb1_in(cdb1_value),     	// CDB bus from functional units 
	.rs_cdb1_tag(cdb1_tag),    		// CDB tag bus from functional units 
	.rs_cdb1_valid(cdb1_valid),  	// The data on the CDB is valid 
	.rs_cdb2_in(cdb2_value),     	// CDB bus from functional units 
	.rs_cdb2_tag(cdb2_tag),    		// CDB tag bus from functional units 
	.rs_cdb2_valid(cdb2_valid),  	// The data on the CDB is valid 
	//for instruction1
	.inst1_rs_opa_in(ID_inst1_opa_valid ? ID_inst1_opa : PRF_RS_inst1_opa),      	// Operand a from Rename  
	.inst1_rs_opb_in(ID_inst1_opb_valid ? ID_inst1_opb : PRF_RS_inst1_opb),      	// Operand a from Rename
	.inst1_rs_opa_valid(PRF_RS_inst1_opa_valid || ID_inst1_opa_valid),   	// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	.inst1_rs_opb_valid(PRF_RS_inst1_opb_valid || ID_inst1_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 

	.inst1_rs_opc_in(PRF_RS_inst1_opc),
	.inst1_rs_opc_valid(PRF_RS_inst1_opc_valid),

	.inst1_rs_rob_idx_in(ROB_inst1_rob_idx),  	// The rob index of instruction 1
	.inst1_rs_alu_func(ID_alu_func1),
	.inst1_rs_op_type_in(ID_op_type1),  					// Instruction type from decoder
	.inst1_rs_fu_select_in(ID_fu_select1),
	.inst1_rs_load_in(ID_inst1_is_valid),     	// Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	.inst1_rs_branch_in({ID_inst1_is_cond_branch,ID_inst1_is_uncond_branch}),
	//for instruction2
	.inst2_rs_opa_in(ID_inst2_opa_valid ? ID_inst2_opa : PRF_RS_inst2_opa),      	// Operand a from Rename  
	.inst2_rs_opb_in(ID_inst2_opb_valid ? ID_inst2_opb : PRF_RS_inst2_opb),      	// Operand a from Rename 
	.inst2_rs_opa_valid(PRF_RS_inst2_opa_valid || ID_inst2_opa_valid),   	// Is Opa a Tag or immediate data (READ THIS COMMENT) 
	.inst2_rs_opb_valid(PRF_RS_inst2_opb_valid || ID_inst2_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT)

	.inst2_rs_opc_in(PRF_RS_inst2_opc),
	.inst2_rs_opc_valid(PRF_RS_inst2_opc_valid),
 
	.inst2_rs_rob_idx_in(ROB_inst2_rob_idx),  	// The rob index of instruction 2
	.inst2_rs_alu_func(ID_alu_func2),
	.inst2_rs_op_type_in(ID_op_type2),  					// Instruction type from decoder
	.inst2_rs_fu_select_in(ID_fu_select2),
	.inst2_rs_load_in(ID_inst2_is_valid),     	// Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	.inst2_rs_branch_in({ID_inst2_is_cond_branch,ID_inst2_is_uncond_branch}),

	.fu_is_available(EX_RS_fu_is_available),			//0,2:mult1,2 1,3:ALU1,2 4:MEM1; from fu to rs, bugs lifan
	.thread1_branch_is_taken(thread1_branch_is_taken),
	.thread2_branch_is_taken(thread2_branch_is_taken),
	.inst1_is_halt(ID_inst1_is_halt),
	.inst2_is_halt(ID_inst2_is_halt),
	
//output
	.fu_rs_opa_out(RS_EX_opa),       	// This RS' opa 
	.fu_rs_opb_out(RS_EX_opb),       	// This RS' opb 

	.fu_rs_opc_out(RS_EX_opc),     //for branch										*********************

	.fu_rs_dest_tag_out(RS_EX_dest_tag),  	// This RS' destination tag  
	.fu_rs_rob_idx_out(RS_EX_rob_idx),   	// This RS' corresponding ROB index
	.fu_alu_func_out(RS_EX_alu_func),
	.fu_rs_out_valid(RS_EX_out_valid),	// RS output is valid
	.fu_rs_op_type_out(RS_EX_op_type),
	.fu_rs_branch_out(RS_EX_branch_out),
	.rs_full(RS_full),			// RS is full now
	
	//for debug
	.inst1_rs_pc_in(PC_proc2Imem_addr_previous),
	.inst2_rs_pc_in(PC_proc2Imem_addr_previous+4),
	.fu_inst_pc_out(fu_next_inst_pc_out)	
);

//////////////////////////////////
//								//
//		   EX_stage				//
//								//
//////////////////////////////////
ex_stage ex(
//input
	.clock(clock),				// system clock
	.reset(reset),          	// system reset 

    .fu_rs_opa_in(RS_EX_opa),		// register A value from reg file
    .fu_rs_opb_in(RS_EX_opb),		// register B value from reg file

	.fu_rs_opc_in(RS_EX_opc),
 
    .fu_rs_dest_tag_in(RS_EX_dest_tag),
    .fu_rs_rob_idx_in(RS_EX_rob_idx),
    .fu_rs_op_type_in(RS_EX_op_type),
    .fu_rs_valid_in(RS_EX_out_valid),
	.fu_alu_func_in(RS_EX_alu_func),
	.fu_rs_branch_out(RS_EX_branch_out),

    .adder1_send_in_success(adder1_send_in_success),
    .adder2_send_in_success(adder2_send_in_success),
    .mult1_send_in_success(mult1_send_in_success),
    .mult2_send_in_success(mult2_send_in_success),
    .memory1_send_in_success(memory1_send_in_success),
    .memory2_send_in_success(memory2_send_in_success),
//output
//ex_take_branch_out,  // is this a taken branch?
    .fu_rs_dest_tag_out(EX_CDB_dest_tag),
    .fu_result_out(EX_CDB_fu_result_out),
    .fu_result_is_valid(EX_CDB_fu_result_is_valid),	// 0,2: mult1,2; 1,3: adder1,2
    .fu_is_available(EX_RS_fu_is_available),	//0,2:mult1,2 1,3:ALU1,2 4:MEM1; from fu to rs
    .fu_rs_rob_idx_out(EX_CDB_rob_idx),
    .fu_mispredict_sig(EX_CDB_mispredict_sig),
        // for debug
    .fu_alu_func_out(EX_alu_func_out),
    .fu_rs_op_type_out(EX_rs_op_type_out),
    .rs_pc_in(fu_next_inst_pc_out),
    .fu_inst_pc_out(fu_inst_pc_out)
  );
//////////////////////////////////
//								//
//			 CDB				//
//								//
//////////////////////////////////
cdb cdb1(
//input
	.mult1_result_ready(EX_CDB_fu_result_is_valid[0]),
	.mult1_result_in(EX_CDB_fu_result_out[0]),
	.mult1_dest_reg_idx(EX_CDB_dest_tag[0]),
	.mult1_rob_idx(EX_CDB_rob_idx[0]),
	.adder1_result_ready(EX_CDB_fu_result_is_valid[1]),
	.adder1_result_in(EX_CDB_fu_result_out[1]),
	.adder1_dest_reg_idx(EX_CDB_dest_tag[1]),
	.adder1_rob_idx(EX_CDB_rob_idx[1]),
	.adder1_branch_taken(EX_CDB_mispredict_sig[0]),
	.mult2_result_ready(EX_CDB_fu_result_is_valid[2]),
	.mult2_result_in(EX_CDB_fu_result_out[2]),
	.mult2_dest_reg_idx(EX_CDB_dest_tag[2]),
	.mult2_rob_idx(EX_CDB_rob_idx[2]),
	.adder2_result_ready(EX_CDB_fu_result_is_valid[3]),
	.adder2_result_in(EX_CDB_fu_result_out[3]),
	.adder2_dest_reg_idx(EX_CDB_dest_tag[3]),
	.adder2_rob_idx(EX_CDB_rob_idx[3]),
	.adder2_branch_taken(EX_CDB_mispredict_sig[1]),
	.memory1_result_ready(EX_CDB_fu_result_is_valid[4]),
	.memory1_result_in(EX_CDB_fu_result_out[4]),
	.memory1_dest_reg_idx(EX_CDB_dest_tag[4]),
	.memory1_rob_idx(EX_CDB_rob_idx[4]),
	.memory2_result_ready(EX_CDB_fu_result_is_valid[5]),
	.memory2_result_in(EX_CDB_fu_result_out[5]),
	.memory2_dest_reg_idx(EX_CDB_dest_tag[5]),
	.memory2_rob_idx(EX_CDB_rob_idx[5]),
//output	
	.cdb1_valid(cdb1_valid),
	.cdb1_tag(cdb1_tag),
	.cdb1_out(cdb1_value),
	.cdb1_rob_idx(cdb1_rob_idx),
	.cdb1_branch_is_taken(cdb1_branch_taken),
	.cdb2_valid(cdb2_valid),
	.cdb2_tag(cdb2_tag),
	.cdb2_out(cdb2_value),
	.cdb2_rob_idx(cdb2_rob_idx),
	.cdb2_branch_is_taken(cdb2_branch_taken),
	.adder1_send_in_success(adder1_send_in_success),
	.adder2_send_in_success(adder2_send_in_success),
	.mult1_send_in_success(mult1_send_in_success),
	.mult2_send_in_success(mult2_send_in_success),
	.memory1_send_in_success(memory1_send_in_success),
	.memory2_send_in_success(memory2_send_in_success)
);

//////////////////////////////////////////
//										//
//		Predictor & BTB         		//     
//										//
//////////////////////////////////////////


	predictor predictor1(
	.two_threads_enable(1'b1),
	.reset(reset),
	.clock(clock),
	.if_inst1_pc(PC_proc2Imem_addr_previous),
	.inst1_valid(PC_inst1_valid && (ID_inst1_is_cond_branch || ID_inst1_is_uncond_branch)),
	.if_inst2_pc(PC_proc2Imem_addr_previous+4),
	.inst2_valid(PC_inst2_valid && (ID_inst2_is_cond_branch || ID_inst2_is_uncond_branch)),

	.branch_result1(ROB_commit1_branch_taken),              //branch taken or not taken
	.branch_pc1(ROB_commit1_pc),             //branch local pc
	.branch_valid1(ROB_commit1_is_thread1 && ROB_commit1_is_branch && ROB_commit1_valid),
	.branch_result2(ROB_commit2_branch_taken),
	.branch_pc2(ROB_commit2_pc),
	.branch_valid2(ROB_commit2_is_thread1 && ROB_commit2_is_branch && ROB_commit2_valid),

	.inst1_predict(inst1_predict),              //inst predict signal
	.inst1_predict_valid(inst1_predict_valid),
	.inst2_predict(inst2_predict),
	.inst2_predict_valid(inst2_predict_valid),
	.branch1_mispredict(inst1_mispredict),
	.branch1_mispredict_valid(inst1_mispredict_valid),
	.branch2_mispredict(inst2_mispredict),
	.branch2_mispredict_valid(inst2_mispredict_valid)
	);


	BTB BTB_1(
	.reset(reset),
	.clock(clock),
	.if_inst1_pc(PC_proc2Imem_addr_previous),
	.if_inst2_pc(PC_proc2Imem_addr_previous+4),
	.inst1_valid(inst1_predict_valid && inst1_predict),
	.inst2_valid(inst2_predict_valid && inst2_predict),
		
	.pc_idx1(ROB_commit1_pc),
	.pc_idx2(ROB_commit2_pc),		
	.target_pc1(ROB_commit1_target_pc),
	.target_pc2(ROB_commit2_target_pc),
	.target_pc1_valid(ROB_commit1_is_thread1 && ROB_commit1_is_branch && ROB_commit1_valid),
	.target_pc2_valid(ROB_commit2_is_thread1 && ROB_commit2_is_branch && ROB_commit2_valid),
		
	.target_inst1_pc(BTB_target_inst1_pc),
	.target_inst2_pc(BTB_target_inst2_pc),
	.target_inst1_valid(BTB_target_inst1_valid),
	.target_inst2_valid(BTB_target_inst2_valid)

	);		
		
		
//////////////////////////////////
//								//
//			  LSQ				//
//								//
//////////////////////////////////
	lsq lsq1(
		.clock(clock),
		.reset(reset),
	
	  	.lsq_cdb1_in(cdb1_value),     		// CDB bus from functional units 
	  	.lsq_cdb1_tag(cdb1_tag),    		// CDB tag bus from functional units 
		.lsq_cdb1_valid(cdb1_valid),  		// The data on the CDB is valid 
	  	.lsq_cdb2_in(cdb2_value),     		// CDB bus from functional units 
	  	.lsq_cdb2_tag(cdb2_tag),    		// CDB tag bus from functional units 
		.lsq_cdb2_valid(cdb2_valid),  		// The data on the CDB is valid 
	
    //for instruction1
   		.inst1_valid(ID_inst1_is_valid),
		.inst1_op_type(ID_op_type1),
		.inst1_pc(PC_proc2Imem_addr_previous),
		//.inst1_in,
		.lsq_rega_in1(PRF_RS_inst1_opc),
		.lsq_rega_valid1(PRF_RS_inst1_opc_valid),
		.lsq_opa_in1(ID_inst1_opa),      	// Operand a from Rename  data
		.lsq_opb_in1(ID_inst1_opb_valid ? ID_inst1_opb : PRF_RS_inst1_opb),      	// Operand a from Rename  tag or data from prf
	    .lsq_opb_valid1(PRF_RS_inst1_opb_valid || ID_inst1_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.lsq_rob_idx_in1(ROB_inst1_rob_idx),  	// The rob index of instruction 1
		.dest_reg_idx1(PC_thread1_is_available ? PRF_RAT1_rename_idx1 : PRF_RAT2_rename_idx1),		//`none_reg if store


    //for instruction2
   		.inst2_valid(ID_inst2_is_valid),
   		.inst2_op_type(ID_op_type2),
		.inst2_pc(PC_proc2Imem_addr_previous+4),
		//.inst2_in,
		.lsq_rega_in2(PRF_RS_inst2_opc),
		.lsq_rega_valid2(PRF_RS_inst2_opc_valid),
		.lsq_opa_in2(ID_inst2_opa),      	// Operand a from Rename  data
		.lsq_opb_in2(ID_inst2_opb_valid ? ID_inst2_opb : PRF_RS_inst2_opb),     	// Operand b from Rename  tag or data from prf
	    .lsq_opb_valid2(PRF_RS_inst2_opb_valid || ID_inst2_opb_valid),   	// Is Opb a tag or immediate data (READ THIS COMMENT) 
		.lsq_rob_idx_in2(ROB_inst2_rob_idx),  	// The rob index of instruction 2
		.dest_reg_idx2(PC_thread1_is_available ? PRF_RAT1_rename_idx2 : PRF_RAT2_rename_idx2),
	//from mem
		.mem_data_in(mem2proc_data),		//when no forwarding possible, load from memory
		.mem_response_in(mem2proc_response),
		.mem_tag_in(mem2proc_tag),
		.cache_hit(1),
	
	//retired store idx
		.t1_head(ROB_t1_head),
		.t2_head(ROB_t2_head),
	//we need to know weather the instruction commited is a mispredict
		.thread1_mispredict(thread1_branch_is_taken),
		.thread2_mispredict(thread2_branch_is_taken),
	//output
	//cdb
		.cdb_dest_tag1(LSQ_CDB_dest_tag1),
		.cdb_result_out1(LSQ_CDB_result_out1),
		.cdb_result_is_valid1(LSQ_CDB_result_is_valid1),
		.cdb_rob_idx1(LSQ_CDB_rob_idx1),
		.cdb_dest_tag2(LSQ_CDB_dest_tag2),
		.cdb_result_out2(LSQ_CDB_result_out2),
		.cdb_result_is_valid2(LSQ_CDB_result_is_valid2),
		.cdb_rob_idx2(LSQ_CDB_rob_idx2),
	//mem
		.mem_data_out(proc2mem_data),
		.mem_address_out(LSQ_address_out),
		.lsq2Dcache_command(LSQ2Dcache_command),
	//full
		.lsq_is_full(LSQ_is_full)
	);
endmodule
