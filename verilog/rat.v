//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  rat.v                                       	        //
//                                                                      //
//   Description :                                                      //
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module rat(

	//input
	input	reset,	//reset signal
	input	clock,	//the clock
	input	[$clog2(`ARF_SIZE)-1:0]	opa_ARF_idx,	//we will use opa_ARF_idx to find PRF_idx
	input	[$clog2(`ARF_SIZE)-1:0]	opb_ARF_idx,	//to find PRF_idx
	input	[$clog2(`ARF_SIZE)-1:0]	dest_ARF_idx,	//the ARF index of dest reg
	input	dest_rename_sig,	//if high, dest_reg need rename, imme => low

	input	opa_valid_in,	//if high opa_valid is immediate
	input	opb_valid_in,

	input	[`ARF_SIZE-1:0]	[clog2(`PRF_SIZE)-1:0]	mispredict_up_idx,	//if mispredict happens, need to copy from rrat
	input	mispredict_sig,	//indicate weather mispredict happened

	input	PRF_rename_valid,	//we get valid signal from prf if the dest address has been allocated
	input	[$clog2(`PRF_SIZE)-1:0]	PRF_rename_idx,	//the PRF alocated for dest
	input	dest_rename_sig;
	//output
	output	logic	[$clog2(`PRF_SIZE)-1:0]	opa_PRF_idx,
	output	logic	[$clog2(`PRF_SIZE)-1:0]	opb_PRF_idx,
	output	logic	request,  //send to PRF indicate weather it need data
	output	logic	[`ARF_SIZE-1:0]	PRF_free_sig,
	output	logic	[`ARF_SIZE-1:0]	[$clog2(`PRF_SIZE)-1:0] PRF_free_list,
	output	logic	RAT_allo_halt,
	output	logic	opa_valid_out,	//if high opa_valid is immediate
	output	logic	opb_valid_out
	);

	logic	[`ARF_SIZE-1:0]	[clog2(`PRF_SIZE)-1:0] rat_reg, l_rat_reg;
	logic	[$clog2(`ARF_SIZE):0]	i;
	logic	[`ARF_SIZE-1:0]	valid, l_valid;


	always_ff@(posedge clock) begin
	 unique if(reset) begin
	  	PRF_free_sig 		<= #1 0;
	  	PRF_free_list 		<= #1 0;
	  	opa_PRF_idx 		<= #1 0;
	  	opb_PRF_idx 		<= #1 0;
	  	request 		<= #1 0;
	  	RAT_allo_halt 		<= #1 0;  
	  	opa_valid_out 		<= #1 0;
	   	opb_valid_out 		<= #1 0;
	  	rat_reg 		<= #1 0; 
	  	l_rat_reg 		<= #1 0; 
	  	valid	 		<= #1 0; 
	  	l_valid 		<= #1 0; 
	  end
	  else if(mispredict_sig) begin
	    	PRF_free_sig 		<= #1 0;
	    	PRF_free_list 		<= #1 0;
	  	for(i=0; i<`ARF_SIZE; i++) begin
	  		valid[i] 	<= #1 1;
	  		PRF_free_sig[i] <= #1 rat_reg[i] ~= mispredict_up_idx[i];	//indicate RAT_idx of i has been overwrite
	  		PRF_free_list[i]<= #1 (rat_reg[i] ~= mispredict_up_idx[i])? rat_reg[i]:0;  //indicate the PRF_idx to be free
	  		rat_reg[i] 	<= #1 mispredict_up_idx[i];  //copy from rrat
	  	end //for
	  	request 		<= #1 0;
	  	RAT_allo_halt 		<= #1 0;
	  	opa_PRF_idx 		<= #1 0;
	  	opb_PRF_idx 		<= #1 0;
	  	opa_valid_out 		<= #1 0;
	    	opb_valid_out 		<= #1 0;
		l_valid			<= #1 valid;
		l_rat_reg 		<= #1 rat_reg;
	  end //else
	  else if((~PRF_rename_valid && dest_rename_sig) | ~dest_rename_sig) begin
	  	PRF_free_sig 	<= #1 0;
	  	PRF_free_list 	<= #1 0;
	    	opa_PRF_idx 	<= #1 0;
	  	opb_PRF_idx 	<= #1 0;
	  	request 	<= #1 0;
	  	RAT_allo_halt 	<= #1 ~PRF_rename_valid && dest_rename_sig;  //if don't need rename, halt=0;
	  	valid 		<= #1 l_valid;
	  	rat_reg 	<= #1 l_rat_reg;
	  	opa_valid_out 	<= #1 0;
	   	opb_valid_out 	<= #1 0;
		l_valid 	<= #1 valid;
		l_rat_reg	<= #1 rae_reg;
	  end //else
	  else	begin //we can allocate PRF
		for(i=0; i<`ARF_SIZE; i++) begin
			if(i==dest_ARF_idx) begin
	    		rat_reg[i] 	<= #1 PRF_rename_idx;
	    		valid[i] 	<= #1 1;
			end
			else begin
			rat_reg[i]	<= #1 l_ret_reg;
			valid[i]	<= #1 l_valid[i]
		end  //for
	    	opa_PRF_idx 		<= #1 (valid[opa_ARF_idx] && ~opa_valid_in) ? rat_reg[opa_ARF_idx]:0;  //opa request prf
	    	opb_PRF_idx 		<= #1 (valid[opb_ARF_idx] && ~opb_valid_in) ? rat_reg[opa_ARF_idx]:0;
	   	opa_valid_out 		<= #1 opa_valid_in;
	    	opb_valid_out		<= #1 opb_valid_in;
	    	request 		<= #1 1;
	    	PRF_free_sig 		<= #1 0;
	  	PRF_free_list 		<= #1 0;
	  	RAT_allo_halt 		<= #1 0;
	  end //else

	end  //always_ff
