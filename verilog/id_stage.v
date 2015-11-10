/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  id_stage.v                                          //
//                                                                     //
//  Description :  instruction decode (ID) stage of the pipeline;      // 
//                 decode the instruction fetch register operands, and // 
//                 compute immediate operand (if applicable)           // 
//                                                                     //
/////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps


  // Decode an instruction: given instruction bits IR produce the
  // appropriate datapath control signals.
  //
  // This is a *combinational* module (basically a PLA).
  //
module decode(// Inputs

				  input [31:0] inst,
				  input valid_inst_in,  // ignore inst when low, outputs will
										// reflect noop (except valid_inst)


				  output logic [1:0] opa_select, opb_select, dest_reg, // mux selects
				  output logic [4:0] alu_func,
				  output logic rd_mem, wr_mem, ldl_mem, stc_mem, cond_branch, uncond_branch,
				  output logic halt,           // non-zero on a halt
				  output logic cpuid,          // get CPUID instruction
				  output logic illegal,        // non-zero on an illegal instruction
				  output logic valid_inst      // for counting valid instructions executed
									           // and for making the fetch stage die on halts/
									           // keeping track of when to allow the next
									           // instruction out of fetch
									           // 0 for HALT and illegal instructions (die on halt)

				);

	assign valid_inst = valid_inst_in & ~illegal;

	always_comb
	begin
		// default control values:
		// - valid instructions must override these defaults as necessary.
		//   opa_select, opb_select, and alu_func should be set explicitly.
		// - invalid instructions should clear valid_inst.
		// - These defaults are equivalent to a noop
		// * see sys_defs.vh for the constants used here
		opa_select = 0;
		opb_select = 0;
		alu_func = 0;
		dest_reg = `DEST_NONE;
		rd_mem = `FALSE;
		wr_mem = `FALSE;
		ldl_mem = `FALSE;
		stc_mem = `FALSE;
		cond_branch = `FALSE;
		uncond_branch = `FALSE;
		halt = `FALSE;
		cpuid = `FALSE;
		illegal = `FALSE;
		if(valid_inst_in)
		begin
			case ({inst[31:29], 3'b0})
				6'h0:
					case (inst[31:26])
						`PAL_INST: begin
							if (inst[25:0] == `PAL_HALT)
								halt = `TRUE;
							else if (inst[25:0] == `PAL_WHAMI) begin
								cpuid = `TRUE;
								dest_reg = `DEST_IS_REGA;   // get cpuid writes to r0
							end else
								illegal = `TRUE;
							end
						default: illegal = `TRUE;
					endcase // case(inst[31:26])
			 
				6'h10:
				begin
					opa_select = `ALU_OPA_IS_REGA;
					opb_select = inst[12] ? `ALU_OPB_IS_ALU_IMM : `ALU_OPB_IS_REGB;
					dest_reg = `DEST_IS_REGC;
					case (inst[31:26])
						`INTA_GRP:
							case (inst[11:5])
								`CMPULT_INST:  alu_func = `ALU_CMPULT;
								`ADDQ_INST:    alu_func = `ALU_ADDQ;
								`SUBQ_INST:    alu_func = `ALU_SUBQ;
								`CMPEQ_INST:   alu_func = `ALU_CMPEQ;
								`CMPULE_INST:  alu_func = `ALU_CMPULE;
								`CMPLT_INST:   alu_func = `ALU_CMPLT;
								`CMPLE_INST:   alu_func = `ALU_CMPLE;
								default:        illegal = `TRUE;
							endcase // case(inst[11:5])
						`INTL_GRP:
							case (inst[11:5])
								`AND_INST:    alu_func = `ALU_AND;
								`BIC_INST:    alu_func = `ALU_BIC;
								`BIS_INST:    alu_func = `ALU_BIS;
								`ORNOT_INST:  alu_func = `ALU_ORNOT;
								`XOR_INST:    alu_func = `ALU_XOR;
								`EQV_INST:    alu_func = `ALU_EQV;
								default:       illegal = `TRUE;
							endcase // case(inst[11:5])
						`INTS_GRP:
							case (inst[11:5])
								`SRL_INST:  alu_func = `ALU_SRL;
								`SLL_INST:  alu_func = `ALU_SLL;
								`SRA_INST:  alu_func = `ALU_SRA;
								default:    illegal = `TRUE;
							endcase // case(inst[11:5])
						`INTM_GRP:
							case (inst[11:5])
								`MULQ_INST:       alu_func = `ALU_MULQ;
								default:          illegal = `TRUE;
							endcase // case(inst[11:5])
						`ITFP_GRP:       illegal = `TRUE;       // unimplemented
						`FLTV_GRP:       illegal = `TRUE;       // unimplemented
						`FLTI_GRP:       illegal = `TRUE;       // unimplemented
						`FLTL_GRP:       illegal = `TRUE;       // unimplemented
					endcase // case(inst[31:26])
				end
				   
				6'h18:
					case (inst[31:26])
						`MISC_GRP:       illegal = `TRUE; // unimplemented
						`JSR_GRP:
						begin
							// JMP, JSR, RET, and JSR_CO have identical semantics
							opa_select = `ALU_OPA_IS_NOT3;
							opb_select = `ALU_OPB_IS_REGB;
							alu_func = `ALU_AND; // clear low 2 bits (word-align)
							dest_reg = `DEST_IS_REGA;
							uncond_branch = `TRUE;
						end
						`FTPI_GRP:       illegal = `TRUE;       // unimplemented
					endcase // case(inst[31:26])
				   
				6'h08, 6'h20, 6'h28:
				begin
					opa_select = `ALU_OPA_IS_MEM_DISP;
					opb_select = `ALU_OPB_IS_REGB;
					alu_func = `ALU_ADDQ;
					dest_reg = `DEST_IS_REGA;
					case (inst[31:26])
						`LDA_INST:  /* defaults are OK */;
						`LDQ_INST:
						begin
							rd_mem = `TRUE;
							dest_reg = `DEST_IS_REGA;
						end // case: `LDQ_INST
						`LDQ_L_INST:
							begin
							rd_mem = `TRUE;
							ldl_mem = `TRUE;
							dest_reg = `DEST_IS_REGA;
						end // case: `LDQ_L_INST
						`STQ_INST:
						begin
							wr_mem = `TRUE;
							dest_reg = `DEST_NONE;
						end // case: `STQ_INST
						`STQ_C_INST:
						begin
							wr_mem = `TRUE;
							stc_mem = `TRUE;
							dest_reg = `DEST_IS_REGA;
						end // case: `STQ_INST
						default:       illegal = `TRUE;
					endcase // case(inst[31:26])
				end
				   
				6'h30, 6'h38:
				begin
					opa_select = `ALU_OPA_IS_NPC;
					opb_select = `ALU_OPB_IS_BR_DISP;
					alu_func = `ALU_ADDQ;
					case (inst[31:26])
						`FBEQ_INST, `FBLT_INST, `FBLE_INST,
						`FBNE_INST, `FBGE_INST, `FBGT_INST:
						begin
							// FP conditionals not implemented
							illegal = `TRUE;
						end

						`BR_INST, `BSR_INST:
						begin
							dest_reg = `DEST_IS_REGA;
							uncond_branch = `TRUE;
						end

						default:
							cond_branch = `TRUE; // all others are conditional
					endcase // case(inst[31:26])
				end
			endcase // case(inst[31:29] << 3)
		end // if(~valid_inst_in)
	end // always
   
