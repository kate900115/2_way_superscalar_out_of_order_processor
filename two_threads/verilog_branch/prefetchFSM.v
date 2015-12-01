module prefetchFSM(
	input 		reset,
	input		clock,
	input 		Icache_rd,
	input 		Icache_hit,
	input 		prefetch_hit_in,
	input 		mem_tag,
	input 		prefetch_tag,
	input [21:0]	current_tag

	output		prefetch_hit_out;
	

	);


	

	typedef enum logic [2:0]{
			    IDLE,
			    CACHE_MISS,
			    PREFETCH,
			    WAIT_MISS,
			    WAIT_PREFETCH
			    }  PF_state;

	PF_state state, n_state;

	always_ff(posedge clock) begin
		
