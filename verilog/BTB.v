module BTB(
		input reset,
		input clock,
		input [63:0] if_inst1_pc,
		input [63:0] if_inst2_pc,
		input inst1_valid,
		input inst2_valid,
		
		input [63:0] pc_idx1,
		input [63:0] pc_idx2,		
		input [63:0] target_pc1,
		input [63:0] target_pc2,
		input target_pc1_valid,
		input target_pc2_valid,
		
		output logic [63:0] target_inst1_pc,
		output logic [63:0] target_inst2_pc,
		output logic target_inst1_valid,
		output logic target_inst2_valid
	);
	
	logic [`BTB_SIZE-1:0] [63:0] BTB_pc_1;
	logic [`BTB_SIZE-1:0] [63:0] BTB_nextpc_1;              //way 1 target pc
	logic [`BTB_SIZE-1:0] [63:0] BTB_pc_2;
	logic [`BTB_SIZE-1:0] [63:0] BTB_nextpc_2;                //way 2 target pc
	logic [`BTB_SIZE-1:0] [61-$clog2(`BTB_SIZE):0] BTB_idx1;                        //idx means tags for way1 and way2
	logic [`BTB_SIZE-1:0] [61-$clog2(`BTB_SIZE):0] BTB_nextidx1;
	logic [`BTB_SIZE-1:0] [61-$clog2(`BTB_SIZE):0] BTB_idx2;
	logic [`BTB_SIZE-1:0] [61-$clog2(`BTB_SIZE):0] BTB_nextidx2;
	logic [`BTB_SIZE-1:0] valid_1;
	logic [`BTB_SIZE-1:0] next_valid_1;
	logic [`BTB_SIZE-1:0] valid_2;
	logic [`BTB_SIZE-1:0] next_valid_2;
	logic [`BTB_SIZE-1:0] switch;        //0 means pointing to way1,1 means pointing to way2
	logic [`BTB_SIZE-1:0] next_switch;
	//logic [`BTB_SIZE-1:0] next_switch_hit;
	
	always_comb begin
		for(int i=0; i<`BTB_SIZE; i++) begin
			BTB_nextpc_1[i]=BTB_pc_1[i];
			BTB_nextidx1[i]=BTB_idx1[i];
			next_valid_1[i]=valid_1[i];
			BTB_nextpc_2[i]=BTB_pc_2[i];
			BTB_nextidx2[i]=BTB_idx2[i];
			next_valid_2[i]=valid_2[i];
			//target_inst1_pc=0;
			//target_inst1_valid=1'b0;
			//target_inst2_pc=0;
			//target_inst2_valid=1'b0;
			next_switch[i] =switch;
			if(i==pc_idx1[$clog2(`BTB_SIZE)+1:2] && target_pc1_valid) begin       //index match
				if(~valid_1[i] && ~valid_2[i]) begin                                       //if has vacancy
					BTB_nextpc_1[i]=target_pc1;
					BTB_nextidx1[i]=pc_idx1[63:$clog2(`BTB_SIZE)+2];
					next_valid_1[i]=1'b1;
					next_switch[i] =1'b1;
				end
				else if(~valid_1[i]) begin
					BTB_nextpc_1[i]=target_pc1;
					BTB_nextidx1[i]=pc_idx1[63:$clog2(`BTB_SIZE)+2];
					next_valid_1[i]=1'b1;
					next_switch[i] =1'b1;
				end
				else if(~valid_2[i]) begin
					BTB_nextpc_2[i]=target_pc1;
					BTB_nextidx2[i]=pc_idx1[63:$clog2(`BTB_SIZE)+2];
					next_valid_2[i]=1'b1;
					next_switch[i] =1'b0;
				end
				else begin
					if(switch[i]) begin
						BTB_nextpc_2[i]=target_pc1;
						BTB_nextidx2[i]=pc_idx1[63:$clog2(`BTB_SIZE)+2];
						next_valid_2[i]=1'b1;
						next_switch[i] =1'b0;
					end
					else begin
						BTB_nextpc_1[i]=target_pc1;
						BTB_nextidx1[i]=pc_idx1[63:$clog2(`BTB_SIZE)+2];
						next_valid_1[i]=1'b1;
						next_switch[i] =1'b1;
					end
				end
			end
			
			if(i==pc_idx2[$clog2(`BTB_SIZE)+1:2] && target_pc2_valid) begin
				if(~valid_1[i] && ~valid_2[i]) begin
					BTB_nextpc_1[i]=target_pc2;
					BTB_nextidx1[i]=pc_idx2[63:$clog2(`BTB_SIZE)+2];
					next_valid_1[i]=1'b1;
					next_switch[i] =1'b1;
				end
				else if(~valid_1[i]) begin
					BTB_nextpc_1[i]=target_pc2;
					BTB_nextidx1[i]=pc_idx2[63:$clog2(`BTB_SIZE)+2];
					next_valid_1[i]=1'b1;
					next_switch[i] =1'b1;
				end
				else if(~valid_2[i]) begin
					BTB_nextpc_2[i]=target_pc2;
					BTB_nextidx2[i]=pc_idx2[63:$clog2(`BTB_SIZE)+2];
					next_valid_2[i]=1'b1;
					next_switch[i] =1'b0;
				end
				else begin
					if(switch[i]) begin
						BTB_nextpc_2[i]=target_pc2;
						BTB_nextidx2[i]=pc_idx2[63:$clog2(`BTB_SIZE)+2];
						next_valid_2[i]=1'b1;
						next_switch[i] =1'b0;
					end
					else begin
						BTB_nextpc_1[i]=target_pc2;
						BTB_nextidx1[i]=pc_idx2[63:$clog2(`BTB_SIZE)+2];
						next_valid_1[i]=1'b1;
						next_switch[i] =1'b1;
					end
				end
			end

			if(inst1_valid && i==if_inst1_pc[$clog2(`BTB_SIZE)+1:2]) begin
				if(valid_1[i] && BTB_idx1[i]==if_inst1_pc[63:$clog2(`BTB_SIZE)+2]) begin
					//target_inst1_pc=BTB_pc_1[i];
					//target_inst1_valid=1'b1;
					//next_switch_hit[i]=1'b1;
					next_switch[i]=1'b1;
				end
				else if(valid_2[i] && BTB_idx2[i]==if_inst1_pc[63:$clog2(`BTB_SIZE)+2]) begin
					//target_inst1_pc=BTB_pc_2[i];
					//target_inst1_valid=1'b1;
					//next_switch_hit[i]=1'b0;
					next_switch[i]=1'b0;
				end
			end
			
			if(inst2_valid && i==if_inst2_pc[$clog2(`BTB_SIZE)+1:2]) begin
				if(valid_1[i] && BTB_idx1[i]==if_inst2_pc[63:$clog2(`BTB_SIZE)+2]) begin
					//target_inst2_pc=BTB_pc_1[i];
					//target_inst2_valid=1'b1;
					//next_switch_hit[i]=1'b1;
					next_switch[i]=1'b1;
				end
				else if(valid_2[i] && BTB_idx2[i]==if_inst2_pc[63:$clog2(`BTB_SIZE)+2]) begin
					//target_inst2_pc=BTB_pc_2[i];
					//target_inst2_valid=1'b1;
					//next_switch_hit[i]=1'b0;
					next_switch[i]=1'b0;
				end
			end
		end
	end
	
	/*always_comb begin
		for(int i=0; i<`BTB_SIZE; i++) begin
			target_inst1_pc=0;
			target_inst1_valid=1'b0;
			target_inst2_pc=0;
			target_inst2_valid=1'b0;
			//next_switch_hit[i]=switch[i];
			if(inst1_valid && i==if_inst1_pc[$clog2(`BTB_SIZE)+1:2]) begin
				if(valid_1[i] && if_inst1_pc[63:$clog2(`BTB_SIZE)+2] == BTB_idx1[i]) begin
					target_inst1_pc=BTB_pc_1[i];
					target_inst1_valid=1'b1;
					//next_switch_hit[i]=1'b1;
				end
				else if(valid_2[i] && if_inst1_pc[63:$clog2(`BTB_SIZE)+2] == BTB_idx2[i]) begin
					target_inst1_pc=BTB_pc_2[i];
					target_inst1_valid=1'b1;
					//next_switch_hit[i]=1'b0;
				end
				else begin
					target_inst1_pc=0;
					target_inst1_valid=1'b0;
					next_switch[i]=switch[i];
				end
			end
			
			if(inst2_valid && i==if_inst2_pc[$clog2(`BTB_SIZE)+1:2]) begin
				if(valid_1[i] && if_inst2_pc[63:$clog2(`BTB_SIZE)+2] == BTB_idx1[i]) begin
					target_inst2_pc=BTB_pc_1[i];
					target_inst2_valid=1'b1;
					//next_switch_hit[i]=1'b1;
				end
				else if(valid_2[i] && if_inst2_pc[63:$clog2(`BTB_SIZE)+2] == BTB_idx2[i]) begin
					target_inst2_pc=BTB_pc_2[i];
					target_inst2_valid=1'b1;
					//next_switch_hit[i]=1'b0;
				end
				else begin
					target_inst2_pc=0;
					target_inst2_valid=1'b0;
					next_switch[i]=switch[i];
				end
			end
		end
	end*/

	//assign target_inst1_pc = inst1_valid ? BTB_idx1[if_inst1_pc[$clog2(`BTB_SIZE)+1:2]]==if_inst1_pc[63:$clog2(`BTB_SIZE)+2] &&
	
		always_comb begin
				if(inst1_valid) begin
					if(valid_1[if_inst1_pc[$clog2(`BTB_SIZE)+1:2]] && if_inst1_pc[63:$clog2(`BTB_SIZE)+2] == BTB_idx1[if_inst1_pc[$clog2(`BTB_SIZE)+1:2]]) begin
						target_inst1_pc=BTB_pc_1[if_inst1_pc[$clog2(`BTB_SIZE)+1:2]];
						target_inst1_valid=1'b1;
						//next_switch_hit[i]=1'b1;
					end
					else if(valid_2[if_inst1_pc[$clog2(`BTB_SIZE)+1:2]] && if_inst1_pc[63:$clog2(`BTB_SIZE)+2] == BTB_idx2[if_inst1_pc[$clog2(`BTB_SIZE)+1:2]]) begin
						target_inst1_pc=BTB_pc_2[if_inst1_pc[$clog2(`BTB_SIZE)+1:2]];
						target_inst1_valid=1'b1;
						//next_switch_hit[i]=1'b0;
					end
					else begin
						target_inst1_pc=0;
						target_inst1_valid=1'b0;
						//next_switch[i]=switch[i];
					end
				end
			
				if(inst2_valid) begin
					if(valid_1[if_inst2_pc[$clog2(`BTB_SIZE)+1:2]] && if_inst2_pc[63:$clog2(`BTB_SIZE)+2] == BTB_idx1[if_inst2_pc[$clog2(`BTB_SIZE)+1:2]]) begin
						target_inst2_pc=BTB_pc_1[if_inst2_pc[$clog2(`BTB_SIZE)+1:2]];
						target_inst2_valid=1'b1;
						//next_switch_hit[i]=1'b1;
					end
					else if(valid_2[if_inst2_pc[$clog2(`BTB_SIZE)+1:2]] && if_inst2_pc[63:$clog2(`BTB_SIZE)+2] == BTB_idx2[if_inst2_pc[$clog2(`BTB_SIZE)+1:2]]) begin
						target_inst2_pc=BTB_pc_2[if_inst2_pc[$clog2(`BTB_SIZE)+1:2]];
						target_inst2_valid=1'b1;
						//next_switch_hit[i]=1'b0;
					end
					else begin
						target_inst2_pc=0;
						target_inst2_valid=1'b0;
						//next_switch[i]=switch[i];
					end
				end
		end
	
	always_ff @(posedge clock) begin
		if(reset) begin
			BTB_pc_1 <= `SD 0;
			BTB_pc_2 <= `SD 0;
			BTB_idx1 <= `SD 0;
			BTB_idx2 <= `SD 0;
			valid_1  <= `SD 0;
			valid_2  <= `SD 0;
			switch   <= `SD 0;
		end
		
		else begin
			BTB_pc_1 <= `SD BTB_nextpc_1;
			BTB_pc_2 <= `SD BTB_nextpc_2;
			BTB_idx1 <= `SD BTB_nextidx1;
			BTB_idx2 <= `SD BTB_nextidx2;
			valid_1  <= `SD next_valid_1;
			valid_2  <= `SD next_valid_2;
			//if((inst1_valid || inst2_valid) && (target_inst1_valid || target_inst2_valid))
			switch   <= `SD next_switch;
		end
	end

endmodule

				//if( pc_idx1[63-$clog2(`BTB_SIZE):0] != BTB_idx1[i] && pc_idx1[63-$clog2(`BTB_SIZE):0] != BTB_idx2[i])
					/*if(valid_1[i] && valid_2[i])
						BTB_nextidx1[i] =pc_idx1[63-$clog2(`BTB_SIZE):0];
						BTB_nextpc_1[i] =target_pc1;
						next_valid_1[i] =1;
					else if(valid_2[i])
						BTB_nextidx2 =pc_idx1[63-$clog2(`BTB_SIZE):0];
						BTB_nextpc_2 =target_pc1;
					else*/
		
		
