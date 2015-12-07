module icache_controller(
	// input from Mem.v										
	input	[3:0]							Imem2proc_response,
	input	[3:0]							Imem2proc_tag,
	
	// input from processor.v
	input	[63:0]							proc2Icache_addr,	
	input  BUS_COMMAND						proc2Icache_command,
	
	// input from Icache.v
	input  [`ICACHE_BLOCK_SIZE-1:0]			cachemem_data,
	input 									cachemem_valid,
	input									cachemem_is_full,
	input									cachemem_is_miss,
	
	// output to mem.v
	output	BUS_COMMAND						proc2Imem_command,
	output	logic	[63:0]					proc2Imem_addr,
	
	// output to processor.v
	output	logic	[63:0]					Icache_data_out,
	output	logic							Icache_data_valid,
	output logic [3:0]						Icache2proc_tag,	 	
	output logic [3:0]						Icache2proc_response,
	
	// output to Icache.v
	output logic [`ICACHE_INDEX_SIZE-1:0]   index,
	output logic [`ICACHE_TAG_SIZE-1:0]		tag,  
	output logic							read_enable,    
	output logic [3:0]						mem_response,
	output logic [3:0]						mem_tag
);
assign 					read_enable 		    	 = (proc2Icache_command==BUS_LOAD);
	// output to Icache.v
	assign {tag, index} 			= proc2Icache_addr[63:`ICACHE_BLOCK_OFFSET];
	always_comb
	begin
				begin
					// to icache.v
  
					if (cachemem_is_miss && cachemem_is_full) 
					begin
						// to mem.v
						proc2Imem_command 		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						// to icache.v
						// for present inst
						mem_response	  		 = 0;
						// for previous inst
						mem_tag			  	 	 = Imem2proc_tag;
						// to proc.v
						// for current instruction
						Icache2proc_response	 = 0;
						Icache_data_valid		 = 0;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						//Icache2proc_tag  		 = Imem2proc_tag;
						Icache2proc_tag  		 = 0;
					end
					else if (cachemem_is_miss)
					begin
						// to mem.v
						proc2Imem_command 		 = BUS_LOAD;
						proc2Imem_addr 	 		 = {proc2Icache_addr[63:3],3'b0};
						// to icache.v
						// for present inst
						mem_response	  		 = Imem2proc_response;
						// for previous inst
						mem_tag			  	 	 = Imem2proc_tag;
						// to proc.v
						// for current instruction
						Icache2proc_response	 = Imem2proc_response;
						Icache_data_valid		 = 0;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						//Icache2proc_tag  		 = Imem2proc_tag;
						Icache2proc_tag  		 = 0;
					end
					else if //((cachemem_is_miss==0) && (Imem2proc_tag!=0))
					(cachemem_is_miss==0 && (proc2Icache_command==BUS_LOAD))
					begin
						// to mem.v
						proc2Imem_command		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						// to icache.v
						mem_response			 = Imem2proc_response;
						mem_tag			  		 = Imem2proc_tag;
						// to proc.v
						// for current instruction
						Icache2proc_response 	 = Imem2proc_response;
						Icache_data_valid		 = 1;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						Icache2proc_tag  		 = Imem2proc_tag;
					end
					else
					begin
						// to mem.v
						proc2Imem_command		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						// to icache.v
						mem_response			 = Imem2proc_response;
						mem_tag			  		 = Imem2proc_tag;
						// to proc.v
						// for current instruction
						Icache2proc_response	 = Imem2proc_response;
						Icache_data_valid		 = 0;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						Icache2proc_tag  		 = Imem2proc_tag;
					end
				end
			

	end	
		
/*	always_comb
	begin
		case(proc2Icache_command)
			BUS_LOAD:
				begin
					// to icache.v
					read_enable 		    	 = 1'b1;  
					if (cachemem_is_miss && cachemem_is_full) 
					begin
						// to mem.v
						proc2Imem_command 		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						// to icache.v
						// for present inst
						mem_response	  		 = 0;
						// for previous inst
						mem_tag			  	 	 = Imem2proc_tag;
						// to proc.v
						// for current instruction
						Icache2proc_response	 = 0;
						Icache_data_valid		 = 0;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						//Icache2proc_tag  		 = Imem2proc_tag;
						Icache2proc_tag  		 = 0;
					end
					else if (cachemem_is_miss)
					begin
						// to mem.v
						proc2Imem_command 		 = BUS_LOAD;
						proc2Imem_addr 	 		 = {proc2Icache_addr[63:3],3'b0};
						// to icache.v
						// for present inst
						mem_response	  		 = Imem2proc_response;
						// for previous inst
						mem_tag			  	 	 = Imem2proc_tag;
						// to proc.v
						// for current instruction
						Icache2proc_response	 = Imem2proc_response;
						Icache_data_valid		 = 0;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						//Icache2proc_tag  		 = Imem2proc_tag;
						Icache2proc_tag  		 = 0;
					end
					else if //((cachemem_is_miss==0) && (Imem2proc_tag!=0))
					(cachemem_is_miss==0)
					begin
						// to mem.v
						proc2Imem_command		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						// to icache.v
						mem_response			 = Imem2proc_response;
						mem_tag			  		 = Imem2proc_tag;
						// to proc.v
						// for current instruction
						Icache2proc_response 	 = Imem2proc_response;
						Icache_data_valid		 = 1;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						Icache2proc_tag  		 = Imem2proc_tag;
					end
					else
					begin
						// to mem.v
						proc2Imem_command		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						// to icache.v
						mem_response			 = Imem2proc_response;
						mem_tag			  		 = Imem2proc_tag;
						// to proc.v
						// for current instruction
						Icache2proc_response	 = Imem2proc_response;
						Icache_data_valid		 = 1;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						Icache2proc_tag  		 = Imem2proc_tag;
					end
				end
			
			BUS_NONE:
				begin
						// to mem.v
						proc2Imem_command		 = BUS_NONE;
						proc2Imem_addr 	 		 = 0;
						// to icache.v
						mem_response			 = Imem2proc_response;
						mem_tag			  		 = Imem2proc_tag;
						read_enable 		     = 1'b0;   
						// to proc.v
						// for current instruction
						Icache2proc_response 	 = Imem2proc_response;
						Icache_data_valid		 = 0;
						// for previous instruction
						Icache_data_out  		 = cachemem_data;
						Icache2proc_tag  		 = Imem2proc_tag;
				end
				
			default:
				begin
					// to mem.v
					proc2Imem_command		 = BUS_NONE;
					proc2Imem_addr 	 		 = 0;
					// to icache.v
					mem_response			 = Imem2proc_response;
					mem_tag			  		 = Imem2proc_tag;
					read_enable 		     = 1'b0; 
					// to proc.v
					// for current instruction
					if (cachemem_is_full)
						Icache2proc_response = 0;
					else
						Icache2proc_response = Imem2proc_response;
					Icache_data_valid		 = 0;
					// for previous instruction
					Icache_data_out  		 = cachemem_data;
					Icache2proc_tag  		 = Imem2proc_tag;
				end
		endcase
	end	*/
endmodule
