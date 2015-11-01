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
	input	dest_rename_sig;	//if high, dest_reg need rename, imme => low

	input	opa_valid_in,	//if high opa_valid is immediate
	input	opb_valid_in,

	input	[`ARF_SIZE-1:0]	[clog2(`PRF_SIZE)-1:0]	mispredict_up_idx,	//if mispredict happens, need to copy from rrat
	input	mispredict_sig,	//indicate weather mispredict happened

	input	PRF_rename_valid,	//we get valid signal from prf if the dest address has been allocated
	input	[$clog2(`PRF_SIZE)-1:0]	PRF_rename_idx,	//the PRF alocated for dest

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
	  	for(i=0; i<`ARF_SIZE; i++) 
	  		valid[i]= 0;
	  	opa_PRF_idx = 0;
	  	opb_PRF_idx = 0;
	  	request = 0;
	  	PRF_free_sig = 0;
	  	PRF_free_list = 0;
	  	RAT_allo_halt = 0;
	  	rat_reg = 0;   
	  	opa_valid_out = 0;
	    opb_valid_out = 0;
	  end
	  else if(mispredict_sig) begin
	    PRF_free_sig = 0;
	    PRF_free_list = 0;
	  	for(i=0; i<`ARF_SIZE; i++) begin
	  		valid[i] = 1;
	  		PRF_free_sig[i] = rat_reg[i] ~= mispredict_up_idx[i];	//indicate RAT_idx of i has been overwrite
	  		PRF_free_list[i] = （rat_reg[i] ~= mispredict_up_idx[i]）？ rat_reg[i]：0;  //indicate the PRF_idx to be free
	  		rat_reg[i] = mispredict_up_idx[i];  //copy from rrat
	  	end //for
	  	request = 0;
	  	RAT_allo_halt = 0;
	  	opa_PRF_idx = 0;
	  	opb_PRF_idx = 0;
	  	opa_valid_out = 0;
	    opb_valid_out = 0;
	  end //else
	  else if((~PRF_rename_valid && dest_rename_sig) | ~dest_rename_sig) begin
	    opa_PRF_idx = 0;
	  	opb_PRF_idx = 0;
	  	request = 0;
	  	PRF_free_sig = 0;
	  	PRF_free_list = 0;
	  	RAT_allo_halt = ~PRF_rename_valid && dest_rename_sig;  //if don't need rename, halt=0;
	  	valid = l_valid;
	  	rat_reg = l_rat_reg;
	  	opa_valid_out = 0;
	    opb_valid_out = 0;
	  end //else
	  else	begin //we can allocate PRF
	    rat_reg[dest_ARF_idx] = PRF_rename_idx;
	    valid[dest_ARF_idx] = 1;
	    opa_PRF_idx = (valid[opa_ARF_idx] && ~opa_valid_in) ? rat_reg[opa_ARF_idx]:0;  //opa request prf
	    opb_PRF_idx = (valid[opb_ARF_idx] && ~opb_valid_in) ? rat_reg[opa_ARF_idx]:0;
	    opa_valid_out = opa_valid_in;
	    opb_valid_out = opb_valid_in;
	    request = 1;
	    PRF_free_sig = 0;
	  	PRF_free_list = 0;
	  	RAT_allo_halt = 0;
	  end //else

	end  //always_ff
