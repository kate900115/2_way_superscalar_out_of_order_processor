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
	input 				RoB_retire_in,	//high when instruction retires
	input 				mispredict_sig,
	
	//output
	output logic 						PRF_free_valid,
	output logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx,
	output logic [`ARF_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0]	mispredict_up_idx

);

	logic [`ARF_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] rrat_reg;
	logic [`ARF_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] n_rrat_reg;
	logic 					      n_PRF_free_valid;
	logic [$clog2(`PRF_SIZE)-1:0] 		      n_PRF_free_idx;
	logic [`ARF_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] n_mispredict_up_idx;

always_ff @(posedge clock) begin
	if(reset) begin
		rrat_reg 		<= #1 0;
		mispredict_up_idx       <= #1 0;
		PRF_free_valid          <= #1 0;
		PRF_free_idx            <= #1 0;
	end
	else begin
		rrat_reg 		<= #1 n_rrat_reg;
		mispredict_up_idx       <= #1 n_mispredict_up_idx;
		PRF_free_valid          <= #1 n_PRF_free_valid;
		PRF_free_idx            <= #1 n_PRF_free_idx;
		
	end
end


always_comb begin
	if(reset) begin
		n_mispredict_up_idx = 0;
		n_PRF_free_valid    = 0;
		n_PRF_free_idx      = 0;
		n_rrat_reg          = 0;
	end
        else begin
		if(mispredict_sig)
	  		n_mispredict_up_idx = rrat_reg;
		else
	 		n_mispredict_up_idx = 0;
		if(RoB_retire_in) begin
			n_PRF_free_valid 	= 1;
			n_PRF_free_idx 		= rrat_reg[RoB_ARF_idx];
			n_rrat_reg[RoB_ARF_idx] = RoB_PRF_idx;	
		end
		else begin
			n_PRF_free_valid 	= 0;
			n_PRF_free_idx 		= 0;
			n_rrat_reg[RoB_ARF_idx] = rrat_reg[RoB_ARF_idx];
		end
	end
end
endmodule
