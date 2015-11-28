module dcache_controller(
	input 							clock,
	input 							reset,
	
	// input from Mem.v
	input  [3:0] 					Dmem2proc_response,
	input  [63:0] 					Dmem2proc_data,
	input  [3:0] 					Dmem2proc_tag,
	
	// input from Dcache.v
	input  [63:0]					cachemem_data,
	input 							cachemem_valid,
	input							cache_is_dirty,
	
	// input from processor.v
	input  [63:0]					proc2Dcache_addr,
	input  BUS_COMMAND				proc2Dcache_command,
	input  [63:0] 					proc2Dcache_data,	
	
	// output to mem.v
	output BUS_COMMAND				proc2Dmem_command,
	output logic [63:0]				proc2Dmem_addr,
	
	// output to processor.v
	output logic [63:0]				Dcache_data_out,	 
	output logic [3:0]				Dcache2proc_tag,	 	// to tell processor the tag of the previous load which is finished
	output logic [3:0]				Dcache2proc_response,	// to tell processor the tag of present load
	output logic					unanswered_miss,		// if unanswered_miss=1 processor will receive a response number

	// output to Dcache.v
	output logic [`INDEX_SIZE-1:0]	current_index,
	output logic [`TAG_SIZE-1:0]	current_tag,  
	output logic [`INDEX_SIZE-1:0]	last_index,   
	output logic [`TAG_SIZE-1:0]	last_tag,
	output logic					read_enable,
	output logic					write_enable,     

	output logic [63:0]				data_to_Dcache,	  		// data that send to dcache.v
	output logic					data_write_enable,		// signal that tells dcache to load data from mem
	output logic					data_write_back_enable	// signal that tells dcache to write back dirty data to mem
);
	
	logic  [3:0]					current_mem_tag;
	logic							miss_outstanding;					
	logic							changed_addr;
	logic							update_mem_tag;
	
	logic  [3:0]					next_Dcache2proc_tag;
	logic  [3:0]					next_Dcache2proc_response;
	logic  [63:0]					Dcache_data_out;	
	
	logic  DCACHE_STATE				current_state;
	logic  DCACHE_STATE				next_state;
	
	// output to processor
	assign Dcache_data_out 				= cachemem_data;
	assign unanswered_miss   			= changed_addr? !cachemem_valid : miss_outstanding & (Dmem2proc_response==0);
	assign Dcache2proc_response			= Dmem2proc_response;
	assign Dcache2proc_tag				= Dmem2proc_tag;
	
	// output to dcache.v
	assign {current_tag, current_index} = proc2Dcache_addr[63:`BLOCK_OFFSET];
	assign data_to_Dcache 	 			= proc2Dcache_data;
	assign data_write_enable 			= data_write_enable_reg;
	assign data_write_back_enable 		= data_write_back_enable_reg;
	
	// output to mem.v
	assign proc2Dmem_addr 	 			= {proc2Dcache_addr[63:0],3'b0};
	
	// internal signal
	assign changed_addr 	 			= (current_index!=last_index) || (current_tag!=last_tag);
	assign update_mem_tag    			= changed_addr | miss_outstanding | data_write_enable;
	
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			last_index			   		<= `SD -1;
			last_tag			   		<= `SD -1;
			current_mem_tag		   		<= `SD 0;
			miss_outstanding	   		<= `SD 0;
			current_state		   		<= `SD DOING_NOTHING;
			data_write_enable_next      <= `SD 0;
			data_write_back_enable_next <= `SD 0;
		end
		else
		begin
			last_index			  		<= `SD current_index;
			last_tag			   		<= `SD current_tag;
			miss_outstanding	   		<= `SD unanswered_miss;
			if(update_mem_tag)
			begin
				current_mem_tag    		<= `SD Dmem2proc_response;
			end
			current_state		   		<= `SD next_state;
			data_write_enable_next      <= `SD data_write_enable_reg;
			data_write_back_enable_next <= `SD data_write_back_enable_reg;
		end
	end
	
	always_comb
	begin
		case(current_state)
			DOING_NOTHING:
				begin
					proc2Dmem_command 			= BUS_NONE;
					data_write_enable_reg 		= 0;
					data_write_back_enable_reg  = 0;
					next_state 					= DOING_NOTHING;
					
					if ((proc2Dcache_command==BUS_LOAD) && unanswered_miss && (cache_is_dirty==0)) ||
							((proc2Dcache_command==BUS_STORE) && unanswered_miss && (cache_is_dirty==0)) 
					begin
						next_state = CACHE_READ_FROM_MEMORY;
					end
					else if	((proc2Dcache_command==BUS_LOAD) && unanswered_miss && cache_is_dirty) ||
							((proc2Dcache_command==BUS_STORE) && unanswered_miss && cache_is_dirty) 
					begin
						next_state = CACHE_WRITE_TO_MEMORY;
					end
				end
			CACHE_READ_FROM_MEMORY:
				begin
					proc2Dmem_command 			= BUS_LOAD;
					data_write_enable_reg 		= (current_mem_tag==Dmem2proc_tag) && (current_mem_tag!=0);
					data_write_back_enable_reg  = 0;
					next_state 					= CACHE_READ_FROM_MEMORY;
					
					if (data_write_enable_next)
					begin
						if ((proc2Dcache_command==BUS_NONE) ||
					   	   ((proc2Dcache_command==BUS_LOAD) && (unanswered_miss==0)) ||
					   	   ((proc2Dcache_command==BUS_STORE) && (unanswered_miss==0)))
						begin
							next_state = DOING_NOTHING;
						end
						else if ((proc2Dcache_command==BUS_LOAD) && unanswered_miss && cache_is_dirty) ||
						     	((proc2Dcache_command==BUS_STORE) && unanswered_miss && cache_is_dirty)) 
					    begin
							next_state = CACHE_WRITE_FROM_MEMORY;
					    end
					end
			CACHE_WRITE_TO_MEMORY:
				begin
					proc2Dmem_command 			= BUS_STORE;
					data_write_enable_reg 		= 0;
					data_write_back_enable_reg  = (current_mem_tag!=0);
					next_state 					= CACHE_WRITE_TO_MEMORY;
					
					if (data_write_back_enable_next)
					begin
						next_state = CACHE_READ_FROM_MEMORY;
					end
				end 
		endcase
	end	
endmodule
