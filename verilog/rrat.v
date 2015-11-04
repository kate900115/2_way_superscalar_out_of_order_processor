//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  rrat.v                                       	//
//                                                                      //
//   Description :                                                      //
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module rrat(
	
	//input
	input 				reset,
	input 				clock,
	input [$clog2(`PRF_SIZE)-1:0]	RoB_PRF_idx,
	input [$clog2(`ARF_SIZE)-1:0] 	RoB_ARF_idx,
	input 				RoB_rename_in,	//high when instruction retires
	input 				mispredict_sig,
	
	//output
	output logic 						PRF_free_valid,
	output logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx,
	output logic [`ARF_SIZE-1:0] [clog2(`PRF_SIZE)-1:0]	mispredict_up_idx

)

	logic	[`ARF_SIZE-1:0]	[clog2(`PRF_SIZE)-1:0] rrat_reg, n_rrat_reg;

always_ff@(posedge clock) begin
	if(reset)
		rrat_reg 		<= #1 0;
	else 
		rrat_reg 		<= #1 n_rrat_reg;
end




end

always_comb begin
	if(mispredict_sig)
	  	mispredict_up_idx = rrat_reg;
	else
	 	mispredict_up_idx = 0;
	if(RoB_rename_in) begin
		PRF_free_valid 		= 1;
		PRF_free_index 		= rrat_reg[RoB_ARF_idx];
		n_rrat_reg[RoB_ARF_idx] = RoB_PRF_idx;
	else
		PRF_free_valid 		= 0;
		PRF_free_index 		= 0;
		n_rrat_reg[RoB_ARF_idx] = rrat_reg[RoB_ARF_idx];
	  
end

























