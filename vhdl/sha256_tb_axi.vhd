-- Thanks to Luca Rossi, I stole his testbench <3

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.axi_pkg.all;
use work.sha256_pkg.all;

entity sha256_tb_axi is
end entity sha256_tb_axi;

architecture sim of sha256_tb_axi is

  constant status_reg   : std_ulogic_vector(11 downto 0) := ("000000000100");
  constant data_reg     : std_ulogic_vector(11 downto 0) := "000000000000";
  constant H1 : std_ulogic_vector(11 downto 0) := "000000001000";
  constant H2 : std_ulogic_vector(11 downto 0) := "000000001100";
  constant H3 : std_ulogic_vector(11 downto 0) := "000000010000";
  constant H4 : std_ulogic_vector(11 downto 0) := "000000010100";
  constant H5 : std_ulogic_vector(11 downto 0) := "000000011000";
  constant H6 : std_ulogic_vector(11 downto 0) := "000000011100";
  constant H7 : std_ulogic_vector(11 downto 0) := "000000100000";
  constant H8 : std_ulogic_vector(11 downto 0) := "000000100100";
  constant new_data_cmd   : std_ulogic_vector(31 downto 0) := "00000000000000000000000000000000";
  constant new_msg_cmd    : std_ulogic_vector(31 downto 0) := "00000000000000000000000000010000";
  

  signal msg : std_ulogic_vector(511 downto 0) := "01100001011000100110001110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000";
  signal msg2 : sha_array(1 downto 0);
  signal msg3 : sha_array(2 downto 0);
  signal res2_sha256 : std_ulogic_vector(255 downto 0);
  signal res3_sha256 : std_ulogic_vector(255 downto 0);
  signal M_parsed : word_vector(15 downto 0);
  signal aclk:            std_ulogic;
  signal aresetn:         std_ulogic;
  signal s0_axi_araddr:   std_ulogic_vector(11 downto 0);
  signal s0_axi_arprot:   std_ulogic_vector(2 downto 0);
  signal s0_axi_arvalid:  std_ulogic;
  signal s0_axi_rready:   std_ulogic;
  signal s0_axi_awaddr:   std_ulogic_vector(11 downto 0);
  signal s0_axi_awprot:   std_ulogic_vector(2 downto 0);
  signal s0_axi_awvalid:  std_ulogic;
  signal s0_axi_wdata:    std_ulogic_vector(31 downto 0);
  signal s0_axi_wstrb:    std_ulogic_vector(3 downto 0);
  signal s0_axi_wvalid:   std_ulogic;
  signal s0_axi_bready:   std_ulogic;
  signal s0_axi_arready:  std_ulogic;
  signal s0_axi_rdata:    std_ulogic_vector(31 downto 0);
  signal s0_axi_rresp:    std_ulogic_vector(1 downto 0);
  signal s0_axi_rvalid:   std_ulogic;
  signal s0_axi_awready:  std_ulogic;
  signal s0_axi_wready:   std_ulogic;
  signal s0_axi_bresp:    std_ulogic_vector(1 downto 0);
  signal s0_axi_bvalid:   std_ulogic;
  signal H_read:  word_vector(7 downto 0);
  signal final_hash:  std_ulogic_vector(255 downto 0);
  signal real_hash:  std_ulogic_vector(255 downto 0);

