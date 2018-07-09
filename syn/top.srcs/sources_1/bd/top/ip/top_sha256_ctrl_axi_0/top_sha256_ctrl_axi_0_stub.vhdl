-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4.1 (lin64) Build 2117270 Tue Jan 30 15:31:13 MST 2018
-- Date        : Sat Jun  9 09:24:25 2018
-- Host        : marti-UX330UAK running 64-bit Ubuntu 17.10
-- Command     : write_vhdl -force -mode synth_stub
--               /tmp/marti/sha256/top.srcs/sources_1/bd/top/ip/top_sha256_ctrl_axi_0/top_sha256_ctrl_axi_0_stub.vhdl
-- Design      : top_sha256_ctrl_axi_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_sha256_ctrl_axi_0 is
  Port ( 
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s0_axi_araddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s0_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s0_axi_arvalid : in STD_LOGIC;
    s0_axi_rready : in STD_LOGIC;
    s0_axi_awaddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s0_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s0_axi_awvalid : in STD_LOGIC;
    s0_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s0_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s0_axi_wvalid : in STD_LOGIC;
    s0_axi_bready : in STD_LOGIC;
    s0_axi_arready : out STD_LOGIC;
    s0_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s0_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s0_axi_rvalid : out STD_LOGIC;
    s0_axi_awready : out STD_LOGIC;
    s0_axi_wready : out STD_LOGIC;
    s0_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s0_axi_bvalid : out STD_LOGIC
  );

end top_sha256_ctrl_axi_0;

architecture stub of top_sha256_ctrl_axi_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,aresetn,s0_axi_araddr[11:0],s0_axi_arprot[2:0],s0_axi_arvalid,s0_axi_rready,s0_axi_awaddr[11:0],s0_axi_awprot[2:0],s0_axi_awvalid,s0_axi_wdata[31:0],s0_axi_wstrb[3:0],s0_axi_wvalid,s0_axi_bready,s0_axi_arready,s0_axi_rdata[31:0],s0_axi_rresp[1:0],s0_axi_rvalid,s0_axi_awready,s0_axi_wready,s0_axi_bresp[1:0],s0_axi_bvalid";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "sha256_ctrl_axi,Vivado 2017.4.1";
begin
end;
