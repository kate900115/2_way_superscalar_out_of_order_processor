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
	input	inst1_enable,	//high if inst can run
	input	inst2_enable,
	input	[$clog2(`ARF_SIZE)-1:0]	opa_ARF_idx1,	//we will use opa_ARF_idx to find PRF_idx
	input	[$clog2(`ARF_SIZE)-1:0]	opb_ARF_idx1,	//to find PRF_idx
	input	[$clog2(`ARF_SIZE)-1:0]	dest_ARF_idx1,	//the ARF index of dest reg
	input	dest_rename_sig1,	//if high, dest_reg need rename

	input	[$clog2(`ARF_SIZE)-1:0]	opa_ARF_idx2,	//we will use opa_ARF_idx to find PRF_idx
	input	[$clog2(`ARF_SIZE)-1:0]	opb_ARF_idx2,	//to find PRF_idx
	input	[$clog2(`ARF_SIZE)-1:0]	dest_ARF_idx2,	//the ARF index of dest reg
	input	dest_rename_sig2,	//if high, dest_reg need rename


	input	opa_valid_in1,	//if high opa_valid is immediate
	input	opb_valid_in1,
	input	opa_valid_in2,	//if high opa_valid is immediate
	input	opb_valid_in2,

	input [$clog2(`ARF_SIZE)-1:0] rega_arf_inst1,  //for branch compute 
	input [$clog2(`ARF_SIZE)-1:0] rega_arf_inst2,  

	input	mispredict_sig1,	//indicate weather mispredict happened
	input	mispredict_sig2,	//indicate weather mispredict happened
	input	[`ARF_SIZE-1:0]	[$clog2(`PRF_SIZE)-1:0]	mispredict_up_idx,	//if mispredict happens, need to copy from rrat

	//Notion: valid1 and idx is the first PRF to use!!!!!!
	//Not for inst1!!!!!!!!!!
	input	PRF_rename_valid1,	//we get valid signal from prf if the dest address has been request
	input	[$clog2(`PRF_SIZE)-1:0]	PRF_rename_idx1,	//the PRF alocated for dest
	input	PRF_rename_valid2,	//we get valid signal from prf if the dest address has been request
	input	[$clog2(`PRF_SIZE)-1:0]	PRF_rename_idx2,	//the PRF alocated for dest


	//output 1
	output	logic	[$clog2(`PRF_SIZE)-1:0]	opa_PRF_idx1,
	output	logic	[$clog2(`PRF_SIZE)-1:0]	opb_PRF_idx1,
	output	logic	request1,  //send to PRF indicate weather it need data
	output	logic	RAT_allo_halt1,
	//output	logic	opa_valid_out1,	//if high opa_valid is immediate
	//output	logic	opb_valid_out1,

	//output 2
	output	logic	[$clog2(`PRF_SIZE)-1:0]	opa_PRF_idx2,
	output	logic	[$clog2(`PRF_SIZE)-1:0]	opb_PRF_idx2,
	output	logic	request2,  //send to PRF indicate weather it need data
	output	logic	RAT_allo_halt2,
	//output	logic	opa_valid_out2,	//if high opa_valid is immediate
	//output	logic	opb_valid_out2,

	output logic [$clog2(`PRF_SIZE)-1:0] rega_prf_inst1,
	output logic [$clog2(`PRF_SIZE)-1:0] rega_prf_inst2,

	//output together
	output	logic	[`PRF_SIZE-1:0]	PRF_free_list_out,
	output	logic			PRF_free_valid
	);

	logic	[`ARF_SIZE-1:0]	[$clog2(`PRF_SIZE)-1:0] rat_reg, n_rat_reg;
	logic	inst1_rename;
	logic	inst2_rename;
	logic	[`ARF_SIZE-1:0]	PRF_free_sig;
	logic	[`ARF_SIZE-1:0]	[$clog2(`PRF_SIZE)-1:0] PRF_free_list;
	logic	i, j;
	//logic	[`PRF_SIZE-1:0]	done;
	

assign inst1_rename = PRF_rename_valid1 & dest_rename_sig1 & inst1_enable;
assign inst2_rename = (PRF_rename_valid2 & dest_rename_sig2) | (PRF_rename_valid1 & ~inst1_rename & dest_rename_sig2) & inst2_enable;

