module router_top(input clock, resetn, pkt_valid, read_enb_0, read_enb_1, read_enb_2,
		  input [7:0] data_in, 
		  output vld_out_0, vld_out_1, vld_out_2, err, busy,
		  output [7:0] data_out_0, data_out_1, data_out_2);

wire detect_add,write_enb_reg,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,
     full_0,full_1,full_2,parity_done,low_pkt_valid,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
wire [7:0] dout;
wire [2:0] write_enb;


router_sync R1(clock,resetn,read_enb_0,read_enb_1,read_enb_2,detect_add,write_enb_reg,
		      empty_0,empty_1,empty_2,full_0,full_1,full_2,data_in[1:0],write_enb,fifo_full,
		      vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);


router_fsm R2(clock,resetn,pkt_valid,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,
		     soft_reset_2,parity_done,low_pkt_valid,data_in[1:0], write_enb_reg,detect_add,ld_state,
		     laf_state,lfd_state,full_state,rst_int_reg,busy);
								 

router_reg R3(clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,
	      lfd_state,rst_int_reg,data_in,err,parity_done,low_pkt_valid,dout);

router_fifo R4(clock,resetn,write_enb[0],soft_reset_0,read_enb_0,lfd_state,dout,empty_0,full_0,data_out_0);


router_fifo R5(clock,resetn,write_enb[1],soft_reset_1,read_enb_1,lfd_state,dout,empty_1,full_1,data_out_1);


router_fifo R6(clock,resetn,write_enb[2],soft_reset_2,read_enb_2,lfd_state,dout,empty_2,full_2,data_out_2);


endmodule




