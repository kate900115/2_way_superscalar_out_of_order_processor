module test_hhh;

	logic start;
	logic [7:0][2:0] signal;


	hhh hhh1(start,signal);
	initial
	begin
		#5 start=1;
#2
		$display("signal= %b",signal);
		$finish;
	end
endmodule
