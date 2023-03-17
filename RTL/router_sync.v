module router_sync(input clock,resetn,read_enb_0,read_enb_1,read_enb_2,detect_add,write_enb_reg,
			  empty_0,empty_1,empty_2,full_0,full_1,full_2,
                   input [1:0] data_in,
		   output reg [2:0] write_enb,
		   output reg fifo_full,
		   output vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);

reg [1:0] add_reg;
reg [4:0] count0,count1,count2;


// Logic for address detection
always@(posedge clock)
	begin
		if(~resetn)
			add_reg<=2'b0;
		else if(detect_add)          
		 	add_reg<=data_in;
	end


// Logic for write enable
always @(*)
begin
	if(write_enb_reg)
	begin
		case(add_reg)
			2'b00 : write_enb <= 3'b100;
			2'b01 : write_enb <= 3'b010;
			2'b10 : write_enb <= 3'b001;
			default : write_enb <= 3'b000;
 		endcase
	end
        else
		write_enb <= 3'b000;
end


// Logic for FIFO full
always @(*)
begin
	case(add_reg)
		2'b00 : fifo_full <= full_0;
		2'b01 : fifo_full <= full_1;
		2'b10 : fifo_full <= full_2;
		default : fifo_full <= 1'b0;
 	endcase
end


// Logic for valid out
assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;


//Logic for soft reset counter
always @(posedge clock)
begin 
	if(~resetn)
		count0 <= 5'b00000;
	else if(~empty_0)
	begin
		if(~read_enb_0)
		begin
			if(count0 == 5'b11111)
				count0 <= 5'b00000;
			else
				count0 <= count0 + 1;
		end
		else
			count0 <= 5'b00000;
	end
	else
		count0 <= 5'b00000;
end

always @(posedge clock)
begin 
	if(~resetn)
		count1 <= 5'b00000;
	else if(~empty_1)
	begin
		if(~read_enb_1)
		begin
			if(count1 == 5'b11111)
				count1 <= 5'b00000;
			else
				count1 <= count1 + 1;
		end
		else
			count1 <= 5'b00000;
	end
	else
		count1 <= 5'b00000;
end

always @(posedge clock)
begin 
	if(~resetn)
		count2 <= 5'b00000;
	else if(~empty_2)
	begin
		if(~read_enb_2)
		begin
			if(count2 == 5'b11111)
				count2 <= 5'b00000;
			else
				count2 <= count2 + 1;
		end
		else
			count2 <= 5'b00000;
	end
	else
		count2 <= 5'b00000;
end


//Logic for soft reset 
assign soft_reset_0 = (count0 == 5'b11111) ? 1'b1 : 1'b0;
assign soft_reset_1 = (count1 == 5'b11111) ? 1'b1 : 1'b0; 
assign soft_reset_2 = (count2 == 5'b11111) ? 1'b1 : 1'b0;



endmodule
		 