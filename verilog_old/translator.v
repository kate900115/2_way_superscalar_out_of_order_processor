/******************************************************************************//
//      	modulename: translator.v				       //
//      								       //
//      		Description:					       //
//      								       //
//  this module tranlate the idx of rob to "SIZE OF ROB" bits,                 //
//  for example {4'd15}->{1,15'd0}, 		      			       //
//      								       //
//      								       //
//      								       //
//      								       //
/////////////////////////////////////////////////////////////////////////////////

module translator(idx,load);
	parameter ROB_SIZE=16;
	input [$clog2(ROB_SIZE)-1:0]	idx;
	output	[ROB_SIZE-1:0]		load;
	always_comb
	begin
		for(int i=0;i<ROB_SIZE;i++)
		begin		
			if(idx==i)
				load[i]=1;
			else
				load[i]=0;
		end

	end



endmodule
