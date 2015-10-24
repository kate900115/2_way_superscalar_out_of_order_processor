// WARNING!!!!
// This RS was written by Ali Saidi 2 years ago and used for a final exam problem last year. 
// I've filled in the blanks that were in the exam, however you should not consider this 
// as a complete solution! It was simplified for the exam and won't handle many cases you'll 
// be required to handle in your design. You may use whatever parts of it you like for your 
// 470 project however, it is largely provided as an example as to how these reservation 
// stations should work. 
//case index_full:
//put the input opa abd opb to the first empty index
//and we should define its output
//all cdb values will be expended (fan out)

module rs1(rs1_dest_in, rs1_opa_in, rs1_opa_valid, rs1_opb_in, rs1_opb_valid,  
           rs1_cdb_in, rs1_cdb_tag, rs1_cdb_valid, rs1_load_in, rs1_avail_out, 
           rs1_ready_out, rs1_opa_out, rs1_opb_out, rs1_dest_tag_out, rs1_use_enable,  
           reset, clock, rs1_rob_index_in, rs1_op_type, RS1_FU_free_in, rs1_rob_index_out, rs1_op_type_out, RS_full); 
 
input  [4:0]  		rs1_dest_in;    // The destination of this instruction 
input  [63:0] 		rs1_cdb_in;     // CDB bus from functional units 
input  [4:0]  		rs1_cdb_tag;    // CDB tag bus from functional units 
input  	      		rs1_cdb_valid;  // The data on the CDB is valid 
input  [63:0] 		rs1_opa_in;     // Operand a from Rename  
input  [63:0] 		rs1_opb_in;     // Operand a from Rename 
input  	     		rs1_opa_valid;  // Is Opa a Tag or immediate data (READ THIS COMMENT) 
input         		rs1_opb_valid;  // Is Opb a tag or immediate data (READ THIS COMMENT) 
input  		        rs1_load_in;    // Signal from rename to flop opa/b 
input   	        rs1_use_enable; // Signal to send data to Func units AND to free this RS ?????????????????????????????????????????????
input         		reset;          // reset signal 
input         		clock;          // the clock 

//input	     rs_stall;       // Ying
input         		rs1_rob_index_in;   // Ying
input        		rs1_op_type_in;     // Ying
input  		        RS1_FU_free_in;        //Ying may need to flush the RS may use multiple bits
input  		        RS1_Flush_free_in;     //Ying when mis-predict happens, we need to flush RS
  
 
output        rs1_ready_out;     // This RS is in use and ready to go to EX 
output [63:0] rs1_opa_out;       // This RS' opa 
output [63:0] rs1_opb_out;       // This RS' opb 
output [4:0]  rs1_dest_tag_out;  // This RS' destination tag  
//output        rs1_avail_out;     // Is this RS is available to be issued to 
output	      rs_full; 		 // Ying
output        rs1_rob_index_out;   // Ying
output        rs1_op_type_out;     // Ying
output 	      RS_full;  //Ying
 
wor    [RS_SIZE-1:0] [63:0] rs1_opa_out; //Ying RS_SIZE entries
wor    [RS_SIZE-1:0] [63:0] rs1_opb_out; //Ying
wor    [RS_SIZE-1:0] [4:0]  rs1_dest_tag_out;  //Ying
 
reg    [RS_SIZE-1:0] [63:0] OPa;              // Operand A 
reg    [RS_SIZE-1:0] [63:0] OPb;              // Operand B 
reg    [RS_SIZE-1:0]        OPaValid;         // Operand a Tag/Value 
reg    [RS_SIZE-1:0]        OPbValid;         // Operand B Tag/Value 
reg    [RS_SIZE-1:0]        InUse;            // InUse bit 
reg    [RS_SIZE-1:0] [4:0]  DestTag;          // Destination Tag bit 
reg    [RS_SIZE-1:0] [$clog2(ROB_SIZE)-1:0] Rob_idx;  // Ying
reg    [RS_SIZE-1:0] [$clog2(OP_SIZE)-1:0] OP_type;  // Ying
 
