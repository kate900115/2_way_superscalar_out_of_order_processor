module hhh(input start,
	   output logic [7:0][2:0] signal);
	
always_comb
begin
	if(start)
	begin
		for (int i=0;i<8;i++)
		begin
			signal[i]=i;
		end	
	end
	else
	begin
		signal=0;
	end
end
endmodule
