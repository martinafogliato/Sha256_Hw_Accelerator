library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use work.sha256_pkg.all;
	use work.axi_pkg.all;

entity sha256_ctrl_axi is
  port(
    aclk:            in    std_ulogic;
    aresetn:   		    in    std_ulogic;
    s0_axi_araddr:  in    std_ulogic_vector(11 downto 0);
    s0_axi_arprot:  in    std_ulogic_vector(2 downto 0);
    s0_axi_arvalid: in    std_ulogic;
    s0_axi_rready:  in    std_ulogic;
    s0_axi_awaddr:  in    std_ulogic_vector(11 downto 0);
    s0_axi_awprot:  in    std_ulogic_vector(2 downto 0);
    s0_axi_awvalid: in    std_ulogic;
    s0_axi_wdata:   in    std_ulogic_vector(31 downto 0);
    s0_axi_wstrb:   in    std_ulogic_vector(3 downto 0);
    s0_axi_wvalid:  in    std_ulogic;
    s0_axi_bready:  in    std_ulogic;
    s0_axi_arready: out   std_ulogic;
    s0_axi_rdata:   out   std_ulogic_vector(31 downto 0);
    s0_axi_rresp:   out   std_ulogic_vector(1 downto 0);
    s0_axi_rvalid:  out   std_ulogic;
    s0_axi_awready: out   std_ulogic;
    s0_axi_wready:  out   std_ulogic;
    s0_axi_bresp:   out   std_ulogic_vector(1 downto 0);
    s0_axi_bvalid:  out   std_ulogic
  );

end entity sha256_ctrl_axi;

architecture fsm of sha256_ctrl_axi is

