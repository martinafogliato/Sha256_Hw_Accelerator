// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4.1 (lin64) Build 2117270 Tue Jan 30 15:31:13 MST 2018
// Date        : Sat Jun  9 09:24:24 2018
// Host        : marti-UX330UAK running 64-bit Ubuntu 17.10
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ top_sha256_ctrl_axi_0_stub.v
// Design      : top_sha256_ctrl_axi_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "sha256_ctrl_axi,Vivado 2017.4.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(aclk, aresetn, s0_axi_araddr, s0_axi_arprot, 
  s0_axi_arvalid, s0_axi_rready, s0_axi_awaddr, s0_axi_awprot, s0_axi_awvalid, s0_axi_wdata, 
  s0_axi_wstrb, s0_axi_wvalid, s0_axi_bready, s0_axi_arready, s0_axi_rdata, s0_axi_rresp, 
  s0_axi_rvalid, s0_axi_awready, s0_axi_wready, s0_axi_bresp, s0_axi_bvalid)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,s0_axi_araddr[11:0],s0_axi_arprot[2:0],s0_axi_arvalid,s0_axi_rready,s0_axi_awaddr[11:0],s0_axi_awprot[2:0],s0_axi_awvalid,s0_axi_wdata[31:0],s0_axi_wstrb[3:0],s0_axi_wvalid,s0_axi_bready,s0_axi_arready,s0_axi_rdata[31:0],s0_axi_rresp[1:0],s0_axi_rvalid,s0_axi_awready,s0_axi_wready,s0_axi_bresp[1:0],s0_axi_bvalid" */;
  input aclk;
  input aresetn;
  input [11:0]s0_axi_araddr;
  input [2:0]s0_axi_arprot;
  input s0_axi_arvalid;
  input s0_axi_rready;
  input [11:0]s0_axi_awaddr;
  input [2:0]s0_axi_awprot;
  input s0_axi_awvalid;
  input [31:0]s0_axi_wdata;
  input [3:0]s0_axi_wstrb;
  input s0_axi_wvalid;
  input s0_axi_bready;
  output s0_axi_arready;
  output [31:0]s0_axi_rdata;
  output [1:0]s0_axi_rresp;
  output s0_axi_rvalid;
  output s0_axi_awready;
  output s0_axi_wready;
  output [1:0]s0_axi_bresp;
  output s0_axi_bvalid;
endmodule
