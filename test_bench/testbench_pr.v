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

module testbench;

	//variables used in the testbench
    logic         clock;                    // System clock
    logic         reset;                    // System reset
    int           wb_fileno;

    logic [3:0]   mem2proc_response;        // Tag from memory about current request
    logic [63:0]  mem2proc_data;            // Data coming back from memory
    logic [3:0]   mem2proc_tag;              // Tag from memory about current reply

    logic [1:0]   proc2mem_command;    // command sent to memory
    logic [63:0]  proc2mem_addr;      // Address sent to memory
    logic [63:0]  proc2mem_data;      // Data sent to memory

    logic [3:0]   pipeline_completed_insts;
    //ERROR_CODE   pipeline_error_status;

    // testing hooks (these must be exported so we can test
    // the synthesized version) data is tested by looking at
    // the final values in memory

    //output
    // Outputs from IF-Stage 
    //Output from rob
    logic							ROB_commit1_valid;
    logic [63:0]					PRF_writeback_value1;
    logic [63:0]					ROB_commit1_pc;
    logic [$clog2(`ARF_SIZE)-1:0]	ROB_commit1_arn_dest;
    logic							ROB_commit1_wr_en;
    logic							ROB_commit2_valid;
    logic [63:0]					PRF_writeback_value2;
    logic [63:0]					ROB_commit2_pc;
    logic [$clog2(`ARF_SIZE)-1:0]	ROB_commit2_arn_dest;
    logic							ROB_commit2_wr_en;

    processor processor_0(
	//input
    .clock(clock),                    // System clock
    .reset(reset),                    // System reset
    .mem2proc_response(mem2proc_response),        // Tag from memory about current request
    .mem2proc_data(mem2proc_data),            // Data coming back from memory
    .mem2proc_tag(mem2proc_tag),              // Tag from memory about current reply

	//output
    .proc2mem_command(proc2mem_command),    // command sent to memory
    .proc2mem_addr(proc2mem_addr),      // Address sent to memory
    .proc2mem_data(proc2mem_data),      // Data sent to memory

    .pipeline_completed_insts(pipeline_completed_insts),
    
    //.pipeline_error_status(pipeline_error_status),
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
    .ROB_commit1_pc(ROB_commit1_pc),
    .ROB_commit1_arn_dest(ROB_commit1_arn_dest),
    .ROB_commit1_wr_en(ROB_commit1_wr_en),
    .PRF_writeback_value1(PRF_writeback_value1),
    .ROB_commit2_valid(ROB_commit2_valid),
    .ROB_commit2_pc(ROB_commit2_pc),
    .ROB_commit2_arn_dest(ROB_commit2_arn_dest),
    .ROB_commit1_wr_en(ROB_commit1_wr_en),
    .PRF_writeback_value2(PRF_writeback_value2)		
);



  // Show contents of a range of Unified Memory, in both hex and decimal


  initial begin
  
    clock = 1'b0;
    reset = 1'b0;

    #10
    reset = 1'b1;

    @(posedge clock);
    @(posedge clock);
    `SD;
    // This reset is at an odd time to avoid the pos & neg clock edges

    reset = 1'b0;


    wb_fileno = $fopen("writeback_t1.out");
    
    //Open header AFTER throwing the reset otherwise the reset state is displayed

  end


  // Count the number of posedges and number of instructions completed
  // till simulation ends

  always @(negedge clock) begin

       // print the writeback information to writeback.out
	//for writeback.out we need pipeline_completed_insts pipeline_commit_wr_en
	//pipeline_commit_NPC  pipeline_commit_wr_idx pipeline_commit_wr_data
       if(pipeline_completed_insts>0) begin
         if(ROB_commit1_wr_en)
           $fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                     ROB_commit1_pc,
                     ROB_commit1_arn_dest,
                     PRF_writeback_value1);
        else
          $fdisplay(wb_fileno, "PC=%x, ---",ROB_commit1_pc);
	if(ROB_commit2_wr_en)
           $fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                     ROB_commit2_pc,
                     ROB_commit2_arn_dest,
                     PRF_writeback_value2);
        else
          $fdisplay(wb_fileno, "PC=%x, ---",ROB_commit2_pc);
      end

      // deal with any halting conditions
      /*if(pipeline_error_status != NO_ERROR) begin
        print_close(); // close the pipe_print output file
        $fclose(wb_fileno);
        #100 $finish;
      end*/

    end  // if(reset) 

endmodule  // module testbench