assign request1 = inst1_enable? dest_rename_sig1 : 0;
assign request2 = inst2_enable? dest_rename_sig2 : 0;

	always_ff @(posedge clock) begin
	if(reset) begin
		rat_reg 		<= #1 0;
	  	end
	else begin
		rat_reg 		<= #1 n_rat_reg;
		end
	end //always_ff

	always_comb begin
	  if(mispredict_sig1|mispredict_sig2) begin
	    	PRF_free_sig		= 0;
	    	PRF_free_list 		= 0;
	  	for(int i=0; i<`ARF_SIZE; i++) begin
	  		PRF_free_sig[i] = !(rat_reg[i] == mispredict_up_idx[i]);	//indicate RAT_idx of i has been overwrite
	  		PRF_free_list[i]= (rat_reg[i] == mispredict_up_idx[i])? 0:rat_reg[i];  //indicate the PRF_idx to be free
	  		n_rat_reg[i] 	= mispredict_up_idx[i];  //copy from rrat
	  	end //for
	  	
	  	RAT_allo_halt1 		= 0;
	  	opa_PRF_idx1 		= 0;
	  	opb_PRF_idx1 		= 0;

	  	
	  	RAT_allo_halt2 		= 0;
	  	opa_PRF_idx2 		= 0;
	  	opb_PRF_idx2 		= 0;

	  end //else
	  else if(~inst1_rename && ~inst2_rename) begin
	  	PRF_free_sig 		= 0;
	  	PRF_free_list 		= 0;
	  	n_rat_reg 		= rat_reg;

    		opa_PRF_idx1 		= `PRF_SIZE;
	  	opb_PRF_idx1 		= `PRF_SIZE;
	  	RAT_allo_halt1 		= ~PRF_rename_valid1 && dest_rename_sig1;  //if don't need rename, halt=0;

		opa_PRF_idx2 		= `PRF_SIZE;
	  	opb_PRF_idx2 		= `PRF_SIZE;
	  	RAT_allo_halt2 		= ~PRF_rename_valid2 && dest_rename_sig2;  //if don't need rename, halt=0;

	  	
	  	
	  end //else

	  else if(inst1_rename && ~inst2_rename) begin
	  	PRF_free_sig 	= 0;
	  	PRF_free_list 	= 0;
	  	n_rat_reg 	= rat_reg;

	    	for(int i=0; i<`ARF_SIZE; i++) begin
			if(i==dest_ARF_idx1) begin
	    		n_rat_reg[i] 	= PRF_rename_idx1;
	    		break;
			end
			else begin
				n_rat_reg[i]	= rat_reg[i];
			end //else
		end  //for

		RAT_allo_halt1 	= 0;

	  	RAT_allo_halt2 	= ~PRF_rename_valid2 && dest_rename_sig2;  //if don't need rename, halt=0;

		
	  	
	  end //else

	  else if(~inst1_rename && inst2_rename) begin
	  	PRF_free_sig 	= 0;
	  	PRF_free_list	= 0;
	  	n_rat_reg 	= rat_reg;

	    	for(int i=0; i<`ARF_SIZE; i++) begin
			if(i==dest_ARF_idx2) begin
	    		n_rat_reg[i] 	= PRF_rename_idx2;
	    		break;
			end
			else begin
			n_rat_reg[i]	= rat_reg[i];
			end //else
		end  //for

		RAT_allo_halt2 	= 0;

	  	RAT_allo_halt1 	= 0;  //if inst can be renamed, then inst 1 must not halt

	  	
		
	  end //else

	  else	begin //we can allocate PRF1 and PRF2
	  	PRF_free_sig 	= 0;
	  	PRF_free_list 	= 0;

		for(int i=0; i<`ARF_SIZE; i++) begin
			n_rat_reg[i] = rat_reg[i];
			if (dest_ARF_idx1 == i)
				n_rat_reg[i] = PRF_rename_idx1;
			if (dest_ARF_idx2 == i)
				n_rat_reg[i] = PRF_rename_idx2;
		end//for


		RAT_allo_halt1 	= 0;


		RAT_allo_halt2 	= 0;
	  	
		

	  end //else
	  	opa_PRF_idx2 	= (~inst2_enable)? 0 : (opa_valid_in2) ? 0:
				(dest_ARF_idx1 == opa_ARF_idx2)? PRF_rename_idx1:(opa_ARF_idx2==5'h1f)?`PRF_SIZE:rat_reg[opa_ARF_idx2];  //opa request prf
		opb_PRF_idx2 	= (~inst2_enable)? 0 : (opb_valid_in2) ? 0:
				(dest_ARF_idx1 == opb_ARF_idx2)? PRF_rename_idx1:(opb_ARF_idx2==5'h1f)?`PRF_SIZE:rat_reg[opb_ARF_idx2];
		opa_PRF_idx1 	= (~inst1_enable)? 0 : (opa_valid_in1) ? 0: (opa_ARF_idx1==5'h1f)? `PRF_SIZE:rat_reg[opa_ARF_idx1];  //opa request prf
		opb_PRF_idx1 	= (~inst1_enable)? 0 : (opb_valid_in1) ? 0: (opb_ARF_idx1==5'h1f)? `PRF_SIZE:rat_reg[opb_ARF_idx1];

		rega_prf_inst1  = (~inst1_enable)? 0 : (rega_arf_inst1 == 5'h1f)? `PRF_SIZE:rat_reg[rega_arf_inst1];
		rega_prf_inst2  = (~inst2_enable)? 0 : (dest_ARF_idx1 == rega_arf_inst2) ? PRF_rename_idx1 : (rega_arf_inst2 == 5'h1f)? `PRF_SIZE:rat_reg[rega_arf_inst2];


	for(int i=0; i<`ARF_SIZE; i++) begin
		if(PRF_free_sig[i] == 1) begin
		  PRF_free_valid = 1;
		  break;
		end // if
		else PRF_free_valid = 0;

	end //for

	for(int j=0; j<`PRF_SIZE; j++) begin		
		for(int i=0; i<`ARF_SIZE; i++) begin
			if(PRF_free_sig[i] && PRF_free_list[i] == j) begin
			PRF_free_list_out[j] = 1;
			break;
			end
			else begin
			PRF_free_list_out[j] = 0;
			
			end
		end//for
	end//for

	end  //always_comb
endmodule


	
