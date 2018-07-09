library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use work.sha256_pkg.all;

entity sha256_tb is
end sha256_tb;
architecture testbench of sha256_tb is
signal sha_msg_test : sha_array(1 downto 0) := ((x"6162636462636465636465666465666765666768666768696768696a68696a6b696a6b6c6a6b6c6d6b6c6d6e6c6d6e6f6d6e6f706e6f70718000000000000000"),(x"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c0"));
signal sha_hash_test, sha_hash_func, sha_hash_func2, sha_hash_test2 : sha_hash;
signal clk, rst, msg_valid, hash_ack, hash_valid, mux_sel, word_sel,  msg_ready, en, rst_AE, en_DM, mux_sel_AE, en_DM_AE, msg_last, en_AE, msg_ready2, hash_valid2 : std_ulogic;
signal w_array : word_vector(15 downto 0); 
signal w_array_exp : word_vector(63 downto 0);
signal mi, wi, mi1, mi2 : word;
signal mux_sel_H : std_ulogic_vector(1 downto 0);
signal K_index : natural range 0 to 64;

begin

	sha_hash_func <= sha256(sha_msg_test, 2);
	--sha_hash_func2 <= sha256(sha_msg_test2);
	--w_array <= break_chunks(sha_msg_test);
	--w_array_exp <= expand_msg_blocks(w_array);
	clk_proc: process
		begin
			clk <= '1';
			wait for 1 ns;
			clk <= '0';
			wait for 1 ns;
	end process;

	rst_proc: process
		begin
			rst<='0';
			wait for 10 ns;
			rst <= '1';
			wait;
	end process rst_proc;

	exp_unit_test: process
		begin
			msg_last <= '0';
			mi <= (others => '0');
			wait for 30 ns;
			for i in 0 to 15 loop
				mi <= return_chunk(sha_msg_test(1), i);
				wait for 2 ns;
			end loop;
			wait for 98 ns;
			for i in 0 to 15 loop
				mi <= return_chunk(sha_msg_test(0), i);
				wait for 2 ns;
			end loop;
			msg_last <= '1';
			wait;
	end process;

	cu_test : process
		begin
			msg_valid <= '0';
			hash_ack <= '0';
			wait for 30 ns;
			msg_valid <= '1';
			wait for 10 ns;
			msg_valid <= '0';
			wait for 10 ns;
			msg_valid <= '1';
			wait for 242 ns;
			--msg_valid <= '0';
			---wait for 10 ns;
			--msg_valid <= '1';
			--wait for 142 ns;
			msg_valid <= '0';
			hash_ack <= '1';
			wait;
	end process cu_test;

	--dut : entity work.sha256_exp_unit(arch) port map (clk, rst, mi, word_sel, wi);
	--cu : entity work.sha256_cu(fsm) port map(clk, rst, msg_valid, msg_last, hash_ack, hash_valid, mux_sel, mux_sel_AE, word_sel, mux_sel_H, K_index, msg_ready, en, en_AE, en_DM, en_DM_AE, rst_AE);
	--dp : entity work.sha256_core(arch) port map(clk, rst, rst_AE, mux_sel, mux_sel_AE, word_sel,  mux_sel_H, K_index, mi, en, en_AE , en_DM, en_DM_AE, sha_hash_test);
	dut : entity work.sha256(struct) port map (clk, rst, msg_valid, msg_last, hash_ack, mi, msg_ready2, hash_valid2, sha_hash_test2);
end testbench;
