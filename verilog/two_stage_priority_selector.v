// this is for selecting two signals from available list using two priority selectors 
// output each one selected then output the "+" of two output



module two_stage_priority_selector(available, enable1, enable2, output1, output2);

	parameter p_SIZE=8;
	input 	[p_SIZE-1:0]	available;
	input   	    	enable1;
	input               	enable2;
	output	[p_SIZE-1:0]	output1;
	output	[p_SIZE-1:0]	output2;
	logic	[p_SIZE-1:0]	available2;

priority_selector #(.SIZE(p_SIZE)) rs_psl1( 
		.req(available),
	        .en(enable1),
        	.gnt(output1)
	);

assign available2 = (~output1) & available;

priority_selector #(.SIZE(p_SIZE)) rs_psl2( 
		.req(available2),
	        .en(enable2),
        	.gnt(output2)
	);

endmodule
