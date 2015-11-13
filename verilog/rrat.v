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

	input				inst1_enable,
	input				inst2_enable,

	input [$clog2(`PRF_SIZE)-1:0]	RoB_PRF_idx1,
	input [$clog2(`ARF_SIZE)-1:0] 	RoB_ARF_idx1,
	input 				RoB_retire_in1,	//high when instruction retires
	input 				mispredict_sig1,

	input [$clog2(`PRF_SIZE)-1:0]	RoB_PRF_idx2,
	input [$clog2(`ARF_SIZE)-1:0] 	RoB_ARF_idx2,
	input 				RoB_retire_in2,	//high when instruction retires
	input 				mispredict_sig2,

	//output

	output	logic 						PRF_free_valid1,
	output  logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx1,
	output	logic 						PRF_free_valid2,
	output	logic [$clog2(`PRF_SIZE)-1:0] 			PRF_free_idx2,
	output logic [`ARF_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0]	mispredict_up_idx

);

	logic [`ARF_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] rrat_reg, n_rrat_reg;
	logic i;


always_ff @(posedge clock) begin
	if(reset) begin
		rrat_reg 		<= #1 0;

	end
	else begin
		rrat_reg 		<= #1 n_rrat_reg;

		
	end
end


always_comb begin
	if(mispredict_sig1 & inst1_enable)
	  		mispredict_up_idx = rrat_reg;
	else if(mispredict_sig2 & inst2_enable) begin
			for(i=0; i<`ARF_SIZE; i++) begin
				if(i==RoB_ARF_idx1)
				mispredict_up_idx[i] = RoB_PRF_idx1;
				else
				mispredict_up_idx[i] = rrat_reg[i];
			end //for
	end //else if
	else 
		mispredict_up_idx = 0;

	PRF_free_valid1 	= (RoB_retire_in1 & inst1_enable) ? 1 : 0;
	PRF_free_idx1 		= (RoB_retire_in1 & inst1_enable) ? rrat_reg[RoB_ARF_idx1] : 0;	

	PRF_free_valid2 	= (RoB_retire_in2 & inst2_enable) ? 1 : 0;
	PRF_free_idx2 		= (RoB_retire_in2 & inst2_enable) ? rrat_reg[RoB_ARF_idx2] : 0;

	for(int i=0; i<`ARF_SIZE; i++) begin
		if(i==RoB_ARF_idx1| i==RoB_ARF_idx2) begin
	    		n_rrat_reg[RoB_ARF_idx1]= (RoB_retire_in1 & inst1_enable) ? RoB_PRF_idx1 : rrat_reg[RoB_ARF_idx1];
			n_rrat_reg[RoB_ARF_idx2]= (RoB_retire_in2 & inst2_enable) ? RoB_PRF_idx2 : rrat_reg[RoB_ARF_idx2];
		end
		else begin
			n_rrat_reg[i]	= rrat_reg[i];
		end //else
	end  //for

	//$display("rrat_reg[0]:%d", rrat_reg[0]);	
	//$display("rrat_reg[1]:%d", rrat_reg[1]);	
	//$display("rrat_reg[2]:%d", rrat_reg[2]);	
	//$display("rrat_reg[3]:%d", rrat_reg[3]);	
	//$display("rrat_reg[4]:%d", rrat_reg[4]);	

	//$display("n_rrat_reg[0]:%d", n_rrat_reg[0]);	
	//$display("n_rrat_reg[1]:%d", n_rrat_reg[1]);	
	//$display("n_rrat_reg[2]:%d", n_rrat_reg[2]);	
	//$display("n_rrat_reg[3]:%d", n_rrat_reg[3]);	
	//$display("n_rrat_reg[4]:%d", n_rrat_reg[4]);

	end //if
endmodule
