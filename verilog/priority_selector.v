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
