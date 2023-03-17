module router_reg(input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,
		   input [7:0] data_in,
		   output reg err,parity_done,low_pkt_valid,
		   output reg [7:0] dout);

reg [7:0] hold_header_byte,fifo_full_state_byte,internal_parity,packet_parity_byte;


//Logic for hold header byte 
always @(posedge clock)
begin
	if(~resetn || rst_int_reg)
		hold_header_byte <= 8'b0;
	if(detect_add && pkt_valid)
		hold_header_byte <= data_in;
end


//Logic for fifo full state byte
always @(posedge clock)
begin
	if(~resetn || rst_int_reg)
		fifo_full_state_byte <= 8'b0;
	if(ld_state && fifo_full)
		fifo_full_state_byte <= data_in;
end


//Logic for dout
always@(posedge clock)
begin
	if(!resetn)
		dout <= 8'b0;
	else if(lfd_state)
		dout <= hold_header_byte;
	else if(ld_state && ~fifo_full)
		dout <= data_in;
	else if(laf_state)
		dout <= fifo_full_state_byte;
end


//Logic for low packet valid
always@(posedge clock)
begin
	if(~resetn || rst_int_reg)
		low_pkt_valid <= 1'b0;
	else if(ld_state && ~pkt_valid)
		low_pkt_valid <= 1'b1;
end


//Logic for parity done
always@(posedge clock)
begin
	if(~resetn)
		parity_done <= 1'b0;	
	else if(ld_state && ~fifo_full && ~pkt_valid)
		parity_done <= 1'b1;
	else if(laf_state && low_pkt_valid && ~parity_done)
		parity_done <= 1'b1;
end
	

//Logic for internal parity
always@(posedge clock)
begin
	if(~resetn || rst_int_reg)
		internal_parity <= 8'b0;
	else if(lfd_state)
		internal_parity <= internal_parity ^ hold_header_byte;
	else if(ld_state && pkt_valid && ~full_state)
		internal_parity <= internal_parity ^ data_in;
end
	

//Logic for packet parity
always@(posedge clock)
begin
	if(~resetn || rst_int_reg)
		packet_parity_byte <= 8'b0;
	else if(ld_state && ~pkt_valid && ~fifo_full)
		packet_parity_byte <= data_in;
	else if(laf_state && low_pkt_valid && ~parity_done)
		packet_parity_byte <= fifo_full_state_byte;
end


//Logic for err
always@(posedge clock)
begin
	if(~resetn)
		err <= 1'b0;
	else if(parity_done)
	begin
		if(internal_parity != packet_parity_byte)
			err <= 1'b1;
		else
			err <= 1'b0;
	end
	else
		err <= 1'b0;
end

endmodule 
	