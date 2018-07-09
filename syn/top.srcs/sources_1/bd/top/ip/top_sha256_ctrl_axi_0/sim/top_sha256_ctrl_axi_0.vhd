-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: martina_fogliato:DS2018:sha256_ctrl_axi:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_sha256_ctrl_axi_0 IS
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s0_axi_araddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s0_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s0_axi_arvalid : IN STD_LOGIC;
    s0_axi_rready : IN STD_LOGIC;
    s0_axi_awaddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s0_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s0_axi_awvalid : IN STD_LOGIC;
    s0_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s0_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s0_axi_wvalid : IN STD_LOGIC;
    s0_axi_bready : IN STD_LOGIC;
    s0_axi_arready : OUT STD_LOGIC;
    s0_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s0_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s0_axi_rvalid : OUT STD_LOGIC;
    s0_axi_awready : OUT STD_LOGIC;
    s0_axi_wready : OUT STD_LOGIC;
    s0_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s0_axi_bvalid : OUT STD_LOGIC
  );
END top_sha256_ctrl_axi_0;

ARCHITECTURE top_sha256_ctrl_axi_0_arch OF top_sha256_ctrl_axi_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF top_sha256_ctrl_axi_0_arch: ARCHITECTURE IS "yes";
  COMPONENT sha256_ctrl_axi IS
    PORT (
      aclk : IN STD_LOGIC;
      aresetn : IN STD_LOGIC;
      s0_axi_araddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s0_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s0_axi_arvalid : IN STD_LOGIC;
      s0_axi_rready : IN STD_LOGIC;
      s0_axi_awaddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s0_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s0_axi_awvalid : IN STD_LOGIC;
      s0_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s0_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s0_axi_wvalid : IN STD_LOGIC;
      s0_axi_bready : IN STD_LOGIC;
      s0_axi_arready : OUT STD_LOGIC;
      s0_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s0_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s0_axi_rvalid : OUT STD_LOGIC;
      s0_axi_awready : OUT STD_LOGIC;
      s0_axi_wready : OUT STD_LOGIC;
      s0_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s0_axi_bvalid : OUT STD_LOGIC
    );
  END COMPONENT sha256_ctrl_axi;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi ARPROT";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s0_axi_araddr: SIGNAL IS "XIL_INTERFACENAME s0_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 12, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN top_ps7_0_FCLK_CLK0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0";
  ATTRIBUTE X_INTERFACE_INFO OF s0_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 s0_axi ARADDR";
  ATTRIBUTE X_INTERFACE_PARAMETER OF aresetn: SIGNAL IS "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW";
  ATTRIBUTE X_INTERFACE_INFO OF aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 aresetn RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF aclk: SIGNAL IS "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF s0_axi, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN top_ps7_0_FCLK_CLK0";
  ATTRIBUTE X_INTERFACE_INFO OF aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 aclk CLK";
BEGIN
  U0 : sha256_ctrl_axi
    PORT MAP (
      aclk => aclk,
      aresetn => aresetn,
      s0_axi_araddr => s0_axi_araddr,
      s0_axi_arprot => s0_axi_arprot,
      s0_axi_arvalid => s0_axi_arvalid,
      s0_axi_rready => s0_axi_rready,
      s0_axi_awaddr => s0_axi_awaddr,
      s0_axi_awprot => s0_axi_awprot,
      s0_axi_awvalid => s0_axi_awvalid,
      s0_axi_wdata => s0_axi_wdata,
      s0_axi_wstrb => s0_axi_wstrb,
      s0_axi_wvalid => s0_axi_wvalid,
      s0_axi_bready => s0_axi_bready,
      s0_axi_arready => s0_axi_arready,
      s0_axi_rdata => s0_axi_rdata,
      s0_axi_rresp => s0_axi_rresp,
      s0_axi_rvalid => s0_axi_rvalid,
      s0_axi_awready => s0_axi_awready,
      s0_axi_wready => s0_axi_wready,
      s0_axi_bresp => s0_axi_bresp,
      s0_axi_bvalid => s0_axi_bvalid
    );
END top_sha256_ctrl_axi_0_arch;
