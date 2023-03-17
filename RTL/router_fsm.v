module router_fsm(input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_pkt_valid,
		  input [1:0] data_in, 
		  output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
								 

parameter DECODE_ADDRESS = 3'b000,
	  WAIT_TILL_EMPTY = 3'b001,
	  LOAD_FIRST_DATA = 3'b010,
	  LOAD_DATA = 3'b011,
	  LOAD_PARITY =	3'b100,
	  FIFO_FULL_STATE = 3'b101,
          LOAD_AFTER_FULL = 3'b110,
	  CHECK_PARITY_ERROR = 3'b111;


reg [1:0] add_reg;
reg [2:0] state,next_state;


// Logic for address detection
always@(posedge clock)
begin
	if(~resetn)
		add_reg<=2'b0;
	else if(detect_add)          
	 	add_reg<=data_in;
end


//Present state logic
always@(posedge clock)
begin
	if(~resetn || ((soft_reset_0) && (add_reg==2'b00)) || ((soft_reset_1) && (add_reg==2'b01)) || ((soft_reset_2) && (add_reg==2'b10)))
		state <= DECODE_ADDRESS;
	else
		state <= next_state;
end

			
//Logic for next state
always@(*)
begin
	case(state)
		DECODE_ADDRESS : 
			begin 
                		if((pkt_valid && (data_in==2'b00) && fifo_empty_0)|| (pkt_valid && (data_in==2'b01) && fifo_empty_1)|| (pkt_valid && (data_in==2'b10) && fifo_empty_2))
		        		next_state <= LOAD_FIRST_DATA;
	             		else if((pkt_valid && (data_in==2'b00) && ~fifo_empty_0)|| (pkt_valid && (data_in==2'b01) && ~fifo_empty_1)|| (pkt_valid && (data_in==2'b10) && ~fifo_empty_2))
	             		        next_state <= WAIT_TILL_EMPTY;
				else
					next_state <= DECODE_ADDRESS;
			end

		WAIT_TILL_EMPTY : 
			begin
				if((fifo_empty_0 && (add_reg==2'b00))||(fifo_empty_1 && (add_reg==2'b01))||(fifo_empty_2 && (add_reg==2'b10))) 
					next_state <= LOAD_FIRST_DATA;
				else
					next_state <= WAIT_TILL_EMPTY;
			end

		LOAD_FIRST_DATA :
			begin
                        	next_state <= LOAD_DATA;
			end

		LOAD_DATA : 
			begin
                        	if(fifo_full)
	                		next_state <= FIFO_FULL_STATE;
	              		else if(~fifo_full && ~pkt_valid)
					next_state <= LOAD_PARITY;
				else
	                		next_state <= LOAD_DATA;
			end
		
		LOAD_PARITY :
			begin
				next_state <= CHECK_PARITY_ERROR;
			end
		
		FIFO_FULL_STATE :
			begin
				if(~fifo_full)
					next_state <= LOAD_AFTER_FULL;
				else
					next_state <= FIFO_FULL_STATE;
			end

		LOAD_AFTER_FULL :
			begin
				if(!parity_done && low_pkt_valid)
					next_state <= LOAD_PARITY;
				else if(!parity_done && !low_pkt_valid)
					next_state <= LOAD_DATA;
				else if(parity_done)
					next_state <= DECODE_ADDRESS;
				else
					next_state <= LOAD_AFTER_FULL;
			end
		CHECK_PARITY_ERROR :
			begin
				if(!fifo_full)
					next_state <= DECODE_ADDRESS;
				else
					next_state <= FIFO_FULL_STATE;
			end

		default: 
                        next_state <= DECODE_ADDRESS;
	endcase
end

//Output logic
assign busy = ((state == DECODE_ADDRESS) || (state == LOAD_DATA)) ? 1'b0:1'b1;
assign detect_add = (state == DECODE_ADDRESS) ? 1'b1 : 1'b0;
assign ld_state = (state == LOAD_DATA) ? 1'b1:1'b0;
assign laf_state = (state == LOAD_AFTER_FULL) ? 1'b1:1'b0;
assign lfd_state = (state == LOAD_FIRST_DATA) ? 1'b1:1'b0;
assign full_state = (state == FIFO_FULL_STATE) ? 1'b1:1'b0;
assign write_enb_reg = ((state == LOAD_DATA) || (state == LOAD_AFTER_FULL) || (state == LOAD_PARITY)) ? 1'b1:1'b0;
assign rst_int_reg=((state == CHECK_PARITY_ERROR))?1:0;
endmodule


