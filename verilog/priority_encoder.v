// parametrized priority encoder (really just an encoder)
// parameter is output width

module priority_encoder(
	gnt,
	enc
	);

        parameter OUT_WIDTH=3;
        parameter IN_WIDTH=1<<OUT_WIDTH;

	input  [IN_WIDTH-1:0] 		gnt;

	output logic [OUT_WIDTH-1:0] 	enc;

	genvar i,j;
        generate
        	for(i=0; i<OUT_WIDTH; i++)
        	begin : foo
        		for(j=0; j<IN_WIDTH; j++)
        		begin : bar
        			if (j[i])begin
                			assign enc[i] = gnt[j];
					break;
				end
            		end
        	end
	endgenerate
endmodule
