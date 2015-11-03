//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  ex_stage.v                                           //
//                                                                      //
//  Description :  instruction execute (EX) stage of the pipeline;      //
//                 given the instruction command code CMD, select the   //
//                 proper input A and B for the ALU, compute the result,// 
//                 and compute the condition for branches, and pass all //
//                 the results down the pipeline. MWB                   // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

//
// The ALU
//
// given the command code CMD and proper operands A and B, compute the
// result of the instruction
//
// This module is purely combinational
//
module alu(
    input [63:0] opa,
    input [63:0] opb,
    ALU_FUNC     func,

    output logic [63:0] result
  );

    // This function computes a signed less-than operation
  function signed_lt;
    input [63:0] a, b;

    if (a[63] == b[63]) 
      signed_lt = (a < b); // signs match: signed compare same as unsigned
    else
      signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
  endfunction

  always_comb begin
    case (func)
      ALU_ADDQ:      result = opa + opb;
      ALU_SUBQ:      result = opa - opb;
      ALU_AND:      result = opa & opb;
      ALU_BIC:      result = opa & ~opb;
      ALU_BIS:      result = opa | opb;
      ALU_ORNOT:    result = opa | ~opb;
      ALU_XOR:      result = opa ^ opb;
      ALU_EQV:      result = opa ^ ~opb;
      ALU_SRL:      result = opa >> opb[5:0];
      ALU_SLL:      result = opa << opb[5:0];
      ALU_SRA:      result = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 -
                              opb[5:0])); // arithmetic from logical shift
      ALU_CMPULT:    result = { 63'd0, (opa < opb) };
      ALU_CMPEQ:    result = { 63'd0, (opa == opb) };
      ALU_CMPULE:    result = { 63'd0, (opa <= opb) };
      ALU_CMPLT:    result = { 63'd0, signed_lt(opa, opb) };
      ALU_CMPLE:    result = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
      default:      result = 64'xxxx_xxxx_xxxx_xxxx;  // here only to force
                              // a combinational solution
                              // a casex would be better
    endcase
  end
endmodule // alu

//
// BrCond module
//
// Given the instruction code, compute the proper condition for the
// instruction; for branches this condition will indicate whether the
// target is taken.
//
// This module is purely combinational
//
module brcond(// Inputs
    input [63:0] opa,    // Value to check against condition
    input  [2:0] func,  // Specifies which condition to check

    output logic cond    // 0/1 condition result (False/True)
  );

  always_comb begin
  case (func[1:0])                              // 'full-case'  All cases covered, no need for a default
    2'b00: cond = (opa[0] == 0);                // LBC: (lsb(opa) == 0) ?
    2'b01: cond = (opa == 0);                    // EQ: (opa == 0) ?
    2'b10: cond = (opa[63] == 1);                // LT: (signed(opa) < 0) : check sign bit
    2'b11: cond = (opa[63] == 1) || (opa == 0);  // LE: (signed(opa) <= 0)
  endcase
  
     // negate cond if func[2] is set
    if (func[2])
    cond = ~cond;
  end
endmodule // brcond


module ex_stage(
    input          			clock,			// system clock
    input          			reset,			// system reset

    input  [63:0]			fu1_rs_opa_in,		// register A value from reg file
    input  [63:0]			fu1_rs_opb_in,		// register B value from reg file
    input  [$clog2(`PRF_SIZE)-1:0]	fu1_rs_dest_tag_in,
    input  [$clog2(`ROB_SIZE)-1:0]	fu1_rs_rob_idx_in,
    input  [5:0]  			fu1_rs_op_type_in,	// incoming instruction
    input				fu1_rs_valid_in,
    ALU_FUNC       			fu1_alu_func_in,	// ALU function select from decoder

    input  [63:0]			fu2_rs_opa_in,		// register A value from reg file
    input  [63:0]			fu2_rs_opb_in,		// register B value from reg file
    input  [$clog2(`PRF_SIZE)-1:0]	fu2_rs_dest_tag_in,
    input  [$clog2(`ROB_SIZE)-1:0]	fu2_rs_rob_idx_in,
    input  [5:0]  			fu2_rs_op_type_in,	// incoming instruction
    input				fu2_rs_valid_in,
    ALU_FUNC       			fu2_alu_func_in,	// ALU function select from decoder

    input  [63:0]			fu3_rs_opa_in,		// register A value from reg file
    input  [63:0]			fu3_rs_opb_in,		// register B value from reg file
    input  [$clog2(`PRF_SIZE)-1:0]	fu3_rs_dest_tag_in,
    input  [$clog2(`ROB_SIZE)-1:0]	fu3_rs_rob_idx_in,
    input  [5:0]  			fu3_rs_op_type_in,	// incoming instruction
    input				fu3_rs_valid_in,
    ALU_FUNC       			fu3_alu_func_in,	// ALU function select from decoder

    input          id_ex_cond_branch,   // is this a cond br? from decoder
    input          id_ex_uncond_branch, // is this an uncond br? from decoder

    output [63:0]	ex_result_out,   // ALU result
    output		ex_take_branch_out,  // is this a taken branch?

    output logic [$clog2(`PRF_SIZE)-1:0]	fu1_rs_dest_tag_out,
    output logic [$clog2(`ROB_SIZE)-1:0]	fu1_rs_rob_idx_out,
    output logic [5:0]  			fu1_rs_op_type_out,	// incoming instruction
    output ALU_FUNC				fu1_alu_func_out,	// ALU function select from decoder
    output logic [63:0]				fu1_result;
    output					fu1_result_is_valid,

    output logic [$clog2(`PRF_SIZE)-1:0]	fu2_rs_dest_tag_out,
    output logic [$clog2(`ROB_SIZE)-1:0]	fu2_rs_rob_idx_out,
    output logic [5:0]  			fu2_rs_op_type_out,	// incoming instruction
    output ALU_FUNC				fu2_alu_func_out,	// ALU function select from decoder
    output logic [63:0]				fu2_result;
    output					fu2_result_is_valid,
/*
    output logic [$clog2(`PRF_SIZE)-1:0]	fu3_rs_dest_tag_out,
    output logic [$clog2(`ROB_SIZE)-1:0]	fu3_rs_rob_idx_out,
    output logic [5:0]  			fu3_rs_op_type_out,	// incoming instruction
    output ALU_FUNC				fu3_alu_func_out,	// ALU function select from decoder
    output					fu3_result_is_valid
*/
  );

	logic		brcond_result;
	logic  [63:0]	mult_result;
	logic		mult_done;
	logic  [63:0]	alu_result;
	assign ex_take_branch_out = id_ex_uncond_branch | (id_ex_cond_branch & brcond_result);

   // fu1: multipler
	mult #(3) (// Inputs
		.clock(clock),
		.reset(reset),
		.mcand(fu1_rs_opa_in),
		.mplier(fu1_rs_opb_in),
		.start(fu1_rs_valid_in),
	// Outputs
		.product(mult_result),
		.done(mult_done)
	);

    // fu2: ALU
	alu alu_0 (// Inputs
		.opa(fu2_rs_opa_in),
		.opb(fu2_rs_opb_in),
		.func(fu2_alu_func_in),
    // Output
		.result(alu_result)
	);

   //
   // instantiate the branch condition tester
   //
	//brcond brcond (// Inputs
	//.opa(id_ex_rega),       // always check regA value
	//.func(id_ex_IR[28:26]), // inst bits to determine check
	    // Output
	//.cond(brcond_result)
	//);

   // ultimate "take branch" signal:
   //    unconditional, or conditional and the condition is true
	always_ff @(posedge clock)
	begin
		if (fu1_rs_valid_in)
		begin
			fu1_rs_dest_tag_out	<= `SD fu1_rs_dest_tag_in;
			fu1_rs_rob_idx_out	<= `SD fu1_rs_rob_idx_in;
			fu1_rs_op_type_out	<= `SD fu1_rs_op_type_in;
			fu1_alu_func_out	<= `SD fu1_alu_func_in;
		end
		if (mult_done) begin
			fu1_result		<= `SD mult_result;
			fu1_result_is_valid	<= `SD 1'b1;
		end
			
		if (fu2_rs_valid_in)
		begin
			fu2_rs_dest_tag_out	<= `SD fu2_rs_dest_tag_in;
			fu2_rs_rob_idx_out	<= `SD fu2_rs_rob_idx_in;
			fu2_rs_op_type_out	<= `SD fu2_rs_op_type_in;
			fu2_alu_func_out	<= `SD fu2_alu_func_in;
			fu2_result		<= `SD alu_result;
			fu2_result_is_valid	<= `SD 1'b1;
		end
/*
		if (fu3_rs_valid_in)
		begin
			fu3_rs_dest_tag_out	<= `SD fu3_rs_dest_tag_in;
			fu3_rs_rob_idx_out	<= `SD fu3_rs_rob_idx_in;
			fu3_rs_op_type_out	<= `SD fu3_rs_op_type_in;
			fu3_alu_func_out	<= `SD fu3_alu_func_in;
		end
*/
	end
endmodule // module ex_stage
