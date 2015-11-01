module cdb(adder_result_ready,
	   adder_result_in,
	   mult_result_ready,
	   mult_result_in,
	   memory_result_ready,
	   memory_result_in,
           dest_reg_idx,
	   cdb_valid,
	   cdb_tag,
           cdb_out
)
	parameter p_SIZE=3;
	input  				adder_result_ready;
	input  [63:0]			adder_result_in;
	input  				mult_result_ready;
	input  [63:0]			mult_result_in;
	input  				memory_result_ready;
	input  [63:0]			memory_result_in;
	input  [$clog2(`PRF_SIZE)-1:0]	dest_reg_idx;
	
	output 				cdb_valid;
	output [$clog2(`PRF_SIZE)-1:0]	cdb_tag;
	output [63:0]			cdb_out;	

	logic  [p_SIZE-1:0]		instruction_select_result;			
	

	priority_selector #(.SIZE(p_SIZE)) cdb_psl1( 
		.req({memory_result_ready,mult_result_ready,adder_result_ready}),
	        .en(1'b1),
        	.gnt(instruction_select_result)
	);

	always_comb
	begin
		case (instruction_select_result)
		3'b001:		
			begin
				cdb_valid = 1'b1;				
				cdb_tag   = dest_reg_idx;
				cdb_out   = adder_result_in;
			end
		3'b010:
			begin
				cdb_valid = 1'b1;				
				cdb_tag   = dest_reg_idx;
				cdb_out   = mult_result_in;
			end
		3'b100:
			begin
				cdb_valid = 1'b1;				
				cdb_tag   = dest_reg_idx;
				cdb_out   = memory_result_in;
			end
		default:
			begin
				cdb_valid = 1'b0;				
				cdb_tag   = 0;
				cdb_out   = 0;
			end
	end
endmodule
