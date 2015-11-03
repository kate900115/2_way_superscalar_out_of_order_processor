module test_cdb;
	//input
	logic 					adder_result_ready;
	logic [63:0]				adder_result_in;
	logic [$clog2(`PRF_SIZE)-1:0]		adder_dest_reg_idx;
	logic 					mult_result_ready;
	logic [63:0]				mult_result_in;
	logic [$clog2(`PRF_SIZE)-1:0]		mult_dest_reg_idx;
	logic  					memory_result_ready;
	logic [63:0]				memory_result_in;
	logic [$clog2(`PRF_SIZE)-1:0] 		memory_dest_reg_idx;

	//output
	logic 					cdb_valid;
	logic [$clog2(`PRF_SIZE)-1:0]		cdb_tag;
	logic [63:0]				cdb_out;
	logic					mult_result_send_in_fail;
	logic					adder_result_send_in_fail;	

	cdb cdb1(
		//input
		.adder_result_ready(adder_result_ready),
	   	.adder_result_in(adder_result_in),
		.adder_dest_reg_idx(adder_dest_reg_idx),
	   	.mult_result_ready(mult_result_ready),
	   	.mult_result_in(mult_result_in),
		.mult_dest_reg_idx(mult_dest_reg_idx),
	   	.memory_result_ready(memory_result_ready),
	   	.memory_result_in(memory_result_in),
           	.memory_dest_reg_idx(memory_dest_reg_idx),

		//output
	   	.cdb_valid(cdb_valid),
	   	.cdb_tag(cdb_tag),
           	.cdb_out(cdb_out),
		.mult_result_send_in_fail(mult_result_send_in_fail),
		.adder_result_send_in_fail(adder_result_send_in_fail)	
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
				cdb_out:%h, \n\
				adder_result_send_in_fail:%b, \n\
				mult_result_send_in_fail:%b",
				$time, 
				cdb_valid,cdb_tag,cdb_out,mult_result_send_in_fail,adder_result_send_in_fail);


		
		$display("@@@ adder send data in!!");
		adder_result_ready	=1;
		adder_result_in		=35;
		adder_dest_reg_idx	=6'b111011;
		mult_result_ready	=0;
		mult_result_in 		=0;
		mult_dest_reg_idx	=0;
		memory_result_ready	=0;
		memory_result_in	=0;
		memory_dest_reg_idx		=0;
		#10;
		$display("@@@ multiplier send data in!!");
		adder_result_ready	=0;
		adder_result_in		=0;
		adder_dest_reg_idx	=0;
		mult_result_ready	=1;
		mult_result_in 		=700;
		mult_dest_reg_idx	=6'b110011;
		memory_result_ready	=0;
		memory_result_in	=0;
		memory_dest_reg_idx	=0;
		#10;
		$display("@@@ memory send data in!!");
		adder_result_ready	=0;
		adder_result_in		=0;
		adder_dest_reg_idx	=0;
		mult_result_ready	=0;
		mult_result_in 		=0;
		mult_dest_reg_idx	=0;
		memory_result_ready	=1;
		memory_result_in	=4;
		memory_dest_reg_idx	=6'b000011;
		#10;
		$display("@@@ memory and multiplier send data in at the same time!!");
		adder_result_ready	=0;
		adder_result_in		=0;
		adder_dest_reg_idx	=0;
		mult_result_ready	=1;
		mult_result_in 		=80;
		mult_dest_reg_idx	=6'b001011;
		memory_result_ready	=1;
		memory_result_in	=7;
		memory_dest_reg_idx	=6'b001010;
		#10;
		$display("@@@ adder and multiplier send data in at the same time!!");
		adder_result_ready	=1;
		adder_result_in		=14;
		adder_dest_reg_idx	=6'b010101;
		mult_result_ready	=1;
		mult_result_in 		=80;
		mult_dest_reg_idx	=6'b100001;
		memory_result_ready	=0;
		memory_result_in	=0;
		memory_dest_reg_idx	=0;
		#10;
		$display("@@@ adder, multiplier and memory send data in at the same time!!");
		adder_result_ready	=1;
		adder_result_in		=29;
		adder_dest_reg_idx	=6'b100111;
		mult_result_ready	=1;
		mult_result_in 		=6;
		mult_dest_reg_idx	=6'b000001;
		memory_result_ready	=1;
		memory_result_in	=7;
		memory_dest_reg_idx	=6'b001000;
		$finish;
		#10;
	end
		


endmodule
