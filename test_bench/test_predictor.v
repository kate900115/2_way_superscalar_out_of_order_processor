module test_predictor;
	logic two_threads_enable;
	logic reset;
	logic clock;
	logic [63:0] if_inst1_pc;
	logic inst1_valid;
	logic [63:0] if_inst2_pc;
	logic inst2_valid;

	logic branch_result1;              //branch taken or not taken
	logic [63:0] branch_pc1;             //branch local pc
	logic branch_valid1;
	logic branch_result2;
	logic [63:0] branch_pc2;
	logic branch_valid2;

	logic inst1_predict;              //inst predict signal
	logic inst1_predict_valid;
	logic inst2_predict;
	logic inst2_predict_valid;


	predictor predictor1(.two_threads_enable(two_threads_enable),
		       	     .reset(reset),
			     .clock(clock),
			     .if_inst1_pc(if_inst1_pc),
			     .inst1_valid(inst1_valid),
			     .if_inst2_pc(if_inst2_pc),
			     .inst2_valid(inst2_valid),

			     .branch_result1(branch_result1),              //branch taken or not taken
			     .branch_pc1(branch_pc1),             //branch local pc
			     .branch_valid1(branch_valid1),
			     .branch_result2(branch_result2),
			     .branch_pc2(branch_pc2),
			     .branch_valid2(branch_valid2),

			     .inst1_predict(inst1_predict),              //inst predict signal
			     .inst1_predict_valid(inst1_predict_valid),
			     .inst2_predict(inst2_predict),
			     .inst2_predict_valid(inst2_predict_valid)
		);


	always #5 clock = ~clock;
	
	task exit_on_error;
		begin
			#1;
			$display("@@@Failed at time %f", $time);
			$finish;
		end
	endtask

	initial 
	begin
		$monitor(" @@@  time:%d, clk:%b, \n\
						inst1_predict:%b, inst1_predict_valid:%b, \
						inst2_predict:%b, inst2_predict_valid:%b", 
				$time, clock, 
				inst1_predict, inst1_predict_valid, inst2_predict, inst2_predict_valid);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1;
		two_threads_enable=0;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");

		$display("@@@ next instruction!");
		reset = 0;
		two_threads_enable=1;

		
		if_inst1_pc=64'h92;
		inst1_valid=1;
		if_inst2_pc=64'h96;
		inst2_valid=1;

		@(negedge clock);
		$display("@@@first two branch need predict");
		
		if_inst1_pc=64'h32;
		inst1_valid=1;
		if_inst2_pc=64'h36;
		inst2_valid=1;

		@(negedge clock);
		$display("@@@second two branch need predict");

		branch_result1=0;              //branch taken or not taken
		branch_pc1=64'h92;             //branch local pc
		branch_valid1=1;
		branch_result2=1;
		branch_pc2=64'h96;
		branch_valid2=1;
		if_inst1_pc=64'h42;
		inst1_valid=1;
		if_inst2_pc=64'h36;
		inst2_valid=0;

		@(negedge clock);
		$display("@@@third two branch need predict and first two savw history");

		inst1_valid=0;
		branch_result1=0;              //branch taken or not taken
		branch_pc1=64'h32;             //branch local pc
		branch_valid1=1;
		branch_result2=1;
		branch_pc2=64'h36;
		branch_valid2=1;

		@(negedge clock);
		$display("@@@second two branch save history");

		branch_result1=1;              //branch taken or not taken
		branch_pc1=64'h42;             //branch local pc
		branch_valid1=1;
		branch_valid2=0;

		
		@(negedge clock);
		$display("@@@third two branch save history");

		$finish;
	end
endmodule
		


 	

