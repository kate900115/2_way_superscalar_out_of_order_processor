//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  cdb.v                                       	        //
//                                                                      //
//   Description :                                                      //
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module cdb(
	input  							adder1_result_ready,
	input  	[63:0]					adder1_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]	adder1_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]	adder1_rob_idx,
	input  							mult1_result_ready,
	input  	[63:0]					mult1_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]	mult1_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]	mult1_rob_idx,
	input  							memory1_result_ready,
	input  	[63:0]					memory1_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]	memory1_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]	memory1_rob_idx,
	input  							adder2_result_ready,
	input  	[63:0]					adder2_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]	adder2_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]	adder2_rob_idx,
	input  							mult2_result_ready,
	input  	[63:0]					mult2_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]	mult2_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]	mult2_rob_idx,
	input  							memory2_result_ready,
	input  	[63:0]					memory2_result_in,
	input	[$clog2(`PRF_SIZE)-1:0]	memory2_dest_reg_idx,
	input	[$clog2(`ROB_SIZE):0]	memory2_rob_idx,
	
	output 	logic							cdb1_valid,
	output  logic [$clog2(`PRF_SIZE)-1:0]	cdb1_tag,
	output 	logic [63:0]					cdb1_out,
	output  logic [$clog2(`ROB_SIZE):0]	cdb1_rob_idx,
	output 	logic							cdb2_valid,
	output  logic [$clog2(`PRF_SIZE)-1:0]	cdb2_tag,
	output 	logic [63:0]					cdb2_out,
	output  logic [$clog2(`ROB_SIZE):0]	cdb2_rob_idx,
	output 	logic				adder1_send_in_success,
	output 	logic				adder2_send_in_success,
	output 	logic				mult1_send_in_success,
	output 	logic				mult2_send_in_success,
	output 	logic				memory1_send_in_success,
	output 	logic				memory2_send_in_success
);

	logic	[5:0]				fu_result_ready;
	logic	[5:0]				fu_send_in_success;
	logic   [5:0]				fu_result_ready2;
	logic   [5:0]				fu_select1;
	logic   [5:0]				fu_select2;


	assign  memory1_send_in_success = fu_send_in_success[5];
	assign  memory2_send_in_success = fu_send_in_success[4];
	assign  mult1_send_in_success   = fu_send_in_success[3]; 
	assign  mult2_send_in_success   = fu_send_in_success[2];
	assign  adder1_send_in_success  = fu_send_in_success[1];
	assign  adder2_send_in_success  = fu_send_in_success[0];

	assign  fu_result_ready      = {memory1_result_ready, memory2_result_ready, mult1_result_ready,
				        mult2_result_ready, adder1_result_ready, adder2_result_ready};

	assign  fu_result_ready2     = (~fu_select1) & fu_result_ready;	
	
	assign  fu_send_in_success   = fu_select1 | fu_select2;

	cdb_one_entry cdb1(
		//input
		.fu_select(fu_select1),
		.adder1_result_in(adder1_result_in),
		.adder1_dest_reg_idx(adder1_dest_reg_idx),
		.adder1_rob_idx(adder1_rob_idx),
		.mult1_result_in(mult1_result_in),
		.mult1_dest_reg_idx(mult1_dest_reg_idx),
		.mult1_rob_idx(mult1_rob_idx),
		.memory1_result_in(memory1_result_in),
		.memory1_dest_reg_idx(memory1_dest_reg_idx),
		.memory1_rob_idx(memory1_rob_idx),
		.adder2_result_in(adder2_result_in),
		.adder2_dest_reg_idx(adder2_dest_reg_idx),
		.adder2_rob_idx(adder2_rob_idx),
		.mult2_result_in(mult2_result_in),
		.mult2_dest_reg_idx(mult2_dest_reg_idx),
		.mult2_rob_idx(mult2_rob_idx),
		.memory2_result_in(memory2_result_in),
		.memory2_dest_reg_idx(memory2_dest_reg_idx),
		.memory2_rob_idx(memory2_rob_idx),
	
		//output
		.cdb_valid(cdb1_valid),
		.cdb_tag(cdb1_tag),
		.cdb_out(cdb1_out),
		.cdb_rob_idx(cdb1_rob_idx)
	);

	cdb_one_entry cdb2(
		//input
		.fu_select(fu_select2),
		.adder1_result_in(adder1_result_in),
		.adder1_dest_reg_idx(adder1_dest_reg_idx),
		.adder1_rob_idx(adder1_rob_idx),
		.mult1_result_in(mult1_result_in),
		.mult1_dest_reg_idx(mult1_dest_reg_idx),
		.mult1_rob_idx(mult1_rob_idx),
		.memory1_result_in(memory1_result_in),
		.memory1_dest_reg_idx(memory1_dest_reg_idx),
		.memory1_rob_idx(memory1_rob_idx),
		.adder2_result_in(adder2_result_in),
		.adder2_dest_reg_idx(adder2_dest_reg_idx),
		.adder2_rob_idx(adder2_rob_idx),
		.mult2_result_in(mult2_result_in),
		.mult2_dest_reg_idx(mult2_dest_reg_idx),
		.mult2_rob_idx(mult2_rob_idx),
		.memory2_result_in(memory2_result_in),
		.memory2_dest_reg_idx(memory2_dest_reg_idx),
		.memory2_rob_idx(memory2_rob_idx),
		
		//output
		.cdb_valid(cdb2_valid),
		.cdb_tag(cdb2_tag),
		.cdb_out(cdb2_out),
		.cdb_rob_idx(cdb2_rob_idx)
	);

	priority_selector #(.WIDTH(6)) cdb_psl1( 
		.req(fu_result_ready),
	        .en(1'b1),
        	.gnt(fu_select1)
	);

	priority_selector #(.WIDTH(6)) cdb_psl2( 
		.req(fu_result_ready2),
	        .en(1'b1),
        	.gnt(fu_select2)
	);



endmodule
