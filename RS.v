// WARNING!!!!
// This RS was written by Ali Saidi 2 years ago and used for a final exam problem last year. 
// I've filled in the blanks that were in the exam, however you should not consider this 
// as a complete solution! It was simplified for the exam and won't handle many cases you'll 
// be required to handle in your design. You may use whatever parts of it you like for your 
// 470 project however, it is largely provided as an example as to how these reservation 
// stations should work. 

//Here we nend to add signals like
//RS_Size, RS_index, 

//case index_full:
//put the input opa abd opb to the first empty index
//and we should define its output
//for example case(index_filled)
// 001:
//index_filled_next <= #1 101;
//work as arrays
//all cdb values will be expended (fan out)

module rs1(rs1_dest_in, rs1_opa_in, rs1_opa_valid, rs1_opb_in, rs1_opb_valid,  
           rs1_cdb_in, rs1_cdb_tag, rs1_cdb_valid, rs1_load_in, rs1_avail_out, 
           rs1_ready_out, rs1_opa_out, rs1_opb_out, rs1_dest_tag_out, rs1_use_enable,  
           reset, clock, rs1_rob_index_in, rs1_op_type, RS1_free_in, rs1_rob_index_out, rs1_op_type_out); 
 
input  [$clog2(RS_SIZE)-1:0] [4:0]  rs1_dest_in;    // The destination of this instruction 
input  [$clog2(RS_SIZE)-1:0] [63:0] rs1_cdb_in;     // CDB bus from functional units 
input  [$clog2(RS_SIZE)-1:0] [4:0]  rs1_cdb_tag;    // CDB tag bus from functional units 
input  [$clog2(RS_SIZE)-1:0]        rs1_cdb_valid;  // The data on the CDB is valid 
input  [$clog2(RS_SIZE)-1:0] [63:0] rs1_opa_in;     // Operand a from Rename  
input  [$clog2(RS_SIZE)-1:0] [63:0] rs1_opb_in;     // Operand a from Rename 
input  [$clog2(RS_SIZE)-1:0]        rs1_opa_valid;  // Is Opa a Tag or immediate data (READ THIS COMMENT) 
input  [$clog2(RS_SIZE)-1:0]        rs1_opb_valid;  // Is Opb a tag or immediate data (READ THIS COMMENT) 
input  [$clog2(RS_SIZE)-1:0]        rs1_load_in;    // Signal from rename to flop opa/b 
input  [$clog2(RS_SIZE)-1:0]        rs1_use_enable; // Signal to send data to Func units AND to free this RS 
input  				    reset;          // reset signal 
input   		            clock;          // the clock 
//input	     rs_stall;       // Ying
input  [$clog2(RS_SIZE)-1:0] [$clog2(ROB_SIZE)-1:0]  rs1_rob_index_in;   // Ying
input  [$clog2(RS_SIZE)-1:0] [$clog2(OP_SIZE)-1:0]   rs1_op_type_in;     // Ying
input  [$clog2(RS_SIZE)-1:0]  			     RS1_free_in;  //Ying
  
 
output [$clog2(RS_SIZE)-1:0]        rs1_ready_out;     // This RS is in use and ready to go to EX 
output [$clog2(RS_SIZE)-1:0] [63:0] rs1_opa_out;       // This RS' opa 
output [$clog2(RS_SIZE)-1:0] [63:0] rs1_opb_out;       // This RS' opb 
output [$clog2(RS_SIZE)-1:0] [4:0]  rs1_dest_tag_out;  // This RS' destination tag  
output [$clog2(RS_SIZE)-1:0]        rs1_avail_out;     // Is this RS is available to be issued to 
output	      			    rs_full; 		 // Ying
output [$clog2(RS_SIZE)-1:0] [$clog2(ROB_SIZE)-1:0]  rs1_rob_index_out;   // Ying
output [$clog2(RS_SIZE)-1:0] [$clog2(OP_SIZE)-1:0]   rs1_op_type_out;     // Ying
 
wor    [$clog2(RS_SIZE)-1:0] [63:0] rs1_opa_out; 
wor    [$clog2(RS_SIZE)-1:0] [63:0] rs1_opb_out; 
wor    [$clog2(RS_SIZE)-1:0] [4:0]  rs1_dest_tag_out;  
 
reg    [63:0] OPa;              // Operand A 
reg    [63:0] OPb;              // Operand B 
reg           OPaValid;         // Operand a Tag/Value 
reg           OPbValid;         // Operand B Tag/Value 
reg           InUse;            // InUse bit 
reg     [4:0] DestTag;          // Destination Tag bit 
reg	[2:0] rs_index;		// Ying
reg	[2:0] rs_index_busy;	// Ying For each index identicade weather it is busy or not
 
wire          LoadAFromCDB;  // signal to load from the CDB 
wire          LoadBFromCDB;  // signal to load from the CDB 
 
 
assign rs1_avail_out = ~InUse;
 
assign rs1_ready_out = InUse & OPaValid & OPbValid; 
 
assign rs1_opa_out = rs1_use_enable ? OPa : 64'b0; 
 
assign rs1_opb_out = rs1_use_enable ? OPb : 64'b0; 
 
assign rs1_dest_tag_out = rs1_use_enable ? DestTag : 64'b0;

assign rs1_rob_index_out = rs1_rob_index_in;	// Ying
assign rs1_op_type_out = rs1_op_type_in;
 
// Has the tag we are waiting for shown up on the CDB 
assign LoadAFromCDB = (rs1_cdb_tag[4:0] == OPa) && !OPaValid && InUse && rs1_cdb_valid; 
assign LoadBFromCDB = (rs1_cdb_tag[4:0] == OPb) && !OPbValid && InUse && rs1_cdb_valid; 



always @(posedge clock) 
begin 
    if (reset) 
    begin 
 
            OPa <= `SD 0; 
            OPb <= `SD 0; 
            OPaValid <= `SD 0; 
            OPbValid <= `SD 0; 
            InUse <= `SD 1'b0; 
            DestTag <= `SD 0; 
    end 
    else 
    begin 
        if (rs1_load_in) 
        begin 
            OPa <= `SD rs1_opa_in; 
            OPb <= `SD rs1_opb_in; 
            OPaValid <= `SD rs1_opa_valid; 
            OPbValid <= `SD rs1_opb_valid; 
            InUse <= `SD 1'b1; 
            DestTag <= `SD rs1_dest_in; 
        end 
        else 
        begin
            if (LoadAFromCDB)
            begin
                OPa <= `SD rs1_cdb_in;
                OPaValid <= `SD 1'b1;
            end
            if (LoadBFromCDB)
            begin
                OPb <= `SD rs1_cdb_in;
                OPbValid <= `SD 1'b1;
            end

            // Clear InUse bit once the FU has data
            if (RS1_free_in)
            begin
                InUse <= `SD 0;
            end
        end // else rs1_load_in 
    end // else !reset 
end // always @ 
endmodule  

