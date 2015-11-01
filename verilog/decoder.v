/******************************************************************************//
//      	modulename: decoder.v				               //
//      								       //
//      		Description:					       //
//      								       //
//  this module decode the input which has one "1",                            //
//  for example {1,15'd0}->{4'd15}, it can calculate the     		       //
//  place if "1" and output the place	{15'd0,1}->{4'd0}		       //
//      								       //
//      								       //
//      								       //
//      								       //
/////////////////////////////////////////////////////////////////////////////////



/*module bitdecoder(
	input 		[3:0]	load,
	output	reg	[1:0]	idx
);	

	always_comb
		begin
			case(load)
				4'b1000:
					idx=2'b11;
				4'b0100:
					idx=2'b10;
				4'b0010:
					idx=2'b01;
				4'b0001:
					idx=2'b00;
				default:
					idx=2'b00;
			endcase
		end







endmodule
	

module decoder(
	input [`ROB_SIZE-1] 				load,

	output	logic	[$clog2(`ROB_SIZE)-1:0]		idx
);
		

	bitdecoder b_decoder[`ROB_SIZE/4-1:0] (
	.load(load),.idx(idx));

endmodule*/
module decoder(load,idx);
parameter ROB_SIZE = 16;
input [ROB_SIZE-1:0] 				load,
output	logic	[$clog2(ROB_SIZE)-1:0]		idx
	always_comb
	begin
		for(int i=0;i<ROB_SIZE;i++)
		begin
			if(load[i]==1)
			begin
				idx=i;
				break;
			end
			
		end
	end

endmodule
	
