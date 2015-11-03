module cdb(
	input  					adder_result_ready,
	input  	[63:0]				adder_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]		adder_dest_reg_idx,
	input  					mult_result_ready,
	input  	[63:0]				mult_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]		mult_dest_reg_idx,
	input  					memory_result_ready,
	input  	[63:0]				memory_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]		memory_dest_reg_idx,
	
	output 	logic				cdb_valid,
	output  logic [$clog2(`PRF_SIZE)-1:0]	cdb_tag,
	output 	logic [63:0]			cdb_out,
	output	logic				mult_result_send_in_fail,
	output	logic				adder_result_send_in_fail	
);

	

	always_comb
	begin
		case ({memory_result_ready, mult_result_ready, adder_result_ready})
		3'b001:		
			begin
				cdb_valid		   = 1'b1;				
				cdb_tag  		   = adder_dest_reg_idx;
				cdb_out  		   = adder_result_in;
				mult_result_send_in_fail   = 0;
				adder_result_send_in_fail  = 0;
			end
		3'b010:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = mult_dest_reg_idx;
				cdb_out   		   = mult_result_in;
				mult_result_send_in_fail   = 0;
				adder_result_send_in_fail  = 0;
			end
		3'b011:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = mult_dest_reg_idx;
				cdb_out   		   = mult_result_in;
				mult_result_send_in_fail   = 0;
				adder_result_send_in_fail  = 1;
			end
		3'b100:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = memory_dest_reg_idx;
				cdb_out   	     	   = memory_result_in;
				mult_result_send_in_fail   = 0;
				adder_result_send_in_fail  = 0;
			end
		3'b101:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag         	   = memory_dest_reg_idx;
				cdb_out   		   = memory_result_in;
				mult_result_send_in_fail   = 0;
				adder_result_send_in_fail  = 1;
			end
		3'b110:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   	   	   = memory_dest_reg_idx;
				cdb_out   		   = memory_result_in;
				mult_result_send_in_fail   = 1;
				adder_result_send_in_fail  = 0;
			end
		3'b111:
			begin
				cdb_valid 		   = 1'b1;				
				cdb_tag   		   = memory_dest_reg_idx;
				cdb_out   		   = memory_result_in;
				mult_result_send_in_fail   = 1;
				adder_result_send_in_fail  = 1;
			end
		default:
			begin
				cdb_valid 		   = 1'b0;				
				cdb_tag   		   = 0;
				cdb_out   		   = 0;
				mult_result_send_in_fail   = 0;
				adder_result_send_in_fail  = 0;
			end
		endcase
	end
endmodule