endmodule // decoder


module id_stage(
             
				  input         clock,                // system clock
				  input         reset,                // system reset
				  input  [31:0] if_id_IR1,             // incoming instruction1
				  input  [31:0] if_id_IR2,             // incoming instruction2
				  //input         wb_reg_wr_en_out,     // Reg write enable from WB Stage
				  //input   [4:0] wb_reg_wr_idx_out,    // Reg write index from WB Stage
				  //input  [63:0] wb_reg_wr_data_out,   // Reg write data from WB Stage
				  input         if_id_valid_inst1,
				  input         if_id_valid_inst2,
				  input  [63:0] if_id_NPC_inst1,           // incoming instruction1 PC+4
				  input  [63:0] if_id_NPC_inst2,           // incoming instruction PC+4

				  
				  output [63:0] opa_mux_out1;               //instr1 opa and opb value or tag
			          output [63:0] opb_mux_out1;
				  output logic  [4:0] id_dest_reg_idx_out1,  // destination (writeback) register index
													        // (ZERO_REG if no writeback)
				 
				  output [63:0] opa_mux_out2;               //instr2 opa and opb value or tag
				  output [63:0] opb_mux_out2;
				  output logic  [4:0] id_dest_reg_idx_out2,  // destination (writeback) register index


				  output logic  [4:0] id_alu_func_out1,      // ALU function select (ALU_xxx *)
				  output logic  [4:0] id_alu_func_out2,      // ALU function select (ALU_xxx *)
				  output logic  [5:0] id_op_type_inst1,  	// op type
				  output logic  [5:0] id_op_type_inst2,

				  output logic        id_rd_mem_out1,        // does inst read memory?
				  output logic        id_wr_mem_out1,        // does inst write memory?
				  output logic        id_ldl_mem_out1,       // load-lock inst?
				  output logic        id_stc_mem_out1,       // store-conditional inst?
				  output logic        id_cond_branch_out1,   // is inst a conditional branch?
				  output logic        id_uncond_branch_out1, // is inst an unconditional branch 
													        // or jump?
				  output logic        id_halt_out1,
				  output logic        id_cpuid_out1,         // get CPUID inst?
				  output logic        id_illegal_out1,
				  output logic        id_valid_inst_out1,     // is inst a valid instruction to be 
													        // counted for CPI calculations?
				  output logic        id_rd_mem_out2,        // does inst read memory?
				  output logic        id_wr_mem_out2,        // does inst write memory?
				  output logic        id_ldl_mem_out2,       // load-lock inst?
				  output logic        id_stc_mem_out2,       // store-conditional inst?
				  output logic        id_cond_branch_out2,   // is inst a conditional branch?
				  output logic        id_uncond_branch_out2, // is inst an unconditional branch 
													        // or jump?
				  output logic        id_halt_out2,
				  output logic        id_cpuid_out2,         // get CPUID inst?
				  output logic        id_illegal_out2,
				  output logic        id_valid_inst_out2     // is inst a valid instruction to be 
              );
   
	logic   [1:0] dest_reg_select;
	logic   [1:0] dest_reg_select;

	// instruction fields read from IF/ID pipeline register
	wire    [4:0] ra_idx1 = if_id_IR1[25:21];   // inst1 operand A register index
	wire    [4:0] rb_idx1 = if_id_IR1[20:16];   // inst1 operand B register index
	wire    [4:0] rc_idx1 = if_id_IR1[4:0];     // inst1 operand C register index
	
	wire    [4:0] ra_idx2 = if_id_IR1[25:21];   // inst2 operand A register index
	wire    [4:0] rb_idx2 = if_id_IR1[20:16];   // inst2 operand B register index
	wire    [4:0] rc_idx2 = if_id_IR1[4:0];     // inst2 operand C register index


	// Instantiate the register file used by this pipeline
	/*regfile regf_0 (.rda_idx(ra_idx),
				  .rda_out(id_ra_value_out), 
	  
				  .rdb_idx(rb_idx),
				  .rdb_out(id_rb_value_out),

				  .wr_clk(clock),
				  .wr_en(wb_reg_wr_en_out),
				  .wr_idx(wb_reg_wr_idx_out),
				  .wr_data(wb_reg_wr_data_out)
				 );*/
	
	wire [63:0] mem_disp1 = { {48{if_id_IR1[15]}}, if_id_IR1[15:0] };
	wire [63:0] br_disp1  = { {41{if_id_IR1[20]}}, if_id_IR1[20:0], 2'b00 };
	wire [63:0] alu_imm1  = { 56'b0, if_id_IR1[20:13] };
	
	wire [63:0] mem_disp2 = { {48{if_id_IR2[15]}}, if_id_IR2[15:0] };
	wire [63:0] br_disp2  = { {41{if_id_IR2[20]}}, if_id_IR2[20:0], 2'b00 };
	wire [63:0] alu_imm2  = { 56'b0, if_id_IR2[20:13] };

	assign id_op_type_inst1 = if_id_IR1[31:26];   //inst op type generate
	assign id_op_type_inst2 = if_id_IR2[31:26];

	//
	// ALU opA mux
	//
	always_comb
	begin
		case (id_opa_select_out1)
			`ALU_OPA_IS_REGA:     opa_mux_out1 = {59{1'b0},ra_idx1};
			`ALU_OPA_IS_MEM_DISP: opa_mux_out1 = mem_disp1;
			`ALU_OPA_IS_NPC:      opa_mux_out1 = if_id_NPC_inst1;
			`ALU_OPA_IS_NOT3:     opa_mux_out1 = ~64'h3;
		endcase
		case (id_opa_select_out2)
			`ALU_OPA_IS_REGA:     opa_mux_out2 = {59{1'b0},ra_idx2};
			`ALU_OPA_IS_MEM_DISP: opa_mux_out2 = mem_disp2;
			`ALU_OPA_IS_NPC:      opa_mux_out2 = if_id_NPC_inst2;
			`ALU_OPA_IS_NOT3:     opa_mux_out2 = ~64'h3;
		endcase
	end

	//
	// ALU opB mux
	//
	always_comb
	begin
		 // Default value, Set only because the case isnt full.  If you see this
		 // value on the output of the mux you have an invalid opb_select
		opb_mux_out1 = 64'hbaadbeefdeadbeef;
		opb_mux_out2 = 64'hbaadbeefdeadbeef;
		case (id_opb_select_out1)
			`ALU_OPB_IS_REGB:    opb_mux_out1 = {59{1'b0},rb_idx1};
			`ALU_OPB_IS_ALU_IMM: opb_mux_out1 = alu_imm1;
			`ALU_OPB_IS_BR_DISP: opb_mux_out1 = br_disp1;
		endcase
		case (id_opb_select_out2)
			`ALU_OPB_IS_REGB:    opb_mux_out2 = {59{1'b0},rb_idx2};
			`ALU_OPB_IS_ALU_IMM: opb_mux_out2 = alu_imm2;
			`ALU_OPB_IS_BR_DISP: opb_mux_out2 = br_disp2;
		endcase  
	end

	
	// instantiate the instruction decoder
	decode decode_1 (// Input
					 .inst(if_id_IR1),
					 .valid_inst_in(if_id_valid_inst1),

					 // Outputs
					 .opa_select(id_opa_select_out1),
					 .opb_select(id_opb_select_out1),
					 .alu_func(id_alu_func_out1),
					 .dest_reg(dest_reg_select1),
					 .rd_mem(id_rd_mem_out1),
					 .wr_mem(id_wr_mem_out1),
					 .ldl_mem(id_ldl_mem_out1),
					 .stc_mem(id_stc_mem_out1),
					 .cond_branch(id_cond_branch_out1),
					 .uncond_branch(id_uncond_branch_out1),
					 .halt(id_halt_out1),
					 .cpuid(id_cpuid_out1),
					 .illegal(id_illegal_out1),
					 .valid_inst(id_valid_inst_out1)
					);

	decode decode_2 (// Input
					 .inst(if_id_IR2),
					 .valid_inst_in(if_id_valid_inst2),

					 // Outputs
					 .opa_select(id_opa_select_out2),
					 .opb_select(id_opb_select_out2),
					 .alu_func(id_alu_func_out2),
					 .dest_reg(dest_reg_select2),
					 .rd_mem(id_rd_mem_out2),
					 .wr_mem(id_wr_mem_out2),
					 .ldl_mem(id_ldl_mem_out2),
					 .stc_mem(id_stc_mem_out2),
					 .cond_branch(id_cond_branch_out2),
					 .uncond_branch(id_uncond_branch_out2),
					 .halt(id_halt_out2),
					 .cpuid(id_cpuid_out2),
					 .illegal(id_illegal_out2),
					 .valid_inst(id_valid_inst_out2)
					);
	// mux to generate dest_reg_idx based on
	// the dest_reg_select output from decoder
	always_comb
	begin
		case (dest_reg_select1)
			`DEST_IS_REGC: id_dest_reg_idx_out1 = rc_idx1;
			`DEST_IS_REGA: id_dest_reg_idx_out1 = ra_idx1;
			`DEST_NONE:    id_dest_reg_idx_out1 = `ZERO_REG;
			default:       id_dest_reg_idx_out1 = `ZERO_REG; 
		endcase
		case (dest_reg_select2)
			`DEST_IS_REGC: id_dest_reg_idx_out2 = rc_idx2;
			`DEST_IS_REGA: id_dest_reg_idx_out2 = ra_idx2;
			`DEST_NONE:    id_dest_reg_idx_out2 = `ZERO_REG;
			default:       id_dest_reg_idx_out2 = `ZERO_REG; 
		endcase
	end
   
endmodule // module id_stage
