//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  priority_selector.v                                  //
//                                                                      //
//   Description :        						//
//                   							//
//                 							// 
//                  							//
//                                    					// 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////


// Simple 2-bit priority selector

module ps2(
	input [1:0] req,
	input en,
	output logic [1:0] gnt,
	output logic req_up);
    
    assign req_up = req[1] | req[0];
    assign gnt[1] = en & req[1];
    assign gnt[0] = en & req[0] & ~req[1];
                
endmodule

module priority_selector (req, en, gnt, req_up);
//synopsys template
parameter SIZE = 8;

  input  [SIZE-1:0] req;
  input             en;

  output [SIZE-1:0] gnt;
  output            req_up;
        
  logic   [SIZE-2:0] req_ups;
  logic   [SIZE-2:0] enables;
        
  assign req_up = req_ups[SIZE-2];
  assign enables[SIZE-2] = en;
        
  genvar i,j;
  generate
    if ( SIZE == 2 )
    begin
      ps2 single (.req(req),.en(en),.gnt(gnt),.req_up(req_up));
    end
    else
    begin
      for(i=0;i<SIZE/2;i=i+1)
      begin : foo
        ps2 base ( .req(req[2*i+1:2*i]),
                   .en(enables[i]),
                   .gnt(gnt[2*i+1:2*i]),
                   .req_up(req_ups[i])
        );
      end

      for(j=SIZE/2;j<=SIZE-2;j=j+1)
      begin : bar
        ps2 top ( .req(req_ups[2*j-SIZE+1:2*j-SIZE]),
                  .en(enables[j]),
                  .gnt(enables[2*j-SIZE+1:2*j-SIZE]),
                  .req_up(req_ups[j])
        );
      end
    end
  endgenerate
endmodule

/*module priority_selector (req, en, gnt);

	parameter SIZE = 8;
	input           [SIZE-1:0] req;
	input           en;
	output logic    [SIZE-1:0] gnt;
	
    logic [SIZE-1:0][1:0]    sub_reqs;    	 // req_up of lower ps connects to req of higher
    logic [SIZE-1:0][1:0]    sub_gnts;    	 // gnt of higher ps connects to enable of lower

    generate
        for(genvar i=0; i<SIZE; i++) begin   	 // Instantiate N-1 ps2 submodules
            					 // the following is a local parameter defined at compile-time to distinguish left 
           					 // subtrees from right subtrees via the least significant bit of i
            localparam left_right = i[0];        // i = odd number -> left sub-tree of parent
            ps2 sub_ps2    (.req    (sub_reqs[i]),
                            .en     (sub_gnts[i/2][left_right]),
                            .gnt    (sub_gnts[i]),
                            .req_up (sub_reqs[i/2][left_right])
                           );
        end
    endgenerate
    
    assign sub_reqs[SIZE-1 : SIZE/2] = req;      // connect top-level requests to bottom layer selectors
    
    assign sub_gnts[0][1] = en;           	 // connect enable to top layer selector
    assign gnt = sub_gnts[SIZE-1 : SIZE/2];    	 // connect bottom layer selectors to top-level grants
    
endmodule*/

