module router_fifo(input clock,resetn,write_enb,soft_reset,read_enb,lfd_state,
                   input [7:0] data_in,
                   output empty, full,
                   output reg [7:0]data_out);

reg [3:0] wr_pt = 4'b0; 
reg [3:0] rd_pt = 4'b0;
reg [4:0] fifo_counter;
reg [6:0] int_counter;
reg [8:0] memory [15:0];
reg temp;
integer i;


//lfd_state
always@(posedge clk)
	begin
		if(!resetn)
			temp<=1'b0;
		else 
			temp<=lfd_state;
	end 


//counter logic
always @(posedge clock)
begin
	if(~resetn || soft_reset)
		fifo_counter <= 0;
	else if((!full && write_enb) && (!empty && read_enb))
		fifo_counter <= fifo_counter;
	else if(!full && write_enb)
		fifo_counter <= fifo_counter + 1;
	else if(!empty && read_enb)
		fifo_counter <= fifo_counter - 1;
	else 
		fifo_counter <= fifo_counter;
end


//full and empty logic
assign empty = (fifo_counter==5'b0)?1'b1:1'b0;
assign full = (fifo_counter > 5'b01111);


//logic for write operation in FIFO 
always @(posedge clock)
begin 
	if(~resetn || soft_reset)
	begin 
		for(i=0; i< 16; i=i+1)  
		begin
			memory[i] <= 0;
			wr_pt <= 4'b0; 
		end
	end
	else if((write_enb==1'b1)&&(full==1'b0)) //writing data
	begin
		memory[wr_pt] <= {temp,data_in}; 
		wr_pt <= wr_pt+1;
	end 
	else
		wr_pt <= wr_pt;
	end


//logic for read operation in FIFO 
always @(posedge clock)
begin 
	if(~resetn)
	begin
		rd_pt <= 4'b0; 
		data_out <= 8'd0;
	end
	else if(soft_reset)
	begin
		rd_pt <= 4'b0; 
		data_out <= 8'bzzzzzzzz;
	end
	else 
	begin
		if ((read_enb==1'b1) && (empty==1'b0))
		begin
			data_out <= memory[rd_pt]; 
			rd_pt <= rd_pt+1;
		end
		if(int_counter == 7'd0)
			data_out <= 8'bzzzzzzzz;
	end
end


//internal counter logic
always @(posedge clock)
begin
	if ((read_enb==1'b1) && (empty==1'b0))
	begin 
		if(memory[rd_pt][8])
			int_counter <= memory[rd_pt][7:2] + 1'b1;
		else if(int_counter!=7'd0) 
			int_counter <= int_counter-1;
		else
			int_counter <= int_counter;
	end
end

endmodule
