/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  testbench.v                                         //
//                                                                     //
//  Description :  Testbench module for the verisimple pipeline;       //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

extern void print_header(string str);
extern void print_cycles();
extern void print_stage(string div, int inst, int npc, int valid_inst);
extern void print_stage_fu(string div, int inst_pc,int optype, int valid);
extern void print_reg(int wb_reg_wr_data_out_hi, int wb_reg_wr_data_out_lo,
                      int wb_reg_wr_idx_out, int wb_reg_wr_en_out);
extern void print_membus(int proc2mem_command, int mem2proc_response,
                         int proc2mem_addr_hi, int proc2mem_addr_lo,
                         int proc2mem_data_hi, int proc2mem_data_lo);
extern void print_close();

`include "sys_defs.vh"

module testbench;

	//variables used in the testbench
    	logic         clock;                    // System clock
    	logic         reset;                    // System reset
		logic [31:0]  clock_count;
		logic [31:0]  instr_count;
    	int           wb_fileno;
	
    	logic [3:0]   mem2proc_response;        // Tag from memory about current request
    	logic [63:0]  mem2proc_data;            // Data coming back from memory
    	logic [3:0]   mem2proc_tag;             // Tag from memory about current reply

    	BUS_COMMAND   proc2mem_command;    		// command sent to memory
    	logic [63:0]  proc2mem_addr;      		// Address sent to memory
  	 	logic [63:0]  proc2mem_data;      		// Data sent to memory

    	logic [3:0]   pipeline_completed_insts;
    	logic [3:0]   pipeline_error_status;

    	// testing hooks (these must be exported so we can test
    	// the synthesized version) data is tested by looking at
    	// the final values in memory

 		//output
    	// Outputs from IF-Stage 
    	//Output from rob
    	logic							ROB_commit1_valid;
    	logic [63:0]					PRF_writeback_value1;
    	logic [$clog2(`ARF_SIZE)-1:0]	ROB_commit1_arn_dest;
    	logic							ROB_commit1_wr_en;
    	logic							ROB_commit2_valid;
    	logic [63:0]					PRF_writeback_value2;
   		logic [$clog2(`ARF_SIZE)-1:0]	ROB_commit2_arn_dest;
    	logic							ROB_commit2_wr_en;

    	//output from IF-stage
		logic [63:0]					PC_proc2Imem_addr;
		logic [63:0]					current_pc;
		logic [31:0]					PC_inst1;
		logic [31:0]					PC_inst2;
		logic							PC_inst1_valid;
		logic							PC_inst2_valid;
    
    	// Outputs from RS
		logic [5:0][63:0]				fu_next_inst_pc_out;
		logic [5:0][5:0]				RS_EX_op_type;
		ALU_FUNC [5:0]					RS_EX_alu_func;
	
		// Outputs from EX-stage
		logic [5:0][63:0]				fu_inst_pc_out;	
		ALU_FUNC [5:0]					EX_alu_func_out;
    	logic [5:0][5:0]				EX_rs_op_type_out;
		logic [5:0]						EX_RS_fu_is_available;
		logic [5:0]						EX_CDB_fu_result_is_valid;
	
		// Outputs from ROB
		logic [63:0]					ROB_commit1_pc;
		logic [63:0]					ROB_commit2_pc;
		logic [31:0]					ROB_commit1_inst_out;
		logic [31:0]					ROB_commit2_inst_out;
		
		logic							ROB_commit1_is_halt;
		logic							ROB_commit2_is_halt;
		logic [1:0]						count;

	processor processor_0(
			//input
    		.clock(clock),                    					// System clock
    		.reset(reset),                    					// System reset
    		.mem2proc_response(mem2proc_response),        		// Tag from memory about current request
    		.mem2proc_data(mem2proc_data),            			// Data coming back from memory
    		.mem2proc_tag(mem2proc_tag),              			// Tag from memory about current reply
		.is_two_threads(0),														//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5 one thread

			//output
    		.proc2mem_command(proc2mem_command),    			// command sent to memory
    		.proc2mem_addr(proc2mem_addr),      				// Address sent to memory
    		.proc2mem_data(proc2mem_data),      				// Data sent to memory

    		.pipeline_completed_insts(pipeline_completed_insts),
    
    		.pipeline_error_status(pipeline_error_status),
    		//.pipeline_commit_wr_idx(pipeline_commit_wr_idx),
    		//.pipeline_commit_wr_data(pipeline_commit_wr_data),
    		//.pipeline_commit_wr_en(pipeline_commit_wr_en),
    		//.pipeline_commit_NPC(pipeline_commit_NPC),


    		// testing hooks (these must be exported so we can test
    		// the synthesized version) data is tested by looking at
    		// the final values in memory

    		//output
    		//Output from rob
    		.ROB_commit1_valid(ROB_commit1_valid),
    		.ROB_commit1_arn_dest(ROB_commit1_arn_dest),
    		.ROB_commit1_wr_en(ROB_commit1_wr_en),
    		.PRF_writeback_value1(PRF_writeback_value1),
    		.ROB_commit2_valid(ROB_commit2_valid),
    		.ROB_commit2_arn_dest(ROB_commit2_arn_dest),
    		.ROB_commit2_wr_en(ROB_commit2_wr_en),
    		.PRF_writeback_value2(PRF_writeback_value2),
    		
    		.PC_proc2Imem_addr(PC_proc2Imem_addr),
			.current_pc(current_pc),
			.PC_inst1(PC_inst1),
			.PC_inst2(PC_inst2),
			.PC_inst1_valid(PC_inst1_valid),
			.PC_inst2_valid(PC_inst2_valid),
    
    		// Outputs from RS
			.fu_next_inst_pc_out(fu_next_inst_pc_out),
			.RS_EX_op_type(RS_EX_op_type),
			.RS_EX_alu_func(RS_EX_alu_func),
	
			// Outputs from EX-stage
			.fu_inst_pc_out(fu_inst_pc_out),	
			.EX_alu_func_out(EX_alu_func_out),
    		.EX_rs_op_type_out(EX_rs_op_type_out),
    		.EX_RS_fu_is_available(EX_RS_fu_is_available),
    		.EX_CDB_fu_result_is_valid(EX_CDB_fu_result_is_valid),
	
			// Outputs from ROB
			.ROB_commit1_pc(ROB_commit1_pc),
			.ROB_commit2_pc(ROB_commit2_pc),
			.ROB_commit1_inst_out(ROB_commit1_inst_out),
			.ROB_commit2_inst_out(ROB_commit2_inst_out),
			
			.ROB_commit1_is_halt(ROB_commit1_is_halt),
			.ROB_commit2_is_halt(ROB_commit2_is_halt)
	);

	// Instantiate the Data Memory
	mem memory(
			// Inputs
			.clock               (clock),
			.proc2mem_command  (proc2mem_command),
			.proc2mem_addr     (proc2mem_addr),
			.proc2mem_data     (proc2mem_data),

			 // Outputs
			.mem2proc_response (mem2proc_response),
			.mem2proc_data     (mem2proc_data),
			.mem2proc_tag      (mem2proc_tag)
		   );

	// Generate System Clock
	always
	begin
		#(`VERILOG_CLOCK_PERIOD/2.0);
		clock = ~clock;
	end

	// Task to display # of elapsed clock edges
	task show_clk_count;
		real cpi;

		begin
			cpi = (clock_count + 1.0) / instr_count;
			$display("@@  %0d cycles / %0d instrs = %f CPI\n@@",
			clock_count+1, instr_count, cpi);
			$display("@@  %4.2f ns total time to execute\n@@\n",
			clock_count*`VIRTUAL_CLOCK_PERIOD);
		end
		
	endtask  // task show_clk_count 

  // Show contents of a range of Unified Memory, in both hex and decimal
	task show_mem_with_decimal;
		input [31:0] start_addr;
		input [31:0] end_addr;
		int showing_data;
		begin
			$display("@@@");
			showing_data=0;
			for(int k=start_addr;k<=end_addr; k=k+1)
				if (memory.unified_memory[k] != 0)
				begin
					$display("@@@ mem[%5d] = %x : %0d", k*8,	memory.unified_memory[k], 
																memory.unified_memory[k]);
					showing_data=1;
				end
				else if(showing_data!=0)
				begin
					$display("@@@");
					showing_data=0;
				end
			$display("@@@");
		end
	endtask  // task show_mem_with_decimal

  	initial begin
  		`ifdef DUMP
			  $vcdplusdeltacycleon;
			  $vcdpluson();
			  $vcdplusmemon(memory.unified_memory);
		`endif
    		clock = 1'b0;
    		reset = 1'b0;
			count = 0;
		//#10
   		// Pulse the reset signal
			
		$display("@@\n@@\n@@  %t  Asserting System reset......", $realtime);
   		reset = 1'b1;
    		@(posedge clock);
    		@(posedge clock);
		
		$readmemh("program.mem", memory.unified_memory);
	
		@(posedge clock);
    	@(posedge clock);
    	`SD;
    	// This reset is at an odd time to avoid the pos & neg clock edges
	
    	reset = 1'b0;
		$display("@@  %t  Deasserting System reset......\n@@\n@@", $realtime);
   
    	wb_fileno = $fopen("writeback.out");

		
    		//Open header AFTER throwing the reset otherwise the reset state is displayed
    		print_header("                                                                            																													D-MEM Bus &\n");
    		print_header("Cycle: PC inst1 | PC inst2 |    RS1   |    RS2    |   RS3   |    RS4   |   RS5   |    RS6    |    EX1    |   EX2   |   EX3   |    EX4    |    EX5    |   EX6   |   RoB1   |   RoB2   | ");
    		
    		/*while (count < 1 && clock_count < 3000) begin
				count = count + (ROB_commit1_is_halt + ROB_commit2_is_halt);
    			#1;
    		end*/
		#100000;
		$display("@@@\n@@");
		show_clk_count;
		//print_close(); // close the pipe_print output file
    		$fclose(wb_fileno);
			$finish;
  		end


  		// Count the number of posedges and number of instructions completed
  		// till simulation ends
	
		// Count the number of posedges and number of instructions completed
		// till simulation ends
	always @(posedge clock or posedge reset)
	begin
		if(reset)
			begin
			clock_count <= `SD 0;
			instr_count <= `SD 0;
			end
		else if(ROB_commit1_valid && ROB_commit2_valid)
			begin
			clock_count <= `SD (clock_count + 1);
			instr_count <= `SD (instr_count + 2*pipeline_completed_insts);
			end
		else
			begin
			clock_count <= `SD (clock_count + 1);
			instr_count <= `SD (instr_count + pipeline_completed_insts);
			end
	end  

  	always @(negedge clock) begin
		if(reset)
			$display(	"@@\n@@  %t : System STILL at reset, can't show anything\n@@",
						$realtime);
		else
		begin
		  `SD;
		  `SD;

       // print the piepline stuff via c code to the pipeline.out
       print_cycles();
       //IF
       print_stage(" ", PC_inst1, current_pc[31:0], {31'b0,PC_inst1_valid});
       print_stage(" ", PC_inst2, current_pc[31:0]+4, {31'b0,PC_inst2_valid});
       
       //RS
       print_stage_fu(" ", fu_next_inst_pc_out[0][63:0],RS_EX_op_type[0],1);
       print_stage_fu(" ", fu_next_inst_pc_out[1][63:0],RS_EX_op_type[1],1);
       print_stage_fu(" ", fu_next_inst_pc_out[2][63:0],RS_EX_op_type[2],1);
       print_stage_fu(" ", fu_next_inst_pc_out[3][63:0],RS_EX_op_type[3],1);
       print_stage_fu(" ", fu_next_inst_pc_out[4][63:0],RS_EX_op_type[4],1);
       print_stage_fu(" ", fu_next_inst_pc_out[5][63:0],RS_EX_op_type[5],1);
       //EX
       print_stage_fu(" ", fu_inst_pc_out[0][63:0],EX_rs_op_type_out[0],~EX_RS_fu_is_available[0] || EX_CDB_fu_result_is_valid[0]);
       print_stage_fu(" ", fu_inst_pc_out[1][63:0],EX_rs_op_type_out[1],~EX_RS_fu_is_available[1] || EX_CDB_fu_result_is_valid[1]);
       print_stage_fu(" ", fu_inst_pc_out[2][63:0],EX_rs_op_type_out[2],~EX_RS_fu_is_available[2] || EX_CDB_fu_result_is_valid[2]);
       print_stage_fu(" ", fu_inst_pc_out[3][63:0],EX_rs_op_type_out[3],~EX_RS_fu_is_available[3] || EX_CDB_fu_result_is_valid[3]);
       print_stage_fu(" ", fu_inst_pc_out[4][63:0],EX_rs_op_type_out[4],~EX_RS_fu_is_available[4] || EX_CDB_fu_result_is_valid[4]);
       print_stage_fu(" ", fu_inst_pc_out[5][63:0],EX_rs_op_type_out[5],~EX_RS_fu_is_available[5] || EX_CDB_fu_result_is_valid[5]);
       
       //ROB
       print_stage(" ", ROB_commit1_inst_out, ROB_commit1_pc, ROB_commit1_valid);
       print_stage(" ", ROB_commit2_inst_out, ROB_commit2_pc, ROB_commit2_valid);

	   // for writeback
       print_reg(PRF_writeback_value1[63:32], PRF_writeback_value1[31:0],{27'b0,ROB_commit1_arn_dest}, {31'b0,ROB_commit1_wr_en});
       print_reg(PRF_writeback_value2[63:32], PRF_writeback_value2[31:0],{27'b0,ROB_commit2_arn_dest}, {31'b0,ROB_commit2_wr_en});
       print_membus({30'b0,proc2mem_command}, {28'b0,mem2proc_response},proc2mem_addr[63:32], proc2mem_addr[31:0],proc2mem_data[63:32], proc2mem_data[31:0]);
                    
                    
    	// print the writeback information to writeback.out
		// for writeback.out we need pipeline_completed_insts pipeline_commit_wr_en
		// pipeline_commit_NPC  pipeline_commit_wr_idx pipeline_commit_wr_data
       			if(pipeline_completed_insts>0) begin
         			if(ROB_commit1_valid&&ROB_commit1_wr_en)
           				$fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                     				ROB_commit1_pc,
                     				ROB_commit1_arn_dest,
                     				PRF_writeback_value1);
        			else begin
					if(ROB_commit1_valid)
          				$fdisplay(wb_fileno, "PC=%x, ---",ROB_commit1_pc);

				end
				if(ROB_commit2_valid&&ROB_commit2_wr_en)
           				$fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                     				ROB_commit2_pc,
                     				ROB_commit2_arn_dest,
                     				PRF_writeback_value2);
        			else begin
					if(ROB_commit2_valid)
        				$fdisplay(wb_fileno, "PC=%x, ---",ROB_commit2_pc);

				end
      		end
      		

			//show_clk_count;
			//$fclose(wb_fileno);

      		// deal with any halting conditions
     		/*if(pipeline_error_status != NO_ERROR) begin
        	print_close(); // close the pipe_print output file
        	$fclose(wb_fileno);
        	#100 $finish;
      		end*/
			// deal with any halting conditions
			if(pipeline_error_status!=NO_ERROR)
			begin
				$display(	"@@@ Unified Memory contents hex on left, decimal on right: ");
							show_mem_with_decimal(0,`MEM_64BIT_LINES - 1); 
				// 8Bytes per line, 16kB total

				$display("@@  %t : System halted\n@@", $realtime);

				case(pipeline_error_status)
					HALTED_ON_MEMORY_ERROR:  
						$display(	"@@@ System halted on memory error");
					HALTED_ON_HALT_I1:          
						$display(	"@@@ System halted on HALT_I1 instruction");
					HALTED_ON_HALT_I2:          
						$display(	"@@@ System halted on HALT_I2 instruction");
					HALTED_ON_ILLEGAL_I1:
						$display(	"@@@ System halted on illegal_I1 instruction");
					HALTED_ON_ILLEGAL_I2:
						$display(	"@@@ System halted on illegal_I2 instruction");
					default: 
						$display(	"@@@ System halted on unknown error code %x",
									pipeline_error_status);
				endcase
				$display("@@@\n@@");
				show_clk_count;
				print_close(); // close the pipe_print output file
				//$fclose(wb_fileno);
				//#100 $finish;
			end
		end// if(reset) 
    	end  

endmodule  // module testbench

/*$monitor (" @@@ time:%d, \
			reset:%h, \
			pipeline_error_status:%h, \
			ROB_commit1_valid:%h,\n\
			ROB_commit1_pc:%h, \n\
			clock:%h,\n\
			mem2proc_tag:%h, \n\
			PC_inst1:%h, \n\
    		PC_inst2:%h,\n\
    		ID_inst1_opa:%h,\n\
    		ID_inst2_opa:%h,\n\
    		RAT1_PRF_opa_idx1:%h,\n\
   			RAT1_PRF_opa_idx2:%h, \n\
   			ROB_t1_is_full: %h, \n\
   			ROB_t2_is_full:%h, \n\
   			PC_inst1_valid:%h, \n\
   			mem2proc_response:%h, \n\
   			PRF_is_full:%h, \n\
   			Imem2proc_valid:%h, \n\
   			fu_next_inst_pc_out0:%h\n\
   			RS_full:%h\n\
   			RS_EX_op_type[0]:%h",
			$time, reset, pipeline_error_status, ROB_commit1_valid, ROB_commit1_pc, clock, mem2proc_tag, processor.PC_inst1, processor.PC_inst2, processor.ID_inst1_opa, processor.ID_inst2_opa, processor.RAT1_PRF_opa_idx1, processor.RAT1_PRF_opa_idx2, processor.ROB_t1_is_full, processor.ROB_t2_is_full, processor.PC_inst1_valid, mem2proc_response, processor.PRF_is_full, processor.Imem2proc_valid, fu_next_inst_pc_out[0],processor.RS_full,RS_EX_op_type[0]);*/
