module test_BTB;
	logic reset;
	logic clock;
	logic two_threads_enable;
	logic [63:0] if_inst1_pc;
	logic [63:0] if_inst2_pc;
	logic inst1_valid;
	logic inst2_valid;
		
	logic [63:0] pc_idx1;
	logic [63:0] pc_idx2;		
	logic [63:0] target_pc1;
	logic [63:0] target_pc2;
	logic target_pc1_valid;
	logic target_pc2_valid;
		
	logic [63:0] target_inst1_pc;
	logic [63:0] target_inst2_pc;
	logic target_inst1_valid;
	logic target_inst2_valid;


	BTB BTB_1(.reset(reset),
		  .clock(clock),
		  .if_inst1_pc(if_inst1_pc),
		  .if_inst2_pc(if_inst2_pc),
		  .inst1_valid(inst1_valid),
		  .inst2_valid(inst2_valid),
		
		  .pc_idx1(pc_idx1),
		  .pc_idx2(pc_idx2),		
		  .target_pc1(target_pc1),
		  .target_pc2(target_pc2),
		  .target_pc1_valid(target_pc1_valid),
		  .target_pc2_valid(target_pc2_valid),
		
		  .target_inst1_pc(target_inst1_pc),
		  .target_inst2_pc(target_inst2_pc),
		  .target_inst1_valid(target_inst1_valid),
		  .target_inst2_valid(target_inst2_valid)

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
						target_inst1_pc:%h, target_inst1_valid:%b,\
						target_inst2_pc:%h, target_inst2_valid:%b",
				$time, clock, 
				target_inst1_pc, target_inst1_valid,target_inst2_pc, target_inst2_valid);


		clock = 0;
		$display("@@@ reset!!");
		//RESET
		reset = 1;
		two_threads_enable=0;
		#5;
		@(negedge clock);
		$display("@@@ stop reset!!");
		reset = 0;
		two_threads_enable=1;

		
		if_inst1_pc=64'h92;                         //predicted taken branch comes into BTB
		inst1_valid=1;
		if_inst2_pc=64'h96;
		inst2_valid=1;

		@(negedge clock);
		$display("@@@first two branch predict taken need target");
		
		if_inst1_pc=64'h32;
		inst1_valid=1;
		if_inst2_pc=64'h36;
		inst2_valid=1;

		@(negedge clock);
		$display("@@@second two branch predict taken need target");

		pc_idx1=64'h92;
		pc_idx2=64'h96;		
		target_pc1=64'h10;
		target_pc2=64'h2c;
		target_pc1_valid=1;
		target_pc2_valid=1;
		if_inst1_pc=64'h42;
		inst1_valid=1;
		if_inst2_pc=64'h36;
		inst2_valid=0;

		@(negedge clock);
		$display("@@@third two branch predict taken and first two target saved");

		inst1_valid=0;
		pc_idx1=64'h32;
		pc_idx2=64'h36;		
		target_pc1=64'h80;
		target_pc2=64'h64;
		target_pc1_valid=1;
		target_pc2_valid=1;

		@(negedge clock);
		$display("@@@second two branch save target");

		pc_idx1=64'h42;		
		target_pc1=64'h30;
		target_pc1_valid=1;
		target_pc2_valid=0;
		if_inst1_pc=64'h92;                         //predicted taken branch comes into BTB
		inst1_valid=1;
		if_inst2_pc=64'h96;
		inst2_valid=1;

		@(negedge clock);
		$display("@@@third two branch save target");

		$finish;
	end
endmodule
		


 	

