// Simple 2-bit priority selector

module ps2( input [1:0] req,
            input en,
            output logic [1:0] gnt,
            output logic req_up);
    
    assign req_up = req[1] | req[0];
    assign gnt[1] = en & req[1];
    assign gnt[0] = en & req[0] & ~req[1];
                
endmodule

/*
By extending the solution from P1, we can see that an N-bit selector can be
    constructed out of a tree N-1 2-bit selectors, where output "gnt" of 
    ps2[i] enables ps[2*i] and ps[2*i+1], and "req_up" of ps2[2*i] and ps2[2*i+1]
    feed into req of ps[i]. This is shown in the diagram below:

                             ^
   sub_gnt[i/2][i[0]]        | sub_req[i/2][i[0]]
                    |    ____|___
                    |__>|        |
    ____________________| ps2[i] |
   | sub_gnt[i]         |________|
   |                       ^ ^
   |       sub_req[i][1]   | | sub_req[i][0]
   |           ____________| |______________
   |          |                            |
   |        __|_________              _____|____
   |______>|            |          _>|          |
   |       | ps2[2*i+1] |         |  | ps2[2*i] |
   |       |____________|         |  |__________|
   |______________________________|
*/   

// Generic N-bit priority selector

module ps_top ( input            [N-1:0]    req,
                input            en,
                output logic    [N-1:0]    gnt);


    logic [N-1:0] [1:0]    sub_reqs;    // req_up of lower ps connects to req of higher
    logic [N-1:0] [1:0]    sub_gnts;    // gnt of higher ps connects to enable of lower

    generate
        for(genvar i=1; i<N; i++) begin    // Instantiate N-1 ps2 submodules
            // the following is a local parameter defined at compile-time to distinguish left 
            //    subtrees from right subtrees via the least significant bit of i
            localparam left_right = i[0];                // i = odd number -> left sub-tree of parent
            ps2 sub_ps2    (.req    (sub_reqs[i]),
                            .en     (sub_gnts[i/2][left_right]),
                            .gnt    (sub_gnts[i]),
                            .req_up (sub_reqs[i/2][left_right])
                        );
        end

    endgenerate
    
    assign sub_reqs[ N-1 : N/2] = req;    // connect top-level requests to bottom layer selectors
    
    assign sub_gnts[0][1] = en;           // connect enable to top layer selector
    assign gnt = sub_gnts[ N-1 : N/2];    // connect bottom layer selectors to top-level grants
    
endmodule

