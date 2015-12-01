/******************************************************************************//
//      	modulename: icache.v				               //
//      								       //
//      		Description:					       //
//      								       //
//  Ichache controller interface 					       //
//      								       //
//      								       //
//      								       //
//      								       //
/////////////////////////////////////////////////////////////////////////////////


input		clock;
input		reset;
input	[3:0]	Imem2proc_responce;
input	[63:0]	Imem2proc_data;
input	[3:0]	Imem2proc_tag;

input	[63:0]	proc2Icache_addr;
input	[63:0]	cachemem_data;
input		cachemem_valid;

output	[1:0]	proc2Imem_command;
output	[63:0]	proc2Imem_addr;

output	[63:0]	Icache_data_out; 	//value is memory[proc2Icache_addr]
output		Icache_valid_out;	//when high

output 	[6:0]	current_index;
output	[21:0]	current_tag;
output	[6:0]	last_index;
output	[21:0]	last_tag;
output		data_write_enable;

reg	[3:0]	current_mem_tag;

reg	mis_outstanding;

assign 	{current_tag, current_index} = proc2Icache_addr[31:3];

reg	[6:0] last_index;
reg	[21:0] last_tag;

wire 	changed_addr= (current_index!=last_index) || (current_ta!=last_tag);

wire 	[63:0] Icache_data_out= cachemem_data;
wire 	Icache_valid_out= cachemem_valid; 
	
assign	proc2Imem_addr = {proc2Icache_addr[63:3],3'b0};
assign 	proc2Imem_command = (miss_outstanding&& !changed_addr) ? `BUS_LOAD : `BUS_NONE;

wire 	data_write_enable= (current_mem_tag==Imem2proc_tag) &&(current_mem_tag!=0);

wire 	update_mem_tag= changed_addr| miss_outstanding| data_write_enable;

wire 	unanswered_miss= changed_addr? !Icache_valid_out: miss_outstanding(Imem2proc_response==0);

always @(posedgeclock)	begin
	if(reset)begin
	  last_index		<= `SD -1;// These are -1 to get ball rolling when
	  last_tag		<= `SD -1;// reset goes low because addr"changes"
	  current_mem_tag	<= `SD 0;              
	  miss_outstanding	<= `SD 0;
	end
	else begin
	  last_index		<= `SD current_index;
	  last_tag		<= `SD current_tag;
	  miss_outstanding	<= `SD unanswered_miss;
	  if(update_mem_tag)
		current_mem_tag	<= `SD Imem2proc_response;
	end
end
