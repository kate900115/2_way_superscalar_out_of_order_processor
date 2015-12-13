module test_cdb_one_entry;
	//input
	logic [5:0]				fu_select;
	logic [63:0]				adder1_result_in;
	logic [$clog2(`PRF_SIZE)-1:0]		adder1_dest_reg_idx;
	logic [63:0]				mult1_result_in;
	logic [$clog2(`PRF_SIZE)-1:0]		mult1_dest_reg_idx;
	logic [63:0]				memory1_result_in;
	logic [$clog2(`PRF_SIZE)-1:0] 		memory1_dest_reg_idx;
	logic [63:0]				adder2_result_in;
	logic [$clog2(`PRF_SIZE)-1:0]		adder2_dest_reg_idx;
	logic [63:0]				mult2_result_in;
	logic [$clog2(`PRF_SIZE)-1:0]		mult2_dest_reg_idx;
	logic [63:0]				memory2_result_in;
	logic [$clog2(`PRF_SIZE)-1:0] 		memory2_dest_reg_idx;


	//output
	logic 					cdb_valid;
	logic [$clog2(`PRF_SIZE)-1:0]		cdb_tag;
	logic [63:0]				cdb_out;	

	cdb_one_entry cdb1(
		//input
		.fu_select(fu_select),
		.memory1_result_in(memory1_result_in),
		.memory1_dest_reg_idx(memory1_dest_reg_idx),
		.memory2_result_in(memory2_result_in),
		.memory2_dest_reg_idx(memory2_dest_reg_idx),
		.mult1_result_in(mult1_result_in),
		.mult1_dest_reg_idx(mult1_dest_reg_idx),
		.mult2_result_in(mult2_result_in),
		.mult2_dest_reg_idx(mult2_dest_reg_idx),
		.adder1_result_in(adder1_result_in),
		.adder1_dest_reg_idx(adder1_dest_reg_idx),
		.adder2_result_in(adder2_result_in),
		.adder2_dest_reg_idx(adder2_dest_reg_idx),

		//output
		.cdb_valid(cdb_valid),
		.cdb_tag(cdb_tag),
		.cdb_out(cdb_out)	
	);
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	initial begin
		$monitor(" @@@  time:%d, \n\
				cdb_valid:%b, \n\
				cdb_tag:%b, \n\
				cdb_out:%h",
				$time, 
				cdb_valid,cdb_tag,cdb_out);


		
		$display("@@@ adder send data in!!");
		fu_select		=6'b000010;
		adder1_result_in	=35;
		adder1_dest_reg_idx	=6'b011011;
		mult1_result_in 	=0;
		mult1_dest_reg_idx	=0;
		memory1_result_in	=0;
		memory1_dest_reg_idx	=0;
		adder2_result_in	=5;
		adder2_dest_reg_idx	=6'b110011;
		mult2_result_in 	=0;
		mult2_dest_reg_idx	=0;
		memory2_result_in	=7;
		memory2_dest_reg_idx	=6'b000011;
		#10;
		$display("@@@ multiplier send data in!!");
		fu_select		=6'b000100;
		adder1_result_in	=35;
		adder1_dest_reg_idx	=6'b011011;
		mult1_result_in 	=0;
		mult1_dest_reg_idx	=0;
		memory1_result_in	=0;
		memory1_dest_reg_idx	=0;
		adder2_result_in	=5;
		adder2_dest_reg_idx	=6'b110011;
		mult2_result_in 	=46;
		mult2_dest_reg_idx	=6'b000101;
		memory2_result_in	=7;
		memory2_dest_reg_idx	=6'b000011;
		#10;
		$display("@@@ memory send data in!!");
		fu_select		=6'b100000;
		adder1_result_in	=35;
		adder1_dest_reg_idx	=6'b011011;
		mult1_result_in 	=0;
		mult1_dest_reg_idx	=0;
		memory1_result_in	=8;
		memory1_dest_reg_idx	=6'b000000;
		adder2_result_in	=5;
		adder2_dest_reg_idx	=6'b110011;
		mult2_result_in 	=46;
		mult2_dest_reg_idx	=6'b000101;
		memory2_result_in	=7;
		memory2_dest_reg_idx	=6'b000011;
		#10;
		$display("@@@ memory and multiplier send data in at the same time!!");
		fu_select		=6'b011000;
		adder1_result_in	=35;
		adder1_dest_reg_idx	=6'b011011;
		mult1_result_in 	=7;
		mult1_dest_reg_idx	=6'b001010;
		memory1_result_in	=8;
		memory1_dest_reg_idx	=6'b000000;
		adder2_result_in	=5;
		adder2_dest_reg_idx	=6'b110011;
		mult2_result_in 	=46;
		mult2_dest_reg_idx	=6'b000101;
		memory2_result_in	=7;
		memory2_dest_reg_idx	=6'b000001;
		#10;
		$display("@@@ adder and multiplier send data in at the same time!!");
		fu_select		=6'b001001;
		adder1_result_in	=35;
		adder1_dest_reg_idx	=6'b011011;
		mult1_result_in 	=7;
		mult1_dest_reg_idx	=6'b001010;
		memory1_result_in	=8;
		memory1_dest_reg_idx	=6'b000000;
		adder2_result_in	=5;
		adder2_dest_reg_idx	=6'b110011;
		mult2_result_in 	=46;
		mult2_dest_reg_idx	=6'b000101;
		memory2_result_in	=7;
		memory2_dest_reg_idx	=6'b000001;
		#10;
		$display("@@@ adder, multiplier and memory send data in at the same time!!");
		fu_select		=6'b100101;
		adder1_result_in	=35;
		adder1_dest_reg_idx	=6'b011011;
		mult1_result_in 	=7;
		mult1_dest_reg_idx	=6'b001010;
		memory1_result_in	=8;
		memory1_dest_reg_idx	=6'b000000;
		adder2_result_in	=5;
		adder2_dest_reg_idx	=6'b110011;
		mult2_result_in 	=46;
		mult2_dest_reg_idx	=6'b000101;
		memory2_result_in	=7;
		memory2_dest_reg_idx	=6'b000001;
		#10;
		$finish;
		
	end
		


endmodule