type read_state_type is (read_idle, reading, read_waiting_ack, read_error);
  signal read_current_state, read_next_state: read_state_type;
  type write_state_type is (write_idle, write_ro_error, write_error, writing, write_waiting_ack);
  signal write_current_state, write_next_state: write_state_type;

  type reg_type is array (0 to 9) of std_ulogic_vector(31 downto 0); -- array of 10 32-bit registers
  signal reg : reg_type; 
  signal data_out, next_data_out: std_ulogic_vector(31 downto 0);
  signal read_resp, write_resp, next_read_resp, next_write_resp: std_ulogic_vector(1 downto 0);
  signal msg_valid, msg_last, hash_ack, msg_ready, hash_valid, data_reg_addr : std_ulogic;
  signal data, next_data, msg_word, data_reg, status_reg : word;
  signal hash : sha_hash;

	begin

		sha256_hw : entity work.sha256(struct) port map (aclk, aresetn, msg_valid, msg_last, hash_ack, msg_word, msg_ready, hash_valid, hash);

		next_data_out <= reg(to_integer(unsigned(s0_axi_araddr(11 downto 2)))) when (read_next_state = reading) else
						 (others => '0') when (read_next_state=read_error) else
						 data_out;

		-- choose read response code
		next_read_resp <= axi_resp_okay when (read_next_state = reading) else
						  axi_resp_decerr when (read_next_state = read_error) else
				    	  read_resp;

		-- chose write response code
		next_write_resp <= axi_resp_okay when (write_next_state = writing) else
						   axi_resp_decerr when (write_next_state = write_error) else
	     				   axi_resp_slverr when (write_next_state = write_ro_error) else
						   write_resp;

		next_data(7 downto 0) <= s0_axi_wdata(7 downto 0) when s0_axi_wstrb(0)='1' else data(7 downto 0);
		next_data(15 downto 8) <= s0_axi_wdata(15 downto 8) when s0_axi_wstrb(1)='1' else data(15 downto 8);
		next_data(23 downto 16) <= s0_axi_wdata(23 downto 16) when s0_axi_wstrb(2)='1' else data(23 downto 16);
		next_data(31 downto 24) <= s0_axi_wdata(31 downto 24) when s0_axi_wstrb(3)='1' else data(31 downto 24);


		data <= status_reg when (s0_axi_awaddr(11 downto 2) = "0000000001") else
				data_reg when (s0_axi_awaddr(11 downto 2) = "0000000000") else
				(others => '0');

		reg(0) <= data_reg;
		reg(1) <= status_reg;
		reg(2) <= hash(255 downto 224);
		reg(3) <= hash(223 downto 192);
		reg(4) <= hash(191 downto 160);
		reg(5) <= hash(159 downto 128);
		reg(6) <= hash(127 downto 96);
		reg(7) <= hash(95 downto 64);
		reg(8) <= hash(63 downto 32);
		reg(9) <= hash(31 downto 0);

		data_reg_addr <= '1' when (s0_axi_awaddr >= "000000000000" and s0_axi_awaddr <= "000000000011") else '0';
		msg_word <= reg(0);
		msg_last <= reg(1)(3);
		hash_ack <= reg(1)(2);
		
		msg_valid_proc : process(aclk)
			begin
				if(aclk='1' and aclk'event) then
					if(aresetn = '0') then
						msg_valid <= '0';
					else
						if(write_current_state = writing and data_reg_addr = '1') then
							msg_valid <= '1';
						else
							msg_valid <= '0';
						end if;
					end if;
				end if;
		end process msg_valid_proc;

		status_proc : process(aclk)
			begin
				if(aclk='1' and aclk'event) then
					if(aresetn='0') then
						status_reg <= (others => '0');
					else
						status_reg(0) <= msg_ready;
						status_reg(1) <= hash_valid;
						if(s0_axi_awaddr(11 downto 2) = "0000000001" and s0_axi_wvalid = '1' and s0_axi_awvalid = '1') then
							status_reg(3 downto 2) <= next_data(3 downto 2);
						end if;
					end if;
				end if;	
		end process status_proc;

		data_proc : process(aclk)
			begin
				if(aclk='1' and aclk'event) then
					if(aresetn='0') then
						data_reg <= (others => '0');
					elsif(s0_axi_awaddr(11 downto 2) = "0000000000" and s0_axi_wvalid = '1' and s0_axi_awvalid= '1') then
						data_reg <= next_data;
					end if;
				end if;
		end process data_proc;

		read_sync_proc: process(aclk)
			begin
				if(aclk='1' and aclk'event) then
					if(aresetn = '0') then --synchronous active low
						read_current_state <= read_idle;
						data_out <= (others => '0');
						read_resp <= (others => '0');
					else
						read_current_state <= read_next_state;
						data_out <= next_data_out;
						read_resp <= next_read_resp;
					end if;
				end if;
		end process read_sync_proc;

	-- process to assign output values according to current state
		read_output_proc: process(read_current_state, data_out, read_resp)
			begin
				s0_axi_arready <= '0';
				s0_axi_rvalid <= '1';
				s0_axi_rdata <= data_out;
				s0_axi_rresp <= read_resp;

				case(read_current_state) is
					when read_idle =>
						s0_axi_rvalid <= '0';
					when reading =>
						s0_axi_arready <= '1';
					when read_waiting_ack =>
					when read_error =>
						s0_axi_arready <= '1';
					when others =>
						s0_axi_arready <= '0';
						s0_axi_rvalid <= '1';
				end case;
		end process read_output_proc;

	--process to define next state according to inputs and current state
		read_next_state_proc: process(reg, read_current_state, s0_axi_arvalid, s0_axi_rready, s0_axi_araddr, s0_axi_arprot)
			begin
				case(read_current_state) is
					when read_idle =>
						if(s0_axi_arvalid = '1' and ("000000000000" <= s0_axi_araddr and s0_axi_araddr < "000001010000")) then -- valid address
							read_next_state <= reading;

						elsif(s0_axi_arvalid = '1' and (s0_axi_araddr < "000000000000" or s0_axi_araddr >= "000001010000")) then
							read_next_state <= read_error;
						else
							read_next_state <= read_idle;
						end if;
					when reading =>
						if(s0_axi_rready = '1') then -- if rready is already = 1 go back to idle, otherwise move to read_waiting_ack and wait for rready
							read_next_state <= read_idle;
						else
							read_next_state <= read_waiting_ack;
						end if;
					when read_waiting_ack => -- wait in here until rready is asserted then go back to idle
						if(s0_axi_rready = '1') then
							read_next_state <= read_idle;
						else
							read_next_state <= read_waiting_ack;
						end if;
					when read_error => -- if rready is already = 1 go back to idle, otherwise move to read_waiting_ack and wait for rready
						if(s0_axi_rready = '1') then
							read_next_state <= read_idle;
						else
							read_next_state <= read_waiting_ack;
						end if;
					when others =>
							read_next_state <= read_idle;
					end case;
		end process read_next_state_proc;

	-- process to handle reset and next state assignment is write fsm
		write_sync_proc: process(aclk)
			begin
				if(aclk='1' and aclk'event) then
					if(aresetn='0') then
						write_current_state <= write_idle;
						write_resp <= (others => '0');
					else
						write_current_state <= write_next_state;
						write_resp <= next_write_resp;
					end if;
				end if;
		end process write_sync_proc;

	-- process to assign output values according to current state
		write_output_proc: process(write_current_state, write_resp)
			begin
				s0_axi_awready <= '0';
				s0_axi_wready <= '0';
				s0_axi_bvalid <= '1';
				s0_axi_bresp <= write_resp;

				case(write_current_state) is
					when write_idle =>
						s0_axi_bvalid <= '0';
					when write_error =>
						s0_axi_wready <= '1';
						s0_axi_awready <= '1';
					when write_ro_error =>
						s0_axi_wready <= '1';
						s0_axi_awready <= '1';
					when writing =>
						s0_axi_awready <= '1';
						s0_axi_wready <= '1';
					when write_waiting_ack =>
					when others =>
						s0_axi_awready <= '0';
						s0_axi_wready <= '0';
						s0_axi_bvalid <= '1';

				end case;
		end process write_output_proc;

	--process to define next state according to inputs and current state
		write_next_state_proc: process(write_current_state, s0_axi_wstrb, s0_axi_awvalid, s0_axi_bready, s0_axi_wvalid, s0_axi_awaddr, s0_axi_awprot, s0_axi_wdata)
			begin
				case(write_current_state) is
					when write_idle =>
						if(s0_axi_awvalid = '1' and s0_axi_wvalid = '1' and (s0_axi_awaddr < "000000000000" or s0_axi_awaddr >= "000001010000")) then
							write_next_state <= write_error;
						elsif(s0_axi_awvalid = '1' and s0_axi_wvalid = '1' and ("000000001000"<=s0_axi_awaddr and s0_axi_awaddr<"000001010000")) then -- read-only register
							write_next_state <= write_ro_error;
						elsif (s0_axi_awvalid = '1' and s0_axi_wvalid = '1') then -- valid address
							write_next_state <= writing;
						else
							write_next_state <= write_idle;
						end if;
					when write_error => -- if bready is already = 1 go back to idle otherwise move to write_waiting_ack and wait for bready
						if(s0_axi_bready = '0') then
							write_next_state <= write_waiting_ack;
						else
							write_next_state <= write_idle;
						end if;
					when write_ro_error => -- if bready is already = 1 go back to idle otherwise move to write_waiting_ack and wait for bready
						if(s0_axi_bready = '0') then
							write_next_state <= write_waiting_ack;
						else
							write_next_state <= write_idle;
						end if;
					when writing => -- if bready is already = 1 go back to idle otherwise move to write_waiting_ack and wait for bready
						if(s0_axi_bready = '0') then
							write_next_state <= write_waiting_ack;
						else
							write_next_state <= write_idle;
						end if;
					when write_waiting_ack => -- wait here until bready is asserted then go back to idle
						if(s0_axi_bready = '1') then
							write_next_state <= write_idle;
						else
							write_next_state <= write_waiting_ack;
						end if;
					when others =>
							write_next_state <= write_idle;
				end case;
		end process write_next_state_proc;

end architecture fsm;