begin

  final_hash <= H_read(0) & H_read(1) & H_read(2) & H_read(3) & H_read(4) & H_read(5) & H_read(6) & H_read(7);
  real_hash <=sha256(msg3, 1);
  M_parsed <= break_chunks(msg);
  msg2(0) <= msg;
  msg2(1) <= msg;
  msg3(0) <= msg;
  msg3(1) <= msg;
  msg3(2) <= msg;
  res2_sha256 <= sha256(msg3, 2);
  res3_sha256 <= sha256(msg3, 3);

  process
  begin
    aclk <= '1';
    wait for 1 ns;
    aclk <= '0';
    wait for 1 ns;
  end process;

  dut: entity work.sha256_ctrl_axi(fsm)
  port map(
    aclk           => aclk,
    aresetn        => aresetn,
    s0_axi_araddr  => s0_axi_araddr,
    s0_axi_arprot  => s0_axi_arprot,
    s0_axi_arvalid => s0_axi_arvalid,
    s0_axi_rready  => s0_axi_rready,
    s0_axi_awaddr  => s0_axi_awaddr,
    s0_axi_awprot  => s0_axi_awprot,
    s0_axi_awvalid => s0_axi_awvalid,
    s0_axi_wdata   => s0_axi_wdata,
    s0_axi_wstrb   => s0_axi_wstrb,
    s0_axi_wvalid  => s0_axi_wvalid,
    s0_axi_bready  => s0_axi_bready,
    s0_axi_arready => s0_axi_arready,
    s0_axi_rdata   => s0_axi_rdata,
    s0_axi_rresp   => s0_axi_rresp,
    s0_axi_rvalid  => s0_axi_rvalid,
    s0_axi_awready => s0_axi_awready,
    s0_axi_wready  => s0_axi_wready,
    s0_axi_bresp   => s0_axi_bresp,
    s0_axi_bvalid  => s0_axi_bvalid
  );


  process
  variable k : integer:= 0;
  variable addr : std_ulogic_vector(11 downto 0);
  variable turn : integer := 0;
  begin
    --- reset phase
    aresetn <= '0';
    s0_axi_araddr  <= (others => '0');
    s0_axi_arprot  <= (others => '0');
    s0_axi_arvalid <= '0';
    s0_axi_rready  <= '0';
    s0_axi_awaddr  <= (others => '0');
    s0_axi_awprot  <= (others => '0');
    s0_axi_awvalid <= '0';
    s0_axi_wdata   <= (others => '0');
    s0_axi_wstrb   <= (others => '0');
    s0_axi_wvalid  <= '0';
    s0_axi_bready  <= '0';
    for i in 1 to 10 loop
      wait until rising_edge(aclk);
    end loop;
    aresetn <= '1';
    loop
    -----
      ----- write status register -----
      k := 0;
      wait until rising_edge(aclk);
      s0_axi_awaddr <= status_reg;
      if (turn = 0) then 
        s0_axi_wdata <= new_msg_cmd;
      else
        s0_axi_wdata <= new_data_cmd;
      end if;
      s0_axi_wstrb <= (others => '1');
      s0_axi_awvalid <= '1';
      s0_axi_wvalid <= '1';
      wait until rising_edge(aclk);
      s0_axi_bready <= '1';
      s0_axi_awvalid <= '0';
      s0_axi_wvalid <= '0';
      wait until rising_edge(aclk);
      for i in 0 to 10 loop
         wait until rising_edge(aclk);
      end loop;
      --- write the msg words
      for j in 0 to 15 loop
        s0_axi_awaddr <= data_reg;
        s0_axi_wdata <= M_parsed(k);
        k := k + 1;
        s0_axi_wstrb <= (others => '1');
        s0_axi_awvalid <= '1';
        s0_axi_wvalid <= '1';
        wait until rising_edge(aclk);
        s0_axi_bready <= '1';
        s0_axi_awvalid <= '0';
        s0_axi_wvalid <= '0';
        for i in 0 to 10 loop
           wait until rising_edge(aclk);
        end loop;
      end loop;
      ---- wait sha end
      for j in 15 to 100 loop
        wait until rising_edge(aclk);
      end loop;
      -- write to status reg to avoid new msg ---
      s0_axi_awaddr <= status_reg;
      s0_axi_wdata <= (others => '0');
      s0_axi_wstrb <= (others => '1');
      s0_axi_awvalid <= '1';
      s0_axi_wvalid <= '1';
      wait until rising_edge(aclk);
      s0_axi_bready <= '1';
      s0_axi_awvalid <= '0';
      s0_axi_wvalid <= '0';
      wait until rising_edge(aclk);
      addr := H1;
      k := 0;
      --- read hash
      for j in 0 to 7 loop
        s0_axi_araddr <= addr;
        s0_axi_arvalid <= '1';
        wait until rising_edge(aclk);
        addr := std_ulogic_vector(unsigned(addr) + 4);
        wait until s0_axi_rvalid = '1';
        s0_axi_rready <= '1';
        s0_axi_arvalid <= '0';
        H_read(k) <= s0_axi_rdata;
        k := k + 1;
        wait until rising_edge(aclk);
      end loop;
      ---
      turn := turn + 1;
      end loop;       
  end process;

end architecture sim;
