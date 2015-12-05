module predictor(
		input two_threads_enable,
		input reset,
		input clock,
		input [63:0] if_inst1_pc,
		input inst1_valid,
		input [63:0] if_inst2_pc,
		input inst2_valid,

		input branch_result1,              //branch taken or not taken
		input [63:0] branch_pc1,             //branch local pc
		input branch_valid1,
		input branch_result2,
		input [63:0] branch_pc2,
		input branch_valid2,

		output logic inst1_predict,              //inst predict signal
		output logic inst1_predict_valid,
		output logic inst2_predict,
		output logic inst2_predict_valid,
		
		output logic branch1_mispredict,
		output logic branch1_mispredict_valid,
		output logic branch2_mispredict,
		output logic branch2_mispredict_valid
	);

	logic [`LOCALTAB_SIZE-1:0] [$clog2(`LHISTORY_SIZE)-1:0] local_history;
	logic [`LOCALTAB_SIZE-1:0] [$clog2(`LHISTORY_SIZE)-1:0] local_nexthistory;
	logic [`LHISTORY_SIZE-1:0] [1:0] l_nextstate,l_state;
	//logic [1:0] predict_state;
	logic [$clog2(`LHISTORY_SIZE)-1:0] inst1_lhistory;
	logic [$clog2(`LHISTORY_SIZE)-1:0] inst2_lhistory;

	always_comb begin

		branch1_mispredict=0;
		branch1_mispredict_valid=0;
		branch2_mispredict=0;
		branch2_mispredict_valid=0;

		for (int j=0; j<`LHISTORY_SIZE; j++) begin

				l_nextstate[j]=l_state[j];
			for (int i=0; i<`LOCALTAB_SIZE; i++) begin
				local_nexthistory[i]=local_history[i];
			
				if(i==branch_pc1[$clog2(`LOCALTAB_SIZE)+1:2] && branch_valid1) begin
				//if(branch_valid1) begin
					local_nexthistory[i]=local_history[i]<<1+branch_result1;
					if(j==local_history[i]) begin

						if(branch_result1 && l_state[j]!= 2'b11) begin
							l_nextstate[j]=l_state[j]+1;

							if(l_state[j][1])   begin     //predict branch taken
								branch1_mispredict=1'b0;
								branch1_mispredict_valid=1'b1;
							end
							else begin
								branch1_mispredict=1'b1;
								branch1_mispredict_valid=1'b1;
							end
						end


						else if(~branch_result1 && l_state[j]!= 2'b00) begin
							l_nextstate[j]=l_state[j]-1;
				
							if(l_state[j][1])   begin     //predict branch taken
								branch1_mispredict=1'b1;
								branch1_mispredict_valid=1'b1;
							end
							else begin
								branch1_mispredict=1'b0;
								branch1_mispredict_valid=1'b1;
							end
						end	
						
						else
							l_nextstate[j]=l_state[j];
					end
				end
			
				if(i==branch_pc2[$clog2(`LOCALTAB_SIZE)+1:2] && branch_valid2) begin
				//if(branch_valid2) begin
					local_nexthistory[i]=local_history[i]<<1+branch_result2;
					if(j==local_history[i]) begin

						if(branch_result2 && l_state[j]!= 2'b11) begin
							l_nextstate[j]=l_state[j]+1;
			
							if(l_state[j][1])   begin     //predict branch taken
								branch2_mispredict=1'b0;
								branch2_mispredict_valid=1'b1;
							end
							else begin
								branch2_mispredict=1'b1;
								branch2_mispredict_valid=1'b1;
							end
						end


						else if(~branch_result2 && l_state[j]!= 2'b00)
							l_nextstate[j]=l_state[j]-1;
				
							if(l_state[j][1])   begin     //predict branch taken
								branch2_mispredict=1'b1;
								branch2_mispredict_valid=1'b1;
							end
							else begin
								branch2_mispredict=1'b0;
								branch2_mispredict_valid=1'b1;
							end
						end

						else
							l_nextstate[j]=l_state[j];
					end
				end
			end
		end
	
	assign inst1_lhistory= (inst1_valid && two_threads_enable) ? local_history[if_inst1_pc[$clog2(`LOCALTAB_SIZE)+1:2]]:0;
	assign inst2_lhistory= (inst2_valid && two_threads_enable) ? local_history[if_inst2_pc[$clog2(`LOCALTAB_SIZE)+1:2]]:0;
	
	assign inst1_predict= (inst1_valid && two_threads_enable) ? l_state[inst1_lhistory][1]:0;
	assign inst2_predict= (inst2_valid && two_threads_enable) ? l_state[inst2_lhistory][1]:0;

	assign inst1_predict_valid= inst1_valid && two_threads_enable;
	assign inst2_predict_valid= inst2_valid && two_threads_enable;

	
		

	
	always_ff @(posedge clock) begin
		if(reset) begin
			local_history <= `SD 0;
			l_state       <= `SD 0;
		end
		else begin
			local_history <= `SD local_nexthistory;
			l_state       <= `SD l_nextstate;
		end	
	end

endmodule

			
		
