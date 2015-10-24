//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  rs_one_entry.v                                       //
//                                                                      //
//   Description :        						//
//                   							//
//                 							// 
//                  							//
//                                    					// 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module rs_one_entry(

	input         				reset;          // reset signal 
	input         				clock;          // the clock 

	input  [$clog2(PRN_SIZE):0]  		rs_dest_in;    // The destination of this instruction
 
	input  [63:0] 				rs_cdb1_in;     // CDB bus from functional units 
	input  [$clog2(PRN_SIZE):0]  		rs_cdb1_tag;    // CDB tag bus from functional units 
	input  	      				rs_cdb1_valid;  // The data on the CDB is valid 
	input  [63:0] 				rs_cdb2_in;     // CDB bus from functional units 
	input  [$clog2(PRN_SIZE):0]  		rs_cdb2_tag;    // CDB tag bus from functional units 
	input  	      				rs_cdb2_valid;  // The data on the CDB is valid 

	input  [63:0] 				rs_opa_in;     // Operand a from Rename  
	input  [63:0] 				rs_opb_in;     // Operand a from Rename 
	input  	     				rs_opa_valid;  // Is Opa a Tag or immediate data (READ THIS COMMENT) 
	input         				rs_opb_valid;  // Is Opb a tag or immediate data (READ THIS COMMENT) 

	input  		        		rs_load_in;    // Signal from rename to flop opa/b /or signal to tell RS to load instruction in
	input   	        		rs_use_enable; // Signal to send data to Func units AND to free this RS


	input  [$clog2(ROB_SIZE):0]       	rs_rob_idx_in;   	// 
	input  [5:0]      			rs_op_type_in;     	// 
  
 	//output
	output logic        			rs_ready;     		// This RS is in use and ready to go to EX 
	output logic [63:0] 			rs_opa_out;       	// This RS' opa 
	output logic [63:0] 			rs_opb_out;       	// This RS' opb 
	output logic [$clog2(PRN_SIZE):0]	rs_dest_tag_out;  	// This RS' destination tag  
	//output        rs1_avail_out;     		// Is this RS is available to be issued to 
	output logic        			rs_available_out; 
	output logic [$clog2(ROB_SIZE):0]      	rs_rob_idx_out;   	// 
	output logic [5:0]		      	rs_op_type_out;     	// 

		  );  


	logic  [63:0] 				OPa;              	// Operand A 
	logic  [63:0] 				OPb;              	// Operand B 
	logic  					OPaValid;         	// Operand a Tag/Value 
	logic  					OPbValid;         	// Operand B Tag/Value 
	logic  					InUse;            	// InUse bit 
	logic  [$clog2(PRN_SIZE):0]  		DestTag;   		// Destination Tag bit 
	logic  [$clog2(ROB_SIZE):0] 		Rob_idx;   		//
	logic  [5:0]  				OP_type;  		//
 
	logic  					LoadAFromCDB1;  	// signal to load from the CDB1 
	logic  					LoadBFromCDB1;  	// signal to load from the CDB1
	logic  					LoadAFromCDB2;  	// signal to load from the CDB2 
	logic  					LoadBFromCDB2;  	// signal to load from the CDB2  

	assign rs_avail_out 	= ~InUse;
 
	assign rs_ready_out 	= InUse & OPaValid & OPbValid; 
 
	assign rs_opa_out 	= rs_use_enable ? OPa : 64'b0; 
 
	assign rs_opb_out 	= rs_use_enable ? OPb : 64'b0; 
 
	assign rs_dest_tag_out 	= rs_use_enable ? DestTag : 0; 

	assign rs_rob_idx_out	= rs_use_enable ? Rob_idx : 0;

	assign rs_op_type_out	= rs_use_enable ? OP_type : 6'b0;

	assign LoadAFromCDB1 	= (rs_cdb1_tag[4:0] == OPa) && !OPaValid && InUse && rs_cdb1_valid; 

	assign LoadBFromCDB1 	= (rs_cdb1_tag[4:0] == OPb) && !OPbValid && InUse && rs_cdb1_valid; 

	assign LoadAFromCDB2 	= (rs_cdb2_tag[4:0] == OPa) && !OPaValid && InUse && rs_cdb2_valid; 

	assign LoadBFromCDB2 	= (rs_cdb2_tag[4:0] == OPb) && !OPbValid && InUse && rs_cdb2_valid; 

	always @(posedge clock) 
	begin 
    		if (reset) 
    		begin 
 
            		OPa 	 <= `SD 0; 
            		OPb 	 <= `SD 0; 
            		OPaValid <= `SD 0; 
            		OPbValid <= `SD 0; 
			OP_type  <= `SD 5'b0;
            		InUse 	 <= `SD 1'b0; 
           		DestTag  <= `SD 0;
			Rob_idx	 <= `SD 0;
    		end 
    		else 
    		begin 
        		if (rs_load_in) 
        		begin 
           			OPa 	 <= `SD rs_opa_in; 
            			OPb 	 <= `SD rs_opb_in; 
            			OPaValid <= `SD rs_opa_valid; 
            			OPbValid <= `SD rs_opb_valid; 
				OP_type  <= `SD rs_op_type_in;
            			InUse 	 <= `SD 1'b1; 
            			DestTag  <= `SD rs_dest_in;
				Rob_idx	 <= `SD rs_rob_idx_in; 
        		end 
        		else 
        		begin
            			if (LoadAFromCDB1)
            			begin
                			OPa 	 <= `SD rs_cdb1_in;
                			OPaValid <= `SD 1'b1;
            			end
            			if (LoadBFromCDB1)
            			begin
                			OPb 	 <= `SD rs_cdb1_in;
                			OPbValid <= `SD 1'b1;
            			end
				if (LoadAFromCDB2)
            			begin
                			OPa 	 <= `SD rs_cdb2_in;
                			OPaValid <= `SD 1'b1;
            			end
            			if (LoadBFromCDB2)
            			begin
                			OPb 	 <= `SD rs_cdb2_in;
                			OPbValid <= `SD 1'b1;
            			end
            			// Clear InUse bit once the FU has data
            			if (rs_use_enable)
            			begin
                			InUse <= `SD 0;
            			end
        		end // else rs1_load_in 
    		end // else !reset 
	end // always @ 
endmodule  

