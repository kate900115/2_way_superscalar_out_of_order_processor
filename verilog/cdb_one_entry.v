//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  cdb_one_entry.v                                      //
//                                                                      //
//   Description :                                                      //
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////


module cdb_one_entry(
	//fu_select signal will give out the result from which function unit
	//is selected. the priority is: mem1 > mem2 > mult1 > mult2 > adder1 > adder2.

	input  	[5:0]							fu_select,		

	input  	[63:0]							memory1_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]			memory1_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]			memory1_rob_idx,
	input  	[63:0]							memory2_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]			memory2_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]			memory2_rob_idx,
	input  	[63:0]							mult1_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]			mult1_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]			mult1_rob_idx,
	input  	[63:0]							mult2_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]			mult2_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]			mult2_rob_idx,
	input  	[63:0]							adder1_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]			adder1_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]			adder1_rob_idx,
	input									adder1_branch_taken,
	input  	[63:0]							adder2_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]			adder2_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]			adder2_rob_idx,
	input									adder2_branch_taken,

	
	output 	logic							cdb_valid,
	output  logic [$clog2(`PRF_SIZE)-1:0]	cdb_tag,
	output 	logic [63:0]					cdb_out,
	output  logic [$clog2(`ROB_SIZE):0]		cdb_rob_idx,
	output	logic							branch_is_taken
);

	

	always_comb
	begin
		case (fu_select)
		6'b100000:		
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = memory1_dest_reg_idx;
				cdb_out   		   = memory1_result_in;
				cdb_rob_idx		   = memory1_rob_idx;
				branch_is_taken	   = 0;
			end
		6'b010000:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = memory2_dest_reg_idx;
				cdb_out   		   = memory2_result_in;
				cdb_rob_idx		   = memory2_rob_idx;
				branch_is_taken	   = 0;
			end
		6'b001000:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = mult1_dest_reg_idx;
				cdb_out   		   = mult1_result_in;
				cdb_rob_idx		   = mult1_rob_idx;
				branch_is_taken	   = 0;
			end
		6'b000100:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = mult2_dest_reg_idx;
				cdb_out   		   = mult2_result_in;
				cdb_rob_idx		   = mult2_rob_idx;
				branch_is_taken	   = 0;
			end
		6'b000010:
			begin
				cdb_valid		   = 1'b1;				
				cdb_tag  		   = adder1_dest_reg_idx;
				cdb_out  		   = adder1_result_in;
				cdb_rob_idx		   = adder1_rob_idx;
				branch_is_taken	   = adder1_branch_taken;
				
			end
		6'b000001:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = adder2_dest_reg_idx;
				cdb_out   		   = adder2_result_in;
				cdb_rob_idx		   = adder2_rob_idx;
				branch_is_taken	   = adder2_branch_taken;
			end
		default:
			begin
				cdb_valid 		   = 1'b0;				
				cdb_tag   		   = 0;
				cdb_out   		   = 0;
				cdb_rob_idx		   = 0;
				branch_is_taken	   = 0;
			end
		endcase
	end
endmodule
