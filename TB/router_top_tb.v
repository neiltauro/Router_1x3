module router_top_tb();

reg clock, resetn, pkt_valid, read_enb_0, read_enb_1, read_enb_2;
reg [7:0] data_in;
wire vld_out_0, vld_out_1, vld_out_2, err, busy;
wire [7:0] data_out_0, data_out_1, data_out_2;


router_top DUT(clock, resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,data_in,vld_out_0, 
	       vld_out_1, vld_out_2, err, busy, data_out_0, data_out_1, data_out_2);



//Task for initialization
task initialize();
begin 
	clock = 1'b0;
	resetn = 1'b1;
	read_enb_0 = 1'b0;
	read_enb_1 = 1'b0; 
	read_enb_2 = 1'b0;
	pkt_valid = 1'b0;
end
endtask


//Clock generation
always #10 clock = ~clock;


//Task for reseting the dut
task rst_dut();
begin
	@(negedge clock);
		resetn = 1'b0;
	@(negedge clock);
		resetn = 1'b1;
end
endtask


//Task for read enable operation
task read(input a,b,c);
begin
	@(negedge clock);
	read_enb_0 = a;
	read_enb_1 = b; 
	read_enb_2 = c;
end
endtask


//Task for data_in 
task din(input [7:0] a);
begin
	@(negedge clock);
	data_in = a;
end
endtask


initial
begin
initialize;
rst_dut;
@(negedge clock);
data_in = 8'b01010000;
pkt_valid = 1'b1;
@(negedge clock);
repeat(10)
	din({$random}%8);

fork
repeat(10)
	din({$random}%8);
read(1'b0,1'b0,1'b1);
join

@(negedge clock);
pkt_valid = 1'b0;
data_in = 8'b00011110;

#550;
read(1'b0,1'b0,1'b0);
#100;

$finish;
end

endmodule










