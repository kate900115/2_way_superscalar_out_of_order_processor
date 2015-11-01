//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  prf_one_entry.v                                      //
//                                                                      //
//   Description :                                                      //
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

module prf_one_entry(
	input                	     clock,
	input                	     reset,
	input			     free_this_entry,
    	input   	[63:0]       data_in,
	input                	     write_prf_enable,
	input                        assign_a_free_reg,
	output  logic                prf_available,
	output  logic                prf_ready,
	output  logic	[63:0]       data_out
		    );

	logic                	     prf_in_use;
	logic                	     prf_is_valid;
	logic   [63:0]       	     value;

	logic                	     prf_in_use_next;
	logic                	     prf_is_valid_next;
	logic   [63:0]       	     value_next;

/*	always_ff@(posedge clock)
	begin
		if(reset)
        	begin
            		prf_in_use     		<= `SD 1'b0;
            		prf_is_valid    	<= `SD 1'b0;
            		value         		<= `SD 64'b0;
        	end   
        	else
        	begin
			if(free_this_entry)
			begin
				prf_in_use     	<= `SD 1'b0;
            			prf_is_valid    <= `SD 1'b0;
				value         	<= `SD 64'b0;
			end
			else if(assign_a_free_reg &&(!prf_in_use))   
            		begin
                		prf_in_use      <= `SD 1'b1;
                		prf_is_valid    <= `SD 1'b0;
				value         	<= `SD 64'b0;
            		end       
            		else if(write_prf_enable && prf_in_use)
           		begin
				prf_in_use      <= `SD 1'b1;
                		prf_is_valid    <= `SD 1'b1;
                		value           <= `SD data_in;
            		end

        	end
    	end


    	always_comb
    	begin
		prf_available    = ~prf_in_use;
        	prf_ready 	= prf_is_valid;
        	if (prf_in_use && prf_is_valid)
        	begin       
            		data_out = value;
        	end
        	else
        	begin
            		data_out = 64'b0;
        	end
    	end


endmodule
*/
	assign	prf_available = ~prf_in_use;
	assign	prf_ready     = prf_is_valid;
	assign	data_out      = value;

	always_ff@(posedge clock)
	begin
		if(reset)
        	begin
            		prf_in_use  		<= `SD 1'b0;
            		prf_is_valid	    	<= `SD 1'b0;
            		value   		<= `SD 64'b0;
        	end   
        	else
        	begin
			prf_in_use		<= `SD prf_in_use_next;
			prf_is_valid		<= `SD prf_is_valid_next;
			value			<= `SD value_next;
        	end
    	end


	always_comb
	begin

		if(free_this_entry)
		begin
			prf_in_use_next		= 1'b0;
            		prf_is_valid_next    	= 1'b0;
			value_next		= 0;
		end
		else if(assign_a_free_reg)   
            	begin
                	prf_in_use_next      	= 1'b1;
                	prf_is_valid_next    	= 1'b0;
			value_next		= 0;
            	end       
            	else if(write_prf_enable)
           	begin
			prf_in_use_next      	= 1'b1;
                	prf_is_valid_next    	= 1'b1;
                	value_next           	= data_in;
            	end
		else
		begin
			prf_in_use_next      	= prf_in_use;
                	prf_is_valid_next    	= prf_is_valid;
                	value_next           	= value;
		end
	end
endmodule