wire   [RS_SIZE-1:0]        LoadAFromCDB;  // signal to load from the CDB 
wire   [RS_SIZE-1:0]        LoadBFromCDB;  // signal to load from the CDB 

 
logic  [$clog2(RS_SIZE):0] i;  // Ying
logic  [$clog2(RS_SIZE)-1:0] rs1_load_idx, l_rs1_load_idx;  //Ying
logic  [$clog2(RS_SIZE)-1:0] rs1_use_idx, l_rs1_use_idx;  //Ying

assign rs1_avail_out = ~InUse;
 
assign rs1_ready_out = InUse[rs1_use_idx] & OPaValid[rs1_use_idx] & OPbValid[rs1_use_idx]; //Ying
 
assign rs1_opa_out = rs1_use_enable ? OPa[rs1_use_idx] :  64'b0; //Ying
 
assign rs1_opb_out = rs1_use_enable ? OPb[rs1_use_idx] :  64'b0; //Ying
 
assign rs1_dest_tag_out = rs1_use_enable ? DestTag[rs1_use_idx] :  64'b0; //Ying

assign rs1_rob_index_out = Rob_idx[rs1_use_idx];	// Ying

assign rs1_op_type_out = OP_type[rs1_use_idx];  //Ying

assign RS_full = (rs1_avail_out == 0);
 
// Has the tag we are waiting for shown up on the CDB 
// All waiting for CDB
assign LoadAFromCDB = ([RS_SIZE-1:0] rs1_cdb_tag[4:0] == OPa) && !OPaValid && InUse && rs1_cdb_valid; 
assign LoadBFromCDB = ([RS_SIZE-1:0] rs1_cdb_tag[4:0] == OPb) && !OPbValid && InUse && rs1_cdb_valid; 

//Here we need to find which RS to store  //Ying 
assign l_rs1_load_idx = rs1_load_idx;
always_ff @(posedge clock) begin
  for(i=0; i<RS_SIZE;i++) begin
	if(rs1_avail_out[i] == 1) begin
	  rs1_load_idx = i;
	  break;
	end //end if
	else
	  rs1_load_idx = l_rs1_load_idx;
	//end else
  end  //end for
end                                      

//Then we need to decide which RS to output  //Ying
assign l_rs1_use_idx = rs1_use_idx;
always_ff @(posedge clock) begin
  for(i=0; i<RS_SIZE; i++) begin
	if(OPaValid[i] ==1 && OPbValid[i] ==1) begin
		rs1_use_idx = i;
		break;
	end
	else
		rs1_use_idx = l_rs1_use_idx;
  end
end

//Then we need to figure out which entry to free

always @(posedge clock) 
begin 
  for(i=0;i<RS_SIZE;i++) begin
    if (reset || RS1_Flush_free_in) 
    begin 
 
            OPa[i] <= `SD 0; 
            OPb[i] <= `SD 0; 
            OPaValid[i] <= `SD 0; 
            OPbValid[i] <= `SD 0; 
            InUse[i] <= `SD 1'b0; 
            DestTag[i] <= `SD 0; 
	    Rob_idx [i] <= `SD 0;
	    OP_type[i] <= `SD 0;
    end 
    else 
    begin 
        if (rs1_load_idx == i) 
        begin 
            OPa[i] <= `SD rs1_opa_in; 
            OPb[i] <= `SD rs1_opb_in; 
            OPaValid[i] <= `SD rs1_opa_valid; 
            OPbValid[i] <= `SD rs1_opb_valid; 
            InUse[i] <= `SD 1'b1; 
            DestTag[i] <= `SD rs1_dest_in; 
	    Rob_idx[i] <= `SD rs1_rob_index_in;
	    OP_type[i] <= `SD rs1_op_type_in;
        end 
        else 
        begin
            if (LoadAFromCDB[i])
            begin
                OPa[i] <= `SD rs1_cdb_in;
                OPaValid[i] <= `SD 1'b1;
            end
            if (LoadBFromCDB[i])
            begin
                OPb[i] <= `SD rs1_cdb_in;
                OPbValid[i] <= `SD 1'b1;
            end

            // Clear InUse bit once the FU has data
            if (RS1_FU_free_in && i == l_rs1_use_idx )        //?????????????????????????????????????
            begin
                InUse[i] <= `SD 0;
            end
        end // else rs1_load_in 
    end // else !reset 
  end //for loop
end // always @ 
endmodule  

